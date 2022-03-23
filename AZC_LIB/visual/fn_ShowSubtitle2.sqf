/*
	Author: Thomas Ryan
	Modified by AZCoder to modify the colors and add a dynamically sized background behind the text.
	
	Description:
	Displays a subtitle at the bottom of the screen.
	
	Parameters:
		_this select 0: STRING - Name of the person speaking.
		_this select 1: STRING - Contents of the subtitle.
	
	Returns:
	SCRIPT - Script controlling the displayed subtitle.
*/

params [
	["_from", "", [""]],
	["_text", "", [""]],
	["_duration", 10]
];

if (_from == "") exitWith {"No speaker defined!" call BIS_fnc_error; scriptNull};
if (_text == "") exitWith {"No text defined!" call BIS_fnc_error; scriptNull};

// Terminate previous script
if (!(isNil {AZC_fnc_showSubtitle_subtitle2})) then {terminate AZC_fnc_showSubtitle_subtitle2};

AZC_fnc_showSubtitle_subtitle2 = [_from,_text,_duration] spawn
{
	disableSerialization;
	scriptName format ["BIS_fnc_showSubtitle: subtitle display - %1", _this];
	
	params ["_from","_text","_duration"];
	
	// Create display and control
	titleRsc ["RscDynamicText", "PLAIN"];
	private "_display";
	waitUntil {_display = uiNamespace getVariable "BIS_dynamicText"; !(isNull _display)};
	private _ctrl = _display displayCtrl 9999;
	uiNamespace setVariable ["BIS_dynamicText", displayNull];
	
	// Position control
	private _multiplier = 0.25 + (count _text / 500) + (count _from / 500);
	private _width = _multiplier * safeZoneW;
	private _xpos = safeZoneX + (0.5 * safeZoneW - (_width / 2));
	private _ypos = safeZoneY + (0.73 * safeZoneH);
	private _height = 0.035 * safeZoneH;
	
	private _textSize = count _text + count _from;
	_height = _height * (floor(_textSize / 80) + 1);
	_ctrl ctrlSetPosition [_xpos,_ypos,_width,_height];
	
	// Hide control
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit 0;
	
	// Show subtitle
	_ctrl ctrlSetStructuredText parseText ("<t align = 'left' shadow = '2' size = '0.7'><t color = '#030303'>" + _from + ":</t> <t color = '#FFFFFF'>" + _text + "</t></t>");
	_ctrl ctrlSetBackgroundColor [0.21,0.66,0.35,0.75];
	_ctrl ctrlSetFade 0;
	_ctrl ctrlCommit 0.75;
	sleep _duration;
	
	// Hide subtitle
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit 0.5;
};

AZC_fnc_showSubtitle_subtitle2