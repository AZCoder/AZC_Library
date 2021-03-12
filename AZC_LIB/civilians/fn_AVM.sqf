/* ----------------------------------------------------------------------------
Function: AZC_fnc_AVM (Ambient Vehicle Module)
Author: AZCoder
Version: 1.0
Created: 10/18/2015
Dependencies: AZC_fnc_CreateVehicle, AZC_fnc_Debug
Description:
	Manages the spawning of vehicles. This way the mission maker does not
	have to keep track of what was spawned, how many, how often, and just let this function handle
	the details.
	
Parameters:
	0 : _locations
	    ARRAY (optional)
	    default: []
	    LOCATIONS (either array of [game_logic, range] or an array of area triggers)
	1 : _minDistance
	    INT (optional)
	    default: 1000
	    MINIMUM distance in meters of player to location center before spawning vehicles
	2 : _maxVehicles
	    INT (optional)
	    default: 10
	    MAX number of vehicles allowed at one time for a single location
	3 : _whiteListParam
	    ARRAY (optional)
	    default: []
	    units to whitelist (only spawn these classes)
	4 : _blackListParam
	    ARRAY (optional)
	    default: []
	    units to blacklist (never spawn these classes, ignored if whitelist is set)
	5 : _chanceCrew
	    INT (optional)
	    default: 50
	    CHANCE to have crew in the vehicle as a whole number percentage (0 - 100)
	6 : _allowOffroad
	    BOOL (optional)
	    default: false
	    ALLOW crewed vehicles to spawn off road. On many maps the AI will not drive and just sit there unless on a road,
	    so it should usually be left as false.
	
NOTES:
	To disable the manager (and spawning) at any time, do this:
	missionNamespace setVariable ["AZC_AmbientVehicleManagerActive",false];
	You will have to call this function to start it again; setting true will have no effect.
	
	Allow spawning vehicle offroad: this flag overrides whether a driver is spawned in a vehicle that is far away from any roads.
	When vehicles are spawned offroad and with a driver, they will often get confused and sit there, run into trees, etc.
	It's usually best to leave this false.
	
	X-CAM-TAUNUS Map: All sidewalks are "roads" on this map, which is very unfortunate. This is not normal on other maps.
	As a result, it's not advisable to spawn vehicles with drivers at all because they will frequently get stuck, and vehicles will
	tend to spawn on crosswalks and sidewalks on this map.

Returns: nothing

Examples:
	[] spawn AZC_fnc_AVM;
---------------------------------------------------------------------------- */
if (isNil "AZC_Debug") then { AZC_Debug = false; };

private ["_maxVehicles","_checkTime","_blackList","_vehicleList","_vehicle","_ambientManagerActive","_vehiclesToDelete","_activeSpawns","_chanceCrew","_allowOffroad","_zones"];

_locations			= [_this, 0, []] call bis_fnc_param;
_minDistance		= [_this, 1, 1000, [1]] call bis_fnc_param;
_maxVehicles		= [_this, 2, 10, [1]] call bis_fnc_param;
_whiteListParam		= [_this, 3, []] call bis_fnc_param;
_blackListParam		= [_this, 4, []] call bis_fnc_param;
_chanceCrew			= [_this, 5, 50] call BIS_fnc_param;
_allowOffroad		= [_this, 6, false, [false]] call bis_fnc_param;

_ambientManagerActive = true;
missionNamespace setVariable ["AZC_AmbientVehicleManagerActive",_ambientManagerActive];

// create list of possible vehicles, starting with blacklist
_blacklist = ["C_Kart_01_F","C_Kart_01_Fuel_F","C_Kart_01_Blu_F","C_Kart_01_Red_F","C_Kart_01_Vrana_F"];
if (typeName _blackListParam == "ARRAY") then
{
	_blackList append _blackListParam;
};
_classlistVehicles = [false,_blackList] call AZC_fnc_GenerateCivilianList;

_whiteList = [];
if (typeName _whiteListParam == "ARRAY") then
{
	if (count(_whiteListParam) > 0) then { _blackList = []; };
	_whiteList append _whiteListParam;
};

// store vehicles
missionNamespace setVariable ["AZC_VEHICLE_CLASSES", _classlistVehicles];

// get trigger zones if they exist
_zones = [_locations] call AZC_fnc_GetZones;
_lastLocation = objNull;

// get closest town to player (format = [position],range)
_nearestLocation = [_zones,_minDistance] call AZC_fnc_GetNearestLocation;

while { _ambientManagerActive } do
{
	_vehicleList = missionNamespace getVariable "AZC_VehicleList";
	if (isNil "_vehicleList") then
	{
		_vehicleList = [];
	};
	
	// systemChat format["%3 -> _nearestLocation: %1 = %2m",_nearestLocation,(player distance (_nearestLocation select 0)),time];
	_vehicleList = [_vehicleList,_chanceCrew,_nearestLocation,_zones,_whiteList,_blacklist] call AZC_fnc_AVM_Main;
	_activeSpawns = count(_vehicleList);
	if (_activeSpawns >= _maxVehicles) then
	{
		[(format ["Cannot spawn anymore vehicles: _activeSpawns: %1 --- _maxVehicles: %2",_activeSpawns,_maxVehicles])] call AZC_fnc_Debug;
	};

	_checkTime = 0.1;
	_usedHouses = missionNamespace getVariable "AZC_UsedCivHouses";
	if (_nearestLocation isEqualTo [[0,0,0],0]) then { _checkTime = 10; };
	if (_activeSpawns >= _maxVehicles) then { _checkTime = 10; };
	sleep _checkTime;

	// get closest town to player (format = [position],range)
	_nearestLocation = [_zones,_minDistance] call AZC_fnc_GetNearestLocation;
	if (typeName _lastLocation != "ARRAY") then { _lastLocation = _nearestLocation; };

	// cleanup vehicles that are too far from player
	_vehicleList = [_vehicleList,_minDistance,(_nearestLocation select 0),(_lastLocation select 0)] call AZC_fnc_CivCleanup;
	
	if !(_nearestLocation isEqualTo _lastLocation) then
	{
		_lastLocation = _nearestLocation;
	};

	// refresh _vehicleList to remove non-existent objects
	_cleanVehicleList = [];
	
	{
		if (!isNull _x) then { _cleanVehicleList pushBack _x; };
	} forEach _vehicleList;
	missionNamespace setVariable ["AZC_VehicleList", _cleanVehicleList];
	_activeSpawns = count _cleanVehicleList;
	_ambientManagerActive = missionNamespace getVariable "AZC_AmbientVehicleManagerActive";
};
