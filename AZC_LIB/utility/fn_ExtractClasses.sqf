/* ----------------------------------------------------------------------------
Function: AZC_fnc_ExtractClasses
Author: AZCoder
Version: 1.0
Created: 11/13/2011
Dependencies: none
Description:
	Takes an array of soldiers, vehicles, and/or groups and returns a list of their class names. The list
	is copied to the clipboard for convenience. Each class name is returned once only, removing duplicates.
	Returns vehicles that are part of a group, and crew members in vehicles.

	This function is useful with any unit spawning function where you need to know the class names. To
	use it, just put some units or groups on the map, give the leaders a name, and pass those group names
	in a call to this function.

	NOTE: this is a utility function to aid with mission design. It is not for use within a mission, except for
	design purposes.

Parameters:
	0 : _this
	    OBJECT ARRAY
	    an array of soldiers, vehicles, or groups

Returns: list of class names to the clipboard and on the screen.

Examples:
	[(group Hammer)] call AZC_fnc_ExtractClasses;
	-- the class name for each unit of group Hammer will be displayed and copied to the clipboard
---------------------------------------------------------------------------- */
private ["_classList","_unitList","_dupeList","_tempArray"];

_classList = [];
_unitList = [];
_dupeList = [];
_tempArray = [];

// determine if type group, add each unit separately per group
{
	if (typeName _x == "GROUP") then
	{
		{
			if (vehicle _x != _x) then
			{ _unitList set [count _unitList, vehicle _x]; };
			_unitList set [count _unitList, _x];
		} forEach units _x;
	}
	else
	{
		{
			if (vehicle _x != _x) then
			{
				// adds anyone inside of a vehicle
				_unitList set [count _unitList, _x];
			}
		} forEach crew _x;

		_unitList set [count _unitList, _x];
	};
	systemChat str (typeName _x);
} forEach _this;

// extract classname for each unit add put it into _classList
for [{_i = 0}, {_i < (count _unitList)}, {_i = _i + 1}] do
{
	_object = _unitList select _i;
	_class = typeOf _object;
	_classList set [count _classList, _class];
};

// remove duplicate class names from _classList
{
	_class = _x;
	_dupe = {_x == _class} count _classList;
	if (_dupe > 1) then
	{
		_tempArray = [_class];
		_dupeList set[count _dupeList,_class];
		_classList = _classList - _tempArray;
	};
} forEach _classList;

// add _dupeList back in as it will contain 1 instance of each duplicated class
_classList = _classList + _dupeList;

hint format["Copied to clipboard: %1",_classList];
copyToClipboard format["%1",_classList];
