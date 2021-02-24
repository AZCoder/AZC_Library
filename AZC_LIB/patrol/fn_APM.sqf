/* ----------------------------------------------------------------------------
Function: AZC_fnc_APM (Auto Patrol Module)
Author: AZCoder
Version: 1.0
Created: 02/05/2017
Dependencies: Patrol directory, AZC_fnc_Debug, AZC_fnc_Delete, AZC_fnc_ReactiveAI, AZC_fnc_GetBuildings
Description:
	Manages patrol routines inside buildings and around buildings. AI finds closest building within 30 meters with interior	positions and automatically walks to it and patrols inside. Can be set to patrol outside, or from building to building randomly within X meters of original starting position.
	
Parameters:
	0 : _unit
	    OBJECT
	    UNIT that will patrol
	1 : _minPositions
	    INT (optional)
	    default: 3
	    number of POSITIONS required for any building to patrol
	2 : _maxPatrolRange
	    INT (optional)
	    default: 0
	    max RANGE from starting position to select buildings for patrolling, must be high enough value
	    to locate other buildings, 0 will keep AI to one building
	3 : _useReactiveAI
	    BOOL (optional)
	    default: true
	    units will use fnc_ReactiveAI which makes them a lot more aware and aggressive when shot at

NOTES:
	This function is designed for individual units, not groups.
	
KNOWN ISSUES:
	Certain buildings they will not enter at all. This is presumably an AI pathing problem. Some positions they will walk to, but are unable to move again unless you forcibly set them outside (setVector or setPos).

Returns: nothing

Examples:
	// patrol closest building, all defaults
	[Guard] spawn AZC_fnc_APM;
	// patrol closest building (at least 5 positions required in building)
	[Guard,5] spawn AZC_fnc_APM;
	// patrol closest building with at least 2 positions, then patrol next closest building with 2+ positions until no more buildings within 100m starting point at which point it starts over, also disable ReactiveAI
	[Guard,2,100,false] spawn AZC_fnc_APM;
	
---------------------------------------------------------------------------- */
private ["_buildings","_onPatrol","_building","_buildingPositions","_wpPerBuilding","_completedWPs","_usedBuildings","_apmUnits"];

_unit				= [_this, 0] call bis_fnc_param;
_minPositions		= [_this, 1, 3] call bis_fnc_param;
_maxPatrolRange 	= [_this, 2, 0] call bis_fnc_param;
_useReactiveAI		= [_this, 3, true] call bis_fnc_param;

#define __IsDestinationCompleted (_unit getVariable "AZC_APM_DESTINATION_COMPLETED")

_onPatrol = true;
_completedWPs = 0;
_unit setVariable ["AZC_APM_OnPatrolActive",_onPatrol];
_unit setVariable ["AZC_APM_OriginalPosition",(getPos _unit)];
_unit setVariable ["AZC_APM_CompletedWPs",_completedWPs];
_lastBuilding = objNull;
_building = [_unit,_maxPatrolRange,_minPositions] call AZC_fnc_GetNearestOpenBuilding;
if (isNull _building) exitWith { ["Null building, cannot patrol."] call AZC_fnc_Debug; };
_usedBuildings = [];
_usedBuildings pushBack _building;
_unit setVariable ["AZC_APM_UsedBuildings",_usedBuildings];
if (_useReactiveAI) then { _unit spawn AZC_fnc_ReactiveAI; };

_buildingPositions = _building getVariable "AZC_APM_BUILDING_POSITIONS";
_wpPerBuilding = (count _buildingPositions - 3) min _minPositions;
if (_wpPerBuilding < 1) then { _wpPerBuilding = 1; };

// this is to fix the dead man standing bug in Arma 3 when killed during an animation
_unit addEventHandler ["Killed", {
	_unit = _this select 0;
	if (_unit isKindOf "CAManBase") then
	{
		[_unit] spawn
		{
			params["_unit"];
			_unit removeAllEventHandlers "Killed";
			_loadout = getUnitLoadout _unit;
			// trying to fix problem of body going vertical multiple times upon being shot!
			waitUntil { animationState _unit == "deadstate" };
			sleep 2;
			// create duplicate proxy unit
			_class = typeOf _unit;
			_proxy = (group _unit) createUnit [_class,[0,0,0],[],0,"FORM"];
			_proxy setDamage 1;
			sleep 2;
			deleteVehicle _unit;
			_pos = getPosATL _unit;
			_dir = getDir _unit;
			_proxy setPosATL _pos;
			_proxy setDir _dir;
			removeAllWeapons _unit;
			removeAllItems _unit;
			removeAllAssignedItems _unit;
			removeUniform _unit;
			removeVest _unit;
			removeBackpack _unit;
			removeHeadgear _unit;
			removeGoggles _unit;
			_proxy setUnitLoadout _loadout;
			// _unit disableAI "ANIM";
			// _unit switchMove "deadstate";
			// sleep 1;
			// _unit enableSimulation false;
		};
	};
}];

while { _onPatrol } do
{
	[_unit] spawn
	{
		params["_unit"];
		// break animation loop if detection occurs
		_onPatrol = _unit getVariable "AZC_APM_OnPatrolActive";
		while { _onPatrol } do
		{
			if (!(alive _unit)) exitWith {};
			_knows = _unit getVariable "AZC_KNOWS_ABOUT";
			if (isNil "_knows") then { _knows = 0; };
			if (_knows > 2) then
			{
				_unit enableAI "ANIM";
				_unit switchMove "";
			};
			sleep 1;
		};
	};
	
	// patrol X number of WPs per building (only used when patrolling multiple buildings)
	if (_maxPatrolRange > 0) then
	{
		_completedWPs = _unit getVariable "AZC_APM_CompletedWPs";
		if (_completedWPs >= _wpPerBuilding) then
		{
			_completedWPs = 0;
			_unit setVariable ["AZC_APM_CompletedWPs",_completedWPs];
			// get new building
			_building = [_unit,_maxPatrolRange,_minPositions] call AZC_fnc_GetNearestOpenBuilding;
			_usedBuildings pushBack _building;
			_unit setVariable ["AZC_APM_UsedBuildings",_usedBuildings];
			_buildingPositions = _building getVariable "AZC_APM_BUILDING_POSITIONS";
			_wpPerBuilding = (count _buildingPositions - 3) min _minPositions;
			if (_wpPerBuilding < 1) then { _wpPerBuilding = 1; };
		};
		[(format["Completed WPs: %1, max: %2",_completedWPs,_wpPerBuilding])] call AZC_fnc_Debug;
	};

	_destinationCompleted = __IsDestinationCompleted;
	if (isNil "_destinationCompleted") then { _destinationCompleted = true; };
	if (_destinationCompleted) then
	{
		_cbt = combatMode (group _unit);
		if (_cbt != "COMBAT") then { [_unit,_building] spawn AZC_fnc_SetInteriorDestination; };
	};
	
	sleep 5;
	if (!(alive _unit)) exitWith {};
	_onPatrol = _unit getVariable "AZC_APM_OnPatrolActive";
};
