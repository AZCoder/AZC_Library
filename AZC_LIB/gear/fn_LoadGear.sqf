/* ----------------------------------------------------------------------------
Function: AZC_fnc_LoadGear
Author: AZCoder
Version: 1.0
Created: 09/11/2011
Description:
	Gets all gear that was previously saved by AZC_fnc_SaveGear. All gear is stored in
	the array AZC_GEAR_ARRAY and saved across missions.

Parameters:
	0 :
	    OBJECT
	    unit or vehicle OBJECT to load with previously saved gear

Returns: nothing.

Examples:
	speedboat call AZC_fnc_LoadGear;
---------------------------------------------------------------------------- */
private ["_object","_mags","_weaps","_gear","_pack","_weapItems","_handItems"];
if (typeName _this == "ARRAY") then
{
	_object = _this select 0;
}
else
{
	_object = _this;
};

_gear = [];
if (!(isNil "AZC_GEAR_ARRAY")) then
{
	_mags 		= AZC_GEAR_ARRAY select 0;
	_weaps 		= AZC_GEAR_ARRAY select 1;
	_pack 		= AZC_GEAR_ARRAY select 2;
	_weapItems 	= AZC_GEAR_ARRAY select 3;
	_handItems 	= AZC_GEAR_ARRAY select 4;

	{ _object addMagazineCargo [_x,1] } forEach _mags;
	{ _object addWeaponCargo [_x,1] } forEach _weaps;
	if (_pack != "") then { _object addBackpackCargo [_pack,1]; };
	{ if (_x != "") then { _object addItemCargo [_x,1]; } } forEach _weapItems;
	{ if (_x != "") then { _object addItemCargo [_x,1]; } } forEach _handItems;
};
