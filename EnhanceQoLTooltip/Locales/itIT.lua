if (GAME_LOCALE or GetLocale()) ~= "itIT" then
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

L["Tooltip"] = "Descrizione comandi"
L[addonName] = "Descrizione comandi"
L["None"] = "Nessuno"
L["Enemies"] = "Nemici"
L["Friendly"] = "Amichevole"
L["Both"] = "Entrambi"
L["TooltipOFF"] = "SPENTO"
L["TooltipON"] = "ACCESO"

-- Tabs
L["Unit"] = "Unità"
L["Spell"] = "Incantesimo"
L["Item"] = "Oggetto"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"

-- Buff
L["TooltipBuffHideType"] = "Nascondi tooltip su buff"
L["TooltipBuffHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipBuffHideInDungeon"] = "Nascondi solo nei dungeon"

-- Debuff
L["TooltipDebuffHideType"] = "Nascondi tooltip su debuff"
L["TooltipDebuffHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipDebuffHideInDungeon"] = "Nascondi solo nei dungeon"

-- Unit
L["TooltipUnitHideType"] = "Nascondi tooltip su unità"
L["TooltipUnitHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipUnitHideInDungeon"] = "Nascondi solo nei dungeon"

-- Spell
L["TooltipSpellHideType"] = "Nascondi tooltip su incantesimi"

L["TooltipSpellHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipSpellHideInDungeon"] = "Nascondi solo nei dungeon"

-- Item
L["TooltipItemHideType"] = "Nascondi tooltip su oggetti"

L["TooltipItemHideInCombat"] = "Nascondi solo in combattimento"
L["TooltipItemHideInDungeon"] = "Nascondi solo nei dungeon"