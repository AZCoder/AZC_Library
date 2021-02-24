/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetPos
Author: AZCoder
Version: 2.0
Created: 9/7/2014
Dependencies: none
Description:
	Gets the position of passed in object. Can be physical object, group, or marker. Z-factor
	is based on position over land or water. Group position is based on the leader.
	
	AZC_fnc_GetPos also calculates location position and will return a 0 z value when location is over water. This came about because some locations on Tanoa (Oumere) are actually on the ocean and the z value changes constantly.

Parameters:
	0: _obj
	    STRING, ARRAY, OBJECT
	    marker, position, or object where position will be calculated
	1: _terrain
	    INT (optional)
	    default: -1
	    3 possible values
	       -1 - automatic (default)
		0 - force ATL [over land]
		1 - force ASL [over water]

Returns: position array

Examples:
	_pos = ["goHere"] call AZC_fnc_GetPos;  --> gets the position of marker named "goHere"
	_pos = [tank1,0] call AZC_fnc_GetPos;  --> forces ATL position of tank1 even if it's over water
---------------------------------------------------------------------------- */

private ["_obj","_terrain","_grp","_pos"];

_obj = [_this, 0] call bis_fnc_param;
_terrain = [_this, 1, -1, [0]] call bis_fnc_param;

switch (typeName _obj) do
{
	case "STRING": 	{ _pos = getMarkerPos _obj	};
	case "ARRAY":	{ _pos = _obj };
	case "LOCATION":{ 
						_pos = locationPosition _obj;
						if (surfaceIsWater _pos) then { _pos = [(_pos select 0),(_pos select 1),0]; };
					};
	default			{
						// default covers OBJECT and GROUP
						// get terrain ATL by default
						_pos = getPosATL _obj;
						if (_terrain > 0) then
						{
							// if user wants water (1) then give ASL reading
							_pos = getPosASL _obj;
						};

						if (_terrain < 0) then
						{
							// if user did not specify _terrain, then return water only if over water
							if (surfaceIsWater _pos) then { _pos = getPosASL _obj; };
						};
					};
};

// return position
_pos
