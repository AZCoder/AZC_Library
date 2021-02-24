/* ----------------------------------------------------------------------------
Function: AZC_fnc_ClearWaypoints
Author: AZCoder
Version: 1.0
Created: 1/15/2021
Dependencies: none
Description:
	Clears a group's waypoints which is sometimes necessary to clear up any pathing confusion.
    
Parameters:
	0: _unit
	    OBJECT
	    unit to clear waypoint (usually a group leader)

Returns: nothing

Examples:
	[Jim] call AZC_fnc_ClearWaypoints;
---------------------------------------------------------------------------- */
params ["_unit"];
if (!(alive _unit)) exitWith {};

group _unit spawn 
{
	[_this,(currentWaypoint _this)] setWaypointPosition [getPosASL ((units _this) select 0),-1];
	sleep 0.1;
	for "_i" from count waypoints _this - 1 to 0 step -1 do 
	{
		deleteWaypoint [_this,_i];
	};
};
