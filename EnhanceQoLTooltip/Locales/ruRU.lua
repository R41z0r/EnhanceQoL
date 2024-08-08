if (GAME_LOCALE or GetLocale()) ~= "ruRU" then
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

L["Tooltip"] = "Подсказка"
L[addonName] = "Подсказка"
L["TooltipUnitHideType"] = "Скрыть на юните"
L["None"] = "Нет"
L["Enemies"] = "Враги"
L["Friendly"] = "Дружественный"
L["Both"] = "Оба"
L["TooltipOFF"] = "ВЫКЛ"
L["TooltipON"] = "ВКЛ"

L["TooltipUnitHideInCombat"] = "Скрывать юнит только в бою"
L["TooltipUnitHideInDungeon"] = "Скрывать юнит только в подземельях"

--Spell
L["TooltipSpellHideType"] = "Скрыть на заклинаниях"

L["TooltipSpellHideInCombat"] = "Скрывать заклинания только в бою"
L["TooltipSpellHideInDungeon"] = "Скрывать заклинания только в подземельях"

--Item
L["TooltipItemHideType"] = "Скрыть на предметах"

L["TooltipItemHideInCombat"] = "Скрывать предметы только в бою"
L["TooltipItemHideInDungeon"] = "Скрывать предметы только в подземельях"