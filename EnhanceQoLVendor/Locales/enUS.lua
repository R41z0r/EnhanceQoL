local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

L["Vendor"] = "Vendor"
L["MerchantWindowClosed"] = "Merchant window is closed. Stopping sales"

-- General
L["vendorMinIlvlDif"] = "Min. ilvl under my average to mark for autosell"
L["vendorIgnoreBoE"] = "Ignore Bind on Equip items"
L["vendorIgnoreWarbound"] = "Ignore Warbound items"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] =
        "This enabled you to automatically sell " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r items\nbased on of filter criteria when at a merchant"
    L["vendor" .. value .. "Enable"] = "Enable automatic selling for " .. ITEM_QUALITY_COLORS[key].hex ..
                                           _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r items"
end
