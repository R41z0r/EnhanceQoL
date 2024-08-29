if (GAME_LOCALE or GetLocale()) ~= "ruRU" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Быстрая запись"
L["Persist LFG signup note"] = "Сохранять заметку LFG"
L["Select an option"] = "Выберите вариант"
L["Save"] = "Сохранить"
L["Hide Minimap Button"] = "Скрыть кнопку мини-карты"
L["Left-Click to show options"] = "Щелкните левой кнопкой для показа опций"

L["Hide Raid Tools"] = "Скрыть рейдовые инструменты в группе"
L["repairCost"] = "Отремонтировано предметов на сумму "
L["autoRepair"] = "Автоматически ремонтировать все предметы"
L["sellAllJunk"] = "Автоматически продавать весь мусор"
L["ignoreTalkingHead"] = "Автоматически скрывать Talking Head Frame"

L["showIlvlOnCharframe"] =
    "Отображать уровень предмета на экране экипировки персонажа"
L["showGemsOnCharframe"] =
    "Отображать гнезда для камней на экране экипировки персонажа"
L["showEnchantOnCharframe"] = "Отображать чары на экране экипировки персонажа"

L["deleteItemFillDialog"] = "Добавить \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" в \"Окно подтверждения удаления\""
L["autoChooseQuest"] = "Автоматически принимать и завершать задания"

L["General"] = "Общий"
L["Character"] = "Персонаж"
L["Dungeon"] = "Подземелье"
L["Misc"] = "Разное"
L["Quest"] = "Задание"

-- Dungeon
L["autoChooseDelvePower"] =
    "Автоматически выбирать силу при исследовании,\nесли есть только один вариант"

-- Quest
L["ignoreTrivialQuests"] = "Игнорировать тривиальные задания"
