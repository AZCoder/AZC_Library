/* ----------------------------------------------------------------------------
Function: AZC_fnc_Delete
Author: AZCoder
Version: 2.1
Created: 10/25/2015
Dependencies: AZC_fnc_Delete (this function must be able to call itself with this name)
Description:
	Deletes objects, markers, groups provided as a parameter (single or array). Removes crew in the case of vehicles in addition to the vehicles.
	
Parameters:
	0 : _objArray
	    Array
	    an ARRAY of types object, marker, group, or array of objects/groups to delete (see examples)
	1 : _distance
	    INT (optional)
	    default: 0
	    DISTANCE from player before deleting, use 0 to ignore distance
	2 : _wait
	    INT (optional)
	    default: 0
	    seconds to WAIT before deleting
	3 : _destination
	    ARRAY of [MARKER, min distance] (optional)
	    default: []
	    ARRAY containing a marker where object must be before deleting and the minimum distance to the marker, the first element of array MUST be a marker

Returns: nothing.

Examples:
	// the following would delete an object named helo1, a group of tanks, and a marker
	// once the player is 500m or greater in distance, and a minimum of 10 seconds has passed
	[[helo1,grpTank,"mrkSpawnPoint"],500,10] spawn AZC_fnc_Delete;
	// delete someVehicle when it's within 50m of mrkEndPoint AND player is 200+ meters from it
	[[someVehicle],200,0,["mrkEndPoint",50]] spawn AZC_fnc_Delete;
---------------------------------------------------------------------------- */
_objArray 		= [_this, 0] call bis_fnc_param;
_distance		= [_this, 1, 0] call bis_fnc_param;
_wait			= [_this, 2, 0] call bis_fnc_param;
_destination	= [_this, 3, []] call bis_fnc_param;

// need to determine if array of objects/groups was passed, or just a single item
private _object = _objArray;
if (typeName _objArray == "ARRAY") then
{
	if (count _objArray == 1) then
	{
		_object = _objArray select 0;
	};
};

if (typeName _destination != "ARRAY") then { _destination = []; };

switch (typeName _object) do
{
	case "STRING": 	{
				[_object,_distance,_wait,_destination] spawn
				{
					params ["_object","_distance","_wait","_destination"];

					if (count _destination == 2) then
					{
						_targLoc = _destination select 0;
						_targDist = _destination select 1;
						waitUntil { _object distance (getMarkerPos _targLoc) < _targDist };
					};
					
					waitUntil { (player distance getMarkerPos _object) > _distance };
					sleep _wait;
					deleteMarker (_this select 0);
				};
			};

	case "OBJECT": 	{
				[_object,_distance,_wait,_destination] spawn
				{
					params ["_object","_distance","_wait","_destination"];

					if (count _destination == 2) then
					{
						_targLoc = _destination select 0;
						_targDist = _destination select 1;
						waitUntil { _object distance (getMarkerPos _targLoc) < _targDist };
					};
					
					waitUntil { (player distance getPos _object) > _distance };
					sleep _wait;
					{ _object deleteVehicleCrew _x; } forEach crew _object;
					deleteVehicle _object;
				};
			};

	case "GROUP":	{
				[_object,_distance,_wait,_destination] spawn
				{
					params ["_object","_distance","_wait","_destination"];

					private _leader = leader _object;
					if (count _destination == 2) then
					{
						_targLoc = _destination select 0;
						_targDist = _destination select 1;
						waitUntil { _leader distance (getMarkerPos _targLoc) < _targDist };
					};
					
					waitUntil { (player distance getPos _leader) > (_this select 1) };
					sleep _wait;
					
					{
						deleteVehicle (vehicle _x);
						deleteVehicle _x;
					} forEach units _object;
					deleteGroup _object;
				};
			};

	case "ARRAY":	{
				// recursive call if array passed as parameter for _objArray
				{ [[_x],_distance,_wait,_destination] call AZC_fnc_Delete; } forEach _object;
			};
};
