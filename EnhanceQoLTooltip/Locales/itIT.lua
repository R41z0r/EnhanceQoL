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
L["TooltipUnitHideType"] = "Nascondi su Unità"
L["None"] = "Nessuno"
L["Enemies"] = "Nemici"
L["Friendly"] = "Amichevole"
L["Both"] = "Entrambi"
L["TooltipOFF"] = "SPENTO"
L["TooltipON"] = "ACCESO"

L["TooltipUnitHideInCombat"] = "Nascondi unità solo in combattimento"
L["TooltipUnitHideInDungeon"] = "Nascondi unità solo in spedizioni"

--Spell
L["TooltipSpellHideType"] = "Nascondi su Incantesimi"

L["TooltipSpellHideInCombat"] = "Nascondi incantesimi solo in combattimento"
L["TooltipSpellHideInDungeon"] = "Nascondi incantesimi solo in spedizioni"

--Item
L["TooltipItemHideType"] = "Nascondi su Oggetti"

L["TooltipItemHideInCombat"] = "Nascondi oggetti solo in combattimento"
L["TooltipItemHideInDungeon"] = "Nascondi oggetti solo in spedizioni"