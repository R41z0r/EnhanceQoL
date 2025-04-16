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
L["landingPageHide"] = "Включите эту опцию, чтобы скрыть кнопку страницы дополнения на миникарте."
L["automaticallyOpenContainer"] = "Автоматически открывать предметы-контейнеры в сумке"

L["showIlvlOnBankFrame"] = "Отображать уровень предмета в банке"
L["showIlvlOnMerchantframe"] = "Отображать уровень предмета в окне торговца"
L["showIlvlOnCharframe"] = "Отображать уровень предмета на экране экипировки персонажа"
L["showGemsOnCharframe"] = "Отображать гнезда для камней на экране экипировки персонажа"
L["showBindOnBagItems"] = "Отображает "
	.. _G.ITEM_BIND_ON_EQUIP
	.. " (BoE), "
	.. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
	.. " (WuE) и "
	.. _G.ITEM_BNETACCOUNTBOUND
	.. " (WB) в дополнение к уровню предмета"
L["showGemsTooltipOnCharframe"] = "Отображать ячейки для камней в окне экипировки персонажа"
L["showEnchantOnCharframe"] = "Отображать чары на экране экипировки персонажа"
L["showCatalystChargesOnCharframe"] = "Отображать заряды катализатора на экране экипировки персонажа"
L["showIlvlOnBagItems"] = "Отображать уровень предмета на экипировке во всех сумках"
L["showDurabilityOnCharframe"] = "Отображать прочность на окне экипировки персонажа"
L["hideOrderHallBar"] = "Скрыть панель команд оплота"
L["showInfoOnInspectFrame"] = "Показывать дополнительную информацию в окне осмотра"
L["MissingEnchant"] = "Чары"
L["hideHitIndicatorPlayer"] = "Скрыть плавающий текст боя (урон и лечение) над вашим персонажем"
L["hideHitIndicatorPet"] = "Скрыть плавающий текст боя (урон и лечение) над вашим питомцем"
L["UnitFrame"] = "Рамка юнита"
L["SellJunkIgnoredBag"] =
	"Вы отключили продажу хлама в %d сумках.\nЭто может помешать автоматической продаже всех предметов хлама."

L["deleteItemFillDialog"] = 'Добавить "' .. DELETE_ITEM_CONFIRM_STRING .. '" в "Окно подтверждения удаления"'
L["confirmPatronOrderDialog"] = "Автоматически подтверждает использование собственных материалов для заказов у "
	.. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Автоматически принимать и завершать задания"
L["confirmTimerRemovalTrade"] = "Автоматически подтверждать продажу обменной добычи в течение времени для обмена"

L["General"] = "Общий"
L["Character"] = "Персонаж"
L["Dungeon"] = "Подземелье"
L["Misc"] = "Разное"
L["Quest"] = "Задание"

L["hideBagsBar"] = "Скрыть панель сумок"
L["hideMicroMenu"] = "Скрыть микроменю"
-- Dungeon
L["autoChooseDelvePower"] = "Автоматически выбирать силу при исследовании, если есть только один вариант"
L["lfgSortByRio"] = "Сортировать кандидатов в мифик-подземелье по мифик-рейтингу"
L["DungeonBrowser"] = "Поиск подземелий"
L["groupfinderAppText"] = 'Скрыть текст поиска группы "Ваша группа в настоящее время формируется"'
L["groupfinderMoveResetButton"] = "Переместите кнопку сброса фильтра в окне поиска подземелий на левую сторону."
L["groupfinderSkipRoleSelect"] = "Пропустить выбор роли"
L["groupfinderSkipRolecheckHeadline"] = "Автоматический выбор роли"
L["groupfinderSkipRolecheckUseSpec"] = "Использовать роль текущей специализации (напр. Рыцарь смерти (Кровь) = танк)"
L["groupfinderSkipRolecheckUseLFD"] = "Использовать роли из поиска подземелий"
L["groupfinderShowDungeonScoreFrame"] = "Показать рамку " .. DUNGEON_SCORE .. " рядом с Поиском подземелий"
L["groupfinderShowPartyKeystone"] = "Показывать информацию о ключах Mythic+ у членов группы"

