if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

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
L["ignoreGemsEarthen"] = "忽略土灵种族的珠宝工艺宝石"
L["mageFoodReminder"] = "显示提醒以从追随者地城获取法师食物"
L["mageFoodReminderDesc"] = "点击提醒以自动排队进入追随者地城"
L["mageFoodReminderText"] = "从追随者地城获取法师食物\n\n点击以自动加入队列"
