if (GAME_LOCALE or GetLocale()) ~= "deDE" then
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

L["Automatically insert keystone"] = "Schlüsselstein automatisch einsetzen"
L["Mythic Plus"] = "Mythisch+"
L[addonName] = "Mythisch+"
L["Close all bags on keystone insert"] = "Schließe alle Taschen,\nwenn der Schlüsselstein eingesetzt wird"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Prüfe Bereitschaft..."
L["PullTimer"] = "Pull Timer"
L["Pull"] = "Pull"
L["Cancel"] = "Abbrechen"
L["Cancel Pull Timer on click"] = "Pull Timer bei erneutem Klick abbrechen"
L["noChatOnPullTimer"] = "Keine Chatnachrichten beim Pull Timer"
L["sliderShortTime"] = "Pull Timer rechtsklick"
L["sliderLongTime"] = "Pull Timer"
L["Stating"] = "Starten..."
L["autoKeyStart"] = "Starte den Schlüsselstein automatisch nach\nAblauf des Pull Timers"

L["None"] = "Kein Pull Timer"
L["Blizzard Pull Timer"] = "Blizzard Pull Timer"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs Pull Timer"
L["Both"] = "Blizzard und DBM / BigWigs"
L["Pull Timer Type"] = "Pull Timer Typ"
