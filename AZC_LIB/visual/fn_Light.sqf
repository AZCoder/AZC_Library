/* ----------------------------------------------------------------------------
Function: AZC_fnc_Light
Author: AZCoder
Version: 1.1
Created: 4/28/2010
Dependencies: none
Description:
	A wrapper function that creates light at a given object's location.  Calls setLightBrightness,
	setLightAmbient, setLightColor, and lightAttachObject.

Parameters:
	0 : _object
	    OBJECT
	    physical object that emits the light
	1 : _luminosity
	    FLOAT
	    overall brightness of light
	2 : _colorArray
	    FLOAT
	    RGB array of colors and their intensities
	3 : _ambientArray
	    FLOAT
	    RGB array of colors and the ambient intensity of each
		
Returns: object emitting light

Examples:
	// create a white light on helo1 with 30% luminosity and no ambient light
	_light = [helo1, 0.3, [0.1,0.1,0.1],[0,0,0]] call AZC_fnc_Light;
---------------------------------------------------------------------------- */
private ["_object","_luminosity","_red","_green","_blue","_light","_colorArray","_ambientArray"];

_object 		= [_this, 0] call bis_fnc_param;
_luminosity 	= [_this, 1] call bis_fnc_param;
_colorArray 	= [_this, 2] call bis_fnc_param;
_ambientArray 	= [_this, 3] call bis_fnc_param;

_light = "#lightpoint" createVehicleLocal position _object;

// set brightness
_light setLightBrightness _luminosity;

// set light color
_red 		= _colorArray select 0;
_green 		= _colorArray select 1;
_blue 		= _colorArray select 2;
_light setLightColor[_red, _green, _blue];

// set ambient light
_red 		= _ambientArray select 0;
_green 		= _ambientArray select 1;
_blue 		= _ambientArray select 2;
_light setLightAmbient[_red, _green, _blue];

_light lightAttachObject [_object, [0,0,0]];

_light
