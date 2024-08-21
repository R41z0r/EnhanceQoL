if (GAME_LOCALE or GetLocale()) ~= "zhTW" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

-- Chinesisch (traditionell)
L["Vendor"] = "商人"
L["MerchantWindowClosed"] = "商人窗口已關閉。停止銷售"

-- 常規
L["vendorMinIlvlDif"] = "標記為自動銷售的最低物品等級低於我的平均值"
L["vendorIgnoreBoE"] = "忽略裝備後綁定的物品"
L["vendorIgnoreWarbound"] = "忽略戰鬥綁定的物品"
L["vendorIgnoreUpgradable"] = "忽略可升級物品"

L["IncludeVendorList"] = "物品列表"
L["Include"] = "包含"

L["Add"] = "添加"
L["Remove"] = "移除"
L["Item id or drag item"] = "物品ID或拖動物品"
L["Item id does not exist"] = "物品ID不存在"
L["vendorAddItemToInclude"] = "將物品添加到此列表中以包含在銷售中。\n重要：這將忽略該物品的所有其他檢查"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] = "這使您能夠根據商人的過濾條件，自動銷售質量為\n" ..
                                                   ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                   "|r 的物品。"
    L["vendor" .. value .. "Enable"] = "啟用自動銷售 " .. ITEM_QUALITY_COLORS[key].hex ..
                                           _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r 物品"
    L["labelExplained" .. value .. "line"] = "這意味著它會自動出售 " .. ITEM_QUALITY_COLORS[key].hex ..
                                                 _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                 "|r\n物品等級為 %s 及以下的物品\n%s"
end
