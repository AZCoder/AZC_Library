/* ----------------------------------------------------------------------------
Function: AZC_fnc_CreateVehicle
Author: AZCoder
Version: 1.5
Created: 01/29/2017
Dependencies: AZC_fnc_CreateUnit, AZC_fnc_AddWaypoint
Description:
	Randomly generates vehicles on roads with random destinations to provide
	more ambience to a mission. Unless you wish to micromanage when and how often
	units spawn, you should use AZC_fnc_AmbientVehicleManager to handle the details.
	
Parameters:
	0 : _playerLocation
	    ARRAY
	    LOCATION of player used as relative waypoint for crewed vehicle (not player's position, but closest town location)
	1 : _center
	    OBJ or ARRAY
	    CENTER position for spawning, can be an object or position array
	2 : _range
	    INT (optional)
	    default: 1000
	    MAX RANGE in meters to spawn vehicle from center (minimum 50)
	3 : _blackList
	    ARRAY (optional)
	    default: []
	    list of unit classes from which to NEVER spawn (blacklist)
	4 : _whiteList
	    ARRAY (optional)
	    default: []
	    list of unit classes from which to ONLY spawn (blacklist ignored if used)
	5 : _housesInRange
	    ARRAY (optional)
	    default: []
	    list of houses available for spawning, provided by AVM to due to cost of calculation
	6 : _includeCrew
	    BOOL (optional)
	    default: false
	    include crew, vehicle will be empty if false, will drive around if true
	7 : _allowOffroad
	    BOOL (optional)
	    allow spawning vehicle crew offroad, false = default

NOTES:
	Karts are always blacklisted since they are a specialty vehicle, no need to include them in the blacklist parameter.
	A list of Arma 3 vehicles are provided in case you want to exclude any of them for being in the wrong era for the mission.

	A3 civilian vehicles: "C_Offroad_01_F","C_Offroad_01_repair_F","C_Quadbike_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F",
	"C_SUV_01_F","C_Van_01_transport_F","C_Van_01_box_F","C_Van_01_fuel_F"

Returns: spawned vehicle

Examples:
	// spawn any Civ vehicle within 3000m
	_vehicle = [nil, 3000] call AZC_fnc_CreateVehicle;
	// Note: must use 'call' to get a return vehicle
	
	// spawn only non-Arma3 vehicles at locations within 1000m (requires an addon with Civ vehicles)
	_blacklist = ["C_Offroad_01_F","C_Offroad_01_repair_F","C_Quadbike_01_F", "C_Hatchback_01_F","C_Hatchback_01_sport_F","C_SUV_01_F","C_Van_01_transport_F", "C_Van_01_box_F","C_Van_01_fuel_F"];
	[_town,1500,_blacklist,nil,_houseList,true,false] call AZC_fnc_CreateVehicle;
---------------------------------------------------------------------------- */
private ["_range","_blacklist","_whiteListParam","_blackListParam","_destinationRange","_includeCrew","_houseBlacklist","_allowOffroad"];

_playerLocation		= [_this, 0] call bis_fnc_param;
_center				= [_this, 1] call bis_fnc_param;
_range 				= [_this, 2, 1000, [0]] call bis_fnc_param;
_whiteList			= [_this, 3, []] call bis_fnc_param;
_blackList			= [_this, 4, []] call bis_fnc_param;
_housesInRange		= [_this, 5, []] call bis_fnc_param;
_includeCrew		= [_this, 6, false, [false]] call bis_fnc_param;
_allowOffroad		= [_this, 7, false, [false]] call bis_fnc_param;

if (typeName _center == "OBJECT") then
{
	_center = getPos _center;
};

if (_range < 500) then { _range = 500 };
_destinationRange = (_range * 2) max 5000;
_houseBlacklist = [];

if (count(_whiteList) > 0) then { _blackList = []; };

_classlistVehicles = missionNamespace getVariable "AZC_VEHICLE_CLASSES";
if (isNil "_classlistVehicles" && (count _whiteList == 0)) then
{
	_classlistVehicles = [false,_blackList] call AZC_fnc_GenerateCivilianList;
};

if (count _whiteList > 0) then
{
	_classlistVehicles = _whiteList;
};

// ensure only valid classes exist
_classlistVehicles = _classlistVehicles call AZC_fnc_AddOnSafeClasses;
// store vehicles
missionNamespace setVariable ["AZC_VEHICLE_CLASSES", _classlistVehicles];

// exit if no vehicles found
if (count(_classlistVehicles) < 1) exitWith {};

private ["_locations","_locationDestination","_roadSegment","_segmentDirection","_vehPos","_roadDestination","_housePos","_house","_bbox","_usedHouses"];

