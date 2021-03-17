/* ----------------------------------------------------------------------------
Function: AZC_fnc_ACM (Ambient Civilian Module)
Author: AZCoder
Version: 2.0
Created: 01/02/2017
Dependencies: Civilians directory, AZC_fnc_Debug, AZC_fnc_Delete
Description:
	Manages the spawning of civilians on foot. This way the mission maker does not
	have to keep track of what was spawned, how many, how often, and just let this function handle
	the details.
	
Parameters:
	Namespace variables have been provided for each parameter. Use either, just be sure to set
	namespace variables prior to calling AZC_fnc_ACM.
	0 : _locations
	    ARRAY (optional)
	    default: [] (whole map)
	    locations (either array of [game_logic, range] or an area trigger) -> single trigger must still be an
		array (inside [])
	    missionNameSpace: AZC_ACM_LOCATIONS
	1 : _minDistance
	    INT (optional)
	    default: 400
	    minimum distance to location CENTER before spawning civilians
	    missionNameSpace: AZC_ACM_MINDISTANCE
	2 : _maxCivilians
	    INT (optional)
	    default: 10
	    number of civilians allowed at one time for a single location
	    missionNameSpace: AZC_ACM_MAXCIVILIANS
	3 : _whiteList
	    ARRAY (optional)
	    default: []
	    units to whitelist (only spawn these classes)
	    missionNameSpace: AZC_ACM_WHITELIST
	4 : _blackList
	    ARRAY (optional)
	    default: []
	    units to blacklist (never spawn these classes, ignored if whitelist is set)
	    missionNameSpace: AZC_ACM_BLACKLIST
	5 : _chimneys
	    BOOL (optional)
	    default: true
	    true to enable random chimney smoke, false to disable this feature
	    missionNameSpace: AZC_ACM_CHIMNEYS
	6 : _action
	    ARRAY (optional)
	    action script in the addAction array format -> ["Greetings", "speech.sqf"], [] = default
	    Note: you must provide a custom script. The civilian is passed as a single object (not array type).
	    The civilian will suspend any waypoints until the custom script terminates.

NOTES:
	For locations, the easiest is to simply put down area triggers because they are visual.
	While you can use any size of circle or rectangle, the function averages the x and y axis,
	so I recommend just using a perfect circle because that's how it will be treated.
	
	The addAction optional array is intentionally simple, only accepting the title and script name.
	If more parameters are required, you may optionally access the missionNamespace variable
	"AZC_AmbientCivilianManagerActive" to get the list of civilians spawned and addAction on any
	or all of them.
	
	To disable the manager (and spawning) at any time, do this:
	missionNamespace setVariable ["AZC_AmbientCivilianManagerActive",false];
	You will have to call this function to start it again; setting true will have no effect.

WARNING:
	Never put down a single large trigger for multiple towns, only the closest location to the center
	will be calculated.	It's ok to use no triggers if you want the whole map available;
	otherwise assign 1 trigger per location that is allowed	to spawn civilians
	(usually 500m to 1000m diameter).

Returns: nothing

Examples:
	[] spawn AZC_fnc_ACM;
	_locations = [[Solnichniy,300],trgIndustry];
	[_locations,300,20,whitelist,nil,true,["Greetings", "speech.sqf"]] spawn AZC_fnc_ACM;
---------------------------------------------------------------------------- */

private ["_zones","_civilianManagerActive","_activeSpawns","_civilianList","_civ","_tooFarAway","_effectiveMaxCivilians"];

_locations		= [_this, 0, [], []] call bis_fnc_param;
_minDistance	= [_this, 1, 400, [1]] call bis_fnc_param;
_maxCivilians 	= [_this, 2, 10, [1]] call bis_fnc_param;
_whiteList		= [_this, 3, []] call bis_fnc_param;
_blackList		= [_this, 4, []] call bis_fnc_param;
_chimneys		= [_this, 5, true] call bis_fnc_param;
_action			= [_this, 6, []] call BIS_fnc_param;

if (_maxCivilians < 1) then { _maxCivilians = 1; };

// Only 1 instance of ACM can run at any time
_acm = missionNamespace getVariable "AZC_AmbientCivilianManagerActive";
// if AZC_AmbientCivilianManagerActive exists and is true, cannot create another instance! 
if (!isNil "_acm") then
{
	if (_acm) exitWith { systemChat "Cannot create duplicate instance of ACM" };
};

