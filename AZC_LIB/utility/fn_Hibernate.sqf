/* ----------------------------------------------------------------------------
Function: AZC_fnc_Hibernate
Author: AZCoder
Version: 1.1
Created: 5/1/2011
Converted to A3: 8/21/2016
Description:
	In a nutshell, this freezes and hides units. Originally written as a performance enhancing function for Arma 2,
	the performance aspect is less important now with dynamic simulation in Arma 3. However it is very useful for situations,
	especially in cut scenes, where you want certain actors to wait until a specific moment before being allowed to activate.
	
	For ease of use, the object array need only consist of group leaders, and all subordinates will automatically be taken into
	account.
	
	Important note! Units killed while in hibernation will not return to normal if group leaders are only passed in.
	For this reason, an array of units is returned when this function is called that contains ALL units that were put
	into hibernation. The caller should maintain this array in a variable until it is time to re-enable the units,
	then pass it back in with the false flag.

	Possible Bug: Since 2017 I have noticed that aircraft cannot be hidden anymore. Do not know if this is intentional, but
	one of the great features of this function was to freeze aircraft until needed. This is still possible, but they will be
	visible (unless BI fixes the issue).

Parameters:
	0 : _objArray
	    ARRAY OF OBJECTS
	    OBJECTS that will be put into hibernation, or taken out of hibernation
	1 : _switch
	    BOOL
	    true = go into hibernation, false = come out of hibernation

Returns: list of actual units put into hibernation.

Note:

Examples:
	_units = [_objArray,true] call AZC_fnc_Hibernate; --> an array of objects, which may simply be group leaders,
	is passed in with true, causing all units in those groups to freeze, and each unit is returned into _units as an array.
	[_units,false] call AZC_fnc_Hibernate; --> units that were frozen in the previous call are now returned to normal,
	even if they were killed.
---------------------------------------------------------------------------- */
private["_switch","_objArray","_unitList"];

_objArray	= [_this, 0] call bis_fnc_param;
_switch		= [_this, 1, false] call bis_fnc_param;

// if bool not passed then set to false (not hibernating)
if (typeName _switch != "BOOL") then { _switch = false; };

// convert array of objects into separate units
// NOTE: this is a convenience so that if a group leader is passed, all units in the group will go into hibernation
// if _switch is false, assume object array is precise list of units, otherwise convert them into list of units
if (!_switch) then
{
	_unitList = _objArray;
}
else
{
	_unitList = [];
	{
		{
			if ((vehicle _x != _x) && (driver (vehicle _x) == _x)) then
			{
				// adds vehicle 1 time (assuming only 1 driver per vehicle :D)
				_unitList set [count _unitList, vehicle _x];
			};
			_unitList set [count _unitList, _x];
		} forEach units group _x;
	} forEach _objArray;
};

// at the risk of confusion, _switch is used by enableSimulation, where true is enabled, false is disabled
// which is opposite of the idea of hibernating, so we must flip the bool flag
_switch = !_switch;

{
	_x enableSimulation _switch;
	_x hideObject (!_switch);
} forEach _unitList;

// return list of units, the caller must keep tabs on this
_unitList
