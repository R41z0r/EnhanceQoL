if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end
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
L["showCatalystChargesOnCharframe"] = "Katalysatorladungen im Charakterausrüstungsfenster anzeigen"
L["showIlvlOnBagItems"] = "Zeige das Itemlevel auf Ausrüstung in allen Taschen"

L["deleteItemFillDialog"] = "Füge \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" zum \"Löschbestätigungs-Popup\" hinzu"
L["autoChooseQuest"] = "Quests automatisch annehmen und abschließen"

L["General"] = "Allgemein"
L["Character"] = "Charakter"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Sonstiges"
L["Quest"] = "Quest"

L["hideBagsBar"] = "Taschenleiste ausblenden"

-- Dungeon
L["autoChooseDelvePower"] = "Delve-Power automatisch auswählen,\nwenn nur 1 Option verfügbar ist"
L["lfgSortByRio"] = "Sortiere Bewerber für Mythisch+ Dungeons nach Mythisch-Wertung"

-- Quest
L["ignoreTrivialQuests"] = "Triviale Quests ignorieren"
L["ignoreDailyQuests"] = "Tägliche/Wöchentliche Quests ignorieren"

L["autoQuickLoot"] = "Gegenstände schnell plündern"
L["openCharframeOnUpgrade"] = "Charakterfenster beim Aufwerten von Gegenständen beim Händler öffnen"

L["headerClassInfo"] = "Diese Einstellungen gelten nur für " .. select(1, UnitClass("player"))

-- Todesritter
L["deathknight_HideRuneFrame"] = "Runenleiste ausblenden"

-- Rufer
L["evoker_HideEssence"] = "Essenzleiste ausblenden"

-- Mönch
L["monk_HideHarmonyBar"] = "Harmonie-Leiste ausblenden"

-- Paladin
L["paladin_HideHolyPower"] = "Heilige Kraft-Leiste ausblenden"

-- Schurke
L["rogue_HideComboPoint"] = "Kombopunktleiste ausblenden"

-- Schamane
L["shaman_HideTotem"] = "Totemleiste ausblenden"

-- Hexenmeister
L["warlock_HideSoulShardBar"] = "Splitterleiste ausblenden"
