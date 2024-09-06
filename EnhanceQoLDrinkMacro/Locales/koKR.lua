if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "마법사 음식 선호"
L["Minimum mana restore for food"] = "음식의 최소 마나 회복량"
L["Ignore bufffood"] = "\"잘 먹었다\" 음식 무시"
L["Drink Macro"] = "음료 매크로"
L[addonName] = "음료 매크로"
L["ignoreGemsEarthen"] = "토석인을 위한 보석세공 보석 무시"
