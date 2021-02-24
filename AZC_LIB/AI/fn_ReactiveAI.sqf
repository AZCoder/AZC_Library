/* ----------------------------------------------------------------------------
Function: AZC_fnc_ReactiveAI
Author: AZCoder
Version: 2.0
Created: 10/23/2016
Description: Simple script to make AI react when a group member is shot. Based on
original script (by AZCoder) from Hoc Est Bellum mission in Arma 2.	

12/04/2016: Added custom weather -> AZC_CUSTOM_WEATHER. Simple store this in the missionNameSpace
with a true value if using custom weather (dust storm or snow storm typically). This will reduce
visibility for the AI when trying to spot the player.

Parameters:
	0 : _this
	    ARRAY of units in a single group or GROUP LEADER
	    the group leader

Returns: nothing.

Examples:
	[grpLeader] spawn AZC_fnc_ReactiveAI;
---------------------------------------------------------------------------- */

params["_object"];
private _groups = [];
// systemChat format["type: %1 = %2 (%3)",_object,typeName _object,diag_tickTime];
if (typeName _object == "OBJECT") then
{
	_groups pushBack (group _object);
}
else
{
	_groups = _object;
};

{
	[leader _x] spawn AZC_fnc_SetReactHandlers;
} forEach _groups;