_civilianManagerActive = true;
missionNamespace setVariable ["AZC_AmbientCivilianManagerActive",_civilianManagerActive];

/********** parameters can be set externally via namespace **********/
_check = missionNamespace getvariable "AZC_ACM_LOCATIONS";
if (!isNil "_check") then
{
	_locations = _check;
};

_check = missionNamespace getvariable "AZC_ACM_MINDISTANCE";
if (!isNil "_check") then
{
	_minDistance = _check;
};

_check = missionNamespace getvariable "AZC_ACM_MAXCIVILIANS";
if (!isNil "_check") then
{
	_maxCivilians = _check;
};

_check = missionNamespace getvariable "AZC_ACM_WHITELIST";
if (!isNil "_check") then
{
	_whiteList = _check;
};

_check = missionNamespace getvariable "AZC_ACM_BLACKLIST";
if (!isNil "_check") then
{
	_blackList = _check;
};

_check = missionNamespace getvariable "AZC_ACM_CHIMNEYS";
if (!isNil "_check") then
{
	_chimneys = _check;
};

_check = missionNamespace getvariable "AZC_ACM_ACTION";
if (!isNil "_check") then
{
	_action = _check;
};

/********************************************************************/

// _zones are positions of triggers and game logics, if not passed in this will always return [] empty array
// set origins, each is a position and range [_pos,_range]
_zones = [_locations] call AZC_fnc_GetZones;

//systemChat format["_zones: %1,_minDistance: %2,_maxCivilians: %3,countW: %4,countB: %5,action: %6",_zones,_minDistance,_maxCivilians,count(_whiteList),count(_blackList),_action];

// if there are existing civilians from a previous run-stop of the manager, update their actions
_civilianList = missionNamespace getVariable "AZC_CivilianList";
if (isNil "_civilianList") then
{
	_civilianList = [];
};

if (count _civilianList > 0) then
{
	{
		removeAllActions _x;
		[_x,_action] spawn AZC_fnc_AmbientCivilianAddAction;
	} forEach _civilianList;
};

_housesInRange = [];
_lastLocation = [objNull];
_effectiveMaxCivilians = _maxCivilians;
_usedHouses = [];
missionNamespace setVariable ["AZC_UsedCivHouses", _usedHouses];

// initial calls before loop
_nearestLocation = [_zones,_minDistance] call AZC_fnc_GetNearestLocation;
if (_chimneys) then
{
	[(_nearestLocation select 0),(_nearestLocation select 1)] spawn AZC_fnc_ChimneySmoke;
};
_center = _nearestLocation select 0;
_range = _nearestLocation select 1;
_usedHouses = [];
missionNamespace setVariable ["AZC_UsedCivHouses", _usedHouses];
_housesInRange = [_center,_range,_blacklist] call AZC_fnc_GetBuildings;
_effectiveMaxCivilians = round((count _housesInRange) / 3) min _maxCivilians;

