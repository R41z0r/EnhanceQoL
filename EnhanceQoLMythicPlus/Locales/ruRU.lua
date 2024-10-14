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
L["noChatOnPullTimer"] =
    "Не отправлять сообщения в чат при\nтаймере начала боя"
L["sliderShortTime"] = "Таймер начала боя правый клик"
L["sliderLongTime"] = "Таймер начала боя"
L["Stating"] = "Запуск..."
L["autoKeyStart"] =
    "Автоматически запускать ключ после\nтаймера начала боя"

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
    "Это позволяет отслеживать кулдаун боевых зелий\nчленов вашей группы в виде перемещаемой полосы"
L["potionTracker"] = "Включить отслеживание кулдауна зелий"
L["potionTrackerUpwardsBar"] = "Рост вверх"
L["potionTrackerClassColor"] = "Использовать цвета классов для полос"
L["potionTrackerDisableRaid"] = "Отключить отслеживание зелий в рейде"

L["Tinker"] = "Инженер"
L["InvisPotion"] = "Невидимость"
L["potionTrackerShowTooltip"] = "Показать подсказку на значке"
L["HealingPotion"] = "Лечение"
L["potionTrackerHealingPotions"] = "Отслеживать КД зелья здоровья"
L["potionTrackerOffhealing"] =
    "Отслеживать использование CD второстепенного исцеления"
-- Инструменты LFG

L["DungeonBrowser"] = "Поиск подземелий"
L["groupfinderAppText"] =
    "Скрыть текст поиска группы \"Ваша группа в настоящее время формируется\""
L["groupfinderSkipRolecheck"] =
    "Пропустить проверку роли\nи использовать текущую роль"

-- Misc Frame
L["Misc"] = "Разное"
L["autoMarkTankInDungeon"] = "Автоматически отмечать " .. TANK .. " в подземельях"
L["autoMarkTankInDungeonMarker"] = "Метка танка"
L["Disabled"] = "Отключено"
L["autoMarkTankExplanation"] = "Будет поставлена метка на " .. TANK ..
                                   ", если\nу него нет метки, и метка изменится только\nв том случае, если вы " ..
                                   COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " или " .. TANK
