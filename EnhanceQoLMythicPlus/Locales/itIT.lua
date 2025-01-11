if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Chiave di volta"
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
L["autoKeyStart"] = "Avvia automaticamente la chiave dopo il timer di pull"
L["mythicPlusTruePercent"] = "Mostra il valore decimale delle Forze nemiche"
L["mythicPlusChestTimer"] = "Mostra i timer delle casse"

L["None"] = "Nessun timer di pull"
L["Blizzard Pull Timer"] = "Timer di pull Blizzard"
L["DBM / BigWigs Pull Timer"] = "Timer di pull DBM / BigWigs"
L["Both"] = "Blizzard e DBM / BigWigs"
L["Pull Timer Type"] = "Tipo di timer di pull"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Trascinami"
L["Potion Tracker"] = "Tracciatore di pozioni"
L["Toggle Anchor"] = "Attiva/disattiva ancora"
L["Save Anchor"] = "Salva ancora"
L["potionTrackerHeadline"] = "Questo ti permette di tracciare il CD delle pozioni di combattimento dei membri del tuo gruppo come barra mobile"
L["potionTracker"] = "Abilita tracciatore di ricarica delle pozioni"
L["potionTrackerUpwardsBar"] = "Crescita verso l'alto"
L["potionTrackerClassColor"] = "Usa i colori della classe per le barre"
L["potionTrackerDisableRaid"] = "Disabilita tracciatore di pozioni in raid"

L["Tinker"] = "Inventore"
L["InvisPotion"] = "Invisibilità"
L["potionTrackerShowTooltip"] = "Mostra tooltip sull'icona"
L["HealingPotion"] = "Cura"
L["potionTrackerHealingPotions"] = "Traccia CD pozione di cura"
L["potionTrackerOffhealing"] = "Traccia l'uso di CD di cura secondaria"
-- Strumenti LFG

L["DungeonBrowser"] = "Esploratore di dungeon"
L["groupfinderAppText"] = 'Nascondi il testo del cercatore di gruppi "Il tuo gruppo si sta formando attualmente"'
L["groupfinderSkipRolecheck"] = "Salta il controllo del ruolo e utilizza il ruolo attuale"

-- Misc Frame
L["Misc"] = "Varie"
L["autoMarkTankInDungeon"] = "Marca automaticamente il " .. TANK .. " nei dungeon"
L["autoMarkTankInDungeonMarker"] = "Segnalatore del tank"
L["Disabled"] = "Disabilitato"
L["autoMarkTankExplanation"] = "Il " .. TANK .. " verrà marcato quando non ha un segno e cambierà il segno solo se sei " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " o " .. TANK
L["mythicPlusIgnoreMythic"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY6
L["mythicPlusIgnoreHeroic"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY2
L["mythicPlusIgnoreNormal"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY1
L["mythicPlusIgnoreTimewalking"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY_TIMEWALKER

-- Teleports
L["Teleports"] = "Teletrasporti"
L["teleportEnabled"] = "Abilita il pannello dei teletrasporti"
L["DungeonCompendium"] = "Compendio dei Teletrasporti"
L["teleportsEnableCompendium"] = "Abilita il Compendio dei Teletrasporti"

L["teleportsHeadline"] = "Aggiunge un pannello con i teletrasporti ai dungeon nella finestra PvE"
L["portalHideMissing"] = "Nascondi i teletrasporti mancanti"
L["portalShowTooltip"] = "Mostra il tooltip sui pulsanti di teletrasporto"
L["hideActualSeason"] = "Nascondi i teletrasporti della stagione attuale in " .. L["DungeonCompendium"]
