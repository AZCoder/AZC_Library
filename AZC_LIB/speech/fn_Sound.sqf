/* ----------------------------------------------------------------------------
Function: AZC_fnc_Sound
Author: AZCoder
Version: 1.0
Created: 08/25/2017
Dependencies: none
Description:
	In a recent Arma 3 update, the attentuation on the say command increased dramatically, making it
	extremely difficult to hear anything. This function is a partial workaround. It uses the playSound3D
	command, but it only works for static scenes. Once the sound is played, it does not move, therefore
	you cannot use it in a moving truck, for example.
	
	Please note that this was written mostly as an alternative to AZC_fnc_Say and is primarily
	intended for simple static scene dialog, although it can be used for other sounds that need
	their db boosted.
	
Note:
	Do not make CfgSound classes for this function. It only reads a direct path on the drive.
	For convention, the sound MUST be in a subfolder called "sound" -> mission_root\sound
	Sound must be an ogg file type.

Parameters (parameters 3 to 5 are intended only for use as dialog):
	0 : _source
	    OBJECT
	    SOURCE of the sound
	1 : _sound
	    STRING
	    sound name in the sound subfolder (if extension omitted, defaults to ogg)
	2 : _volume
	    INT
	    default: 2
	    VOLUME of the sound
	3 : _textXML
	    STRING (optional)
	    default: "" (to display no text)
	    Name of XML entry containing the TEXT to display
	4 : _name
	    STRING (optional)
	    default: "" (to display no name)
	    NAME of the speaker for display purposes only
	5 : _duration
	    INT (optional)
	    default: 0
	    DURATION of speech, used to shut off the random lip movement
	6 : _path
		STRING (optional)
		default: "sound"
		Allows playing sound from a different directory

Returns: nothing

Basic Example:
	[AZC_ANATOLI,"INTRO_PYOTR1",3,"STR_INTRO_PYOTR1","Pyotr",6] spawn AZC_fnc_Sound;
	[AZC_GATE_GUARD,"move.wss",2,"STR_GUARD_STOP","Guard",1] spawn AZC_fnc_Sound;

---------------------------------------------------------------------------- */
private ["_source","_name","_textXml","_textClass","_conversation","_sentenceClass","_showTextTime"];

_source			= [_this, 0] call bis_fnc_param;
_sound			= [_this, 1] call bis_fnc_param;
_volume			= [_this, 2, 2] call bis_fnc_param;
_textXML		= [_this, 3, ""] call bis_fnc_param;
_name		 	= [_this, 4, ""] call bis_fnc_param;
_duration		= [_this, 5, 0] call bis_fnc_param;
_path		 	= [_this, 6, "sound"] call bis_fnc_param;

// is _source a human?
_type = typeOf _source;
_isMan = getNumber (configFile >> "CfgVehicles" >> _type >> "isMan");
// if human not alive then exit
if (_isMan == 1 && !(alive _source)) exitWith {};

// if text & name provided then display it (for dialog purposes)
_showTextTime = _duration + 1;
if (_showTextTime < 4) then { _showTextTime = 4; };
if (count _textXML > 0) then { [_name,(localize _textXML),_showTextTime] call AZC_fnc_ShowSubtitle2; };

if (_isMan == 1 && _duration > 0) then
{
	[_source,_duration] spawn
	{
		params["_speaker","_duration"];
		_speaker setRandomLip true;
		sleep _duration;
		_speaker setRandomLip false;
	};
};

if (!isNil "_sound") then
{
	if (_volume < 1) then { _volume = 1; };
	if (vehicle _source != _source) then { _source = vehicle _source };
	_basePath = str missionConfigFile select [0, count str missionConfigFile - 15];
	_soundToPlay = _basePath + _path + "\" + _sound;
	// extension included?
	_splitArray = _sound splitString ".";
	if (count _splitArray == 1) then { _soundToPlay = _soundToPlay + ".ogg"; };
	playSound3D [_soundToPlay,_source,false,getPosASL _source,_volume];
};
