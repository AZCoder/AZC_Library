/*
	Get list of origins for civilians where they can spawn.
	
*/
params["_center","_range"];

_houseList = _center nearObjects ["House",_range];
_houselistAll = [];

{
	// remove small "house" type objects
	_house = _x;
	_bbox = abs((boundingBox _house select 1) select 0) min abs((boundingBox _house select 1) select 1);
	if (_bbox >= 3) then
	{
		_houselistAll pushBack _house;
	};
} forEach _houseList;

_houselistAll
