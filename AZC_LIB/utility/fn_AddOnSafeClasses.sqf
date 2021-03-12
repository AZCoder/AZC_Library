/* ----------------------------------------------------------------------------
Function: AZC_fnc_AddOnSafeClasses
Author: AZCoder
Version: 1.0
Created: 11/08/2015
Dependencies: none
Description:
	Tests a given a array of classes to see if they are active on the client, returning only those that
	test true. In this way, you could pass in a list of classes from RDS, MAS, and RHS related mods and
	this function will return only what the user has running (such as only RHS).
	
	For example of its use, see AZC_fnc_AmbientCivilian which uses it to filter out potentially non-existent classes before spawning a civilian.
	
Parameters:
	0: _array
	    ARRAY
	    array of class names found in a mod, such as "RH_masacog" or "C_mas_cer_7_i"

Returns: true if all items in array are found, false if not. Typically you will call this function for just one addon, because it will return false if ANY item in the array is not running.

Examples:
_safeList = ["RDS_Woodlander2","C_mas_cer_7_i"] call AZC_fnc_AddOnSafeClasses;
// if user/client is running RDS mod but not the MAS Chernarus mod, then _safeList will equal ["RDS_Woodlander2"] 
	
---------------------------------------------------------------------------- */
private ["_array","_class"];
_array = [];

{
	_class = _x;
	if ((count(configFile >> "CfgVehicles" >> _x) > 0) ||
		(count(configFile >> "CfgWeapons" >> _x) > 0) ||
		(count(configFile >> "CfgAmmo" >> _x) > 0) ||
		(count(configFile >> "CfgGlasses" >> _x) > 0) ||
		(count(configFile >> "CfgPatches" >> _x) > 0)) then
		{ 
			_array pushBack _class;
		};
} forEach _this;

_array
