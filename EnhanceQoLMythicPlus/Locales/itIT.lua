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
L["NoKeystone"] = "Nessuna info"
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
L["interruptWithShift"] = "Tieni premuto Shift per interrompere questa funzione"

L["None"] = "Nessun timer di pull"
L["Blizzard Pull Timer"] = "Timer di pull Blizzard"
L["DBM / BigWigs Pull Timer"] = "Timer di pull DBM / BigWigs"
L["Both"] = "Blizzard e DBM / BigWigs"
L["Pull Timer Type"] = "Tipo di timer di pull"

L["groupfinderShowDungeonScoreFrame"] = "Mostra il riquadro " .. DUNGEON_SCORE .. " accanto al Ricerca delle spedizioni"
-- Keystone
L["groupfinderShowPartyKeystone"] = "Mostra le informazioni della Chiave Mitica dei membri del gruppo"
L["groupfinderShowPartyKeystoneDesc"] = "Ti consente di cliccare sull'icona delle informazioni della chiave per teletrasportarti in quel dungeon"

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

-- AutoMark Frame
L["AutoMark"] = "Segnalatore del tank"
L["autoMarkTankInDungeon"] = "Marca automaticamente il " .. TANK .. " nei dungeon"
L["autoMarkTankInDungeonMarker"] = "Segnalatore del tank"
L["Disabled"] = "Disabilitato"
L["autoMarkTankExplanation"] = "Il " .. TANK .. " verrà marcato quando non ha un segno e cambierà il segno solo se sei " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " o " .. TANK
L["mythicPlusIgnoreMythic"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY6
L["mythicPlusIgnoreHeroic"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY2
L["mythicPlusIgnoreEvent"] = "Non applicare un marcatore da raid nei dungeon " .. BATTLE_PET_SOURCE_7
L["mythicPlusIgnoreNormal"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY1
L["mythicPlusIgnoreTimewalking"] = "Non applicare un marcatore da raid nei dungeon " .. PLAYER_DIFFICULTY_TIMEWALKER

-- Teleports
L["Teleports"] = "Teletrasporti"
L["teleportEnabled"] = "Abilita il pannello dei teletrasporti"
L["DungeonCompendium"] = "Compendio dei Teletrasporti"
L["teleportsEnableCompendium"] = "Abilita il Compendio dei Teletrasporti"
L["teleportCompendiumHeadline"] = "Nascondi i teletrasporti di specifiche espansioni"

L["teleportsHeadline"] = "Aggiunge un pannello con i teletrasporti ai dungeon nella finestra PvE"
L["portalHideMissing"] = "Nascondi i teletrasporti mancanti"
L["portalShowTooltip"] = "Mostra il tooltip sui pulsanti di teletrasporto"
L["hideActualSeason"] = "Nascondi i teletrasporti della stagione attuale in " .. L["DungeonCompendium"]
L["teleportCompendiumAdditionHeadline"] = "Opzioni aggiuntive di portale"
L["portalShowDungeonTeleports"] = "Mostra teletrasporti delle spedizioni"
L["portalShowRaidTeleports"] = "Mostra teletrasporti delle incursioni"
L["portalShowToyHearthstones"] = "Mostra oggetti e giocattoli di teletrasporto (es. pietre del ritorno)"
L["portalShowEngineering"] = "Mostra teletrasporti d'Ingegneria (richiede Ingegneria)"
L["portalShowClassTeleport"] = "Mostra teletrasporti specifici di classe (solo se disponibili)"
L["portalShowMagePortal"] = "Mostra portali del Mago (solo Mago)"

-- BR Tracker
L["BRTracker"] = "Resurrezione in combattimento"
L["brTrackerHeadline"] = "Aggiunge un tracker per la resurrezione in combattimento nei dungeon Mitici+"
L["mythicPlusBRTrackerEnabled"] = "Abilita il tracker di resurrezione in combattimento"
L["mythicPlusBRTrackerLocked"] = "Blocca la posizione del tracker"
L["mythicPlusBRButtonSizeHeadline"] = "Dimensione del pulsante"

-- Talent Reminder
L["TalentReminder"] = "Promemoria Talenti"
L["talentReminderEnabled"] = "Abilita il promemoria talenti"
L["talentReminderEnabledDesc"] = "Funziona solo in modalità " .. _G["PLAYER_DIFFICULTY6"] .. " in preparazione a " .. _G["PLAYER_DIFFICULTY_MYTHIC_PLUS"]
L["talentReminderLoadOnReadyCheck"] = "Verificare i talenti solo durante il " .. _G["READY_CHECK"]
L["talentReminderSoundOnDifference"] = "Riproduci un suono se i talenti differiscono dalla configurazione salvata"
L["WrongTalents"] = "Talenti errati"
L["ActualTalents"] = "Talenti attuali"
L["RequiredTalents"] = "Talenti richiesti"
