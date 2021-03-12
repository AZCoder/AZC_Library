// script written by TPW and adapted for Gates of ARMAgeddon by AZCoder
params ["_unit","_intensity",["_baseDelay",2],["_inVehicle",true]];

_unit setVariable ["HasFogBreath",true];
while { alive _unit } do 
{
	// if show fog inside vehicle or player is on foot....
	if (_inVehicle || (vehicle player == player)) then
	{
		sleep (_baseDelay + random 3); // random time between breaths
		waitUntil { sleep 3; (_unit getVariable ["HOLD_TPW_SMOKE",false]) isEqualTo false };

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
							[[1,1,1,_intensity],[1,1,1,0.01],[1,1,1,0]],
							[1000],
							1,
							0.04,
							"",
							"",
							_source];
		_fog setParticleRandom [2, [0, 0, 0], [0.25, 0.25, 0.25], 0, 0.5, [0, 0, 0, 0.1], 0, 0, 10];
		_fog setDropInterval 0.001;
		_source attachto [_unit,[0,0.2,0],"neck"]; // get fog to come out of player mouth
		sleep 0.5; // 1/2 second exhalation
		deletevehicle _source;
	};
};
