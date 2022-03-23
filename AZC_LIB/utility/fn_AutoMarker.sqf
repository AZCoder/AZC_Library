/* ----------------------------------------------------------------------------
Function: AZC_fnc_AutoMarker
Author: AZCoder
Version: 1.0
Created: 12/16/2012
Description:
	Creates and attaches a marker to an in-game object so that it can be tracked on the map. Sets
	marker type by what side the object is (west/east/resistance).

Parameters:
	0 : _target
	    OBJECT
	    target OBJECT for attaching the marker
	1 : _text
	    STRING (optional)
	    default: ""
	    marker TEXT
	2 : _terminate
	    BOOL (optional)
	    default: false
	    TERMINATE marker
	3 : _updateTime
	    INT (optional)
	    default: 3
	    how often to UPDATE the marker on the map in seconds

Returns: the marker

Examples:
	// add marker with 5 sec refresh
	[AZC_Squad,"Bravo Squad",false,5] call AZC_fnc_AutoMarker;
	// terminate marker
	[AZC_Squad,"",true] call AZC_fnc_AutoMarker;
---------------------------------------------------------------------------- */
params ["_target",["_text",""],["_terminate",false],["_updateTime",3]];
private["_marker","_markerList","_markerIndex","_markerIndexName"];

// track if the target already has a marker, if so then don't recreate it
_marker = _target getVariable "AZC_MARKER";
// always remove marker if target destroyed
if (damage _target > 0.99) then { _terminate = true };
_target setVariable["AZC_TERMINATE",_terminate];

if (isNil "_marker") then
{
	if (!isNil "AZC_LAST_TARG") then
	{
		if (_target == AZC_LAST_TARG) exitWith {};
	};
	_markerList = missionNamespace getVariable "AZC_MARKER_LIST";
	if (isNil "_markerList") then { _markerList = []; };
	_markerIndex = count _markerList;
	_markerIndexName = format["AZC_MARKER_%1",_markerIndex];
	_markerList set [_markerIndex, _markerIndexName];
	missionNamespace setVariable[ "AZC_MARKER_LIST",_markerList];

	_marker = createMarker [_markerIndexName, position _target];
	_marker setMarkerShape "ICON";
	_markerIndexName setMarkerType "c_unknown";

	if (side _target == east) then { _markerIndexName setMarkerType "o_inf" };
	if (side _target == west) then { _markerIndexName setMarkerType "b_inf" };
	if (side _target == resistance) then { _markerIndexName setMarkerType "n_inf" };
	_markerIndexName setMarkerText _text;
	_target setVariable["AZC_MARKER",_marker];

	[_markerIndexName,_target,_updateTime] spawn
	{
		private["_markerName","_target","_updateTime","_term"];
		_markerName 		= _this select 0;
		_target 			= _this select 1;
		_updateTime			= _this select 2;
		_term = false;
		while { !_term } do
		{
			_term = _target getVariable "AZC_TERMINATE";
			_markerName setMarkerPos [(getPos _target select 0),(getPos _target select 1)];
			sleep _updateTime;
			if (isNil "_term") then { _term = false; };
			if (isNull _target) then { _term = true; };
		};
		deleteMarker _markerName;
		_target setVariable["AZC_MARKER",nil]; // in case we need to create this marker again
	};
};

AZC_LAST_TARG = _target;
// return marker object in case caller wants it
_marker
