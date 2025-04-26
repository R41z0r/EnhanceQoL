if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Iscrizione veloce"
L["interruptWithShift"] = "Tieni premuto Shift per interrompere questa funzione"

L["Persist LFG signup note"] = "Mantieni nota di iscrizione LFG"
L["Select an option"] = "Seleziona un'opzione"
L["Save"] = "Salva"
L["Hide Minimap Button"] = "Nascondi pulsante della minimappa"
L["Left-Click to show options"] = "Clicca con il tasto sinistro per mostrare le opzioni"

L["Hide Raid Tools"] = "Nascondi strumenti da raid nel gruppo"
L["repairCost"] = "Oggetti riparati per "
L["autoRepair"] = "Ripara automaticamente tutti gli oggetti"
L["sellAllJunk"] = "Vendi automaticamente tutti gli oggetti spazzatura"
L["ignoreTalkingHead"] = "Nascondi automaticamente la cornice di Talking Head"
L["landingPageHide"] = "Abilita questa opzione per nascondere il pulsante della pagina di espansione sulla minimappa."
L["automaticallyOpenContainer"] = "Apri automaticamente gli oggetti contenitore nella borsa"

L["bagFilterDockFrameUnlock"] = "Fai clic per sganciare la finestra filtro dalle borse"
L["bagFilterDockFrameLock"] = "Fai clic per agganciare la finestra filtro alle borse"
L["enableMoneyTracker"] = "Abilita il tracciamento dell'oro su tutti i personaggi"
L["enableMoneyTrackerDesc"] = "Passa il mouse sull'oro nelle borse per vedere l'oro di tutti i personaggi"
L["moneyTrackerRemovePlayer"] = "Tutti i personaggi conosciuti"
L["showBagFilterMenu"] = "Abilita il filtro degli oggetti nelle borse"
L["showBagFilterMenuDesc"] = ("Utilizzabile solo quando è selezionata l’opzione Borse combinate. Tieni premuto %s per spostare il riquadro"):format(SHIFT_KEY_TEXT)
L["fadeBagQualityIcons"] = "Abilita la dissolvenza delle icone di qualità delle professioni durante la ricerca e il filtraggio"
L["bagFilterSpec"] = "Consigliato per la Specializzazione"
L["bagFilterEquip"] = "Solo equipaggiamento"
L["showIlvlOnBankFrame"] = "Mostra il livello degli oggetti nella banca"
L["showIlvlOnMerchantframe"] = "Mostra il livello dell'oggetto nella finestra del mercante"
L["showIlvlOnCharframe"] = "Mostra il livello dell'oggetto nel pannello dell'equipaggiamento del personaggio"
L["showGemsOnCharframe"] = "Mostra le gemme nel pannello dell'equipaggiamento del personaggio"
L["showBindOnBagItems"] = "Mostra " .. _G.ITEM_BIND_ON_EQUIP .. " (BoE), " .. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP .. " (WuE) e " .. _G.ITEM_BNETACCOUNTBOUND .. " (WB) in aggiunta al livello dell'oggetto"
L["showGemsTooltipOnCharframe"] = "Mostra gli slot delle gemme nel pannello dell'equipaggiamento del personaggio"
L["showEnchantOnCharframe"] = "Mostra gli incantamenti nel pannello dell'equipaggiamento del personaggio"
L["showCatalystChargesOnCharframe"] = "Mostra le cariche del Catalizzatore nel riquadro dell'equipaggiamento del personaggio"
L["showIlvlOnBagItems"] = "Mostra il livello dell'oggetto sull'equipaggiamento in tutte le borse"
L["showDurabilityOnCharframe"] = "Mostra la durabilità sulla finestra dell'equipaggiamento del personaggio"
L["hideOrderHallBar"] = "Nascondi barra dei comandi della Enclave"
L["showInfoOnInspectFrame"] = "Mostra informazioni aggiuntive nella finestra di ispezione"
L["MissingEnchant"] = "Incantamento"
L["hideHitIndicatorPlayer"] = "Nascondi il testo di combattimento fluttuante (danni e cure) sopra il tuo personaggio"
L["hideHitIndicatorPet"] = "Nascondi il testo di combattimento fluttuante (danni e cure) sopra il tuo famiglio"
L["UnitFrame"] = "Riquadro unità"
L["SellJunkIgnoredBag"] = "Hai disattivato la vendita di oggetti inutili in %d borse.\nQuesto potrebbe impedire la vendita automatica di tutti gli oggetti inutili."

L["deleteItemFillDialog"] = 'Aggiungi "' .. DELETE_ITEM_CONFIRM_STRING .. '" al "Popup di conferma eliminazione"'
L["confirmPatronOrderDialog"] = "Conferma automaticamente l'uso dei materiali propri per gli ordini di " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Accetta e completa le missioni automaticamente"
L["confirmTimerRemovalTrade"] = "Conferma automaticamente la vendita del bottino scambiabile durante il periodo di scambio"

L["General"] = "Generale"
L["Character"] = "Personaggio"
L["Dungeon"] = "Spedizione"
L["Misc"] = "Varie"
L["Quest"] = "Missione"

