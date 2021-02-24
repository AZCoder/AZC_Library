/*
	Gets the closest location to the player within range.
	
	_origins = list of locations on map that are spawn areas, but if set to nil then this function
	will find the closest location within _maxRange
	
	_maxRange = max range to find towns for spawning (not the same as max spawn range from town center)
	
*/
private["_nearestLocation","_closest","_location","_spawnPoint","_origins"];
_origins	= [_this, 0, []] call bis_fnc_param;
_maxRange	= [_this, 1] call bis_fnc_param;

_nearestLocation = [[0,0,0],0];
_localities = +_origins;
// if locations are provided, only spawn at those locations, otherwise spawn at nearest location
if (count _origins < 1) then
{
	_locations = [];

	{
		_locations pushBack _x;
	} forEach nearestLocations [player, ["NameCity","NameCityCapital","NameVillage"], _maxRange];
	//systemChat format["_maxRange: %1, _locations: %2",_maxRange,_locations];

	if (count(_locations) < 1) exitWith { };
	_closest = _locations select 0;

	{
		_location = _x;
		_posLoc = _location call AZC_fnc_GetPos;
		_posClosest = _closest call AZC_fnc_GetPos;
		
		if ((player distance _posLoc) < (player distance _posClosest)) then
		{
			_closest = _location;
		};
	} forEach _locations;

	_loc = _closest;
	if (!isNil "_loc") then
	{
		_pos = _loc call AZC_fnc_GetPos;
		// limiting spawn range to 1200m from city center, if city is larger then consider
		// adding multiple trigger zones (only closest to player will be used at any given time)
		_range = 1200 min _maxRange;
		_spawnPoint = [_pos,_range];
		_localities pushBack _spawnPoint;
	};
};

if (count _localities == 1) then { _nearestLocation = _localities select 0; };
if (count _localities > 1) then
{
	_nearestLocation = _localities select 0;
	{
		_posLoc = _x select 0;
		_posClosest = _nearestLocation select 0;
		if ((player distance _posLoc) < (player distance _posClosest)) then
		{
			_nearestLocation = _x;
		};
	} forEach _localities;
};
_nearestLocation
