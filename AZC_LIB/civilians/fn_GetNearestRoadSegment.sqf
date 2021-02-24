params ["_object","_maxRadius"];
private["_segment","_roadsNearHouse"];
_segment = objNull;

_roadsNearObject = (getPos _object) nearRoads _maxRadius;
if (count _roadsNearObject > 0) then
{
	_segment = _roadsNearObject select 0;
	_range = _segment distance (getPos _object);

	{
		if (_x distance (getPos _object) < _range) then
		{
			_segment = _x;
			_range = _segment distance (getPos _object);
		};
	} forEach _roadsNearObject;
};
_segment