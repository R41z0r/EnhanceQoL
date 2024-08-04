if (GAME_LOCALE or GetLocale()) ~= "itIT" then
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

L["Automatically insert keystone"] = "Inserisci automaticamente la chiave"
L["Mythic Plus"] = "Mitica+"
L[addonName] = "Mitica+"
L["Close all bags on keystone insert"] = "Chiudi tutte le borse all'inserimento della chiave"
L["ReadyCheck"] = "Controllo di prontezza"
L["ReadyCheckWaiting"] = "Verifica della prontezza in corso..."
L["PullTimer"] = "Timer di pull"
L["Pull"] = "Pull"
L["Cancel"] = "Annulla"
L["Cancel Pull Timer on click"] = "Annulla il timer di pull al clic"
L["noChatOnPullTimer"] = "Nessun messaggio di chat sul timer di pull"
L["sliderShortTime"] = "Timer di pull clic destro"
L["sliderLongTime"] = "Timer di pull"
L["Stating"] = "Inizio..."
L["autoKeyStart"] = "Avvia automaticamente la chiave\ndopo il timer di pull"

L["None"] = "Nessun timer di pull"
L["Blizzard Pull Timer"] = "Timer di pull Blizzard"
L["DBM / BigWigs Pull Timer"] = "Timer di pull DBM / BigWigs"
L["Both"] = "Blizzard e DBM / BigWigs"
L["Pull Timer Type"] = "Tipo di timer di pull"