/* ----------------------------------------------------------------------------
Function: AZC_fnc_Replacer
Author: AZCoder
Version: 1.0
Dependencies: AZC_fnc_DoReplace
Created: 2020/03/07
Description:

This function replaces vehicles (not AI) with optional mod replacement classes.
For example, you build a mission with an RHS MiG-29 but want to substitute the MiG-29
with an Su-35 for players running an optional Su-35 mod, this will do it!

Why write this at all?
Dark Tides has a good sized mod list as it stands. I wanted to have more mods, but realize
many players will say "why do we need this mod just for a few fancy cars that I won't drive?"
This function makes it so that the player can just ignore the fancy cars or optional jet mods
and just go with the minimal requirements. For those like myself that want the full immersion,
this function allows for it. I admit it's a bit of a pain to setup. You must get the class names
(easy to do by howevering over the desired object in eden with your text editor in focus). Also
it is highly recommended to do the replacements at the very start of the mission. I did handle
cases of vehicles moving and it seems to work alright. It handles water or land or air. Be careful
that the replacement vehicle has another seating positions to match up with the original if there are
passengers aboard. It simply moves the same people to the new vehicle.

You may either match on a specific vehicle name, or replace all by class name.

1) match by vehicle class (replace all A with B)
2) match by vehicle "name" only, such as AZC_CAR1, and replace with specific class

WARNING: if you replace a vehicle by "name", you will not be able to refer to the replacement by that name again.
However the function does return the new object.

Parameters:
0 : _original
	STRING or OBJECT NAME
	String class name to replace, or Object name to replace a particular vehicle
1 : _replacement
	STRING
	Replacement class name

Returns: vehicle object

Examples:
-- replace all matching rhs_mig29s_vvsc with pook_Mig23_OPFOR
["rhs_mig29s_vvsc","pook_Mig23_OPFOR"] call AZC_fnc_Replacer;
-- replace object named AZC_VIKTOR_CAR with a d3s_escalade_16_pt class and return object back to itself
AZC_VIKTOR_CAR = [AZC_VIKTOR_CAR,"d3s_escalade_16_pt"] call AZC_fnc_Replacer;
*/

params ["_original","_replacement"];

// if _isClassReplace == true then treat _original as a class name and replace ALL of them in mission
// if false then treat _original as object name and replace that one instance

// if _original is an object name, this test will return 0, otherwise treat it as a class name
_originalName = _original;
if (typeName _original == "OBJECT") then { _originalName = str _original; };
_test = configFile >> "CfgVehicles" >> _originalName;
// test if original and replacement classes exist (this is key to having optional mods)
if ((typeName _original != "OBJECT") && !([_originalName] call AZC_fnc_addOnSafe)) exitWith { objNull };
if (!([_replacement] call AZC_fnc_addOnSafe)) exitWith { _original };
private["_newVeh"];
_newVeh = objNull;

if (count _test > 0) then
{
	// find all vehicles of the provided CLASS name on the map and replace them
	vehicles apply
	{
		// if vehicle is driveable
		if (getNumber (configfile >> "CfgVehicles" >> typeof _x >> "hasDriver") == 1) then
		{
			_unit = vehicle _x;
			_type = typeOf _unit;
			if (_type isEqualTo _original) then
			{
				_newVeh = [_unit,_replacement] call AZC_fnc_DoReplace;
			};
		};
	};
}
else
{
	if (typeName _original == "OBJECT") then
	{
		_newVeh = [(vehicle _original),_replacement,(str _original)] call AZC_fnc_DoReplace;
	}
	else
	{
		_newVeh = objNull;
	};
};

_newVeh