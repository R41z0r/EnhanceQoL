local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Tooltip"
L[addonName] = "Tooltip"
L["TooltipUnitHideType"] = "Hide on Unit"
L["None"] = "None"
L["Enemies"] = "Enemies"
L["Friendly"] = "Friendly"
L["Both"] = "Both"
L["TooltipOFF"] = "OFF"
L["TooltipON"] = "ON"

L["TooltipUnitHideInCombat"] = "Only hide Unit in combat"
L["TooltipUnitHideInDungeon"] = "Only hide Unit in dungeons"

--Spell
L["TooltipSpellHideType"] = "Hide on Spells"

L["TooltipSpellHideInCombat"] = "Only hide spell in combat"
L["TooltipSpellHideInDungeon"] = "Only hide spell in dungeon"

--Item
L["TooltipItemHideType"] = "Hide on Items"

L["TooltipItemHideInCombat"] = "Only hide items in combat"
L["TooltipItemHideInDungeon"] = "Only hide items in dungeon"

