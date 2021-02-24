/* ----------------------------------------------------------------------------
Function: AZC_fnc_Explosion
Author: AZCoder
Version: 3.0
Created: 9/21/2010
Updated: 5/22/2015 for Arma 3
Dependencies: AZC_fnc_GetPos
Description:
	Purpose is to set off 1 or more explosions (or smoke) for a given ammo type and position.

Parameters:
	0 : _target
	    STRING, ARRAY, OBJECT
	    marker, position, or object where explosion will occur
	1 : _shell
	    STRING
	    default: "B_30mm_HE"
	    Ammo Type (see list below)
	2 : _force
	    INT (optional)
	    default: 1
	    number of explosions to set off (1 to 10 max for performance reasons)
	3 : _damage
	    FLOAT (optional)
	    default: 0
	    damage to set to target object if param 0 is OBJECT (0.0 to 1.0)

Some possible ammo types (from cfgAmmo)
B_30mm_HE
Bo_GBU12_LGB
Bo_GBU12_LGB_MI10
Bo_Mk82
Bo_Mk82_MI08
Bomb_03_F
Bomb_04_F
Bomb_mas_03_F (Massi)
M_Air_AA
M_Air_AA_MI02
M_Air_AT
Missile_AA_03_F
Missile_AA_04_F
Missile_AGM_01_F
Missile_AGM_02_F
Rocket_03_HE_F
Rocket_04_HE_F
G_40mm_Smoke
Returns: nothing

Examples:
	[apc, "M_Air_AA", 2] call AZC_fnc_Explosion; -> object 'apc' with 2 AA missiles
	[AZC_CHARGE, "Bomb_04_F"] call AZC_fnc_Explosion;
	["ied"] call AZC_fnc_Explosion; --> marker "ied" with 1 B_30mm_HE shell
---------------------------------------------------------------------------- */

private ["_target","_force","_shell","_damage","_warhead","_holder","_bombLoc","_bombLocX","_bombLocY","_bombLocZ"];

_target 	= [_this,0,objNull,["marker",[0,0,0],player]] call bis_fnc_param;
_shell 		= [_this,1,"B_30mm_HE",["B_30mm_HE"]] call bis_fnc_param;
_force 		= [_this,2,1,[1]] call bis_fnc_param;
_damage		= [_this,3,0,[0]] call bis_fnc_param;

if (_force < 1 || _force > 10) then {_force = 1;};
_bombLoc = [_target] call AZC_fnc_GetPos;
_bombLocX = _bombLoc select 0;
_bombLocY = _bombLoc select 1;
_bombLocZ = (_bombLoc select 2);

// set damage level if passed in as a parameter
if (typeName _target == "OBJECT") then
{
	if (_damage > 0 && (_target isKindOf "LandVehicle") || (_target isKindOf "Air") || (_target isKindOf "Ship")) then
	{
		private["_dmg"];
		_dmg = getDammage _target;
		_dmg = _dmg + _damage;
		if (_dmg > 1) then { _dmg = 1; };
		_target setDamage _dmg;
	};
};

_warhead = createVehicle [_shell, _bombLoc, [], 0, "CAN_COLLIDE"];
_holder = createVehicle ["groundWeaponHolder", _bombLoc, [], 0, "CAN_COLLIDE"];
_warhead setPosATL (getPosATL _holder);

// create ring of bombs based on force level if _force > 1
// bombs are placed close together in a circular fashion, the more the merrier
if (_force > 1) then
{
	_angularSeparation = (360 / _force);
	for [{_i = 0}, {_i < _force}, {_i = _i + 1}] do
	{
		// if altitude above 20m then smash all warheads into target
		if (_bombLocZ > 20) then
		{
			_warhead = createVehicle [_shell,([_target] call AZC_fnc_getPos), [], 0, "CAN_COLLIDE"];
			_warhead setDamage 1;
		}
		else
		{
			_anglePlacement = _i * _angularSeparation;
			_bombLocX = (_bombLoc select 0) + (_force * sin _anglePlacement) + (_force * 2);
			_bombLocY = (_bombLoc select 1) + (_force * cos _anglePlacement) + (_force * 2);
			_bombLocZ = _bombLoc select 2;
			_warhead = createVehicle [_shell, [_bombLocX, _bombLocY, _bombLocZ], [], 0, "CAN_COLLIDE"];
			_warhead setDamage 1;
		};
	};
};
