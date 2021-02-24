if (isNil "AZC_Debug") then { AZC_Debug = false; };
private ["_leader","_targ","_firer","_nearUnits","_notifyGroups","_cmdr","_grp","_reveal","_modDistance","_hasCustomWeather"];

params["_targ","_firer"];

// group leader already reacted?
_leader = leader _targ;
_unitsLeader = units group _leader;

// expose this value for other functions to use it
_leader setVariable ["AZC_KNOWS_ABOUT",(_leader knowsAbout _firer)];
// systemChat format["Leader knows: %1 = %2",_leader,(_leader knowsAbout _firer)];
if (count _unitsLeader < 1) exitWith {};
if ((_unitsLeader select 0) knowsAbout _firer >= 2) then
{
	{ [_x] call AZC_fnc_RemoveReactHandlers; } forEach units group _leader;
};

// notify nearby friendlies in other groups
_notifyGroups = [];

{
	_grp = _x;
	_grpLeader = leader _grp;
	if ((_grp != group _firer) && (side _grpLeader == side _targ) && (_grpLeader distance _leader < 150)) then
	{
		_notifyGroups pushBack _grpLeader;
	};
} forEach allGroups;

// check if custom snow or dust storm in effect
_hasCustomWeather = missionNamespace getVariable "AZC_CUSTOM_WEATHER";
if (isNil "_hasCustomWeather") then { _hasCustomWeather = false; };

_modDistance = _firer distance _targ;
// determine environmental visibility
_modDistance = _modDistance + (3*((fog * 10)^2));
_modDistance = _modDistance + (1.5*((rain * 10)^2));

if (sunOrMoon == 0) then
{
	_modDistance = _modDistance + 200;
	_modDistance = _modDistance - (moonIntensity * 100);
};

if (_hasCustomWeather) then { _modDistance = _modDistance + 200; };
_reveal = 0;
if (_modDistance < 800) then { _reveal = 1; };
if (_modDistance < 600) then { _reveal = 2; };
if (_modDistance < 400) then { _reveal = 3; };
if (_modDistance < 200) then { _reveal = 4; };
// if (AZC_DEBUG) then
// { systemChat format["Actual range: %1, _modDistance: %2, reveal: %3",(_firer distance _targ),_modDistance,_reveal] };

{
	_grp = _x;
	if ( { alive _x } count units _grp > 0) then
	{
		_cmdr = leader _x;
		if ((_cmdr knowsAbout _firer) < _reveal) then
		{
			_cmdr reveal [_firer,_reveal];
			// systemChat format["%4: %1 reveal = %2 -- Firer: %3",_cmdr,_reveal,_firer,time];
		};
		_cmdr setBehaviour "COMBAT";
		_cmdr setCombatMode "RED";
	};
} forEach _notifyGroups;
