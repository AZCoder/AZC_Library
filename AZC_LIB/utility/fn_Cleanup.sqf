/* ----------------------------------------------------------------------------
Function: AZC_fnc_Cleanup
Author: AZCoder
Version: 1.0
Created: 2020.05.27
Dependencies: AZC_fnc_Delete, AZC_fnc_Debug
Description:
	AZC_fnc_Cleanup is a manager that calls AZC_fnc_Delete to simplify cleanup of dead units and vehicles. It is intended to be used by specifying a trigger zone to clean up the dead with a distance from the player before initiating the cleaning. If no trigger is provided then it will cleanup the entire map.
	AZC_fnc_Cleanup will only consider units within a trigger zone at the time this function is called (or optionally the entire map). Only units which are dead at the time this function is called will be cleaned up. Also this function does not affect any units in the player's group. 
	See Examples below for HOW TO USE IT.

Parameters:
	0 : _trigger
	    OBJECT
	    An area trigger, or objNull for all units on map
	1 : _distance
	    INT
	    default: 200
	    DISTANCE of a dead unit from player before cleanup, use 0 to ignore distance

Returns: nothing.

Examples:
	Create an area trigger. All units within the trigger will be tested for the conditions. Do not set Type or Activation (those are ignored). Call this function when you want the cleanup to be activated. Only affects units within the trigger at the time the call is made, OR all units on the map if no trigger specified. In the latter case, they must be 200+m from the player when dead.
	
	Simplest usage:
	[] spawn AZC_fnc_Cleanup;
	// This will delete all dead units that are 200m+ from player (built-in minimum distance).
	
	Cleanup units in the area of trigger trgAirport:
	[trgAirport,500] spawn AZC_fnc_Cleanup;
	// When called, all [dead] units and vehicles within trgAirport and 500m or more from player are deleted as soon as the distance condition is met.
	
	Cleanup all units regardless of distance within trgAirport.
	[trgAirport,0] spawn AZC_fnc_Cleanup;
	// If player is still in the trigger when called, any dead units around will be deleted immediately. This never affects units that were part of the player's group.
---------------------------------------------------------------------------- */
private ["_trigger","_pos","_objListToDelete"];

_trigger 		= [_this, 0, objNull] call bis_fnc_param;
_distance		= [_this, 1, 200] call bis_fnc_param;

// no negative distances
_distance = abs(_distance);

// min distance 200m if no trigger provided
if ((_trigger isEqualTo objNull) && (_distance < 200)) then { _distance = 200; };

// by default start with all units on the map
_objListToDelete = allUnits + allDead;
if (!(_trigger isEqualTo objNull)) then
{
	_objListToDelete = (allUnits + allDead) inAreaArray _trigger;
};

_objListToDelete = _objListToDelete - (units group player);
[format["Objects to Delete: %1",_objListToDelete],true] call AZC_fnc_Debug;
[_objListToDelete,_distance] spawn AZC_fnc_Delete;
