if (isNil "AZC_Debug") then { AZC_Debug = false; };

params["_unit","_range","_minPositions","_lastBuilding"];

if (_range < 1) then { _range = 30; };
_origPosition = _unit getVariable "AZC_APM_OriginalPosition";
_buildings = [_origPosition,_range,[]] call AZC_fnc_GetBuildings;
_closestBuilding = objNull;
_closestRange = 999999;

_usedBuildings = _unit getVariable "AZC_APM_UsedBuildings";
if (isNil "_usedBuildings") then { _usedBuildings = []; };

{
	_building = _x;
	_dist = _unit distance _building;
	if ((_dist < _closestRange) && !(_building in _usedBuildings)) then
	{
		_buildingPositions = _building getVariable "AZC_APM_BUILDING_POSITIONS";
		if (isNil "_buildingPositions") then
		{
			_buildingPositions = [_building] call BIS_fnc_buildingPositions;
		};

		if (count _buildingPositions >= _minPositions) then
		{
			_building setVariable ["AZC_APM_BUILDING_POSITIONS",_buildingPositions];
			_closestRange = _dist;
			_closestBuilding = _building;
		};
	};
} forEach _buildings;

//systemChat format["AZC_APM_BUILDING_POSITIONS: %1",count _buildingPositions];

if (!isNull _closestBuilding) then
{
	if (AZC_DEBUG) then
	{
		_z = format["blding%1", random(139030)];
		_pos = getPos _closestBuilding;
		_markerstr = createMarker [_z,[_pos select 0,_pos select 1]];
		_markerstr setMarkerShape "ICON";
		_markerstr setMarkerType "rhs_flag_VMF";
	};
}
else
{
	// if the _closestBuilding is null we end up here
	// reset the _usedBuildings list and use the first one in it (if there are any)
	if (count _usedBuildings > 0) then
	{
		_closestBuilding = _usedBuildings select 0;
		_usedBuildings = [];
		_unit setVariable ["AZC_APM_UsedBuildings",_usedBuildings];
	};
};

_closestBuilding