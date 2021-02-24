/* ----------------------------------------------------------------------------
Function: AZC_fnc_IntroTitle
Author: AZCoder
Version: 1.0
Created: 10/23/2011
Modified: 12/19/2016
Description:
	This prints out a message 1 character at a time using the bis_fnc_dynamictext function.

Parameters:
	0 : _text
	    STRING
	    TEXT to display
	1 : _color
	    STRING (optional)
		default: "FFFFFF"
	    COLOR of the text in hex code
	2 : _showDate
		BOOL (optional)
		default: true
		SHOW DATE if true
	3 : _sound
		STRING (optional)
		default: nil
		Play the SOUND class. Must be defined in mission config.

Returns: nothing.

Examples:
	// spawn opening title message with a strong red color
	[localize "STR_LOCATION","FF0033"] spawn AZC_fnc_IntroTitle;
---------------------------------------------------------------------------- */

private["_text","_color","_showDate","_month","_hour","_min","_day","_year","_sound"];
_text 		= toUpper(_this select 0);
_color		= [_this, 1, "FFFFFF"] call bis_fnc_param;
_showDate	= [_this, 2, true] call bis_fnc_param;
_sound		= [_this, 3, nil, ["String"]] call bis_fnc_param;

if (_showDate) then
{
	_month = 
	switch (date select 1) do
	{
		case 1: { "JAN" };
		case 2: { "FEB" };
		case 3: { "MAR" };
		case 4: { "APR" };
		case 5: { "MAY" };
		case 6: { "JUN" };
		case 7: { "JUL" };
		case 8: { "AUG" };
		case 9: { "SEP" };
		case 10: { "OCT" };
		case 11: { "NOV" };
		case 12: { "DEC" };
	};

	if ((date select 3) < 10) then
	{
		_hour = format["0%1",(date select 3)];
	}
	else
	{
		_hour = str(date select 3);
	};
	if ((date select 4) < 10) then
	{
		_min = format["0%1",(date select 4)];
	}
	else
	{
		_min = str(date select 4);
	};
	if ((date select 2) < 10) then
	{
		_day = format["0%1",(date select 2)];
	}
	else
	{
		_day = str(date select 2);
	};

	_time = format["%1:%2 HOURS", _hour,_min];
	_date = format["%1 %2 %3",_month,_day,(date select 0)];
	_text = _text + "~" + _date + " " + _time;
};

_array = [];
{
	_elem = toString [_x];
	// roundabout way of adding linebreak between input text and date/time
	if (_elem == "~") then { _elem = "<br />"; };
	_array = _array + [_elem];
} forEach (toArray(_text));

_title = "";
{
	_title = format["<t color='#%1' size='1.4'>%2</t>",_color, (_title + _x)];
	[_title,0,0.1,6,0] spawn bis_fnc_dynamictext;
	if (!isNil "_sound") then { playSound _sound; };
	sleep 0.1;
} forEach _array;
