/* ----------------------------------------------------------------------------
Function: AZC_fnc_HasLOS
Author: AZCoder
Version: 1.0
Created: 01/03/2016
Dependencies: AZC_fnc_GetPos
Description:
	Returns true if object 1 has a line of sight to object 2, otherwise false. Checks for
	line intersection and terrain intersection with a 1m z-direction boost.
	
Parameters:
	0 : _objectA	
	    OBJECT
	    the object doing the seeing, usually the player
	1 : _objectB
	    OBJECT
	    the target object that could be seen or blocked
	
NOTES:
	It is important to make sure the parameters are passed in the correct order, or the result will
	be backwards. Generally speaking, a result of 55 or less means that the target object is within
	the field of view of the seeing object (such as the player).

Returns: true/false

Examples:
	[player,truck] call AZC_fnc_HasLOS;
---------------------------------------------------------------------------- */
private["_pos1","_pos2","_line","_terrain","_los"];

_objectA	= [_this, 0] call bis_fnc_param;
_objectB	= [_this, 1] call bis_fnc_param;

_pos1 = [_objectA] call AZC_fnc_GetPos;
_pos2 = [_objectB] call AZC_fnc_GetPos;
_pos2 set[2,(_pos2 select 2)+1];
_line = lineIntersects [(eyePos _objectA),(aimPos _objectB),_objectA,_objectB];
_terrain = terrainIntersect [_pos1,_pos2];
_los = !_line && !_terrain;
_los
