/* ----------------------------------------------------------------------------
Function: AZC_fnc_Speak
Author: AZCoder
Version: 1.0
Created: 08/24/2016
Dependencies: see below
Description:
	Causes the player or an AI to speak a predefined sentence with sound and visual text. Intended for cutscenes.
	
	OK - with kbTell and the say command, you may be wondering why I made this. Simple. BIS broke both kbTell and say when Arma 3
	released and has done nothing to fix them as of this writing.

	With the say command, it only seems to work if there is NO lip file. The character's mouth does not move at all.
	If you have a matching lip file there tends to be silence or garbled static.
	
	kbTell? It works, but ONLY if the character possesses a radio in their inventory slot. Otherwise no sound!
	I think they broke it by introducting the forceRadio parameter which does absolutely nothing to force a character to speak
	without a radio. I'm referring to direct face to face communication, obviously not the kind requiring a radio.
	
	This function will do a few things: it checks the character for a radio, and if not present, adds one to ensure that kbTell 
	has sound. The BIS function BIS_fnc_showSubtitle is used to show the dialog in the lower center of the screen.
	To ensure this works properly, sentences must be defined in cfgSentences as normal for kbTell to function,
	however the text lines should be empty like this:
	text = "";
	
	I wrote this because I preferred using the say command for cutscenes so that I could control the visualization
	of the spoken text, but it seems now that only kbTell works, and only with radios.
	The kbTell bug is here: https://feedback.bistudio.com/T82860

Parameters:
	0 : _speaker
	    OBJECT
	    SPEAKER of dialog
	1 : _listener
	    OBJECT
	    LISTENER of dialog
	2 : _name
	    STRING
	    display NAME of the speaker
	3 : _sentenceClass
	    STRING
	    SENTENCE CLASS from cfgSentences (must be wrapped in quotes "")
	4 : _textXML
	    STRING
	    Name of XML entry containing the TEXT to display
	5 : _conversation
	    STRING
	    Name of the kbTell CONVERSATION (must be setup before calling this function)
	6 : _convPathName
	    STRING
	    PATH to bikb file containing conversation classes
	7 : _forceRadio
		BOOL
		True to force speaker to use radio

Returns: nothing

Basic Example:
	[AZC_DAD, player, "Dad", "INTRO_DAD1", "STR_GA1SF02_INTRO_DAD1", _conversation] spawn AZC_fnc_Speak;

Extended Example (for conversations):
	_conversation = "truck";
	AZC_DAD kbAddTopic [_conversation, "dialog\intro.bikb"];
	player kbAddTopic [_conversation, "dialog\intro.bikb"];

	_hnd1 = [AZC_DAD,player,"Dad","INTRO_DAD1","STR_GA1SF02_INTRO_DAD1",_conversation] spawn AZC_fnc_Speak;
	waitUntil { scriptDone _hnd1 };

	OR the kbAddTopic can be done automatically if added as a parameter
	
	_hnd1 = [AZC_DAD,player,"Dad","INTRO_DAD1","STR_GA1SF02_INTRO_DAD1","truck","dialog\intro.bikb"] spawn AZC_fnc_Speak;
	waitUntil { scriptDone _hnd1 };
---------------------------------------------------------------------------- */
params ["_speaker","_listener","_name",["_sentenceClass",""],["_textXML",""],"_conversation",["_convPathName",""],["_forceRadio",false]];

if (!(alive _speaker) || !(alive _listener)) exitWith {};
if (accTime != 1) then { setAccTime 1; };

if (_convPathName != "") then
{
	if (!(_speaker kbHasTopic _conversation)) then
	{
		_speaker kbAddTopic [_conversation, _convPathName];
	};

	if (!(_listener kbHasTopic _conversation)) then
	{
		_listener kbAddTopic [_conversation, _convPathName];
	};
};

private _radioFound = false;

{
	private _item = _x;
	// RHS has unique radio names so I made this a generic search
	if (_item find "radio" > -1) exitWith { _radioFound = true; };
} forEach assignedItems _speaker;

if (!_radioFound) then
{
	_speaker linkItem "ItemRadio";
};

if (count _textXML > 0) then
{
	[_name,(localize _textXML)] call AZC_fnc_ShowSubtitle2;
};

if (_sentenceClass != "") then
{
	_speaker kbTell [_listener,_conversation,_sentenceClass,["",{},"",[]],_forceRadio];
	waitUntil {_speaker kbWasSaid [_listener,_conversation,_sentenceClass,8]};
}
else
{
	// this is for mission development, allows tester to briefly see dialog when no sound is recorded yet
	sleep 4;
};