L["hideBagsBar"] = "Nascondi la barra delle borse"
L["hideMicroMenu"] = "Nascondi micro menu"
L["MicroMenu"] = "Micro menu"
L["BagsBar"] = "Barra delle borse"
-- Dungeon
L["autoChooseDelvePower"] = "Seleziona automaticamente il potere di immersione quando c'è solo 1 opzione"
L["lfgSortByRio"] = "Ordina i candidati dei dungeon mitici per punteggio mitico"
L["DungeonBrowser"] = "Esploratore di dungeon"
L["groupfinderAppText"] = 'Nascondi il testo del cercatore di gruppi "Il tuo gruppo si sta formando attualmente"'
L["groupfinderMoveResetButton"] = "Sposta il pulsante di ripristino del filtro del Ricerca Spedizioni sul lato sinistro."
L["groupfinderSkipRoleSelect"] = "Salta la selezione del ruolo"
L["groupfinderSkipRolecheckHeadline"] = "Assegnazione automatica del ruolo"
L["groupfinderSkipRolecheckUseSpec"] = "Usa il ruolo della tua specializzazione (es. Cavaliere della Morte (Sangue) = Tank)"
L["groupfinderSkipRolecheckUseLFD"] = "Usa i ruoli dal Ricerca Dungeon"

-- Quest
L["ignoreTrivialQuests"] = "Non gestire automaticamente le " .. QUESTS_LABEL .. " di bassa importanza"
L["ignoreDailyQuests"] = "Non gestire automaticamente le " .. QUESTS_LABEL .. " giornaliere/settimanali"
L["ignoreWarbandCompleted"] = "Non gestire automaticamente le " .. QUESTS_LABEL .. " " .. ACCOUNT_COMPLETED_QUEST_LABEL

L["autoQuickLoot"] = "Saccheggio rapido degli oggetti"
L["openCharframeOnUpgrade"] = "Apri il riquadro del personaggio durante il potenziamento degli oggetti presso il mercante"

L["headerClassInfo"] = "Queste impostazioni si applicano solo a " .. select(1, UnitClass("player"))

-- Cavaliere della Morte
L["deathknight_HideRuneFrame"] = "Nascondi barra delle rune"

-- Evocatore
L["evoker_HideEssence"] = "Nascondi barra dell'essenza"

-- Monaco
L["monk_HideHarmonyBar"] = "Nascondi barra dell'armonia"

-- Paladino
L["paladin_HideHolyPower"] = "Nascondi barra della potenza sacra"

-- Ladro
L["rogue_HideComboPoint"] = "Nascondi barra dei punti combo"

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Sciamano
L["shaman_HideTotem"] = "Nascondi barra dei totem"

-- Stregone
L["warlock_HideSoulShardBar"] = "Nascondi barra dei frammenti d'anima"

L["questAddNPCToExclude"] = "Aggiungi il PNG selezionato/finestra di dialogo aperta all'elenco di esclusione"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Ricaricamento interfaccia richiesto"
L["bReloadInterface"] = "Devi ricaricare la tua interfaccia per applicare le modifiche"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Abilita lo smontaggio automatico durante l'uso delle abilità" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Abilita lo smontaggio automatico durante il volo" },
	["chatMouseScroll"] = { description = "Abilita lo scorrimento del mouse nella chat", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Disabilita gli effetti di morte", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Abilita lo sbiadimento della mappa durante il movimento" },
	["scriptErrors"] = { description = "Mostra errori LUA nell'interfaccia", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Mostra i colori delle classi sulle targhette", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Mostra la barra degli incantesimi del bersaglio" },
	["showTutorials"] = { description = "Disattiva i tutorial", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Abilita tooltip avanzati", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Mostra la gilda sui giocatori" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Mostra il titolo sui giocatori" },
	["WholeChatWindowClickable"] = { description = "Rendi cliccabile l'intera finestra di chat", trueValue = "1", falseValue = "0" },
}

L["autoAcceptGroupInvite"] = "Accetta automaticamente gli inviti al gruppo"
L["autoAcceptGroupInviteGuildOnly"] = "Membri di gilda"
L["autoAcceptGroupInviteFriendOnly"] = "Amici"
L["autoAcceptGroupInviteOptions"] = "Accetta inviti da..."

L["showLeaderIconRaidFrame"] = "Mostra l’icona del capogruppo sui frame di gruppo in stile incursione"
L["showPartyFrameInSoloContent"] = "Mostra i riquadri del gruppo nei contenuti in solitaria"

L["ActionbarHideExplain"] = 'Imposta la barra delle azioni come nascosta e visibile al passaggio del mouse. Funziona solo se la barra è impostata su "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"]
	.. '" e "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"]
	.. '" in '
	.. _G["HUD_EDIT_MODE_MENU"]
	.. "."

L["enableMinimapButtonBin"] = "Abilita la raccolta di pulsanti minimappa"
L["enableMinimapButtonBinDesc"] = "Raggruppa tutti i pulsanti della minimappa in un singolo pulsante"
L["ignoreMinimapSinkHole"] = "Ignora i seguenti pulsanti della minimappa nella raccolta..."
L["useMinimapButtonBinIcon"] = "Usa un pulsante sulla minimappa per la raccolta"
L["useMinimapButtonBinMouseover"] = "Mostra un riquadro spostabile per la raccolta con mouseover"
L["lockMinimapButtonBin"] = "Blocca il riquadro di raccolta"

L["UnitFrameHideExplain"] = "Nascondi l’elemento e mostralo solo al passaggio del mouse"
L["chatFrameFadeEnabled"] = "Abilita lo sbiadimento della chat"
L["chatFrameFadeTimeVisibleText"] = "Il testo rimane visibile per"
L["chatFrameFadeDurationText"] = "Durata dell’animazione di sbiadimento"

L["enableLootspecQuickswitch"] = "Abilita il cambio rapido di specializzazione di bottino e attiva sulla minimappa"
L["enableLootspecQuickswitchDesc"] = "Fai clic sinistro su una specializzazione per impostare la spec di bottino, o clic destro per cambiare la spec attiva."
