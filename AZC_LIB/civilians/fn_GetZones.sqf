/*
	Get list of zones from a list of possible locations. Zones are an array of town center positions and their ranges. So if 3 different sized triggers were passed in, there would be origins with different ranges include for their respective triggers.
	
	_locations = a list of area triggers and/or game logics in array format with a distance provided
*/
private["_locType","_pos","_range","_spawnPoint","_trigger","_origins"];

params["_locations"];
if (typeName _locations != "ARRAY") then { _locations = []; };
_zones = [];

{
	_locType = typeName _x;
	if (_locType == "ARRAY") then
	{
		_pos = getPos (_x select 0);
		_range = _x select 1;
		_spawnPoint = [_pos,_range];
		_zones pushBack _spawnPoint;
	}
	else
	{
		_trigger = _x;
		_pos = getPos _trigger;
		// get average trigger size to get house range
		_range = ((triggerArea _trigger select 0) + (triggerArea _trigger select 1)) / 2;
		_spawnPoint = [_pos,_range];
		_zones pushBack _spawnPoint;
	};
} forEach _locations;

_zones