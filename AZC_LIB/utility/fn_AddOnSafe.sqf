/* ----------------------------------------------------------------------------
Function: AZC_fnc_AddOnSafe
Author: AZCoder
Version: 2.0
Created: 08/24/2014 (original version 10/19/2010)
Dependencies: none
Description:
	Tests a given class name (or array of classes) to see if it exists in CfgPatches, CfgVehicles, CfgAmmo, or CfgWeapons. Beware of extra addons required, such as GLT_F16 requiring extended event handlers. There is no way to reliably test CfgPatches for specific addon information because addon authors do not consistently put the correct information in there. For example, requiredAddons is sometimes short of actual requirements, and even units and weapons do not necessarily list everything if anything at all.
	
Parameters:
	0 : _this
	    ARRAY
	    ARRAY of class names found in a mod, such as "RDS_Woodlander2" or "C_mas_cer_7_i"

Returns: true if all items in array are found, false if not.
Typically you will call this function for just one addon, because it will return false if ANY item in the array is not running.

Examples:
_exists = ["C_mas_cer_7_i"] call AZC_fnc_addOnSafe;	// returns true if C_mas_cer_7_i exists
_exists = ["RDS_Woodlander2","C_mas_cer_7_i"] call AZC_fnc_addOnSafe;  // returns true only if both classes exist
---------------------------------------------------------------------------- */
private ["_cfg","_exist","_array"];

_array = [];
{
	if ((count(configFile >> "CfgVehicles" >> _x) > 0) ||
		(count(configFile >> "CfgWeapons" >> _x) > 0) ||
		(count(configFile >> "CfgAmmo" >> _x) > 0) ||
		(count(configFile >> "CfgGlasses" >> _x) > 0) ||
		(count(configFile >> "CfgPatches" >> _x) > 0)) then
		{ 
			[_array, true] call BIS_fnc_arrayPush;
		};
} forEach _this;

// verify if # of found items matches # of parameters passed in
if ((count _array) == (count _this)) then
{
	_exist = true;
}
else
{
	_exist = false;
};
_exist
