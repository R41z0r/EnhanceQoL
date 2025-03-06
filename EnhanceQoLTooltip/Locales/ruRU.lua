if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

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
L["None"] = "Нет"
L["Enemies"] = "Враги"
L["Friendly"] = "Дружественные"
L["Both"] = "Оба"
L["TooltipOFF"] = "ВЫКЛ"
L["TooltipON"] = "ВКЛ"
L["TooltipAnchorType"] = "Позиция подсказки"
L["CursorCenter"] = "По центру курсора"
L["CursorLeft"] = "Слева от курсора"
L["CursorRight"] = "Справа от курсора"
L["TooltipAnchorOffsetX"] = "Горизонтальное смещение"
L["TooltipAnchorOffsetY"] = "Вертикальное смещение"

-- Tabs
L["Unit"] = "Единица"
L["Spell"] = "Заклинание"
L["Item"] = "Предмет"
L["Buff"] = "Бафф"
L["Debuff"] = "Дебафф"
L["Buff_Debuff"] = L["Buff"] .. "/" .. L["Debuff"]

-- Buff
L["TooltipBuffHideType"] = "Скрыть подсказку на " .. L["Buff_Debuff"]
L["TooltipBuffHideInCombat"] = "Скрывать только в бою"
L["TooltipBuffHideInDungeon"] = "Скрывать только в подземельях"

-- Debuff
L["TooltipDebuffHideType"] = "Скрыть подсказку на дебаффы"
L["TooltipDebuffHideInCombat"] = "Скрывать только в бою"
L["TooltipDebuffHideInDungeon"] = "Скрывать только в подземельях"

-- Unit
L["TooltipUnitHideType"] = "Скрыть подсказку на единицы"
L["TooltipUnitHideInCombat"] = "Скрывать только в бою"
L["TooltipUnitHideInDungeon"] = "Скрывать только в подземельях"
L["BestMythic+run"] = "Лучший забег"
L["TooltipShowMythicScore"] = "Показывать " .. DUNGEON_SCORE .. " в подсказке"
L["TooltipShowClassColor"] = "Показывать цвет класса в подсказке"
L["TooltipShowNPCID"] = "Показать ID NPC"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "Скрыть подсказку на заклинания"

L["TooltipSpellHideInCombat"] = "Скрывать только в бою"
L["TooltipSpellHideInDungeon"] = "Скрывать только в подземельях"

L["TooltipShowSpellID"] = "Показать ID заклинания в подсказке"
L["SpellID"] = "ID заклинания"
L["MacroID"] = "ID макроса"

-- Item
L["TooltipItemHideType"] = "Скрыть подсказку на предметы"

L["TooltipItemHideInCombat"] = "Скрывать только в бою"
L["TooltipItemHideInDungeon"] = "Скрывать только в подземельях"

L["ItemID"] = "ID предмета"
L["TooltipShowItemID"] = "Показать ID предмета в подсказке"

L["TooltipShowItemCount"] = "Показать количество предметов в подсказке"
L["TooltipShowSeperateItemCount"] = "Показать количество предметов по отдельным местам"
L["Reagentbank"] = "Банк реагентов"
L["Bank"] = "Банк"
L["Bag"] = "Сумка"
L["Itemcount"] = "Количество предметов"
