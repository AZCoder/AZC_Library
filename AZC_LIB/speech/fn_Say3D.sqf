/* ----------------------------------------------------------------------------
Function: AZC_fnc_Say3D
Author: AZCoder
Version: 1.0
Created: 2021.02.24
Dependencies: none
Description:
	This is a replacement for AZC_fnc_Say. I am keeping the old function there for backwards compatibility.
	Differences:
	- AZC_fnc_Say3D uses "say3D" instead of "say" (mostly matters in cutscenes)
	- Got rid of the setRandomLip which was simply a quick & dirty way of bypassing a bug with the say command,
	but since Arma 3 v2.02, that bug is fixed and say works with lip files. That means AZC_fnc_Say3D
	*requires* lip files in order for the AI lips to move.
	- you can now specify the maxDistance, pitch, and whether it is speech or not (affected by fadeSpeech or fadeSound) -- all of these parameters have the same defaults as the say3D command
	
	Why use AZC_fnc_Say3D over the say3D command?
	- it automatically prints text on the screen using the ShowSubtitle function which is clean
	and easy to read
	- sets accTime back to 1 in case player was zooming along
	
Note:
	In CfgSounds, each sound must have titles set like this: titles[] = {};
	If missing, you get a popup error. If you it has something like 0,"" then it overrides the title set below.

Parameters:
	0 : _speaker
	    OBJECT
	    SPEAKER of the sound
	1 : _soundClass
	    STRING
	    CfgSound class name referencing a sound file for speech
	2 : _textXML
	    STRING
	    Name of stringtable.xml entry containing the text to display
	3 : _displayName
	    STRING
	    Name of the speaker for display purposes only, if empty then the 'name' command will be used
		on the _speaker object
	4 : _textDuration
	    INT
	    DURATION to display the spoken text on the screen (min value 3)
	5 : _maxDistance
	    INT
	    default value 100
	6 : _pitch
	    INT
	    default value 1
	7 : _isSpeech
	    BOOL
	    default value false

Returns: nothing

Basic Example:
	[AZC_KNIGHT,"UNDERGROUND_KNIGHT16","STR_UNDERGROUND_KNIGHT16","Knight",3,200,1.2,true] execVM "fn_Say.sqf";

---------------------------------------------------------------------------- */

params ["_speaker","_soundClass","_textXML","_displayName",["_textDuration",3],["_maxDistance",100],["_pitch",1],["_isSpeech",false]];

if (alive _speaker) then
{
	if (accTime != 1) then { setAccTime 1; };
	if (_displayName isEqualTo "") then { _displayName = name _speaker; };
	if (_textDuration < 3) then { _textDuration = 3; };
	[_displayName,(localize _textXML),_textDuration] call AZC_fnc_ShowSubtitle2;
	if (!(isNil "_soundClass")) then { _speaker say3D [_soundClass,_maxDistance,_pitch,_isSpeech]; };
};
