/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetSpokenDate
Author: AZCoder
Version: 1.0
Created: 03/05/2017
Dependencies: none
Description:
	Simply returns the current game date in full text.
	
Parameters:
	none
		
Returns: string of the date

Examples:
	_date = call AZC_fnc_GetSpokenDate;
---------------------------------------------------------------------------- */
params [["_date",date]];
private ["_heading","_spoken","_day","_month","_hour","_minute"];

_month = switch (_date select 1) do
		{
			case 1: { "January" };
			case 2: { "February" };
			case 3: { "March" };
			case 4: { "April" };
			case 5: { "May" };
			case 6: { "June" };
			case 7: { "July" };
			case 8: { "August" };
			case 9: { "September" };
			case 10: { "October" };
			case 11: { "November" };
			case 12: { "December" };
		};

if ((_date select 2) < 10) then
{
	_day = format["0%1",(_date select 2)];
}
else
{
	_day = str(_date select 2);
};

_hour = _date select 3;
_minute = _date select 4;
if (_hour < 10) then { _hour = format["0%1",_hour]; };
if (_minute < 10) then { _minute = format["0%1",_minute]; };
_date = format["%1 %2, %3",_month,_day,(_date select 0)];
_spoken = format["%1 %2:%3 %4 hours",_date,_hour,_minute];

_spoken
