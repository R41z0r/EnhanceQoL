if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "偏愛法師食物"
L["Minimum mana restore for food"] = "食物的最低法力恢復"
L["Ignore bufffood"] = "忽略“吃飽喝足”的食物"
L["Drink Macro"] = "飲料巨集"
L["ignoreGemsEarthen"] = "忽略土灵种族的珠宝工艺宝石"
