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
L["None"] = "Aucun"
L["Enemies"] = "Ennemis"
L["Friendly"] = "Amical"
L["Both"] = "Les deux"
L["TooltipOFF"] = "DÉSACTIVÉ"
L["TooltipON"] = "ACTIVÉ"

-- Tabs
L["Unit"] = "Unité"
L["Spell"] = "Sort"
L["Item"] = "Objet"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"

-- Buff
L["TooltipBuffHideType"] = "Masquer l'infobulle sur les buffs"
L["TooltipBuffHideInCombat"] = "Masquer uniquement en combat"
L["TooltipBuffHideInDungeon"] = "Masquer uniquement en donjons"

-- Debuff
L["TooltipDebuffHideType"] = "Masquer l'infobulle sur les debuffs"
L["TooltipDebuffHideInCombat"] = "Masquer uniquement en combat"
L["TooltipDebuffHideInDungeon"] = "Masquer uniquement en donjons"

-- Unit
L["TooltipUnitHideType"] = "Masquer l'infobulle sur les unités"
L["TooltipUnitHideInCombat"] = "Masquer uniquement en combat"
L["TooltipUnitHideInDungeon"] = "Masquer uniquement en donjons"
L["Mythic+ Score"] = "Score Mythique+"
L["BestMythic+run"] = "Meilleure course"
L["TooltipShowMythicScore"] = "Afficher le score Mythique+ dans l'infobulle"
L["TooltipShowClassColor"] = "Afficher la couleur de la classe dans l'infobulle"

-- Spell
L["TooltipSpellHideType"] = "Masquer l'infobulle sur les sorts"

L["TooltipSpellHideInCombat"] = "Masquer uniquement en combat"
L["TooltipSpellHideInDungeon"] = "Masquer uniquement en donjons"

L["TooltipShowSpellID"] = "Afficher l'ID du sort dans l'infobulle"
L["SpellID"] = "ID du sort"
L["MacroID"] = "ID du macro"

-- Item
L["TooltipItemHideType"] = "Masquer l'infobulle sur les objets"

L["TooltipItemHideInCombat"] = "Masquer uniquement en combat"
L["TooltipItemHideInDungeon"] = "Masquer uniquement en donjons"

L["ItemID"] = "ID de l'objet"
L["TooltipShowItemID"] = "Afficher l'ID de l'objet dans l'infobulle"
