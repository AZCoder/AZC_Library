/* ----------------------------------------------------------------------------
Function: AZC_fnc_Fadein
Author: AZCoder
Version: 1.0
Created: 01/15/2021
Dependencies: none
Description:
	Convenience function to fade in screen, sound, and environmental sounds. Enables sentences and radio.

Parameters:
	0: _fadeDelay
	    INT
	    default: 5
	    fade time
	1: _soundDelay
	    INT
	    default: 5
	    sound time
	2: _maxVolume
		DECIMAL
		default: 1 (0-1)
		the volume level to fade to

Returns: none

Examples:
	_pos = [] spawn AZC_fnc_Fadein;  // fade in screen and sound to full level 1 over 5 secs (defaults)
	_pos = [3,10,0.5] spawn AZC_fnc_Fadein; // fade in screen in 3 secs, sound in 10 secs, to a volume of 50%
---------------------------------------------------------------------------- */
params[["_fadeDelay",5],["_soundDelay",5],["_maxVolume",1]];
if (_fadeDelay < 0 || _fadeDelay > 20) then { _fadeDelay = 20; };
if (_soundDelay < 0 || _soundDelay > 20) then { _fadeDelay = 20; };
if (_maxVolume < 0 || _maxVolume > 1) then { _maxVolume = 1; };

0 fadeEnvironment 0;
enableEnvironment true;

cutText ["","BLACK IN",_fadeDelay];
_soundDelay fadeSound _maxVolume;
_soundDelay fadeSpeech _maxVolume;
_soundDelay fadeEnvironment _maxVolume;
enableRadio true;
enableSentences true;
