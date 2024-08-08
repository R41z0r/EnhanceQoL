if (GAME_LOCALE or GetLocale()) ~= "frFR" then
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

L["Tooltip"] = "Infobulle"
L[addonName] = "Infobulle"
L["TooltipUnitHideType"] = "Masquer sur Unité"
L["None"] = "Aucun"
L["Enemies"] = "Ennemis"
L["Friendly"] = "Amical"
L["Both"] = "Les deux"
L["TooltipOFF"] = "DÉSACTIVÉ"
L["TooltipON"] = "ACTIVÉ"

L["TooltipUnitHideInCombat"] = "Masquer unité seulement en combat"
L["TooltipUnitHideInDungeon"] = "Masquer unité seulement dans les donjons"

--Spell
L["TooltipSpellHideType"] = "Masquer sur Sorts"

L["TooltipSpellHideInCombat"] = "Masquer les sorts seulement en combat"
L["TooltipSpellHideInDungeon"] = "Masquer les sorts seulement dans les donjons"

--Item
L["TooltipItemHideType"] = "Masquer sur Objets"

L["TooltipItemHideInCombat"] = "Masquer les objets seulement en combat"
L["TooltipItemHideInDungeon"] = "Masquer les objets seulement dans les donjons"