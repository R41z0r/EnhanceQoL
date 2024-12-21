if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

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
L["landingPageHide"] =
    "Включите эту опцию, чтобы скрыть\nкнопку страницы дополнения на миникарте."

L["showIlvlOnCharframe"] =
    "Отображать уровень предмета на экране экипировки персонажа"
L["showGemsOnCharframe"] =
    "Отображать гнезда для камней на экране экипировки персонажа"
L["showEnchantOnCharframe"] = "Отображать чары на экране экипировки персонажа"
L["showCatalystChargesOnCharframe"] =
    "Отображать заряды катализатора на экране экипировки персонажа"
L["showIlvlOnBagItems"] =
    "Отображать уровень предмета на экипировке во всех сумках"
L["showDurabilityOnCharframe"] =
    "Отображать прочность на окне экипировки персонажа"
L["hideOrderHallBar"] = "Скрыть панель команд оплота"
L["showInfoOnInspectFrame"] =
    "Показывать дополнительную информацию в окне осмотра (Экспериментально)"
L["MissingEnchant"] = "Чары"

L["deleteItemFillDialog"] = "Добавить \"" .. DELETE_ITEM_CONFIRM_STRING ..
                                "\" в \"Окно подтверждения удаления\""
L["autoChooseQuest"] = "Автоматически принимать и завершать задания"

L["General"] = "Общий"
L["Character"] = "Персонаж"
L["Dungeon"] = "Подземелье"
L["Misc"] = "Разное"
L["Quest"] = "Задание"

L["hideBagsBar"] = "Скрыть панель сумок"

-- Dungeon
L["autoChooseDelvePower"] =
    "Автоматически выбирать силу при исследовании,\nесли есть только один вариант"
L["lfgSortByRio"] =
    "Сортировать кандидатов в мифик-подземелье по мифик-рейтингу"

-- Quest
L["ignoreTrivialQuests"] = "Игнорировать тривиальные задания"
L["ignoreDailyQuests"] = "Игнорировать ежедневные/еженедельные задания"

L["autoQuickLoot"] = "Быстрое получение предметов"
L["openCharframeOnUpgrade"] =
    "Открыть окно персонажа при улучшении предметов у торговца"

L["headerClassInfo"] = "Эти настройки применяются только к " ..
                           select(1, UnitClass("player"))

-- Рыцарь смерти
L["deathknight_HideRuneFrame"] = "Скрыть панель рун"

-- Пробудитель
L["evoker_HideEssence"] = "Скрыть панель эссенции"

-- Монах
L["monk_HideHarmonyBar"] = "Скрыть панель гармонии"

-- Паладин
L["paladin_HideHolyPower"] = "Скрыть панель священной силы"

-- Разбойник
L["rogue_HideComboPoint"] = "Скрыть панель очков серии"

-- Шаман
L["shaman_HideTotem"] = "Скрыть панель тотемов"

-- Чернокнижник
L["warlock_HideSoulShardBar"] = "Скрыть панель осколков душ"

L["questAddNPCToExclude"] =
    "Добавить выбранного NPC/открытое окно общения в список исключений"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Требуется перезагрузка интерфейса"
L["bReloadInterface"] =
    "Вам нужно перезагрузить интерфейс, чтобы применить изменения"

L["CVarOptions"] = {["autoDismount"] = {trueValue = "1", falseValue = "0",
                                        description = "Включить автоматическое спешивание при использовании способностей"},
                    ["autoDismountFlying"] = {trueValue = "1", falseValue = "0",
                                              description = "Включить автоматическое спешивание в полете"},
                    ["chatMouseScroll"] = {description = "Включить прокрутку чата мышью",
                                           trueValue = "1", falseValue = "0"},
                    ["ffxDeath"] = {description = "Отключить эффекты смерти", trueValue = "0",
                                    falseValue = "1"}, ["mapFade"] = {trueValue = "1", falseValue = "0",
                                                                      description = "Включить затухание карты при движении"},
                    ["scriptErrors"] = {description = "Показывать ошибки LUA в интерфейсе",
                                        trueValue = "1", falseValue = "0"},
                    ["ShowClassColorInNameplate"] = {description = "Показывать цвета классов на индикаторах",
                                                     trueValue = "1", falseValue = "0"},
                    ["ShowTargetCastbar"] = {trueValue = "1", falseValue = "0",
                                             description = "Показывать панель заклинаний цели"},
                    ["showTutorials"] = {description = "Отключить обучение", trueValue = "0",
                                         falseValue = "1"},
                    ["UberTooltips"] = {description = "Включить расширенные подсказки",
                                        trueValue = "1", falseValue = "0"},
                    ["UnitNamePlayerGuild"] = {trueValue = "1", falseValue = "0",
                                               description = "Показывать гильдию игроков"},
                    ["UnitNamePlayerPVPTitle"] = {trueValue = "1", falseValue = "0",
                                                  description = "Показывать титул игроков"},
                    ["WholeChatWindowClickable"] = {description = "Сделать весь чат кликабельным",
                                                    trueValue = "1", falseValue = "0"}}
