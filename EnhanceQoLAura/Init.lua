local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Aura = {}
addon.Aura.functions = {}
addon.Aura.variables = {}
addon.LAura = {} -- Locales for aura

addon.functions.InitDBValue("AuraCooldownTrackerBarHeight", 30)
addon.functions.InitDBValue("AuraSafedZones", {})
addon.functions.InitDBValue("personalResourceBarHealth", {})
addon.functions.InitDBValue("personalResourceBarHealthWidth", 100)
addon.functions.InitDBValue("personalResourceBarHealthHeight", 25)
addon.functions.InitDBValue("personalResourceBarManaWidth", 100)
addon.functions.InitDBValue("personalResourceBarManaHeight", 25)
addon.functions.InitDBValue("buffTrackerList", {})
addon.functions.InitDBValue("buffTrackerEnabled", false)
addon.functions.InitDBValue("buffTrackerPoint", "CENTER")
addon.functions.InitDBValue("buffTrackerX", 0)
addon.functions.InitDBValue("buffTrackerY", 0)
addon.functions.InitDBValue("buffTrackerDirection", "RIGHT")
