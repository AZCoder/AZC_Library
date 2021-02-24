/* ----------------------------------------------------------------------------
Function: AZC_fnc_Invincible
Author: AZCoder
Version: 2.0
Created: 08/24/2014 (original version 10/18/2010)
Dependencies: none
Description:
	Makes given unit invincible to death. Its purpose is to simulate severe injuries without allowing a key AI to die during a mission.

NOTE #1: This script does NOT work if other "HandleDamage" eventHandlers are attached to the unit.
NOTE #2: setUnconscious has never worked in Arma 3 as of this writing
http://feedback.arma3.com/view.php?id=5513
NOTE #3: Earlier versions of this script would inflict up to 95% damage on a unit. However in A3, the unit can still heal himself despite disabling animations, and disabling simulation is not desirable because it looks out of place. Setting damage to 0 prevents medics from healing the injured unit (nothing to do). The happy medium I found is 20% damage. Too low to heal self, but a medic is able to do the job.
NOTE #4: Earlier versions used getVariable/setVariable for storing _unit related info, however this data gets badly out of sync after the handle_damage event is called multiple times in a row. Instead, dynamic global variables created with 'call compile' are used to store timing critical data.

Parameters:
	0 : _unit
	    OBJECT
	    Unit to keep alive; if it's human then it will simulate injury.

	1 : _recovery
	    NUMERIC (optional)
	    default: 60
	    Recovery time from severe injury in seconds.

Returns: nothing.
	
Examples:
	[Smith] spawn AZC_fnc_invincible; --> unit Smith will remain incapcitated for 60 seconds if mortally wounded.
---------------------------------------------------------------------------- */
private ["_unit","_recovery"];
_unit		= [_this, 0] call bis_fnc_param;
_recovery	= [_this, 1, 60] call bis_fnc_param;
if (_recovery < 1) then { _recovery = 1; };

// store variable with unique name in mission namespace
_unit setVariable["AZC_recoveryTime",_recovery];
// create dynamic global variable to hold damage for the given unit
call compile format ["%1_DMG = %2",_unit,(damage _unit)];
// injury count prevents the handler from spawning 5+ simultaneous animation spawns on same unit
call compile format ["%1_INJURY_COUNT = %2",_unit,0];

// max damage applied to unit in order to get the medics to work, but not self-healing
AZC_INVINCIBLE_MAXAPPLIED_DMG = 0.65;
// damage required before unit enters 'unconscious' state
AZC_INVINCIBLE_THRESHOLD_DMG = 0.90;
// amount of damage unit has after auto recovery
AZC_INVINCIBLE_AUTORECOVER_DMG = 0.5;

