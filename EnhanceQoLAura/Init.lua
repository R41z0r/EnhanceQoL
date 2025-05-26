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
addon.functions.InitDBValue("buffTrackerCategories", {
	[1] = {
		name = "Example",
		point = "CENTER",
		x = 0,
		y = 0,
		size = 36,
		direction = "RIGHT",
		buffs = {},
	},
})
addon.functions.InitDBValue("buffTrackerEnabled", false)
addon.functions.InitDBValue("buffTrackerLocked", false)
addon.functions.InitDBValue("buffTrackerHidden", {})
addon.functions.InitDBValue("buffTrackerSelectedCategory", 1)
addon.functions.InitDBValue("buffTrackerOrder", {})
addon.functions.InitDBValue("buffTrackerSounds", {})

-- migrate legacy database entries to new structure
if addon.db["buffTrackerList"] then
	local cat = addon.db["buffTrackerCategories"][1]
	cat.buffs = addon.db["buffTrackerList"]
	cat.point = addon.db["buffTrackerPoint"] or cat.point
	cat.x = addon.db["buffTrackerX"] or cat.x
	cat.y = addon.db["buffTrackerY"] or cat.y
	cat.size = addon.db["buffTrackerSize"] or cat.size
	cat.direction = addon.db["buffTrackerDirection"] or cat.direction

	addon.db["buffTrackerList"] = nil
	addon.db["buffTrackerPoint"] = nil
	addon.db["buffTrackerX"] = nil
	addon.db["buffTrackerY"] = nil
	addon.db["buffTrackerDirection"] = nil
	addon.db["buffTrackerSize"] = nil
end

if addon.db["buffTrackerOrder"] and #addon.db["buffTrackerOrder"] > 0 then addon.db["buffTrackerOrder"] = { [1] = addon.db["buffTrackerOrder"] } end

if type(addon.db["buffTrackerSelectedCategory"]) ~= "number" then addon.db["buffTrackerSelectedCategory"] = 1 end
