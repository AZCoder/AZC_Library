if (isNil "AZC_Debug") then { AZC_Debug = false; };

[] spawn
{
	waitUntil {!(isNil "bis_fnc_init")};

	// set init true
	AZC_libInit = true;
};