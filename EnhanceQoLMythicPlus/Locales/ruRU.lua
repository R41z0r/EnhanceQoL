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
local L = addon.LMythicPlus

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
L["noChatOnPullTimer"] = "Не отправлять сообщения в чат при\nтаймере начала боя"
L["sliderShortTime"] = "Таймер начала боя правый клик"
L["sliderLongTime"] = "Таймер начала боя"
L["Stating"] = "Запуск..."
L["autoKeyStart"] = "Автоматически запускать ключ после\nтаймера начала боя"

L["None"] = "Нет таймера начала боя"
L["Blizzard Pull Timer"] = "Таймер начала боя Blizzard"
L["DBM / BigWigs Pull Timer"] = "Таймер начала боя DBM / BigWigs"
L["Both"] = "Blizzard и DBM / BigWigs"
L["Pull Timer Type"] = "Тип таймера начала боя"