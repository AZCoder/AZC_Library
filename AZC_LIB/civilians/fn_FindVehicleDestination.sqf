// AZC_fnc_FindVehicleDestination
params["_playerLocation","_center"];
private["_roadDestination","_locationDestination","_locations"];

// start by setting destination town for waypoint to player's town location
_locationDestination = _playerLocation;

// if vehicle is already in the player's town, then set its destination to another town
if (_center isEqualTo _playerLocation) then
{
	// find random destination
	_locations = [];
	{
		_locations pushBack _x;
	} forEach nearestLocations [player, ["NameCity","NameCityCapital","NameVillage"], _destinationRange];
	// set second location
	_index = floor random(count(_locations));
	_locationDestination = (_locations select _index) call AZC_fnc_GetPos;
};

// find closest road to destination because AI drivers cannot always figure out offroad places
_roads = _locationDestination nearRoads 200;
if (count _roads < 1) then { _roads = _locationDestination nearRoads 500; };

// default destination position is the location
_roadDestination = _locationDestination;

if (count(_roads) > 0) then
{
	// get road segment
	_roadSegment = _roads select (floor random(count _roads));
	_roadDestination = getPos _roadSegment;
};

_roadDestination