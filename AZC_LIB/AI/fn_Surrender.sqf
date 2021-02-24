/* ----------------------------------------------------------------------------
Function: AZC_fnc_Surrender
Author: AZCoder
Version: 1.0
Created: 02/07/2021
Description: Makes a group of AI surrender by removing their weapons and putting their hands
on their head.	If group leader is passed, everyone in the group will surrender. Does NOT work for
units inside vehicles.

Parameters:
	0 : _this
	    ARRAY of units to surrender

Returns: nothing.

Examples:
	[array of units] spawn AZC_fnc_Surrender;
---------------------------------------------------------------------------- */

params["_losers"];

{
	_unit = _x;
	if (alive _unit) then
	{
		removeAllWeapons _unit;
		_unit setCaptive true;
		_unit disableAI "ANIM";
		_unit switchMove "AmovPercMstpSsurWnonDnon";
	};
} forEach _losers;
