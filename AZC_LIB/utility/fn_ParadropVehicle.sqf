params ["_vehicle","_altitude","_dir"];
// all credit goes to Kylania!

_para = createVehicle ["B_Parachute_02_F", [0,0,100], [], 0, ""];
_para setPosATL (_vehicle modelToWorld[0,0,_altitude]);
_vehicle attachTo [_para,[0,0,0]];
_vehicle setDir _dir;

// Land safely
waitUntil {((((position _vehicle) select 2) < 0.6) || (isNil "_para"))};
detach _vehicle;
_vehicle SetVelocity [0,0,-5];
sleep 0.3;
_vehicle setPos [(position _vehicle) select 0, (position _vehicle) select 1, 1];
_vehicle SetVelocity [0,0,0];
