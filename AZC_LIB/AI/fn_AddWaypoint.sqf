/* ----------------------------------------------------------------------------
Function: AZC_fnc_AddWaypoint
Author: AZCoder
Version: 1.1
Created: 5/2/2010
Dependencies: AZC_fnc_getPos
Description:
	This is a simple waypoint function that adds a single waypoint to the provided object.  The object
	must be of a type that could normally receive a waypoint.
    
Parameters:
	0: _object
	    OBJECT
	    OBJECT (group or unit) to receive a waypoint
	1: _location
		POSITION, OBJECT OR MARKER
		LOCATION to place the waypoint
	2 : _type
		STRING
		default: "MOVE"
		TYPE of waypoint (move,sad,hold,etc)
	3 : _behavior
		STRING
		default: "AWARE"
		BEHAVIOR (safe,aware,combat,etc)
	4 : _speed
		STRING
		default: "NORMAL"
		SPEED MODE (limited, normal, full)
	5 : _combat
		STRING
		default: "NO CHANGE"
		COMBAT MODE (BLUE, GREEN, WHITE, YELLOW, RED)
	6 : _formation
		STRING
		default: "NO CHANGE"
		FORMATION ("COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND")
	7 : _timeout
		ARRAY of INT values
		= TIMEOUT at waypoint as an array of [min,mid,max], no timeout = default

Returns: waypoint

Examples:
	_wp1 = [AZC_MI8A,"mrkHeloEscape","MOVE","SAFE","NORMAL","BLUE"] call AZC_fnc_AddWaypoint;
---------------------------------------------------------------------------- */
private ["_object","_location","_type","_behavior","_speed","_grp","_combat","_formation","_timeout","_position"];

_combat 	= "NO CHANGE";
_formation 	= "NO CHANGE";
_timeout	= [];

_object		= [_this, 0] call bis_fnc_param;
_location	= [_this, 1] call bis_fnc_param;
_type		= [_this, 2, "MOVE"] call bis_fnc_param;
_behavior	= [_this, 3, "AWARE"] call bis_fnc_param;
_speed		= [_this, 4, "NORMAL"] call bis_fnc_param;
_combat		= [_this, 5, "NO CHANGE"] call bis_fnc_param;
_formation	= [_this, 6, "NO CHANGE"] call bis_fnc_param;
_timeout	= [_this, 7, []] call bis_fnc_param;

if (typeName _object == "GROUP") then
{
	_grp = _object;
}
else
{
	_grp = group _object;
};

if ((count units _grp < 1) ||
	( { alive _x } count units _grp == 0 )) exitWith { diag_log format["Group %1 has no units left to issue waypoints",_grp] };

_position = [_location] call AZC_fnc_getPos;
_wp = _grp addWaypoint [_position, 0];
_wp setWaypointBehaviour _behavior;
_wp setWaypointType _type;
_grp setSpeedMode _speed;
_wp setWaypointCombatMode _combat;
_wp setWaypointFormation _formation;
_wp showWaypoint "NEVER";
if (count _timeout == 3) then { _wp setWaypointTimeout _timeout; };
_wp
