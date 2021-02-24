/* ----------------------------------------------------------------------------
Function: AZC_fnc_Say
Author: AZCoder
Version: 1.0
Created: 09/06/2016
Dependencies: none
Description:
	Since the say command is borked as of this date (9/6/16), causing words to be static if there is a lip file, and otherwise no lip movement at all, this will emulate the say command with moving lips. This is just one of several speech related bugs in Arma 3. To use, simply provide the string table text to be spoken, and be sure to NOT have any lip files or the sound will be garbage!
	
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
	    Name of XML entry containing the text to display
	3 : _name
	    STRING
	    Name of the speaker for display purposes only
	4 : _duration
	    INT
	    DURATION of speech, used to shut off the random lip movement

Returns: nothing

Basic Example:
	[AZC_ANATOLI,"INTRO_PYTOR1","STR_SCENE_D2","Anatoli",6] spawn AZC_fnc_Say;

---------------------------------------------------------------------------- */
private ["_speaker","_name","_textXml","_textClass","_conversation","_sentenceClass"];

_speaker		= [_this, 0] call bis_fnc_param;
_soundClass		= [_this, 1] call bis_fnc_param;
_textXML		= [_this, 2] call bis_fnc_param;
_name		 	= [_this, 3] call bis_fnc_param;
_duration		= [_this, 4] call bis_fnc_param;

if (alive _speaker) then
{
	if (accTime != 1) then { setAccTime 1; };
	_showTextTime = _duration + 1;
	if (_showTextTime < 4) then { _showTextTime = 4; };
	[_name, (localize _textXML),_showTextTime] call AZC_fnc_ShowSubtitle2;
	_speaker setRandomLip true;
	if (!isNil "_soundClass") then { _speaker say _soundClass; };
	sleep _duration;
	_speaker setRandomLip false;
};
