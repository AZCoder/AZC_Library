/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetSpokenDirection
Author: AZCoder
Version: 1.0
Created: 12/26/2015
Dependencies: none
Description:
	Simply returns the spoken direction for a given heading in degrees.
	For example, 10 deg would return 'north' while 40 deg would return 'north-east'.
	
Parameters:
	0 : _heading
	    float
	    default: 0
	    direction in degrees
		
Returns: string of the direction

Examples:
	127.35 call AZC_fnc_GetSpokenDirection;
---------------------------------------------------------------------------- */
private ["_heading","_spoken"];

_heading = [_this, 0, 0] call bis_fnc_param;
_spoken = "north";

if (_heading < 0) then
{
	// why are you passing in a negative direction?
	_spoken = "somewhere";
};

if (_heading > 360) then
{
	_factor = _heading / 360;
	_factor = _factor mod 1; // remove INT portion
	// yes it works, try this in debugger -> 370 / 360 mod 1 * 360 => 10
	_heading = 360 * _factor;
};

if (_heading > 20) then { _spoken = "north-east"; };
if (_heading > 65) then { _spoken = "east"; };
if (_heading > 110) then { _spoken = "south-east"; };
if (_heading > 155) then { _spoken = "south"; };
if (_heading > 205) then { _spoken = "south-west"; };
if (_heading > 245) then { _spoken = "west"; };
if (_heading > 285) then { _spoken = "north-west"; };
if (_heading > 335) then { _spoken = "north"; };

_spoken
