/* ----------------------------------------------------------------------------
Function: AZC_fnc_InsideBuilding
Author: AZCoder (heavily based on code from Killzone Kid)
Version: 1.0
Created: 03/06/2016
Dependencies: none
Description:
	Tests if provided object is under shelter with direct line of sight to the sky from above,
	useful for spawning and detecting weather effects
---------------------------------------------------------------------------- */

_object = _this;
_inside = false;
_worldPos = getPosWorld _object;
_skyPos = getPosWorld _object vectorAdd [0, 0, 50];
_line = lineIntersectsSurfaces [_worldPos,_skyPos,_object,objNull,true,1,"GEOM","NONE"];
if (count _line > 0) then
{
	_result = _line select 0;
	_house = _result select 3;
	if (!(isNil "_house")) then { _inside = true };
};

_inside
