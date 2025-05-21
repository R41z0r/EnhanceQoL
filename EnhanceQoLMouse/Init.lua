local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Mouse = {}
addon.Mouse.functions = {}
addon.LMouse = {} -- Locales for aura

addon.functions.InitDBValue("mouseRingEnabled", false)
addon.functions.InitDBValue("mouseTrailEnabled", false)
addon.functions.InitDBValue("mouseTrailDensity", 1)
addon.functions.InitDBValue("mouseRingSize", 70)
