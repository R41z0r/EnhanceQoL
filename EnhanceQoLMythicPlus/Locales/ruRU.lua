if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Ключевой камень"
L["Automatically insert keystone"] = "Автоматически вставлять ключ"
L["Mythic Plus"] = "Мифик+"
L[addonName] = "Мифик+"
L["Close all bags on keystone insert"] = "Закрыть все сумки при вставке ключа"
L["ReadyCheck"] = "Проверка готовности"
L["ReadyCheckWaiting"] = "Проверка готовности..."
L["PullTimer"] = "Таймер начала боя"
L["Pull"] = "Начало боя"
L["Cancel"] = "Отмена"
L["Cancel Pull Timer on click"] = "Отменить таймер начала боя при нажатии"
L["noChatOnPullTimer"] = "Не отправлять сообщения в чат при таймере начала боя"
L["sliderShortTime"] = "Таймер начала боя правый клик"
L["sliderLongTime"] = "Таймер начала боя"
L["Stating"] = "Запуск..."
L["autoKeyStart"] = "Автоматически запускать ключ после таймера начала боя"
L["mythicPlusTruePercent"] = "Показывать десятичное значение вражеских сил"
L["mythicPlusChestTimer"] = "Показывать таймеры сундуков"

L["None"] = "Нет таймера начала боя"
L["Blizzard Pull Timer"] = "Таймер начала боя Blizzard"
L["DBM / BigWigs Pull Timer"] = "Таймер начала боя DBM / BigWigs"
L["Both"] = "Blizzard и DBM / BigWigs"
L["Pull Timer Type"] = "Тип таймера начала боя"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Перетащи меня"
L["Potion Tracker"] = "Отслеживание зелий"
L["Toggle Anchor"] = "Переключить якорь"
L["Save Anchor"] = "Сохранить якорь"
L["potionTrackerHeadline"] =
	"Это позволяет отслеживать кулдаун боевых зелий членов вашей группы в виде перемещаемой полосы"
L["potionTracker"] = "Включить отслеживание кулдауна зелий"
L["potionTrackerUpwardsBar"] = "Рост вверх"
L["potionTrackerClassColor"] = "Использовать цвета классов для полос"
L["potionTrackerDisableRaid"] = "Отключить отслеживание зелий в рейде"

L["Tinker"] = "Инженер"
L["InvisPotion"] = "Невидимость"
L["potionTrackerShowTooltip"] = "Показать подсказку на значке"
L["HealingPotion"] = "Лечение"
L["potionTrackerHealingPotions"] = "Отслеживать КД зелья здоровья"
L["potionTrackerOffhealing"] = "Отслеживать использование CD второстепенного исцеления"
-- Инструменты LFG

L["DungeonBrowser"] = "Поиск подземелий"
L["groupfinderAppText"] = 'Скрыть текст поиска группы "Ваша группа в настоящее время формируется"'
L["groupfinderSkipRolecheck"] = "Пропустить проверку роли и использовать текущую роль"
L["groupfinderMoveResetButton"] = "Переместите кнопку сброса фильтра в окне поиска подземелий на левую сторону."

-- Misc Frame
L["Misc"] = "Разное"
L["autoMarkTankInDungeon"] = "Автоматически отмечать " .. TANK .. " в подземельях"
L["autoMarkTankInDungeonMarker"] = "Метка танка"
L["Disabled"] = "Отключено"
L["autoMarkTankExplanation"] = "Будет поставлена метка на "
	.. TANK
	.. ", если у него нет метки, и метка изменится только в том случае, если вы "
	.. COMMUNITY_MEMBER_ROLE_NAME_LEADER
	.. " или "
	.. TANK
L["mythicPlusIgnoreMythic"] = "Не применять метку рейда в подземельях " .. PLAYER_DIFFICULTY6
L["mythicPlusIgnoreHeroic"] = "Не применять метку рейда в подземельях " .. PLAYER_DIFFICULTY2
L["mythicPlusIgnoreEvent"] = "Не применять метку рейда в подземельях " .. BATTLE_PET_SOURCE_7
L["mythicPlusIgnoreNormal"] = "Не применять метку рейда в подземельях " .. PLAYER_DIFFICULTY1
L["mythicPlusIgnoreTimewalking"] = "Не применять метку рейда в подземельях " .. PLAYER_DIFFICULTY_TIMEWALKER

-- Teleports
L["Teleports"] = "Телепорты"
L["teleportEnabled"] = "Включить окно телепортации"
L["DungeonCompendium"] = "Справочник по телепортам"
L["teleportsEnableCompendium"] = "Включить справочник по телепортам"

L["teleportsHeadline"] = "Добавляет окно с телепортами в подземелья в ваше PvE-окно"
L["portalHideMissing"] = "Скрыть отсутствующие телепорты"
L["portalShowTooltip"] = "Показывать подсказки на кнопках телепортов"
L["hideActualSeason"] = "Скрыть телепорты текущего сезона в " .. L["DungeonCompendium"]
