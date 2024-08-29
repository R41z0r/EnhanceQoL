if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Schnellanmeldung für Dungeon-Such-Tool"
L["Persist LFG signup note"] = "Dungeon-Such-Tool Notiz wiederverwenden"
L["Select an option"] = "Bitte auswählen"
L["Save"] = "Speichern"
L["Hide Minimap Button"] = "Minimap-Schaltfläche verstecken"
L["Left-Click to show options"] = "Linksklick, um Optionen anzuzeigen"

L["Hide Raid Tools"] = "Raid-Werkzeuge in der Gruppe ausblenden"
L["repairCost"] = "Gegenstände repariert für "
L["autoRepair"] = "Alle Gegenstände automatisch reparieren"
L["sellAllJunk"] = "Alle Plundergegenstände automatisch verkaufen"
L["ignoreTalkingHead"] = "Automatisch das Talking Head Fenster ausblenden"

L["showIlvlOnCharframe"] = "Gegenstandsstufe im Charakterausrüstungsfenster anzeigen"
L["showGemsOnCharframe"] = "Sockelplätze im Charakterausrüstungsfenster anzeigen"
L["showEnchantOnCharframe"] = "Verzauberungen im Charakterausrüstungsfenster anzeigen"

L["deleteItemFillDialog"] = "Füge \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" zum \"Löschbestätigungs-Popup\" hinzu"
L["autoChooseQuest"] = "Quests automatisch annehmen und abschließen"

L["General"] = "Allgemein"
L["Character"] = "Charakter"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Sonstiges"
L["Quest"] = "Quest"

-- Dungeon
L["autoChooseDelvePower"] = "Delve-Power automatisch auswählen,\nwenn nur 1 Option verfügbar ist"

-- Quest
L["ignoreTrivialQuests"] = "Triviale Quests ignorieren"
L["ignoreDailyQuests"] = "Tägliche/Wöchentliche Quests ignorieren"
