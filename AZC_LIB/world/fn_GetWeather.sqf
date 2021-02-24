/* ----------------------------------------------------------------------------
Function: AZC_fnc_GetWeather
Author: AZCoder
Version: 1.0
Created: 12/30/2012
Updated: 5/22/2015 for Arma 3, 7/3/2017 added temperatures
Dependencies: AZC_fnc_GetWorldStats, AZC_fnc_GetWeather (recursive call when radio trigger activated)
Description:
	Gets the current and projected weather forecast based on values for overcast, rain, time of year, and wind.
	The return result is a text description that can be directly output using whatever method you prefer (hint, bis_fnc_dynamicText, sideChat, etc).

Parameters:
	0 : _radio
	    BOOL or STRING (optional)
	    default: false
	    true - create a radio trigger set to India (0-0-9) for displaying the weather
	    false - returns the weather information (default)
	    radio name - (ALPHA,DELTA,INDIA,etc) this is equivalent to true and it specifies which radio to assign, or just
	    use true and INDIA will be assigned
	1 : _display
	    BOOL (optional)
	    default: false
	    true - immediately display weather in a hintSilent box
	    false - do not display weather automatically
	2 : _weatherOnly
	    BOOL (optional)
	    default: false
	    true - only return the weather information
	    false - includes sunrise/sunset/world info from AZC_fnc_getWorldStats
	3 : _temp
	    ARRAY of INT
	    default: []
	    min and max TEMPerature for the forecast

Returns: string text describing the weather.

Examples:
	[true] call AZC_fnc_GetWeather -> create a 0-0-9 radio trigger for calling this function by the player
	[false,true] call AZC_fnc_GetWeather -> displays the weather in hintSilent (no trigger)
	_result = [false,false,true] call AZC_fnc_GetWeather -> returns weather data only (not displayed, no trigger)
---------------------------------------------------------------------------- */
private ["_radio","_radioName","_display","_weatherOnly","_text","_direction","_force","_weather","_latitude","_longitude","_eastwest","_low","_high"];

_radio 			= [_this, 0, false, [false,"ALPHA"]] call bis_fnc_param;
_display 		= [_this, 1, false] call bis_fnc_param;
_weatherOnly 	= [_this, 2, false] call bis_fnc_param;
_temp			= [_this, 3, []] call bis_fnc_param;

_radioName = "INDIA";
_month = date select 1;
_day = date select 2;
_hour = date select 3;
_minute = date select 4;
if (_month < 10) then { _month = format["0%1",_month]; };
if (_day < 10) then { _day = format["0%1",_day]; };
if (_hour < 10) then { _hour = format["0%1",_hour]; };
if (_minute < 10) then { _minute = format["0%1",_minute]; };
_text = format["Date: %1.%2.%3 Time: %4:%5",(date select 0),_month,_day,_hour,_minute];
_weather = call AZC_fnc_getWorldStats;
_latitude = (_weather select 1) select 1;
_longitude = getNumber(configFile >> "CfgWorlds" >> worldName >> "longitude");
_eastwest = "east";
if (_longitude < 0) then
{
	_longitude = _longitude * -1;
	_eastwest = "west";
};
_text = _text + format["\nLocation is %1 degs %2 at %3 degs latitude.\n",_longitude,_eastwest,_latitude];

_low = 100;
_high = 100;

if (typeName _temp == "ARRAY" && count _temp > 1) then
{
	_low = _temp select 0;
	_high = _temp select 1;
	if (_low > _high) then { _low = _high; };
};

// calculate rain now and future
_ocForecast = overcastForecast;
_cloudy = "clear skies";
_rain = ".";
_rainsnow = "rain";
if ((_high < 1) || (_low < 1)) then { _rainsnow = "snow"; };
if (overcast > 0.2) then { _cloudy = "partly cloudy" };
if (overcast > 0.6) then { _cloudy = "cloudy" };
if (overcastForecast > 0.75 && rain < 0.2) then { _rain = format[" with chance of %1 later on.",_rainsnow] };
if (rain > 0.2) then { _rain = format[" and currently %1ing.",_rainsnow] };
_text = _text + format["\nCurrent conditions: %1%2\n",_cloudy,_rain];

if (!(_low == 100 && _high == 100)) then
{
	_text = _text + format["\n High Temp: %1 C, Low Temp: %2 C",_high,_low];
};

// calculate wind
// direction and force based on MadDog equations: http://forums.bistudio.com/showthread.php?132805-Formula-to-convert-quot-wind-quot-values-into-degree-%280-359%29&p=2124666&viewfull=1#post2124666

// force is m/sec according to BIS Dev
_force = sqrt((wind select 0)^2 + (wind select 1)^2) * 3.6; // 3.6 converts to km/hour
_direction = (wind select 0) atan2 (wind select 1);
if (_direction < 0) then { _direction = 360 + _direction };
if (_direction > 360) then { _direction = 360 - _direction };
// 90 = east, -90 = west, 0 = north, 180 = south --> directions tested with smoke on Moschnyi
_text = _text + format["\nWind is %1 km/hour at %2 degs.\n",round(_force),round(_direction)];

if (!_weatherOnly) then
{
	_sunrise = _weather select 2;
	_sunset = _weather select 3;
	_h1 = _sunrise select 1;
	_m1 = _sunrise select 2;
	_h2 = _sunset select 1;
	_m2 = _sunset select 2;
	_text = _text + format["\nSunrise at %1:%2, sunset at %3:%4.\n",_h1,_m1,_h2,_m2];
};

_text = parseText _text;
if (_display) then
{
	hintSilent format["%1",_text];
};

if (typeName _radio == "STRING") then
{
	_radioName = _radio;
	_radio = true;
};

if (_radio && !_display) then
{
	showRadio true;
	_trg=createTrigger["EmptyDetector",getPos player];
	_trg setTriggerArea[0,0,0,false];
	_trg setTriggerActivation[_radioName,"PRESENT",true];
	_trg setTriggerText "Weather Report";
	_format = format["_radio = [false,true,%1,%2] call AZC_fnc_GetWeather",_weatherOnly,_temp];
	_trg setTriggerStatements["this",_format,""];
	missionNamespace setVariable ["AZC_WEATHER_TRIGGER",_trg];
};
// return string
_text
