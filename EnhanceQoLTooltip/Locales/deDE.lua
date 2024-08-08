if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Tooltip"
L[addonName] = "Tooltip"
L["TooltipUnitHideType"] = "Bei Einheiten ausblenden"
L["None"] = "Keines"
L["Enemies"] = "Feinde"
L["Friendly"] = "Freundlich"
L["Both"] = "Beides"
L["TooltipOFF"] = "AUS"
L["TooltipON"] = "AN"

L["TooltipUnitHideInCombat"] = "Einheit nur im Kampf ausblenden"
L["TooltipUnitHideInDungeon"] = "Einheit nur in Dungeons ausblenden"

--Spell
L["TooltipSpellHideType"] = "Bei Zaubern ausblenden"

L["TooltipSpellHideInCombat"] = "Zauber nur im Kampf ausblenden"
L["TooltipSpellHideInDungeon"] = "Zauber nur in Dungeons ausblenden"

--Item
L["TooltipItemHideType"] = "Bei Gegenständen ausblenden"

L["TooltipItemHideInCombat"] = "Gegenstände nur im Kampf ausblenden"
L["TooltipItemHideInDungeon"] = "Gegenstände nur in Dungeons ausblenden"