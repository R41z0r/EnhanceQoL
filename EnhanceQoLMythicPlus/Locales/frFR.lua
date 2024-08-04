if (GAME_LOCALE or GetLocale()) ~= "frFR" then
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

L["Automatically insert keystone"] = "Insérer automatiquement la clé de voûte"
L["Mythic Plus"] = "Mythique+"
L[addonName] = "Mythique+"
L["Close all bags on keystone insert"] = "Fermer tous les sacs,\nlorsque la clé de voûte est insérée"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Vérification\nde préparation..."
L["PullTimer"] = "Pull Timer"
L["Pull"] = "Pull"
L["Cancel"] = "Annuler"
L["Cancel Pull Timer on click"] = "Annuler le minuteur de pull au clic"
L["noChatOnPullTimer"] = "Pas de messages dans le\nchat pour le minuteur de pull"
L["sliderShortTime"] = "Minuteur de pull clic droit"
L["sliderLongTime"] = "Minuteur de pull"
L["Stating"] = "Démarrage..."
L["autoKeyStart"] = "Démarrer automatiquement la clé de voûte\naprès expiration du minuteur de pull"

L["None"] = "Aucun minuteur de pull"
L["Blizzard Pull Timer"] = "Minuteur de pull Blizzard"
L["DBM / BigWigs Pull Timer"] = "Minuteur de pull DBM / BigWigs"
L["Both"] = "Blizzard et DBM / BigWigs"
L["Pull Timer Type"] = "Type de minuteur de pull"