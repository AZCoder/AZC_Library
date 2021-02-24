params ["_unit","_building"];
 private ["_completedWPs","_bpos","_loop","_index","_dist"];
_buildingPositions = _building getVariable "AZC_APM_BUILDING_POSITIONS";
_index = floor(random(count(_buildingPositions)));
_bpos = _buildingPositions select _index;
#define __IsAtBpos (_unit distance _bpos < 3.5)

// check unit distance from destination, if unit is "stuck" (not moving), and time limit based on distance
if (!(alive _unit)) exitWith {};
_unit setBehaviour "SAFE";
_unit limitSpeed 2;
_unit doMove _bpos;
_unit setVariable ["AZC_APM_DESTINATION_COMPLETED",false];
sleep 5;

if (!(alive _unit)) exitWith {};
_loop = 0;
while { !__IsAtBpos } do
{
	sleep 1;
	if ((speed _unit < 0.1) && (!__IsAtBpos)) then
	{
		_speed = 5;
		_dir = getDir _unit;
		_xv = sin _dir * _speed;
		_yv = cos _dir * _speed;
		_zv = 1;
		_unit setVelocity [_xv,_yv,_zv];
		_loop = _loop + 1;
	};
	if (_loop > 2) exitWith {};
};

if (!(alive _unit)) exitWith {};
_dist = _unit distance _bpos;
_completedWPs = (_unit getVariable "AZC_APM_CompletedWPs") + 1;
_unit setVariable ["AZC_APM_CompletedWPs",_completedWPs];
[(format["AZC_APM_DESTINATION_COMPLETED WPs: unit %1 = WPs %2",_unit,_completedWPs])] call AZC_fnc_Debug;

sleep 2;
if (!(alive _unit)) exitWith {};
_index = floor(random(2)) + 1;
_anim = format["InBaseMoves_patrolling%1",_index];
_unit disableAI "ANIM";
_unit switchMove _anim;

// wait at location
sleep (random(30)+10);
if (!(alive _unit)) exitWith {};
_unit enableAI "ANIM";
_unit switchMove "";
_unit setVariable ["AZC_APM_DESTINATION_COMPLETED",true];
