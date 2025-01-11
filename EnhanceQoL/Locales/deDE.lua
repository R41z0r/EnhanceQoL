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
L["landingPageHide"] = "Aktivieren Sie diese Option, um den Erweiterungs-Button auf der Minimap auszublenden."
L["automaticallyOpenContainer"] = "Behältergegenstände in der Tasche automatisch öffnen"

L["showIlvlOnBankFrame"] = "Zeige Gegenstandsstufe im Bankfenster an"
L["showIlvlOnMerchantframe"] = "Gegenstandslevel im Händlerfenster anzeigen"
L["showIlvlOnCharframe"] = "Gegenstandsstufe im Charakterausrüstungsfenster anzeigen"
L["showGemsOnCharframe"] = "Sockelplätze im Charakterausrüstungsfenster anzeigen"
L["showGemsTooltipOnCharframe"] = "Zeige Edelstein-Sockel-Tooltip im Charakterausrüstungsfenster"
L["showEnchantOnCharframe"] = "Verzauberungen im Charakterausrüstungsfenster anzeigen"
L["showCatalystChargesOnCharframe"] = "Katalysatorladungen im Charakterausrüstungsfenster anzeigen"
L["showIlvlOnBagItems"] = "Zeige das Itemlevel auf Ausrüstung in allen Taschen"
L["showDurabilityOnCharframe"] = "Zeige Haltbarkeit auf dem Charakterausrüstungsfenster"
L["hideOrderHallBar"] = "Ordenshallen-Kommandoleiste ausblenden"
L["showInfoOnInspectFrame"] = "Zeige zusätzliche Informationen im Betrachten-Fenster an (Experimentell)"
L["MissingEnchant"] = "Verzauberung"
L["hideHitIndicatorPlayer"] = "Schwebenden Kampftext (Schaden und Heilung) über deinem Charakter ausblenden"
L["hideHitIndicatorPet"] = "Schwebenden Kampftext (Schaden und Heilung) über deinem Begleiter ausblenden"
L["UnitFrame"] = "Einheitenfenster"
L["SellJunkIgnoredBag"] = "Du hast das Verkaufen von Plunder in %d Taschen deaktiviert.\nDies könnte verhindern, dass alle Plunder-Artikel automatisch verkauft werden."

L["deleteItemFillDialog"] = 'Füge "' .. DELETE_ITEM_CONFIRM_STRING .. '" zum "Löschbestätigungs-Popup" hinzu'
L["confirmPatronOrderDialog"] = "Bestätigt automatisch die Nutzung eigener Materialien für " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC .. "-Aufträge"
L["autoChooseQuest"] = "Quests automatisch annehmen und abschließen"
L["confirmTimerRemovalTrade"] = "Automatisch bestätigen, handelbare Beute im Handelszeitraum zu verkaufen"

L["General"] = "Allgemein"
L["Character"] = "Charakter"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Sonstiges"
L["Quest"] = "Quest"

L["hideBagsBar"] = "Taschenleiste ausblenden"

-- Dungeon
L["autoChooseDelvePower"] = "Delve-Power automatisch auswählen, wenn nur 1 Option verfügbar ist"
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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Schamane
L["shaman_HideTotem"] = "Totemleiste ausblenden"

-- Hexenmeister
L["warlock_HideSoulShardBar"] = "Splitterleiste ausblenden"

L["questAddNPCToExclude"] = "Füge anvisierten NPC/geöffnetes Gossip-Fenster zur Ausschlussliste hinzu"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Interface-Neuladen erforderlich"
L["bReloadInterface"] = "Sie müssen Ihr Interface neu laden, um Änderungen zu übernehmen"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Automatisches Absteigen bei Fähigkeiten aktivieren" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Automatisches Absteigen beim Fliegen aktivieren" },
	["chatMouseScroll"] = { description = "Maus-Scrollen im Chat aktivieren", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Todeseffekte deaktivieren", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Karten-Ausblenden beim Bewegen aktivieren" },
	["scriptErrors"] = { description = "LUA-Fehler im Interface anzeigen", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Klassenfarben in Namensplaketten anzeigen", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Zauberleiste des Ziels anzeigen" },
	["showTutorials"] = { description = "Tutorials deaktivieren", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Erweiterte Tooltips aktivieren", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Gilde bei Spielern anzeigen" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Titel bei Spielern anzeigen" },
	["WholeChatWindowClickable"] = { description = "Ganzes Chatfenster anklickbar machen", trueValue = "1", falseValue = "0" },
}
