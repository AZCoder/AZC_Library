/*
	Author: Thomas Ryan
	Modified by AZCoder to make the text a bit larger.
	
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

AZC_fnc_showSubtitle_subtitle2 = [_from,_text,_duration] spawn {
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
	private _w = 0.4 * safeZoneW;
	private _x = safeZoneX + (0.5 * safeZoneW - (_w / 2));
	private _y = safeZoneY + (0.73 * safeZoneH);
	private _h = safeZoneH;
	
	_ctrl ctrlSetPosition [_x, _y, _w, _h];
	
	// Hide control
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit 0;
	
	// Show subtitle
	_ctrl ctrlSetStructuredText parseText ("<t align = 'center' shadow = '2' size = '0.8'><t color = '#00ccff'>" + _from + ":</t> <t color = '#d0d0d0'>" + _text + "</t></t>");
	_ctrl ctrlSetFade 0;
	_ctrl ctrlCommit 0.5;
	sleep _duration;
	
	// Hide subtitle
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit 0.5;
};

AZC_fnc_showSubtitle_subtitle2