/* ----------------------------------------------------------------------------
Function: AZC_fnc_CreateLHD
Author: ArMaTeC
Version: 1.0
Dependencies: CUPS Terrain
Created: 05/15/2015
Modified: 07/23/2017 because no longer able to set direction of game logic
Description:
	This function was pulled from Arma 2 EW (Eagle Wing). Only works if CUPS terrain is loaded.

Parameters:
	0 : _unitObj
	    OBJECT (best results with game logic)
	    Name of Game Logic to spawn an LHD upon.
	1 : _unitDir
	    INT
	    Direction to spawn the LHD

Returns: nothing

Examples:
	AZC_LHD spawn AZC_fnc_CreateLHD;
*/

private ["_unitObj","_LHDdir","_LHDspawnpoint","_parts","_dummy"];

_unitObj 	= [_this, 0] call bis_fnc_param;
_LHDdir 	= [_this, 1] call bis_fnc_param;

_LHDspawnpoint = [(getPosASL _unitObj select 0),(getPosASL _unitObj select 1),1];
_parts =
[
	"Land_LHD_house_1",
	"Land_LHD_house_2",
	"Land_LHD_elev_R",
	"Land_LHD_1",
	"Land_LHD_2",
	"Land_LHD_3",
	"Land_LHD_4",
	"Land_LHD_5",
	"Land_LHD_6"
];

{
	_dummy = _x createvehicle _LHDspawnpoint;
	_dummy setdir _LHDdir;
	_dummy setpos _LHDspawnpoint;
}foreach _parts;
