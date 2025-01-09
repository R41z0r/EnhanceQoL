if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Iscrizione veloce"
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

L["showIlvlOnBankFrame"] = "Mostra il livello degli oggetti nella banca"
L["showIlvlOnMerchantframe"] = "Mostra il livello dell'oggetto nella finestra del mercante"
L["showIlvlOnCharframe"] = "Mostra il livello dell'oggetto nel pannello dell'equipaggiamento del personaggio"
L["showGemsOnCharframe"] = "Mostra le gemme nel pannello dell'equipaggiamento del personaggio"
L["showGemsTooltipOnCharframe"] = "Mostra gli slot delle gemme nel pannello dell'equipaggiamento del personaggio"
L["showEnchantOnCharframe"] = "Mostra gli incantamenti nel pannello dell'equipaggiamento del personaggio"
L["showCatalystChargesOnCharframe"] = "Mostra le cariche del Catalizzatore nel riquadro dell'equipaggiamento del personaggio"
L["showIlvlOnBagItems"] = "Mostra il livello dell'oggetto sull'equipaggiamento in tutte le borse"
L["showDurabilityOnCharframe"] = "Mostra la durabilità sulla finestra dell'equipaggiamento del personaggio"
L["hideOrderHallBar"] = "Nascondi barra dei comandi della Enclave"
L["showInfoOnInspectFrame"] = "Mostra informazioni aggiuntive nella finestra di ispezione (Sperimentale)"
L["MissingEnchant"] = "Incantamento"
L["hideHitIndicatorPlayer"] = "Nascondi il testo di combattimento fluttuante (danni e cure) sopra il tuo personaggio"
L["hideHitIndicatorPet"] = "Nascondi il testo di combattimento fluttuante (danni e cure) sopra il tuo famiglio"
L["UnitFrame"] = "Riquadro unità"

L["deleteItemFillDialog"] = 'Aggiungi "' .. DELETE_ITEM_CONFIRM_STRING .. '" al "Popup di conferma eliminazione"'
L["autoChooseQuest"] = "Accetta e completa le missioni automaticamente"

L["General"] = "Generale"
L["Character"] = "Personaggio"
L["Dungeon"] = "Spedizione"
L["Misc"] = "Varie"
L["Quest"] = "Missione"

L["hideBagsBar"] = "Nascondi la barra delle borse"

-- Dungeon
L["autoChooseDelvePower"] = "Seleziona automaticamente il potere di immersione quando c'è solo 1 opzione"
L["lfgSortByRio"] = "Ordina i candidati dei dungeon mitici per punteggio mitico"

-- Quest
L["ignoreTrivialQuests"] = "Ignora le missioni banali"
L["ignoreDailyQuests"] = "Ignora missioni giornaliere/settimanali"

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
