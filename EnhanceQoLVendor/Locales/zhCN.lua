if (GAME_LOCALE or GetLocale()) ~= "zhCN" then
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

-- Chinesisch (vereinfacht)
L["Vendor"] = "商人"
L["MerchantWindowClosed"] = "商人窗口已关闭。停止销售"

-- 常规
L["vendorMinIlvlDif"] = "标记为自动销售的最低物品等级低于我的平均值"
L["vendorIgnoreBoE"] = "忽略装备后绑定的物品"
L["vendorIgnoreWarbound"] = "忽略战斗绑定的物品"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] = "这使您能够根据商人的过滤条件，自动销售质量为\n" ..
                                                   ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                   "|r 的物品。"
    L["vendor" .. value .. "Enable"] = "启用自动销售 " .. ITEM_QUALITY_COLORS[key].hex ..
                                           _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r 物品"
end
