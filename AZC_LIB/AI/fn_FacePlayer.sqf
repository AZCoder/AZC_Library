params ["_unit","_minDistance"];
if (isNull _unit) exitWith {};
while { alive _unit } do
{
	waitUntil { (_unit knowsAbout player > 2) && (player distance _unit < _minDistance) };
	// waitUntil { sleep 1; [_unit,player] call AZC_fnc_HasLOS };
	_dir = [_unit,player] call BIS_fnc_DirTo;
	_unit setDir _dir;
	_unit setFormDir _dir;
	sleep 5;
};
