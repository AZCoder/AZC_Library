/* ----------------------------------------------------------------------------
Function: AZC_fnc_FenceInit
Author: AZCoder
Part of this function is derived from the work of Big_Wilk
Original can be found here: http://www.armaholic.com/page.php?id=25482
Version: 1.0
Created: 02/26/2017
Dependencies: AZC_fnc_FenceCut
Description:
	This version differes from the work of Big_Wilk in that it handles both map fences and
	editor placed fences equally well thanks to a new command nearestTerrainObjects. This version
	also only shows the action menu when the player is near a detected fence. I removed the need
	for a toolkit because I wrote this for special forces who are probably using a liquid spray cutter,
	but that can easily be added back in. I also removed some other things and went with simplicity
	where possible, such as damaging fences instead of replacing them.
	
Parameters:
	0 : _unit
	    OBJECT
	    unit to add the action (in an SP mission, you may want to restrict to a certain team member that
	    is switchable by the player)

Returns: nothing

Examples:
	[player] call AZC_fnc_FenceInit;

---------------------------------------------------------------------------- */
params["_unit"];

AZC_Cuttable_Fences =
	["Wire",
	"WireFence",
	"Land_Razorwire_F",
	"IndFnc_3_F",
	"Land_IndFnc_3_F",
	"IndFnc_9_F",
	"Land_IndFnc_9_F",
	"wall_indfnc_9",
	"mil_wiredfence_f",
	"Mil_WiredFenceD_F",
    "Land_Mil_WiredFence_F", 
    "Land_Mil_WiredFenceD_F", 
    "Land_NetFence_03_m_3m_F",
    "Land_Net_Fence_4m_F", 
    "Land_NetFence_03_m_9m_F",
	"netfence_03_m_9m_f",
    "net_fence_8m_f",
    "Land_Net_Fence_8m_F",
    "Land_New_WiredFence_5m_F", 
    "Land_New_WiredFence_10m_F", 
    "Land_Wired_Fence_4m_F", 
    "Land_Wired_Fence_8m_F"];

// _unit addAction [("<t color=""#CC2900"">" + ("Cut Fence") + "</t>"),AZC_fnc_FenceCut,nil,6,true,true,"","(vehicle player == player) && (count (nearestObjects [_target,AZC_Cuttable_Fences,5]) > 0 || count (nearestTerrainObjects [_target, [""fence""], 5]) > 0)"];
_unit addAction [("<t color=""#CC2900"">" + ("Cut Fence") + "</t>"),AZC_fnc_FenceCut,nil,6,true,true,"","(vehicle player == player) && (count (nearestObjects [_target,AZC_Cuttable_Fences,5]) > 0)"];

