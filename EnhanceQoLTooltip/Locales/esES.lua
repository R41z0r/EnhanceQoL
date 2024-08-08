if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then
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
L["TooltipUnitHideType"] = "Ocultar en Unidad"
L["None"] = "Ninguno"
L["Enemies"] = "Enemigos"
L["Friendly"] = "Amistoso"
L["Both"] = "Ambos"
L["TooltipOFF"] = "APAGADO"
L["TooltipON"] = "ENCENDIDO"

L["TooltipUnitHideInCombat"] = "Ocultar unidad solo en combate"
L["TooltipUnitHideInDungeon"] = "Ocultar unidad solo en mazmorras"

--Spell
L["TooltipSpellHideType"] = "Ocultar en Hechizos"

L["TooltipSpellHideInCombat"] = "Ocultar hechizos solo en combate"
L["TooltipSpellHideInDungeon"] = "Ocultar hechizos solo en mazmorras"

--Item
L["TooltipItemHideType"] = "Ocultar en Objetos"

L["TooltipItemHideInCombat"] = "Ocultar objetos solo en combate"
L["TooltipItemHideInDungeon"] = "Ocultar objetos solo en mazmorras"
