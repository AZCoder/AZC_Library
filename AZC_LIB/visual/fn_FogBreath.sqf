// script written by TPW and adapted for Gates of ARMAgeddon by AZCoder
// _inVehicle determines whether to show foggy breath inside a vehicle or not
params ["_unit",["_inVehicle",false]];

_unit setVariable ["HasFogBreath",true];
while { alive _unit } do 
{
	// if show fog inside vehicle or player is on foot....
	if (_inVehicle || ((isNull objectParent player) && !([_unit] call AZC_fnc_InsideBuilding))) then
	{
		// pause if HOLD_TPW_SMOKE is set to true
		waitUntil { (_unit getVariable ["HOLD_TPW_SMOKE",false]) isEqualTo false };
		
		// slight random variation between breaths at rest
		private _inhaleWait = 3.5 + random(0.5) - (3.0 min (getFatigue player * 10));
		sleep _inhaleWait;

		_source = "logic" createVehicleLocal (getpos _unit);
		_fog = "#particlesource" createVehicleLocal getpos _source;
		_fog setParticleParams [["\Ca\Data\ParticleEffects\Universal\Universal", 16, 12, 13,0],
							"",
							"Billboard",
							0.5,
							0.5,
							[0,0,0],
							[0,0.2,-0.2],
							1, 1.275,1,0.2,
							[0, 0.2,0],
							[[1,1,1,0.2],[1,1,1,0.01],[1,1,1,0]],
							[1000],
							1,
							0.04,
							"",
							"",
							_source];

		_fog setParticleRandom [2, [0, 0, 0], [0.25, 0.25, 0.25], 0, 0.5, [0, 0, 0, 0.1], 0, 0, 10];
		_fog setDropInterval 0.001;
		_source attachto [_unit,[0,0.2,0],"neck"]; // get fog to come out of player mouth
		private _exhaleWait = (_inhaleWait / 5);
		sleep _exhaleWait;
		deletevehicle _source;
	};
};
