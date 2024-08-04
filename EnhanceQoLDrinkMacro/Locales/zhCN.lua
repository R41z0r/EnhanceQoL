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
local L = addon.LDrinkMacro

L["Prefer mage food"] = "偏爱法师食物"
L["Minimum mana restore for food"] = "食物的最低法力恢复"
L["Ignore bufffood"] = "忽略“吃饱喝足”的食物"
L["Drink Macro"] = "饮料宏"
L[addonName] = "饮料宏"
