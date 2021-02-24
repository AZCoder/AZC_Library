/* ----------------------------------------------------------------------------
Function: AZC_fnc_Debug
Author: AZCoder
Version: 1.0
Created: 06/07/2015
Dependencies: none
Description:
	Encapsulates several commonly used commands for creating debug information while testing
	a mission. Uses AZC_Debug as the bool flag to determine whether or not to create the
	output. AZC_Debug is set false when the AZC-LIB is created, and can either be set true
	within the mission, or by using the debug console. By default, this function will output
	the debug info via systemChat, but can also output to the log file, and copy to the clipboard.
	
	I created this function because I was starting to put a lot of "if (AZC_Debug)" lines of
	code into my functions, cluttering up the text. Now it's just a simple line to call this
	function and not worry about checking if true or not.
	
Parameters:
	0 : _output
	    STRING
	    text for OUTPUT
	1 : _useLog
	    BOOL (optional)
	    default: false
	    Output to log file if true
	2 : _useClipboard
	    BOOL (optional)
	    default: false
	    Copy to clipboard

Returns: systemChat text from parameter 0

Examples:
	["copy me to the clipboard if you would",false,true] call AZC_fnc_Debug

---------------------------------------------------------------------------- */
private ["_output","_useLog","_useClipboard"];

_output	 		= [_this,0,"",["text"]] call bis_fnc_param;
_useLog 		= [_this,1,false,[false]] call bis_fnc_param;
_useClipboard 	= [_this,2,false,[false]] call bis_fnc_param;

if (isNil "AZC_Debug") then { AZC_Debug = false; };

if (AZC_Debug) then
{
	systemChat _output;
	if (_useLog) then { diag_log _output };
	if (_useClipboard) then { copyToClipboard _output };
};
