/* ----------------------------------------------------------------------------
Function: AZC_fnc_QuickSave
Author: AZCoder
Version: 1.0
Created: 01/15/2021
Dependencies: none
Description:
	Adds a quick save to the 0-0-0 key sequence by adding a "JULIET" trigger.
	
Parameters:
	none

Returns: nothing

Examples:
	[] spawn AZC_fnc_QuickSave;
---------------------------------------------------------------------------- */

_trg = createTrigger["EmptyDetector",[0,0,0]];
_trg setTriggerArea[0,0,0,false];
_trg setTriggerActivation["JULIET","PRESENT",true];
_trg setTriggerText "Unlimited Save Game";
_trg setTriggerStatements["this","saveGame",""];