_usedHouses = missionNamespace getVariable "AZC_UsedHouses";
if (isNil "_usedHouses") then { _usedHouses = []; };
_houseBlacklist append _usedHouses;
if (count _housesInRange < 1) then
{
	_housesInRange = [_center,_range,_houseBlacklist] call AZC_fnc_GetBuildings;
};

if (count _housesInRange < 1) exitWith { };

// select random vehicle
_vehClass = _classlistVehicles select (floor random(count _classlistVehicles));
_vehicle = nil;

/* this section is for setting initial position */
_index = floor random(count(_housesInRange));
_house = _housesInRange select _index;
_housePos = _house modeltoworld [0,0,0];
_houseSize = sizeof typeof _house;
_vehPos = _housePos findEmptyPosition [1,(_houseSize + 10),_vehClass];
if (count _vehPos < 1) then { _vehPos = _housePos; };

// determine if vehicle is allowed to have a driver
_roads = _housePos nearRoads 30;

private _generateVehicle = true;
if (_includeCrew && (count(_roads) < 1) && !_allowOffroad) then
{
	_generateVehicle = false;
};

// do not spawn if within 50m of player
if (_generateVehicle && ((player distance _vehPos) > 50)) then
{
	_vehDirection = getDir _house;
	
	// spawn vehicle
	_vehicle = [_vehClass,_vehPos,civilian,_includeCrew,_vehDirection,0,"NONE",[],false,0,true,false] call AZC_fnc_CreateUnit;
	_vehicle setVectorUp [0,0,1];
	
	if (_includeCrew && (driver _vehicle isNotEqualTo objNull)) then
	{
		_vehPos = [_vehicle,_house] call AZC_fnc_SetVehicleOnRoad2;
		_roadDestination = [_playerLocation,_center] call AZC_fnc_FindVehicleDestination;
		player vehicleChat format["create driver: %1",driver _vehicle];
		[_vehicle,_roadDestination] call AZC_fnc_SetVehicleDestination;
	}
	else
	{
		// if no driver, move vehicle perpendicular to the road
		_vehPos = [_vehicle,_house] call AZC_fnc_SetEmptyVehiclePosition;
	};
	
	// set _vehPos up a bit in case it's on sidewalk or track or something that doesn't measure well
	if (count _vehPos == 3) then
	{
		_vehPos = [_vehPos select 0,_vehPos select 1,(_vehPos select 2)+1];
	};
};

if (_vehPos isEqualTo []) then
{
	// vehicle could not be set, remove it
	_vehicle = nil;
};

if (!(isNil "_vehicle")) then
{
	// store used house
	_usedHouses pushBack (typeOf _house);
	missionNamespace setVariable ["AZC_UsedHouses", _usedHouses];

	// random fuel
	_fuel = (random(70) + 25) / 100;
	_vehicle setFuel _fuel;
	clearWeaponCargo _vehicle;
	clearMagazineCargo _vehicle;
	[_vehicle] spawn
	{
		_vehicle = _this select 0;
		
		sleep 2;
		// if z-vector dir is not near 0 or if the z-ATL position is far from 0, vehicle is usually
		// on a building or other object, or inside a building flipping around until it explodes
		_absHeight = abs(getPosATL _vehicle select 2);
		_absVector = abs(vectorDir _vehicle select 2);
		if ((_absHeight > 0.5) || (_absVector > 0.2)) then
		{
			[[_vehicle]] spawn AZC_fnc_Delete; // will delete anyone inside too
			_vehicle = nil;
			_msg = format ["Deleting vehicle for height and vector: %1 - %2",_absHeight,_absVector];
			[_msg] spawn AZC_fnc_Debug;
		};
		
		// still getting some explosions, had one guy ram his SUV into a pole and explode!
		// sleep 2;
		if (isNil "_vehicle") exitWith {};
		[_vehicle] spawn
		{
			params["_veh"];
			waitUntil { player distance _veh < 100 };
			if (!(isNil "_veh")) then { _veh allowDamage true; };
		};
	};

	// player allowDamage false;
	// player setPos [(getPos _vehicle select 0)+3,(getPos _vehicle select 1)-3,0];
	// missionNamespace setVariable ["AZC_AmbientVehicleManagerActive",false];
	// TRUCK = _vehicle;

	// _vector = format["%1",(vectorDir _vehicle)];
	// _curPos = getPosATL _vehicle;
	// player setPos [(_curPos select 0)+5,(_curPos select 1)-5,(_curPos select 2)];
	// _houseFormat = format["%1 -> final vehPos: %2 -> final vector: %3",_house,_curPos,_vector];
	// systemChat _houseFormat;
	// copyToClipboard _houseFormat;
};

if (isNil "_vehicle") then
{
	_vehicle = objNull;
}
else
{
	_vehicle hideObject false;
};
// set vector again
_vehicle setVectorUp [0,0,1];
// return the spawned vehicle or null
_vehicle
