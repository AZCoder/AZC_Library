/* ----------------------------------------------------------------------------
Function: AZC_fnc_SpawnMissile
Author: AZCoder
Version: 1.0
Created: 1/16/2011
Converted to A3: 8/21/2016
Description:
	Spawns a missile in the air and flies it to a target.
	This script is derived from "launchMissile.sqf" in Harvest Red's C1_IntoTheStorm mission. After using derivations numerous times, decided to put this into a formal function for ease of use.

Parameters:
	0 : _launcher
	    OBJECT, MARKER, or POSITION
	    Object, marker, or position to launch the missile
	1 : _primaryTarget
	    OBJECT
	    Object only, numerous calculations made against object type therefore type object is required
	2 : _missileType
	    STRING
	    missile class name to fire
	3 : _destroyTarget
	    BOOL (optional)
	    default: true
	    if true, setDamage 1 is applied to target after impact, otherwise it's left up to chance
	4 : _missileSpeed
	    NUMERIC (optional)
	    default: 220
	    value in m/sec, recommend to leave alone unless impact is glitchy
	5 : _launchSeparation
	    NUMERIC (optional)
	    default: 5
	    z-axis separation of missile launch from source, sometimes missile will explode with default value

Returns: nothing.

Note:
	Due to various complications with simulating missile flight, a missile will be spawned 30 meters above the _launcher and 30m
	in front *unless* a position array is given. This helps reduce the chance of the launcher exploding.

A few valid types:
M_Air_AA
M_Air_AA_MI02
M_Air_AT
Missile_AA_03_F
Missile_AA_04_F
Missile_AGM_01_F
Missile_AGM_02_F
ammo_Missile_Cruise_01 - regular cruise missile
ammo_Missile_Cruise_01_Cluster - cruise missile with cluster droplets, very impressive to watch

Examples:
	[samDude,enemyHelo,"Missile_AA_04_F",false,200,12] spawn AZC_fnc_SpawnMissile;

---------------------------------------------------------------------------- */
private ["_destroyTarget","_launcher","_velocityX", "_velocityY", "_velocityZ", "_target","_missileSpeed","_primaryTarget","_missileStart","_missileType"];

_launcher			= [_this, 0] call bis_fnc_param;
_primaryTarget		= [_this, 1] call bis_fnc_param;
_missileType		= [_this, 2] call bis_fnc_param;
_destroyTarget		= [_this, 3, true, [true]] call bis_fnc_param;
_missileSpeed		= [_this, 4, 220, [0]] call bis_fnc_param;
_launchSeparation	= [_this, 5, 5] call bis_fnc_param;

_missileStart = [_launcher,1] call AZC_fnc_getPos;
_xm = _missileStart select 0;
_ym = (_missileStart select 1) - 5;
_missileStart = [_xm,_ym,_launchSeparation]; // this won't work over land unless at sea level !!

// accelerated time causes the missile to miss endlessly
[_primaryTarget] spawn
{
	_primaryTarget = _this select 0;
	while { alive _primaryTarget } do
	{
		if (accTime > 1) then { setAccTime 1; };
		sleep 0.5;
	};
};

_perSecondChecks = 25; //direction checks per second
_getPrimaryTarget = 
{ 
	if (typeName _primaryTarget == typename {}) then
	{
		call _primaryTarget;
	}
	else { _primaryTarget }
};
_target = call _getPrimaryTarget;

_missile = _missileType createVehicle _missileStart;
if (surfaceIsWater (getPos _missile)) then
{
	_missile setPosASL [(_missileStart select 0),(_missileStart select 1),(_missileStart select 2)];
}
else
{
	_missile setPosATL [(_missileStart select 0),(_missileStart select 1),(_missileStart select 2)];
};

_minDistance = _missileSpeed * 0.5;
// expose missile externally so that caller can react to missile being created and/or destroyed
AZC_MISSILE_X = _missile;

//procedure for guiding the missile
_homeMissile = 
{
	//altering the direction, pitch and trajectory of the missile
	//if (_missile distance _target > (_missileSpeed / 10)) then
	if (_missile distance _target > _minDistance) then
	{
		_travelTime = (_target distance _missile) / _missileSpeed;
		_steps = floor (_travelTime * _perSecondChecks);

		_relDirHor = [_missile, _target] call BIS_fnc_DirTo;
		_missile setDir _relDirHor;

		_relDirVer = asin ((((getPosASL _missile) select 2) - ((getPosASL _target) select 2)) / (_target distance _missile));
		_relDirVer = (_relDirVer * -1);
		[_missile, _relDirVer, 0] call BIS_fnc_setPitchBank;

		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _missile) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _missile) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _missile) select 2)) / _travelTime;
	}
	else
	{
		_missile setDamage 1;
		// deleteVehicle _missile;
	};

	[_velocityX, _velocityY, _velocityZ]
};

call _homeMissile;

//fuel burning should illuminate the landscape
_fireLight = "#lightpoint" createVehicle position _missile;
_fireLight setLightBrightness 0.9;
_fireLight setLightAmbient [1.0, 0.7, 0.7];
_fireLight setLightColor [1.0, 0.7, 0.7];
_fireLight lightAttachObject [_missile, [0, -0.5, 0]];

//missile flying
while {alive _missile} do 
{
	_velocityForCheck = call _homeMissile;
	if ({(typeName _x) == (typeName 0)} count _velocityForCheck == 3) then {_missile setVelocity _velocityForCheck};
	sleep (1 / _perSecondChecks);
};

deleteVehicle _fireLight;
if (_destroyTarget) then
{
	waitUntil { !alive _missile };
	_primaryTarget setDamage 1;
};
