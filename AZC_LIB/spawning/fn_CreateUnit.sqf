/* ----------------------------------------------------------------------------
Function: AZC_fnc_CreateUnit
Author: AZCoder
Version: 2.1
Dependencies: AZC_fnc_GetPos
Created: 09/07/2014 (based on old script 'fnc_spawnUnit' from 01/29/2012)
Description:
	Creates any CfgVehicle item permitted by the game engine.

Special Note #1:
	The _speed parameter is generally only of use with fixed wing aircraft.
	Setting it above 0 with anything else, including helicopters, generally results in disaster.
	By default, fixed wing aircraft will automatically set their speed to 220 if (and ONLY if) their
	altitude is greater than the ground position. Therefore this parameter can be ignored except
	in special circumstances.

Special Note #2:
	When creating an aircraft that should be flying in the air, you *must* pass in "FLY" for
	the _special parameter or it will simply tumble out of the sky... unless that's what you want.

Parameters:
	0 : _unitObj
	    STRING
	    Class of object to spawn.
	1 : _position
	    ARRAY, MARKER, or OBJECT
	    Position where vehicle will spawn. Can be object, marker, or a position array.
	2 : _side
	    KEYWORD
	    Side the vehicle belongs to: east, west, civilian, resistance.
	3 : _crew
	    BOOL (optional)
	    default: false
	    If true, spawns crew if _unitObj is a crewable vehicle.
	4 : _heading
	    NUMERIC (optional)
	    default: 0
	    Direction that unit faces when created.
	5 : _altitude
	    NUMERIC (optional)
	    default: 0
	    Overrides the 3rd _position array value with this number. Useful when spawning on markers.
	    Pass in nil or 0 to use the 3rd _position value instead.
	6 : _special
	    STRING (optional)
	    default: "NONE"
	    Can be "NONE", "FLY", "FORM", or "CAN_COLLIDE".
	7 : _skillRange
	    ARRAY (optional)
	    default: []
	    Range array from 0.1 to 1.0.
	8 : _forcePosition
	    BOOL (optional)
	    default: false
	    When true the position provided will be used without regard to safety.
	9 : _speed
	    NUMERIC (optional)
	    default: 0
	    Initial velocity of _unitObj. Useful with fixed wing aircraft.
	10 : _hideOnCreation
	     BOOL (optional)
	     default: false
	     If the created unit is hidden or not.
	11 : _allowDamage
	     BOOL (optional)
	     default: true
	     Spawn in with allowDamage set to true/false.

Returns: unit object

Examples:
	Parameter Order: _unitObj,_position,_side,_crew,_heading,_altitude,_special,_skillRange,_forcePosition,
_speed,_hideOnCreation

	_truck = ["B_Truck_01_Repair_F","markerGasStation",west,true,45,nil,nil,[0.25,0.28]] call AZC_fnc_CreateUnit;
	-> creates a repair truck for side west, with default crew for that type of vehicle, facing 45 degs, and setting the skill range from 0.25 to 0.28.

	_cas = ["B_Plane_CAS_01_F",[23364,24175.1,250],west,true,180,nil,"FLY"] call AZC_fnc_CreateUnit;
	-> creates the aircraft resembling an A-10 at a specific position heading south and set to FLY; the altitude was not passed in because it's already set to 250 in the position array.
*/

private ["_unitObj","_side","_position","_heading","_speed","_altitude","_special","_posx","_posy",
"_posz","_velx","_vely","_velz","_group","_crew","_skillRange","_object"];

_unitObj 			= [_this, 0] call bis_fnc_param;
_position			= [_this, 1] call bis_fnc_param;
_side				= [_this, 2] call bis_fnc_param;
_crew 				= [_this, 3, false, [false]] call bis_fnc_param;
_heading			= [_this, 4, 0, [0]] call bis_fnc_param;
_altitude			= [_this, 5, 0, [0]] call bis_fnc_param;
_special			= [_this, 6, "NONE", [""]] call bis_fnc_param;
_skillRange			= [_this, 7, []] call bis_fnc_param;
_forcePosition		= [_this, 8, false, [false]] call bis_fnc_param; // this is NOT being used!
_speed				= [_this, 9, 0, [0]] call bis_fnc_param;
_hideOnCreation		= [_this, 10, false] call bis_fnc_param;
_allowDamage		= [_this, 11, true] call bis_fnc_param;

// verify valid side parameter
if  (({_x == _side} count [west, east, civilian, resistance]) < 1) exitWith {};

// if crew parameter not boolean, default it to false
if (typeName _crew != "BOOL") then { _crew = false; };

// get x,y,z positions
_position =  [_position] call AZC_fnc_getPos;
_posx = _position select 0;
_posy = _position select 1;
if (_altitude > 0) then
{
	_posz = _altitude;
}
else
{
	_posz = (_position select 2);
};

// verify legal direction
if (_heading > 365) then {_heading = 0};

// set velocity based on _speed and _heading
if (_speed > 0) then
{
	_velx = (sin _heading * _speed);
	_vely = (cos _heading * _speed);
	_velz = 0;	// for now this is always 0, but could be used to alter rate of climb or descent
}
else
{
	_velx = 0;
	_vely = 0;
	_velz = 0;
};

// note: if neither BLUFOR or OPFOR exist at start, setFriend must be called after this or they will not engage in battle
// however this may cause unexpected results, so either put red and blue on the map first, or createCenter & setFriend
// first thing in the init.sqf
_group = createGroup _side;
if (isNull _group) then
{
	createCenter _side;
	_group = createGroup _side;
};

if (_unitObj isKindOf "MAN") then
{
	_object = _group createUnit [_unitObj, _position, [], 0, "FORM"];
	_object allowDamage _allowDamage;
	_object hideObject _hideOnCreation;
	_object setFormDir _heading;
}
else
{
	// create vehicle
	_object = createVehicle [_unitObj, [_posx, _posy, _posz], [], 0, _special];
	_object allowDamage _allowDamage;
	_object hideObject _hideOnCreation;
	_object setDir _heading;
	if (_special == "FLY") then { _object engineOn true; };
	_object setVelocity [_velx, _vely, _velz];
	
	// create crew
	if (_crew) then
	{
		createVehicleCrew _object;
	};
};

if (typeName _skillRange == "ARRAY") then
{
	if (count _skillRange == 2) then
	{
		private["_low","_high","_diff"];
		_low = _skillRange select 0;
		_high = _skillRange select 1;
		if (_low > 0.09 && _low < 1 && _high > _low && _high <= 1) then
		{
			_diff = _high - _low;
			_object setUnitAbility (_low + random(_diff));
		};
	}
}
else
{
	_object setUnitAbility _skillRange;
};

// createUnit always returns the unit for the default side that it belongs to, regardless of the
// side of the group used .... but the join command changes the side of a unit back to that of the group
if (side _object != _side) then
{
	[_object] joinSilent _group;
};

// return newly spawned object
_object
