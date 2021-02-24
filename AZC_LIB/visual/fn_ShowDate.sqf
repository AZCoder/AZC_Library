/* ----------------------------------------------------------------------------
Function: AZC_fnc_ShowDate
Author: AZCoder
Version: 1.0
Created: 03/06/2016
Dependencies: none
Description:
	Displays the current game date in full English format, such as August 5, 2005. Time component optional.
	
Parameters:
	0 : _color
	    STRING (optional)
	    default: "FFFFFF"
	    COLOR code in Hex format
	1 : _size
	    INT (optional)
	    default: 1
	    SIZE of the text
	2 : _wait
	    INT (optional)
	    default: 5
	    duration to WAIT in seconds while displaying the date
	3 : _displayTime
	    BOOL (optional)
	    default: true
	    DISPLAY TIME if true

Returns: nothing

Examples:
	["0077FF",0.5,8] spawn AZC_fnc_ShowDate;
---------------------------------------------------------------------------- */
private["_color","_size","_wait","_month","_day","_displayTime"];

_color		= [_this, 0, "FFFFFF"] call bis_fnc_param;
_size		= [_this, 1, 1] call bis_fnc_param;
_wait		= [_this, 2, 5] call bis_fnc_param;
_displayTime	= [_this, 3, false] call bis_fnc_param;

_month = 	switch (date select 1) do
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

if ((date select 2) < 10) then
{
	_day = format["0%1",(date select 2)];
}
else
{
	_day = str(date select 2);
};

_date = format["%1 %2, %3",_month,_day,(date select 0)];
if (!_displayTime) then
{
	[(format["<t color='#%1' size='%3'>%2</t>",_color,_date,_size]),0,0.2,_wait,4] spawn bis_fnc_dynamictext;
}
else
{
	_hour = date select 3;
	_minute = date select 4;
	_qualifier = "AM";
	if (_hour > 11) then { _qualifier = "PM"; };
	_displayDate = format["<t color='#%1' size='%3'>%2</t>",_color,_date,_size];
	if (_hour < 10) then { _hour = format["0%1",_hour]; };
	if (_minute < 10) then { _minute = format["0%1",_minute]; };
	_displayTime = format["<br /><t color='#%1' size='%2'>%3:%4 %5</t>",_color,_size,_hour,_minute,_qualifier];
	[(_displayDate + _displayTime),0,0.2,_wait,4] spawn bis_fnc_dynamictext;
};
