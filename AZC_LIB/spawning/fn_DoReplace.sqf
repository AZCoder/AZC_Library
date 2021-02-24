/* ----------------------------------------------------------------------------
	DO NOT CALL THIS DIRECTLY
	Used by fnc_Replacer.
---------------------------------------------------------------------------- */

params ["_vehicle","_replacement",["_vehName",""]];

// find any people inside _vehicle
private ["_fullCrew"];
_fullCrew = fullCrew _vehicle;

if (count _fullCrew > 0) then
{
	// protect and pop out the crew
	{
		_crew = _x select 0;
		_crew allowDamage false;
		_crew action ["Eject",_vehicle];
		_crew setPos [0,0,150000];
		_crew enableSimulation false;
	} forEach _fullCrew;
};

_posVeh = getPosATL _vehicle;
_onWater = surfaceIsWater position _vehicle;
if (_onWater) then { _posVeh = getPosASL _vehicle; };
_dirVeh = getDir _vehicle;
_vms = velocityModelSpace _vehicle;
_damage = damage _vehicle;
_fuel = fuel _vehicle;
_locked = locked _vehicle;

// does vehicle appear to be flying?
_special = "NONE";
if (_posVeh select 2 > 10) then { _special = "FLY"; };

_tempPos = [(_posVeh select 0),(_posVeh select 1),15000];
_newPos = [(_posVeh select 0),(_posVeh select 1),(_posVeh select 1)+2];
// create replacement
private["_newVeh"];
if (_vehicle isKindOf "MAN") then
{
	_group = createGroup (side _vehicle);
	_newVeh = _group createUnit [_replacement,_tempPos,[],0,"FORM"];
}
else
{
	_newVeh = createVehicle [_replacement,_tempPos,[],0,_special];
};

if (count _vehName > 0) then
{
	_newVeh setVehicleVarName _vehName;
	// none of this works, cannot use the _vehName to represent the object again
	// _vehName call { _this = _newVeh; };
	// call compile format ["%1 = %2",_vehName,_newVeh];
};

deleteVehicle _vehicle;
_newVeh allowDamage false;
_newVeh setDir _dirVeh;

[_newVeh,_posVeh,_fullCrew,_onWater,_vms,_fuel,_damage,_dirVeh,_locked] spawn
{
	params["_newVeh","_posVeh","_fullCrew","_onWater","_vms","_fuel","_damage","_dirVeh","_locked"];
	// I need to delay here to prevent a silly situation where the vehicles collide
	// when deleting the old one and replacing with the new one
	// while still being able to return the new vehicle object
	sleep 0.1;
	if (_onWater) then
	{
		_newVeh setPosASL _posVeh;
	}
	else
	{
		_newVeh setPosATL _posVeh;
	};

	_newVeh setDir _dirVeh; // yes set it twice, sometimes changes on impact
	_newVeh setDamage _damage;
	_newVeh setFuel _fuel;
	_newVeh lock _locked;
	// put crew into replacement vehicle in same positions
	{
		_crew = _x select 0;
		if (_x select 1 == "driver") then
		{
			_crew assignAsDriver _newVeh;
			_crew moveInDriver _newVeh;
		}
		else
		{
			_crew assignAsCargo _newVeh;
			_crew moveInCargo [_newVeh,(_x select 2)];
		};
		_crew allowDamage true;
		_crew enableSimulation true;
	} forEach _fullCrew;

	_newVeh setVelocityModelSpace _vms;
	_newVeh allowDamage true;
};

_newVeh