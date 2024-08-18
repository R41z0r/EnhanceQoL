if (GAME_LOCALE or GetLocale()) ~= "ruRU" then
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

-- Russisch
L["Vendor"] = "Продавец"
L["MerchantWindowClosed"] = "Окно торговца закрыто. Остановка продаж"

-- Общее
L["vendorMinIlvlDif"] = "Минимальный уровень предмета ниже моего\nсреднего, чтобы отметить его для автоматической продажи"
L["vendorIgnoreBoE"] = "Игнорировать предметы, привязываемые при надевании"
L["vendorIgnoreWarbound"] = "Игнорировать военные предметы"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] =
        "Это позволяет автоматически продавать предметы\nкачества " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r на основе\nкритериев фильтра при посещении торговца."
    L["vendor" .. value .. "Enable"] = "Включить автоматическую продажу предметов\nкачества " .. ITEM_QUALITY_COLORS[key].hex ..
                                           _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
end