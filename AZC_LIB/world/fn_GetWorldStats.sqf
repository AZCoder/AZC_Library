/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetWorldStats
Author: AZCoder
Original Sun Angle Calculations: CarlGustaffa
Version: 1.0
Created: 9/16/2010
Dependencies: none
Description:
	Gets the current world's latitude, time of sunrise (when it breaks the horizon), and current angle of the sun.

Note: This function is based on the original work of CarlGustaffa.
My contribution is to to calculate the time of sunrise and sunet based on when the sun is approximately 0 degs (on the horizon).

Parameters:
	None

Returns: array[current sun angle, latitude, sunrise hour, sunrise mins, sunset hour, sunset mins]

Examples:
	_array = call AZC_fnc_GetWorldStats;
---------------------------------------------------------------------------- */
private ["_lat","_day","_degs","_calc1","_calc2","_calc3","_hourSunrise","_minSunrise","_hourSunset","_minSunset","_angle","_worldStats","_fTime","_sunrise","_sunset"];
_lat = abs(getNumber(configFile >> "CfgWorlds" >> worldName >> "latitude"));
_day = 365.25 * (dateToNumber date);
_degs = (daytime / 24) * 360;
_calc1 = ((12 * cos(_day)) - 78) * cos(_lat);
_calc2 = cos(_degs);
_calc3 = 24 * sin(_lat) * cos(_day);
_angle = _calc1 * _calc2 - _calc3;

// calculate sunrise time when angle = 0 deg (on horizon)
// solve for _calc2 because it holds the time of day
_calc2 = acos(_calc3 / _calc1);
_fTime = (_calc2 * 24) / 360;  // float value of time
_hourSunrise = round(_fTime);
_minSunrise = _fTime - _hourSunrise;
if (_minSunrise < 0) then
{
	_hourSunrise = _hourSunrise - 1;
	_minSunrise = _fTime - _hourSunrise;
};
_minSunrise = round(_minSunrise * 60);

// calculate sunset time
_calc2 = acos(_calc3 / _calc1 * -1);
_fTime = (_calc2 * 24) / 360 + 12;
_hourSunset = round(_fTime);
_minSunset = _fTime - _hourSunset;
if (_minSunset < 0) then
{
	_hourSunset = _hourSunset - 1;
	_minSunset = _fTime - _hourSunset;
};
_minSunset = round(_minSunset * 60);

_sunrise = ["Sunrise",_hourSunrise, _minSunrise];
_sunset = ["Sunset",_hourSunset, _minSunset];

 // if hours or minutes digit has 1 character, prepend a 0 in front for proper 24 hr formatting
 {
	private["_v", "_hour","_min"];
	_hour = _x select 1;
	_min = _x select 2;
	if (_hour < 10) then
	{
		_x set[1, format["0%1",_hour]];
	}
	else
	{
		_x set[1, format["%1",_hour]];
	};
	if (_min < 10) then
	{
		_x set[2, format["0%1",_min]];
	}
	else
	{
		_x set[2, format["%1",_min]];
	};
 } forEach [_sunrise, _sunset];

_worldStats = [["Sun Angle",_angle], ["Latitude",_lat], _sunrise, _sunset];
_worldStats
