if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
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
L["TooltipUnitHideType"] = "Ocultar em Unidade"
L["None"] = "Nenhum"
L["Enemies"] = "Inimigos"
L["Friendly"] = "Amigável"
L["Both"] = "Ambos"
L["TooltipOFF"] = "DESLIGADO"
L["TooltipON"] = "LIGADO"

L["TooltipUnitHideInCombat"] = "Ocultar unidade apenas em combate"
L["TooltipUnitHideInDungeon"] = "Ocultar unidade apenas em masmorras"

--Spell
L["TooltipSpellHideType"] = "Ocultar em Feitiços"

L["TooltipSpellHideInCombat"] = "Ocultar feitiços apenas em combate"
L["TooltipSpellHideInDungeon"] = "Ocultar feitiços apenas em masmorras"

--Item
L["TooltipItemHideType"] = "Ocultar em Itens"

L["TooltipItemHideInCombat"] = "Ocultar itens apenas em combate"
L["TooltipItemHideInDungeon"] = "Ocultar itens apenas em masmorras"