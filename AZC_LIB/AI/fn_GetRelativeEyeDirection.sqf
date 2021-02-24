/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetRelativeEyeDirection
Author: AZCoder
Version: 1.0
Created: 01/03/2016
Dependencies: none
Description:
	Returns relative eye direction from object A (the seeing object) to object B (the seen object).
	More specifically, it takes the positions of object A and object B, and finds the direction from A
	to B. Then it takes the absolute angle of object A's eye direction subtracted from the direction to B.
	This will produce a value of 0 to 180, where 55 or under is looking toward object B, and anything over
	55 is looking away. This value will vary depending upon the size of object B and the depth of
	field of the monitor, and that's up to the user of this function to determine.
	
Parameters:
	0 : _objectA
	    OBJECT
	    the object doing the seeing
	1 : _objectB
	    OBJECT
	    the target object that could be seen
	
NOTES:
	It is important to make sure the parameters are passed in the correct order, or the result will
	be backwards. Generally speaking, a result of 55 or less means that the target object is within
	the field of view of the seeing object (such as the player).
	
	Note that animations do NOT return visual direction. In other words, the unit will have the same direction they had at the start of the animation, regardless of what direction they appear to be facing!

Returns: relative direction in degrees

Examples:
	[player,enemy] call AZC_fnc_GetRelativeEyeDirection;
---------------------------------------------------------------------------- */
private["_objectA","_objectB","_eyeDir","_angle1","_angle2"];

_objectA	= [_this, 0] call bis_fnc_param;
_objectB	= [_this, 1] call bis_fnc_param;

_angle1 = [(position _objectA),(position _objectB)] call BIS_fnc_dirTo;
_eyeDir = eyeDirection _objectA;
_angle2 = (_eyeDir select 0) atan2 (_eyeDir select 1);
if (_angle2 < 0) then { _angle2 = 360 + _angle2; };
_rd = abs (_angle2 - _angle1);
if (_rd > 180) then
{
	_rd = 360 - _rd;
};
_rd
