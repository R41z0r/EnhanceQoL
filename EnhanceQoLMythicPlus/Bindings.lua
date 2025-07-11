BINDING_HEADER_ENHANCEQOL_MYTHICPLUS = "Enhance QoL - Mythic+"
BINDING_NAME_ENHANCEQOL_WORLD_MARKER_CYCLE = "Cycle World Marker"

function EnhanceQoL_WorldMarkerCycle()
	if EnhanceQoL and EnhanceQoL.MythicPlus and EnhanceQoL.MythicPlus.functions then EnhanceQoL.MythicPlus.functions.cycleWorldMarker() end
end