-- Quest
L["ignoreTrivialQuests"] = "Не обрабатывать автоматически тривиальные " .. QUESTS_LABEL
L["ignoreDailyQuests"] = "Не обрабатывать автоматически ежедневные/еженедельные " .. QUESTS_LABEL
L["ignoreWarbandCompleted"] = "Не обрабатывать автоматически " .. ACCOUNT_COMPLETED_QUEST_LABEL .. " " .. QUESTS_LABEL

L["autoQuickLoot"] = "Быстрое получение предметов"
L["openCharframeOnUpgrade"] = "Открыть окно персонажа при улучшении предметов у торговца"

L["headerClassInfo"] = "Эти настройки применяются только к " .. select(1, UnitClass("player"))

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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Шаман
L["shaman_HideTotem"] = "Скрыть панель тотемов"

-- Чернокнижник
L["warlock_HideSoulShardBar"] = "Скрыть панель осколков душ"

L["questAddNPCToExclude"] = "Добавить выбранного NPC/открытое окно общения в список исключений"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Требуется перезагрузка интерфейса"
L["bReloadInterface"] = "Вам нужно перезагрузить интерфейс, чтобы применить изменения"

L["CVarOptions"] = {
	["autoDismount"] = {
		trueValue = "1",
		falseValue = "0",
		description = "Включить автоматическое спешивание при использовании способностей",
	},
	["autoDismountFlying"] = {
		trueValue = "1",
		falseValue = "0",
		description = "Включить автоматическое спешивание в полете",
	},
	["chatMouseScroll"] = { description = "Включить прокрутку чата мышью", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Отключить эффекты смерти", trueValue = "0", falseValue = "1" },
	["mapFade"] = {
		trueValue = "1",
		falseValue = "0",
		description = "Включить затухание карты при движении",
	},
	["scriptErrors"] = { description = "Показывать ошибки LUA в интерфейсе", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = {
		description = "Показывать цвета классов на индикаторах",
		trueValue = "1",
		falseValue = "0",
	},
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Показывать панель заклинаний цели" },
	["showTutorials"] = { description = "Отключить обучение", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Включить расширенные подсказки", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Показывать гильдию игроков" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Показывать титул игроков" },
	["WholeChatWindowClickable"] = { description = "Сделать весь чат кликабельным", trueValue = "1", falseValue = "0" },
	["addonProfilerEnabled"] = {
		description = "Включить профилирование аддонов от Blizzard (требует много ресурсов ЦП)",
		trueValue = "1",
		falseValue = "0",
		register = true,
	},
}

L["autoAcceptGroupInvite"] = "Автоматически принимать приглашения в группу"
L["autoAcceptGroupInviteGuildOnly"] = "Члены гильдии"
L["autoAcceptGroupInviteFriendOnly"] = "Друзья"
L["autoAcceptGroupInviteOptions"] = "Принимать приглашения от..."

L["showLeaderIconRaidFrame"] = "Показывать значок лидера в рейдовых групповых фреймах"

L["ActionbarHideExplain"] = 'Сделайте панель команд скрытой и показываемой при наведении мыши. Это работает только если ваша панель настроена на "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"]
	.. '" и "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"]
	.. '" в '
	.. _G["HUD_EDIT_MODE_MENU"]
	.. "."

L["enableMinimapButtonBin"] = "Включить сборщик кнопок мини-карты"
L["enableMinimapButtonBinDesc"] = "Собирает все кнопки мини-карты в одну кнопку"
L["ignoreMinimapSinkHole"] = "Игнорировать следующие кнопки мини-карты при сборе..."
L["useMinimapButtonBinIcon"] = "Использовать кнопку на мини-карте для сборщика"
L["useMinimapButtonBinMouseover"] = "Показать перемещаемое окно при наведении для сборщика"
L["lockMinimapButtonBin"] = "Зафиксировать окно сборщика"

L["UnitFrameHideExplain"] = "Скрыть элемент и показывать только при наведении курсора"
L["chatFrameFadeEnabled"] = "Включить постепенное скрытие чата"
L["chatFrameFadeTimeVisibleText"] = "Текст остаётся видимым в течение"
L["chatFrameFadeDurationText"] = "Продолжительность анимации исчезновения"

L["enableLootspecQuickswitch"] = "Включить быстрый выбор добычи и активной специализации на миникарте"
L["enableLootspecQuickswitchDesc"] = "ЛКМ по специализации для выбора добычи, ПКМ — чтобы сменить активную специализацию."
