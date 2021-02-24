/*
	Get list of civilians loaded by the client and not blacklisted.
	_civs = true to return civilians, false to return civilian vehicles
	_blacklist = classes to exclude
*/
private["_entries","_actual","_classlist","_classlistCivs","_totalObjects","_class","_civClass","_side","_scope"];

params["_civs","_blacklist"];

// create list of civilian type objects
_entries = [];
if (_civs) then
{
	_entries = "((configName _x) isKindOf 'Man')" configClasses (configFile >> "CfgVehicles");
}
else
{
	_entries = "((configName _x) isKindOf 'Car')" configClasses (configFile >> "CfgVehicles");
};

_classlist = [];
_classlistCivs = [];
_totalObjects = count (_entries);

for [{_i = 0}, {_i < _totalObjects}, {_i = _i + 1}] do
{
	_actual = _entries select _i;
	if (isClass _actual) then
	{
		_class = configname _actual;
		_civClass = getText (configfile >> "cfgVehicles" >> _class >> "vehicleClass");
		if !(_civClass in ["Sounds","Mines"]) then
		{
			_scope = getnumber (_actual >> "scope");
			_side = getnumber (_actual >> "side");
			
			_isValid = false;
			if (_civs) then
			{
				_isValid = _class isKindOf "civilian" && _side != 7 && _scope == 2 && typeName _class == "string";
			}
			else
			{
				_isValid = _side == 3 && _scope == 2 && typeName _class == "string"
			};
			
			if (_isValid && !(_class in _blacklist)) then
			{
				_classlistCivs pushBack _class;
			};
		};
	};
};

_classlistCivs