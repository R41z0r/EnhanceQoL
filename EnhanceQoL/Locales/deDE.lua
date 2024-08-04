if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
  end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Schnellanmeldung für Dungeon-Such-Tool"
L["Persist LFG signup note"] = "Dungeon-Such-Tool Notiz wiederverwenden"
L["Select an option"] = "Bitte auswählen"
L["Save"] = "Speichern"