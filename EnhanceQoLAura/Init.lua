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
addon.Aura.sounds = {}
addon.LAura = {} -- Locales for aura

addon.functions.InitDBValue("AuraCooldownTrackerBarHeight", 30)
addon.functions.InitDBValue("AuraSafedZones", {})
addon.functions.InitDBValue("personalResourceBarHealth", {})
addon.functions.InitDBValue("personalResourceBarHealthWidth", 100)
addon.functions.InitDBValue("personalResourceBarHealthHeight", 25)
addon.functions.InitDBValue("personalResourceBarManaWidth", 100)
addon.functions.InitDBValue("personalResourceBarManaHeight", 25)
addon.functions.InitDBValue("enableResourceFrame", false)
addon.functions.InitDBValue("buffTrackerCategories", {
	[1] = {
		name = "Example",
		point = "CENTER",
		x = 0,
		y = 0,
		size = 36,
		direction = "RIGHT",
		trackType = "BUFF",
		allowedSpecs = {},
		allowedClasses = {},
		allowedRoles = {},
		buffs = {},
	},
})
addon.functions.InitDBValue("buffTrackerEnabled", {})
addon.functions.InitDBValue("buffTrackerLocked", {})
addon.functions.InitDBValue("buffTrackerHidden", {})
addon.functions.InitDBValue("buffTrackerSelectedCategory", 1)
addon.functions.InitDBValue("buffTrackerOrder", {})
addon.functions.InitDBValue("buffTrackerSounds", {})
addon.functions.InitDBValue("buffTrackerSoundsEnabled", {})

if type(addon.db["buffTrackerSelectedCategory"]) ~= "number" then addon.db["buffTrackerSelectedCategory"] = 1 end

for _, cat in pairs(addon.db["buffTrackerCategories"]) do
	if not cat.trackType then cat.trackType = "BUFF" end
	if not cat.allowedSpecs then cat.allowedSpecs = {} end
	if not cat.allowedClasses then cat.allowedClasses = {} end
	if not cat.allowedRoles then cat.allowedRoles = {} end
	for _, buff in pairs(cat.buffs or {}) do
		if not buff.altIDs then buff.altIDs = {} end
		if buff.showWhenMissing == nil then buff.showWhenMissing = false end
		if buff.showAlways == nil then buff.showAlways = false end
		if buff.glow == nil then buff.glow = false end
	end
end
