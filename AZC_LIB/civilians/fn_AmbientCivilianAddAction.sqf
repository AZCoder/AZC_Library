/*
	Adds action to a civilian, such as an action to speak with the civilian.
	
*/
params["_civ","_action"];
if (count(_action) == 2) then { _civ addAction [(_action select 0), {
		_civ 	= _this select 0;
		_caller = _this select 1;
		_id 	= _this select 2;
		_script = _this select 3;

		// stop civilian and face the person bothering them
		_civ disableAI "MOVE";
		_civ lookAt _caller;
		_civ doWatch _caller;
		_civ removeAction _id;

		_handle = _civ execVM _script;
		waitUntil { scriptDone _handle };

		// stop watching
		_civ lookAt objNull;
		_civ doWatch objNull;

		// continue on their current waypoint (if any)
		_civ enableAI "MOVE";
	}, (_action select 1), 110, true, true, "", "true", 5];
};
