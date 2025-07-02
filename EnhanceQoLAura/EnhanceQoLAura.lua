-- Store the original Blizzard SetupMenu generator for rewrapping
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

addon.tempScrollPos = 0 -- holds last scroll offset for Essential list

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")

addon.variables.statusTable.groups["aura"] = true
addon.functions.addToTree(nil, {
	value = "aura",
	text = L["Aura"],
	children = {
		--    { value = "resourcebar", text = DISPLAY_PERSONAL_RESOURCE },
		{ value = "bufftracker", text = L["BuffTracker"] },
	},
})

function addon.Aura.functions.treeCallback(container, group)
	container:ReleaseChildren()
	if group == "aura\001resourcebar" then
		addon.Aura.Resources.functions.addResourceFrame(container)
	elseif group == "aura\001bufftracker" then
		addon.Aura.functions.addBuffTrackerOptions(container)
		addon.Aura.scanBuffs()
	end
end
