private ["_fence","_caller","_editorPlacedFences"];
_caller = _this select 1;

_unableToCut = "Unable to cut this fence.";
// get terrain fences
_mapObjectFences = nearestTerrainObjects [_caller, ["fence"], 5];
// get editor placed fences and merge with terrain fences
_editorPlacedFences = nearestObjects [_caller,AZC_Cuttable_Fences,5];
if (count _editorPlacedFences > 0) then { _mapObjectFences = _mapObjectFences + _editorPlacedFences };
if (count _mapObjectFences > 0) then
{
	// pick first fence, then search all fences to find the closest to player
	_nearFence = _mapObjectFences select 0;
	{
		if (_x distance _caller < _nearFence distance _caller) then { _nearFence = _x; };
	} forEach _mapObjectFences;
	// the fence name can have various numbers and symbols prior to a single colon :
	// first divide by colon, then divide the 2nd array element to find actual name
	_split = str _nearFence splitString ":";
	if (count _split < 2) exitWith { _caller groupChat _unableToCut };
	_split = (_split select 1) splitString " .";
	if (count _split < 1) exitWith { _caller groupChat _unableToCut };
	_fence = _split select 0;
	if ( ({ _fence == _x } count AZC_Cuttable_Fences) < 1) exitWith {_caller groupChat _unableToCut };
	
	_caller playMoveNow "gear";
	sleep 1;
	_caller switchMove "Acts_carFixingWheel";
	sleep (random(5)+5);
	_caller playActionNow "PutDown";
	sleep 2;
	_nearFence setDamage 1;
};