while { _civilianManagerActive } do
{
	_civilianList = missionNamespace getVariable "AZC_CivilianList";
	if (isNil "_civilianList") then
	{
		_civilianList = [];
	};
	
	/********** find closest location available to the player for spawning **********/
	_nearestLocation = [_zones,_minDistance] call AZC_fnc_GetNearestLocation;
	if (objNull isEqualTo (_lastLocation select 0)) then { _lastLocation = _nearestLocation; };
	
	//_tickTime = time;
	//systemChat format["%3 => _nearestLocation: %1, _lastLocation: %2",_nearestLocation select 0,_lastLocation select 0,_tickTime];
	
	if (!((_lastLocation select 0) isEqualTo (_nearestLocation select 0))) then
	{
		if (_chimneys) then
		{
			[(_nearestLocation select 0),(_nearestLocation select 1)] spawn AZC_fnc_ChimneySmoke;
		};
		// AZC_fnc_GetBuildings is a costly function call, only call it when location changes
		_center = _nearestLocation select 0;
		_range = _nearestLocation select 1;
		_usedHouses = [];
		missionNamespace setVariable ["AZC_UsedCivHouses", _usedHouses];
		_housesInRange = [_center,_range,_blacklist] call AZC_fnc_GetBuildings;
		// _effectiveMaxCivilians is about 1/3 of the _housesInRange
		// this helps prevent village density from being far higher than cities
		_effectiveMaxCivilians = round((count _housesInRange) / 3) min _maxCivilians;
	};
	
	/********************************************************************************/
	
	// get player distance to _nearestLocation
	_playerDistance = player distance (_nearestLocation select 0);
	
	_activeSpawns = count(_civilianList);
	_effectiveDistance = _minDistance max (_nearestLocation select 1);
	if ((_activeSpawns < _effectiveMaxCivilians) && (_playerDistance < _effectiveDistance)) then
	{
		_civ = [(_nearestLocation select 0),(_nearestLocation select 1),_blackList,_whiteList,_housesInRange] call AZC_fnc_CreateCivilian;
		if (!isNull _civ) then
		{
			_civilianList pushBack _civ;
			// move civilian (only needs to be called once)
			[_civ,(_nearestLocation select 0),(_nearestLocation select 1),_blacklist,_housesInRange] spawn AZC_fnc_SetDestination;
			
			missionNamespace setVariable ["AZC_CivilianList", _civilianList];
			[_civ,_action] spawn AZC_fnc_AmbientCivilianAddAction;
			_activeSpawns = count(_civilianList);
			[(format ["Created civilian: %1 --- _activeSpawns: %2 --- _effectiveMaxCivilians: %3",_civ,_activeSpawns,_effectiveMaxCivilians])] call AZC_fnc_Debug;
		}
		else
		{
			[(format["%1: Civ was null",time])] call AZC_fnc_Debug;
		};
	}
	else
	{
		[(format ["%3: Cannot spawn anymore civilians: _activeSpawns: %1 --- _effectiveMaxCivilians: %2",_activeSpawns,_effectiveMaxCivilians,time])] call AZC_fnc_Debug;
	};
	
	// cleanup civs that are too far from player
	_civilianList = [_civilianList,_minDistance,(_nearestLocation select 0),(_lastLocation select 0)] call AZC_fnc_CivCleanup;
	missionNamespace setVariable ["AZC_CivilianList", _civilianList];
	_lastLocation = _nearestLocation;

	_checkTime = 1;
	// if no more houses to use or max civilians reached, increase check time
	_usedHouses = missionNamespace getVariable "AZC_UsedCivHouses";
	if ((count _usedHouses >= count _housesInRange) || (count _civilianList >= _effectiveMaxCivilians)) then
	{ _checkTime = 10; };
	sleep _checkTime;
	_civilianManagerActive = missionNamespace getVariable "AZC_AmbientCivilianManagerActive";
};

