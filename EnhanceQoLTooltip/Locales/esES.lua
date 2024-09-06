if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end
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
L["None"] = "Ninguno"
L["Enemies"] = "Enemigos"
L["Friendly"] = "Amistoso"
L["Both"] = "Ambos"
L["TooltipOFF"] = "APAGADO"
L["TooltipON"] = "ENCENDIDO"

-- Tabs
L["Unit"] = "Unidad"
L["Spell"] = "Hechizo"
L["Item"] = "Objeto"
L["Buff"] = "Beneficio"
L["Debuff"] = "Perjuicio"

-- Buff
L["TooltipBuffHideType"] = "Ocultar tooltip en beneficios"
L["TooltipBuffHideInCombat"] = "Ocultar solo en combate"
L["TooltipBuffHideInDungeon"] = "Ocultar solo en mazmorras"

-- Debuff
L["TooltipDebuffHideType"] = "Ocultar tooltip en perjuicios"
L["TooltipDebuffHideInCombat"] = "Ocultar solo en combate"
L["TooltipDebuffHideInDungeon"] = "Ocultar solo en mazmorras"

-- Unit
L["TooltipUnitHideType"] = "Ocultar tooltip en unidades"
L["TooltipUnitHideInCombat"] = "Ocultar solo en combate"
L["TooltipUnitHideInDungeon"] = "Ocultar solo en mazmorras"
L["Mythic+ Score"] = "Puntuación Mítica+"
L["BestMythic+run"] = "Mejor carrera"
L["TooltipShowMythicScore"] = "Mostrar puntuación Mítica+ en el Tooltip"
L["TooltipShowClassColor"] = "Mostrar color de clase en el Tooltip"
L["TooltipShowNPCID"] = "Mostrar ID de NPC"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "Ocultar tooltip en hechizos"

L["TooltipSpellHideInCombat"] = "Ocultar solo en combate"
L["TooltipSpellHideInDungeon"] = "Ocultar solo en mazmorras"

L["TooltipShowSpellID"] = "Mostrar ID de hechizo en el tooltip"
L["SpellID"] = "ID de hechizo"
L["MacroID"] = "ID de macro"

-- Item
L["TooltipItemHideType"] = "Ocultar tooltip en objetos"

L["TooltipItemHideInCombat"] = "Ocultar solo en combate"
L["TooltipItemHideInDungeon"] = "Ocultar solo en mazmorras"

L["ItemID"] = "ID de objeto"
L["TooltipShowItemID"] = "Mostrar ID de objeto en el tooltip"

L["TooltipShowItemCount"] = "Mostrar cantidad de objetos en el tooltip"
L["TooltipShowSeperateItemCount"] = "Mostrar cantidad de objetos por ubicación"
L["Reagentbank"] = "Banco de componentes"
L["Bank"] = "Banco"
L["Bag"] = "Bolsa"
L["Itemcount"] = "Cantidad de objetos"
