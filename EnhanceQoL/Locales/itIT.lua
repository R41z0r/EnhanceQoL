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

L["showIlvlOnCharframe"] = "Mostra il livello dell'oggetto nel\npannello dell'equipaggiamento del personaggio"
L["showGemsOnCharframe"] = "Mostra le gemme nel pannello\ndell'equipaggiamento del personaggio"
L["showEnchantOnCharframe"] = "Mostra gli incantamenti nel\npannello dell'equipaggiamento del personaggio"
L["showCatalystChargesOnCharframe"] =
    "Mostra le cariche del Catalizzatore nel riquadro dell'equipaggiamento del personaggio"

L["deleteItemFillDialog"] = "Aggiungi \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" al \"Popup di conferma eliminazione\""
L["autoChooseQuest"] = "Accetta e completa le missioni automaticamente"

L["General"] = "Generale"
L["Character"] = "Personaggio"
L["Dungeon"] = "Spedizione"
L["Misc"] = "Varie"
L["Quest"] = "Missione"

L["hideBagsBar"] = "Nascondi la barra delle borse"

-- Dungeon
L["autoChooseDelvePower"] = "Seleziona automaticamente il potere di\nimmersione quando c'è solo 1 opzione"
L["lfgSortByRio"] = "Ordina i candidati dei dungeon mitici per punteggio mitico"

-- Quest
L["ignoreTrivialQuests"] = "Ignora le missioni banali"
L["ignoreDailyQuests"] = "Ignora missioni giornaliere/settimanali"

L["autoQuickLoot"] = "Saccheggio rapido degli oggetti"

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
