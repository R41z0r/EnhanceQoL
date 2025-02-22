local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Vendor = {}
addon.LVendor = {} -- Locales for MythicPlus
addon.Vendor.functions = {}

addon.Vendor.variables = {}
local _, avgItemLevelEquipped = GetAverageItemLevel()
addon.Vendor.variables.avgItemLevelEquipped = avgItemLevelEquipped

addon.Vendor.variables.itemQualityFilter = {} -- Filter for Enable/Disable Qualities
addon.Vendor.variables.itemBindTypeQualityFilter = {} -- Filter for BindType in Quality
addon.Vendor.variables.tabNames = { -- Used to create autosell tabs
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
}

-- Includelist
addon.functions.InitDBValue("vendorIncludeSellList", {})

-- Excludelist
addon.functions.InitDBValue("vendorExcludeSellList", {})

addon.Vendor.variables.tabKeyNames = {}
for key in pairs(addon.Vendor.variables.tabNames) do
	table.insert(addon.Vendor.variables.tabKeyNames, key)
end
table.sort(addon.Vendor.variables.tabKeyNames)

addon.functions.InitDBValue("vendorSwapAutoSellShift", false)
addon.functions.InitDBValue("vendorOnly12Items", true)

for key, value in pairs(addon.Vendor.variables.tabNames) do
	addon.functions.InitDBValue("vendor" .. value .. "Enable", false)
	addon.functions.InitDBValue("vendor" .. value .. "MinIlvlDif", 200)
	addon.functions.InitDBValue("vendor" .. value .. "IgnoreWarbound", true)
	addon.functions.InitDBValue("vendor" .. value .. "IgnoreBoE", true)
	addon.functions.InitDBValue("vendor" .. value .. "AbsolutIlvl", false)

	if key ~= 1 then addon.functions.InitDBValue("vendor" .. value .. "IgnoreUpgradable", false) end

	addon.Vendor.variables.itemQualityFilter[key] = addon.db["vendor" .. value .. "Enable"]
	addon.Vendor.variables.itemBindTypeQualityFilter[key] = {
		[0] = true, -- None
		[1] = true, -- Bind on Pickup
		[2] = not addon.db["vendor" .. value .. "IgnoreBoE"], -- Bind on Equip
		[3] = true, -- Bind on Use
		[4] = false, -- Quest item
		[5] = false, -- Unused 1
		[6] = false, -- Unused 2
		[7] = not addon.db["vendor" .. value .. "IgnoreWarbound"], -- Bind to Account
		[8] = not addon.db["vendor" .. value .. "IgnoreWarbound"], -- Bind to Warband
		[9] = not addon.db["vendor" .. value .. "IgnoreWarbound"], -- Bind to Warband
	}
end

addon.Vendor.variables.itemTypeFilter = {
	[2] = true, -- Weapon
	[3] = true, -- Gems
	[4] = true, -- Armor
}

-- List to filter specific gems only
addon.Vendor.variables.itemSubTypeFilter = {
	[3] = {
		[11] = true, -- Artifact Relic
	},
}

addon.Vendor.variables.upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s", "%%a+"):gsub("%%d", "%%d+")
