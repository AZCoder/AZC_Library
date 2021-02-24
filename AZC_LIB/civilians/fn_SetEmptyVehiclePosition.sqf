params ["_vehicle","_house"];
private["_size","_tooCloseToHouse","_vehPos","_isInside","_isOnRoad","_roadsNearHouse","_roadConnectedTo"];
_size = sizeOf typeOf _vehicle;
_tooCloseToHouse = (_vehicle distance _house) < (_size + 8);
_vehPos = getPos _vehicle;
_isInside = _vehicle call AZC_fnc_InsideBuilding;

if (_isInside || _tooCloseToHouse) then
{
	_vehPos = [_vehicle,_house] call AZC_fnc_SetVehicleOnRoad;
};

if (isOnRoad _vehicle) then
{
	// this will set the vehicle direction
	_vehPos = [_vehicle,_house] call AZC_fnc_SetVehicleOnRoad;
	
	// next move vehicle as close to house object as possible while remaining on the road
	_segment = [_vehicle,3] call AZC_fnc_GetNearestRoadSegment;
	if (isNull _segment) exitWith { _vehPos };
	_houseDir = [_segment,_house] call BIS_fnc_DirTo;
	
	// move vehicle to edge of road
	_isOnRoad = true;
	_lastPos = getPos _vehicle;
	while { _isonroad && (_vehicle distance _house > _size) } do
	{
		_dirToMove = _houseDir;
		if (_dirToMove > 360) then { _dirToMove = _dirToMove - 180; };
		_xd = (sin _dirToMove) * _size * .05;
		_yd = (cos _dirToMove) * _size * .05;
		_lastPos = getPos _vehicle;
		_vehicle setPos [(_lastPos select 0) + _xd,(_lastPos select 1) + _yd,0];
		_isOnRoad = isOnRoad _vehicle;
	};
	// now that vehicle is off the road, move it back to the last road position
	_vehPos = _lastPos;
};

// if still considered "inside" a buildling, return empty position for removal
if (_vehicle call AZC_fnc_InsideBuilding) then { _vehPos = []; };
_vehPos
