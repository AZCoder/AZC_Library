// AZC_fnc_SetVehicleOnRoad
params ["_vehicle","_house"];
_vehPos = getPos _vehicle;

_roadsNearHouse = (position _house) nearRoads 30;
if (count _roadsNearHouse > 0) then
{
	// find nearest segment
	_segment = [_house,30] call AZC_fnc_GetNearestRoadSegment;
	if (isNull _segment) exitWith { _vehPos };
	_roadPos = getPos _segment;
	
	// find connected segments to determine direction
	_roadConnectedTo = roadsConnectedTo _segment;
	if (count(_roadConnectedTo) < 2) exitWith { _vehicle setDir (getDir _house); _vehPos };
	
	_connectedRoad = _roadConnectedTo select 1;
	_roadDir = [_segment,_connectedRoad] call BIS_fnc_DirTo;
	_vehicle setPos _roadPos;
	_vehicle setDir _roadDir;
	_vehPos = getPos _vehicle;
};

// if somehow vehicle is in a building, then set position to empty for removal (it happens on Taunus)
if (_vehicle call AZC_fnc_InsideBuilding) then { _vehPos = []; };
_vehPos