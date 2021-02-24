/* ----------------------------------------------------------------------------
Function: AZC_fnc_SaveGear
Author: AZCoder
Version: 1.0
Created: 09/11/2016
Description:
	Saves all items, magazines, and weapons for a given "human" unit (not vehicles or boxes).
	For use with campaigns.

Parameters:
	0 : _this
	    OBJECT
	    unit object with gear to save

Returns: nothing.

Examples:
	player call AZC_fnc_SaveGear;
---------------------------------------------------------------------------- */
private ["_unit","_mags","_weaps","_gear","_pack","_weapItems","_handItems"];
if (typeName _this == "ARRAY") then
{
	_unit = _this select 0;
}
else
{
	_unit = _this;
};

AZC_GEAR_ARRAY = [];

_mags = magazines _unit;
_weaps = weapons _unit;
_pack = backpack _unit;
_weapItems = primaryWeaponItems _unit;
_handItems = handgunItems _unit;
_mags pushBack (secondaryWeaponMagazine _unit);
AZC_GEAR_ARRAY = [_mags,_weaps,_pack,_weapItems,_handItems];
saveVar "AZC_GEAR_ARRAY";
