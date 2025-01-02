if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Schlüsselstein"
L["Automatically insert keystone"] = "Schlüsselstein automatisch einsetzen"
L["Mythic Plus"] = "Mythisch+"
L[addonName] = "Mythisch+"
L["Close all bags on keystone insert"] = "Schließe alle Taschen, wenn der Schlüsselstein eingesetzt wird"
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
L["autoKeyStart"] = "Starte den Schlüsselstein automatisch nach Ablauf des Pull Timers"
L["mythicPlusTruePercent"] = "Dezimalwert der Gegnerstärke anzeigen"
L["mythicPlusChestTimer"] = "Truhen-Timer anzeigen"

L["None"] = "Kein Pull Timer"
L["Blizzard Pull Timer"] = "Blizzard Pull Timer"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs Pull Timer"
L["Both"] = "Blizzard und DBM / BigWigs"
L["Pull Timer Type"] = "Pull Timer Typ"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Zieh mich"
L["Potion Tracker"] = "Trank-Tracker"
L["Toggle Anchor"] = "Anker umschalten"
L["Save Anchor"] = "Anker speichern"
L["potionTrackerHeadline"] = "Dies ermöglicht es dir, die Abklingzeit der Kampftränke deiner Gruppenmitglieder als verschiebbare Leiste zu verfolgen."
L["potionTracker"] = "Trank-Abklingzeit-Tracker aktivieren"
L["potionTrackerUpwardsBar"] = "Nach oben wachsen"
L["potionTrackerClassColor"] = "Klassenfarben für Leisten verwenden"
L["potionTrackerDisableRaid"] = "Trank-Tracker im Raid deaktivieren"

L["Tinker"] = "Tüftler"
L["InvisPotion"] = "Unsichtbarkeit"
L["potionTrackerShowTooltip"] = "Tooltip auf dem Icon anzeigen"
L["HealingPotion"] = "Heilung"
L["potionTrackerHealingPotions"] = "Gesundheitstrank-CD verfolgen"
L["potionTrackerOffhealing"] = "Verfolge Offheilung CD Nutzung"
-- LFG Tools

L["DungeonBrowser"] = "Dungeonbrowser"
L["groupfinderAppText"] = 'Verstecke den Gruppenfinder-Text "Deine Gruppe wird derzeit gebildet"'
L["groupfinderSkipRolecheck"] = "Überspringe die Rollenauswahl und nutze die aktuelle Rolle"

-- Misc Frame
L["Misc"] = "Verschiedenes"
L["autoMarkTankInDungeon"] = "Markiere automatisch den " .. TANK .. " in Dungeons"
L["autoMarkTankInDungeonMarker"] = "Tank-Marker"
L["Disabled"] = "Deaktiviert"
L["autoMarkTankExplanation"] = "Der "
	.. TANK
	.. " wird markiert, wenn er keine Markierung hat und die Markierung wird nur geändert, wenn du entweder "
	.. COMMUNITY_MEMBER_ROLE_NAME_LEADER
	.. " oder "
	.. TANK
	.. " bist"
-- Teleports
L["Teleports"] = "Teleporte"
L["teleportEnabled"] = "Teleport-Fenster aktivieren"
L["DungeonCompendium"] = "Teleport-Kompendium"
L["teleportsEnableCompendium"] = "Teleport-Kompendium aktivieren"

L["teleportsHeadline"] = "Dies fügt ein Fenster mit Dungeon-Teleporten zu deinem PVE-Fenster hinzu"
L["portalHideMissing"] = "Fehlende Teleporte ausblenden"
L["portalShowTooltip"] = "Tooltip auf Teleport-Buttons anzeigen"
L["hideActualSeason"] = "Verstecke Teleports der aktuellen Saison im " .. L["DungeonCompendium"]
