params["_civ","_housesInRange"];
_civ setVariable ["AZC_PANIC_HOUSES",_housesInRange];
_civ setVariable ["AZC_PANIC",false];

_civ addEventHandler["FiredNear", {
	_civ = _this select 0;
	_civ removeAllEventHandlers "FiredNear";
	_civ setVariable ["AZC_PANIC",true];
}];
