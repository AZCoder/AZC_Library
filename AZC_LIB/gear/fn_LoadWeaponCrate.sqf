/* ----------------------------------------------------------------------------
Function: AZC_fnc_LoadWeaponCrate
Author: AZCoder
Version: 1.0
Created: 10/3/2010
Modified: 8/3/2016 (ported to A3 and renamed)
Description:
	Takes an array of weapons and verifies if each exists in CfgWeapons. If true, then it adds
	the weapon to the given ammo box (or vehicle) with the quantity provided. Also automatically
	adds 10 magazines per weapon, per ammo type available for each muzzle associated with this weapon.

Note:
	This function is semi-obsolete since it is generally easier to modify weapon crates in the Eden editor now.
	However for a campaign it might be useful to recreate the same custom crate loadout multiple times.
	
Parameters:
	0 : _box
	    OBJECT
	    the object to add the weapons to, must be an ammo box or vehicle
	1 : [_weapon,_quantity]
	    ARRAY OF ARRAYS
	    An array containing subarrays of [_weapon,_quantity] (see example below)

Returns: nothing.

Example:
	_arrayGuns = [["rhs_weap_ak74m_2mag_camo",3],["rhs_weap_ak74m_desert",1],["rhs_weap_svds",2]];
	[ammoBox, _arrayGuns] call AZC_fnc_LoadWeaponCrate;  --> loads "ammoBox" with array of weapons list above
---------------------------------------------------------------------------- */

private ["_box","_arrayGuns","_cfg"];

_box 		= [_this, 0] call bis_fnc_param;
_arrayGuns	= [_this, 1] call bis_fnc_param;

{
	private["_gun","_quantity","_cfg","_mags","_base","_className","_loaded","_total","_pos","_magArray","_add","_magazine"];
	_gun 		= _x select 0;
	_quantity	= _x select 1;
	_cfg		= configFile >> "CfgWeapons" >> _gun;
	_mags		= [];
	
	// verify weapon exists (if count > 0) then add weapon and magazines to _box
	if (count _cfg > 0) then
	{
		_muzzles = getArray (_cfg >> "muzzles");
		
		{
			if (toLower(_x) != "this" && toLower(_x) != "safe") then
			{
				_className = "";
				_base = _cfg;
				while { (_className != _x) && (count _base > 0) } do
				{
					for [{_i=1},{_i< (count _base)},{_i=_i+1}] do
					{
						if (isClass(_base select _i)) then
						{
							_className = configName(_base select _i);
							if (_className == _x) exitWith 
							{
								_mags = getArray (_base >> _className >> "magazines");
							};
						};
					};
					_base = inheritsFrom (_base);
				};
			}
			else
			{
				if (toLower(_x) == "this") then { _mags = getArray (_cfg >> "magazines"); };
			};

			{
				_magazine = tolower(_x);
				_add = 0;
				_loaded = getMagazineCargo _box;
				_magArray = _loaded select 0; // select first array of mag names
				for "_i" from 0 to (count _magArray - 1) do
				{
					_mag = _magArray select _i;
					_magArray set[_i,(toLower(_mag))];
				};

				// count does case-INsenstive compare
				if ({ _x == _magazine} count _magArray > 0) then
				{
					_pos = _magArray find _magazine;
					_total = (_loaded select 1) select _pos;
					_add = (10 * _quantity) - _total;
					if (_add < 0) then { _add = 0 };
					_box addMagazineCargo [_magazine,_add];
				}
				else
				{
					_box addMagazineCargo [_x,(10 * _quantity)];
				};
			} forEach _mags;
		} forEach _muzzles;
		_box addWeaponCargo [_gun,_quantity];
	};
} forEach _arrayGuns;
