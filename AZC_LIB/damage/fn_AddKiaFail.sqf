/* ----------------------------------------------------------------------------
Function: AZC_fnc_AddKiaFail
Author: AZCoder
Version: 1.0
Created: 01/15/2021
Dependencies: none
Description:
	Fails the mission if the given unit is killed. This was created for missions with team switching, so that if the player's main character is killed (while playing another team member) then the mission ends. This is important for missions with dialog. The loser ending is used which allows the player to reload the last save as opposed to having to star the mission from the beginning.
	
Parameters:
	none

Returns: nothing

Examples:
	[Asgard] spawn AZC_fnc_AddKiaFail; // mission fails if Asgard is killed
---------------------------------------------------------------------------- */

params["_unit"];
_unit addEventHandler ["killed", {
	_unit = _this select 0;
	[_unit] spawn {
		params["_unit"];
		enableTeamSwitch false;
		_unit switchMove "";
		cutText ["","BLACK OUT",5];
		0 fadeMusic 1;
		playMusic "EventTrack02_F_Curator";
		5 fadeSound 0;
		0 fadeSpeech 0;
		enableEnvironment false;
		enableSentences false;
		enableRadio false;
		[(format["<t color='#%1'>%2 was killed. Mission failed.</t>","E0981D",(name _unit)]),0,0.2,8,1] spawn bis_fnc_dynamictext;
		sleep 9;
		failMission "LOSER";
	};
}];
