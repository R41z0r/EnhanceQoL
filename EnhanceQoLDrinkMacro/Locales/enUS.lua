local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Prefer mage food"
L["Minimum mana restore for food"] = "Minimum mana restore for food"
L["Ignore bufffood"] = 'Ignore "Well Fed" food'
L["Drink Macro"] = "Drink Macro"
L[addonName] = "Drink Macro"
L["ignoreGemsEarthen"] = "Ignore Jewelcrafting Gems for Earthen Race"
L["mageFoodReminder"] = "Show reminder to get mage food from follower dungeon"
L["mageFoodReminderDesc"] = "Click the reminder to automatically queue for follower dungeon"
L["mageFoodReminderText"] = "Get Mage food from follower Dungeon\n\nClick to automatically queue"