// verify unit is alive then add event handler
if (alive _unit) then
{
	_unit addEventHandler ["HandleDamage", {
		private ["_target","_hitDamage","_cumulativeDmg","_returnDmg","_recoveryTime","_isInjured","_message"];
		_target 	= _this select 0;
		_hitDamage 	= _this select 2;

		// number of times handler has been called
		_injuryCount = call compile format ["%1_INJURY_COUNT",_target];
		// amount of damage returned to game engine (should always be <= AZC_INVINCIBLE_MAXAPPLIED_DMG)
		_returnDmg = 0;
		
		_cumulativeDmg = call compile format ["%1_DMG",_target];
		if (_injuryCount < 1) then
		{
			_dmgTarget = (damage _target);
			// if stored damage is somehow less than actual damage, set it to the real level
			if (_cumulativeDmg < _dmgTarget) then { _cumulativeDmg = _dmgTarget; };
			// update stored damage for target unit
			_cumulativeDmg = _cumulativeDmg + _hitDamage;
			call compile format ["%1_DMG = %2",_target,_cumulativeDmg];
			[(format["%1: _cumulativeDmg = %2",_target,_cumulativeDmg]),true] call AZC_fnc_Debug;
		};
		
		// if damage is critical then increment _injuryCount
		if ((_cumulativeDmg >= (AZC_INVINCIBLE_THRESHOLD_DMG - 0.01)) && (_injuryCount < 1)) then
		{
			_injuryCount = call compile format ["%1_INJURY_COUNT",_target];
			_injuryCount = _injuryCount + 1;
			call compile format ["%1_INJURY_COUNT = %2",_target,_injuryCount];
			[(format["%1: _injuryCount = %2",_target,_injuryCount]),true] call AZC_fnc_Debug;

			// if alive & kind of man & _injuryCount = 1
			if ((_target isKindOf "Man") && (alive _target) && (_injuryCount == 1)) then
			{
				[_target] spawn
				{
					private["_target","_limit","_message","_items","_startDamage","_cumulativeDmg"];
					_target = _this select 0;
					_recoveryTime = _target getVariable "AZC_recoveryTime";
					
					// remove and save items on target (removing medkits prevents self-healing while "unconcious")
					_items = items _target;
					_itemListName = format["%1_AZC_ITEM_LIST",_target];
					_target setVariable [_itemListName,_items];
					{ _target removeItem _x } forEach _items;
					
					// AI should ignore this target
					_target setCaptive true;
					_target playAction "AgonyStart";
					_maxWait = time + 6;
					waitUntil
					{
						animationState _target == "ainjppnemstpsnonwnondnon" ||
						animationState _target == "unconscious" ||
						(time > _maxWait);
					};
					
					if ((animationState _target != "ainjppnemstpsnonwnondnon")
						&& (animationState _target != "unconscious")) then
					{
						_target switchMove "ainjppnemstpsnonwnondnon";
					}
					else
					{
						_target switchMove "ainjppnemstpsnonwnondnon";
					};
					_target disableAI "ANIM";
					_target disableAI "MOVE";
					_cumulativeDmg = call compile format ["%1_DMG",_target];
					_startDamage = _cumulativeDmg;
					_limit = time + _recoveryTime;

					while { (time < _limit) } do
					{
						sleep 1;
						// if damage goes down, exit loop
						_cumulativeDmg = call compile format ["%1_DMG",_target];
						if (_cumulativeDmg < _startDamage) then { _limit = 0; };
						_message = format["anim loop exit in %1 seconds, unit damage: %2, animState: %3",(_limit - time),_target,(animationState _target)];
						[_message,true] call AZC_fnc_Debug;
					};

					_message = format["%1: Targ %2 is recovered with %3 damage.",time,_target,(damage _target)];
					[_message,true] call AZC_fnc_Debug;

					_target enableAI "MOVE";
					_target enableAI "ANIM";
					_target playAction "AgonyStop";
					_target setCaptive false;
					//_target setUnconscious false;
					// restore saved items on target (medkits)
					_itemListName = format["%1_AZC_ITEM_LIST",_target];
					_target getVariable _itemListName;
					{ _target addItem _x } forEach _items;
					
					// if unit was healed by a medic, adjust _cumulativeDmg to reflect that
					if (damage _target < AZC_INVINCIBLE_MAXAPPLIED_DMG) then
					{
						call compile format ["%1_DMG = %2",_target,(damage _target)];
					};
					
					// if unit was not healed, make sure tracked damage is no higher than autorecover
					_cumulativeDmg = call compile format ["%1_DMG",_target];
					if (_cumulativeDmg > AZC_INVINCIBLE_AUTORECOVER_DMG) then
					{
						call compile format ["%1_DMG = %2",_target,AZC_INVINCIBLE_AUTORECOVER_DMG];
					};
					// set injury count back to 0 or injury anim cannot get called again
					call compile format ["%1_INJURY_COUNT = %2",_target,0];
				};
			};
		}
		else
		{
			_message = format["%1: %2 is injured, ignoring further hits.",time,_target];
			[_message,true] call AZC_fnc_Debug;
			// do not return damage below threshold
			0
		};
		
		_cumulativeDmg = call compile format ["%1_DMG",_target];
		if (_cumulativeDmg > AZC_INVINCIBLE_MAXAPPLIED_DMG) then
		{
			_returnDmg = AZC_INVINCIBLE_MAXAPPLIED_DMG;
		}
		else
		{
			_returnDmg = _cumulativeDmg;
		};
		// sync up damage done to target
		_target setDamage _returnDmg;
		_message = format["%1: Targ %2 is set with _returnDmg: %3.",time,_target,_returnDmg];
		[_message,true] call AZC_fnc_Debug;

		_returnDmg = 0.65;
		_returnDmg
	}];
	
	_unit addEventHandler ["HandleHeal", {
		(_this select 0) spawn
		{
			private ["_target","_startDmg"];
			_target = _this;
			_startDmg = damage _target;
			_cumulativeDmg = call compile format ["%1_DMG",_target];
			_wait = time + 5;
			_message = format["%3: Healing. Unit real damage: %1, stored damage: %2",_startDmg,_cumulativeDmg,time];
			[_message,true] call AZC_fnc_Debug;

			// note: using <= BECAUSE this event handler will be called once OR twice per heal
			// and I don't want to leave a spawn hanging if the damage was already set to 0 on the first try
			waitUntil { ((damage _target) <= _startDmg) && (time > _wait) };
			call compile format ["%1_DMG = %2",_target,(damage _target)];
			_message = format["%2: Target Healed. Unit real damage: %1",damage _target,time];
			[_message,true] call AZC_fnc_Debug;
		};
	}];
};
