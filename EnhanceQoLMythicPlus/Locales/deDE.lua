if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    -- return
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
L["Mythic Plus"] = "Mythisch Plus"
L[addonName] = "Mythisch Plus"
L["Close all bags on keystone insert"] = "Schließe alle Taschen,\nwenn der Schlüsselstein eingesetzt wird"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Prüfe Bereitschaft..."
L["Pull"] = "Pull"
L["Cancel"] = "Abbrechen"
L["Cancel Pull Timer on click"] = "Pull Timer bei erneutem Klick abbrechen"
L["noChatOnPullTimer"] = "Keine Chatnachrichten beim Pull Timer"
L["sliderShortTime"] = "Pull Timer rechtsklick"
L["sliderLongTime"] = "Pull Timer"
L["Stating"] = "Starten..."
L["autoKeyStart"] = "Starte den Schlüsselstein automatisch nach\nAblauf des Pull Timers"