/*
// Chernarus with Max Women, Contact DLC, and UK3CB mod
["C_man_hunter_1_F","C_Zatanna","C_Kara","C_Selina","C_man_p_beggar_F_euro","UK3CB_CHC_C_ACT","UK3CB_CHC_C_CIT","UK3CB_CHC_C_COACH","UK3CB_CHC_C_FUNC","UK3CB_CHC_C_HIKER","UK3CB_CHC_C_LABOUR","UK3CB_CHC_C_POLITIC","UK3CB_CHC_C_PRIEST","UK3CB_CHC_C_PROF","UK3CB_CHC_C_CIV","UK3CB_CHC_C_SPY","UK3CB_CHC_C_VILL","UK3CB_CHC_C_CAN","Max_woman4","Max_woman3","Max_woman1","UK3CB_CHC_C_WOOD","UK3CB_CHC_C_WORKER","C_Man_4_enoch_F","C_Man_6_enoch_F","C_Farmer_01_enoch_F"];

// Altis
["C_man_hunter_1_F","C_Zatanna","C_Kara","C_Selina","C_man_p_beggar_F_euro","C_Nikos","C_man_polo_3_F_euro","C_Man_casual_1_F","C_man_polo_1_F","C_man_shorts_1_F","Max_woman4","Max_woman3","Max_woman1","C_Man_ConstructionWorker_01_Blue_F","C_Man_ConstructionWorker_01_Vrana_F","C_Man_Fisherman_01_F","C_man_hunter_1_F","C_man_polo_4_F","C_man_shorts_2_F","C_man_shorts_4_F","C_Man_UtilityWorker_01_F","C_man_polo_6_F","C_man_polo_3_F_afro","C_man_shorts_3_F_afro","C_Man_casual_5_F_afro"];

// Tanoan
["C_Man_casual_1_F_Tanoan","C_Zatanna","C_Kara","C_Selina","C_Man_casual_2_F_Tanoan","C_Man_casual_3_F_Tanoan","Max_woman4","Max_woman3","Max_woman1","C_Man_ConstructionWorker_01_Blue_F","C_Man_ConstructionWorker_01_Vrana_F","C_Man_Fisherman_01_F","C_Man_casual_4_F_Tanoan","C_Man_casual_5_F_Tanoan","C_Man_casual_6_F_Tanoan","C_Man_sport_1_F_Tanoan","C_Man_sport_2_F_Tanoan","C_Man_sport_3_F_Tanoan"];

// Recommended blacklist from Project OPFOR (Armed Civilians)
["LOP_CHR_Civ_Citizen_07","LOP_CHR_Civ_Citizen_05","LOP_CHR_Civ_Citizen_06","LOP_CHR_Civ_Woodlander_05","LOP_CHR_Civ_Woodlander_06","LOP_CHR_Civ_Worker_05","LOP_CHR_Civ_Worker_06","LOP_CHR_Civ_Worker_07",
"LOP_AFRCiv_Soldier_SL","LOP_AFRCiv_Driver","LOP_AFRCiv_Soldier_Marksman","LOP_AFRCiv_Soldier_AT","LOP_AFRCiv_Soldier_AR","LOP_AFRCiv_Soldier_GL","LOP_AFRCiv_Soldier","LOP_AFRCiv_Soldier_Medic","LOP_AFRCiv_Soldier_IED"];

// some civilian classes for vanilla, RDS, and Massi: ["C_man_1","C_man_1_1_F","C_man_1_2_F","C_man_1_3_F","C_man_polo_1_F","C_man_polo_1_F_afro","C_man_polo_1_F_euro","C_man_polo_1_F_asia","C_man_polo_2_F","C_man_polo_2_F_afro","C_man_polo_2_F_euro","C_man_polo_2_F_asia","C_man_polo_3_F","C_man_polo_3_F_afro","C_man_polo_3_F_euro","C_man_polo_3_F_asia","C_man_polo_4_F","C_man_polo_4_F_afro","C_man_polo_4_F_euro","C_man_polo_4_F_asia","C_man_polo_5_F","C_man_polo_5_F_afro","C_man_polo_5_F_euro","C_man_polo_5_F_asia","C_man_polo_6_F","C_man_polo_6_F_afro","C_man_polo_6_F_euro","C_man_polo_6_F_asia","C_man_p_fugitive_F","C_man_p_fugitive_F_afro","C_man_p_fugitive_F_euro","C_man_p_fugitive_F_asia","C_man_p_beggar_F","C_man_p_beggar_F_afro","C_man_p_beggar_F_euro","C_man_p_beggar_F_asia","C_man_w_worker_F","C_scientist_F","C_man_hunter_1_F","C_man_p_shorts_1_F","C_man_p_shorts_1_F_afro","C_man_p_shorts_1_F_euro","C_man_p_shorts_1_F_asia","C_man_shorts_1_F","C_man_shorts_1_F_afro","C_man_shorts_1_F_euro","C_man_shorts_1_F_asia","C_man_shorts_2_F","C_man_shorts_2_F_afro","C_man_shorts_2_F_euro","C_man_shorts_2_F_asia","C_man_shorts_3_F","C_man_shorts_3_F_afro","C_man_shorts_3_F_euro","C_man_shorts_3_F_asia","C_man_shorts_4_F","C_man_shorts_4_F_afro","C_man_shorts_4_F_euro","C_man_shorts_4_F_asia","C_man_pilot_F","C_journalist_F","C_Orestes","C_Nikos","C_Nikos_aged","C_Driver_1_F","C_Driver_2_F","C_Driver_3_F","C_Driver_4_F","C_Soldier_VR_F","RDS_Citizen1","RDS_Citizen2","RDS_Citizen3","RDS_Citizen4","RDS_Worker1","RDS_Worker2","RDS_Worker3","RDS_Worker4","RDS_Profiteer1","RDS_Profiteer2","RDS_Profiteer3","RDS_Profiteer4","RDS_Woodlander1","RDS_Woodlander2","RDS_Woodlander3","RDS_Woodlander4","RDS_Functionary1","RDS_Functionary2","RDS_Villager1","RDS_Villager2","RDS_Villager3","RDS_Villager4","RDS_Priest","RDS_Policeman","RDS_Doctor","RDS_SchoolTeacher","RDS_Assistant","C_mas_cer_1","C_mas_cer_2","C_mas_cer_3","C_mas_cer_4","C_mas_cer_5","C_mas_cer_6","C_mas_cer_7","C_mas_cer_8","C_mas_cer_9","C_mas_cer_10"]
*/

