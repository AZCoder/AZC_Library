/* ----------------------------------------------------------------------------
Function: AZC_fnc_ClearJournal
Author: AZCoder
Version: 1.0
Created: 2021.02.15
Dependencies: AZC_fnc_Delete, AZC_fnc_Debug
Description:
	Removes CBA references from the in-game journal to give it a cleaner look and make it more obvious
	that there are special entries added in GoA campaigns.

Parameters:
	none

Returns: nothing.

Examples:
	call AZC_fnc_ClearJournal;
---------------------------------------------------------------------------- */

[] spawn {
    waitUntil {!isNil "cba_help_DiaryRecordAddons"};

    // delete whole subject
    player removeDiarySubject "cba_help_docs";

    // or delete individual records
    player removeDiaryRecord ["cba_help_docs", cba_help_DiaryRecordKeys];
    player removeDiaryRecord ["cba_help_docs", cba_help_DiaryRecordCredits];
    player removeDiaryRecord ["cba_help_docs", cba_help_DiaryRecordAddons];
};
