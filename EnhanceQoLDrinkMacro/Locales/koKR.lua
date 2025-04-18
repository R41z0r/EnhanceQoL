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
L["Ignore bufffood"] = '"잘 먹었다" 음식 무시'
L["Drink Macro"] = "음료 매크로"
L[addonName] = "음료 매크로"
L["ignoreGemsEarthen"] = "토석인을 위한 보석세공 보석 무시"
L["mageFoodReminder"] = "추종자 던전에서 마법사 음식을 얻도록 알림 표시"
L["mageFoodReminderDesc"] = "알림을 클릭하여 추종자 던전에 자동으로 대기열에 참여"
L["mageFoodReminderText"] = "추종자 던전에서 마법사 음식을 얻기\n\n클릭하여 자동으로 대기열 참여"
