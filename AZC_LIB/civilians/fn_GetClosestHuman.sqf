/*
	Finds the closest other human to given unit.
*/

params["_unit"];

_closeList = [];

{
	if (_unit distance _x <= 30) then
	{
		_closeList pushBack _x;
	};
} forEach allUnits-[_unit];

_closest = objNull;
if (count _closeList > 0) then
{
	_closest = _closeList select 0;
	// if any enemy were found, return just the closest one
	{
		_dood = _x;
		if ((_unit distance _dood) < (_unit distance _closest)) then
		{
			_closest = _dood;
		};
	} forEach _closeList;
};
_closest
