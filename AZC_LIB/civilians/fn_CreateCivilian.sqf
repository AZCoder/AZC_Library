/* ----------------------------------------------------------------------------
Function: AZC_fnc_CreateCivilian
Author: AZCoder
Version: 1.0
Created: 10/18/2015
Dependencies: AZC_fnc_CreateUnit, AZC_fnc_AddOnSafeClasses, AZC_fnc_AddWaypoint, AZC_fnc_GetRelativeEyeDirection, AZC_fnc_HasLOS
Description:
	Creates a random civilian unit and assigns a waypoint. Attempts to spawn at buildings.
	
Parameters:
	0 : _center
	    OBJ or ARRAY
	    center position for spawning, can be an object or position array
	1 : _range
	    INT (optional)
	    default: 1000
	    max RANGE in meters to spawn civilian from center (minimum 50)
	2 : _blackList
	    ARRAY (optional)
	    default: []
	    list of unit classes from which to NEVER spawn (blacklist)
	3 : _whiteList
	    ARRAY (optional)
	    default: []
	    list of unit classes from which to ONLY spawn (blacklist ignored if used)
	4 : _housesInRange
	    ARRAY (optional)
	    default: []
	    list of houses available for spawning, provided by ACM to due to cost of calculation
	
NOTES:
	To disable the manager (and spawning) at any time, do this:
	missionNamespace setVariable ["AZC_AmbientManagerActive",false];
	Difference between white and black lists: Use blacklist if you have a certain set of units
	that you don't want to appear. The drawback is that you can't control what addons a player
	may be using. The whitelist will only spawn units from that list. Its only drawback is that
	you have to provide a list of all possible classes. If both lists are provided, the blacklist
	will be ignored. Use utility/fnc_ExtractClasses for help creating either list.
	
	Also note that by using the whitelist, you could potentially pass in all sorts of non-civilian
	units and objects. As long as they can be given waypoints, it should work.

	Civilians will only spawn when location is > 30m from the player at moment of creation,
	and as long as the player is not looking in the direction of spawning when under 300m.
	
Returns: civilian unit

Examples:
	_civ = [town] call AZC_fnc_CreateCivilian;
---------------------------------------------------------------------------- */
if (isNil "AZC_Debug") then { AZC_Debug = false; };

private ["_classlistCivs","_civClass","_blackList","_whiteList"];
_center			= [_this, 0] call bis_fnc_param;
_range 			= [_this, 1, 1000, [0]] call bis_fnc_param;
_blackList		= [_this, 2, []] call bis_fnc_param;
_whiteList		= [_this, 3, []] call bis_fnc_param;
_housesInRange		= [_this, 4, []] call bis_fnc_param;

if (typeName _center == "OBJECT") then
{
	_center = getPos _center;
};

// check if minimal _range violated
if (_range < 50) then { _range = 50; };
if (!("C_Soldier_VR_F" in _blackList)) then { _blackList pushBack "C_Soldier_VR_F"; };

if (count(_whiteList) < 1) then
{
	_classlistCivs = [true,_blackList] call AZC_fnc_GenerateCivilianList;
}
else
{
	_classlistCivs = _whiteList;
};

// ensure only valid classes exist
_classlistCivs = _classlistCivs call AZC_fnc_AddOnSafeClasses;

private ["_civClassIndex","_civ","_civClass","_dir","_house","_targetHouse","_houses","_posLoc","_minTime","_midTime","_maxTime","_maxWaypoints","_index","_buildingPositions","_eyeDir","_hasLos"];
_civ = objNull;

// get origin buildings
if (count _housesInRange < 1) then
{
	_housesInRange = [_center,_range,_blacklist] call AZC_fnc_GetBuildings;
};

_usedHouses = missionNamespace getVariable "AZC_UsedCivHouses";
if (isNil "_usedHouses") then { _usedHouses = []; };
_houses = _housesInRange - _usedHouses;
//systemChat format["Houses: %1",count(_houses)];
if (count(_houses) > 0) then
{
	_index = floor random(count(_houses));
	_house = _houses select _index;
	_pos = getPos _house;
	_dir = floor random(360);
	
	// does house have positions?
	_buildingPositions = [_house] call BIS_fnc_buildingPositions;
	if (count _buildingPositions > 0) then
	{
		_index = floor random(count _buildingPositions);
		_pos = _buildingPositions select _index;
	};
	
	// set civ class
	_civClassIndex = floor(random(count(_classlistCivs)));
	_civClass = _classlistCivs select _civClassIndex;

	_civ = [_civClass,_pos,civilian,false,_dir,0,"NONE",[],false,0,true] call AZC_fnc_CreateUnit;

	_civ setskill 0;
	// only spawn if not in front of player's face
	_eyeDir = [player,_civ] call AZC_fnc_GetRelativeEyeDirection;
	_hasLos = [player,_civ] call AZC_fnc_HasLOS;
	if ((player distance _civ < 300) && (_hasLos && (_eyeDir < 55))) exitWith
	{
		[_civ] spawn AZC_fnc_Delete;
		_civ = objNull;
	};
	_civ hideObject false;
	_civ setDir _dir;
	_civ forceWalk true;
	_civ setBehaviour "SAFE";
		
	// store used house
	_usedHouses pushBack _house;
	missionNamespace setVariable ["AZC_UsedCivHouses", _usedHouses];
}
else
{
	[(format ["%1: Ran out of houses to spawn civilians.",time])] call AZC_fnc_Debug;
};

if (isNil "_civ") then { _civ = objNull; };
if (!(isNull _civ)) then
{
	if (AZC_Debug) then { [_civ,name _civ] call AZC_fnc_AutoMarker; };
	[_civ,_housesInRange] spawn AZC_fnc_Panic;

	// _civ addEventHandler ["Killed", {
		// _civ = _this select 0;
		// _civ removeAllEventHandlers "Killed";
	// }];
};
// return civilian
_civ
