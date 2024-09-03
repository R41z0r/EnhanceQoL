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

L["deleteItemFillDialog"] = "Aggiungi \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" al \"Popup di conferma eliminazione\""
L["autoChooseQuest"] = "Accetta e completa le missioni automaticamente"

L["General"] = "Generale"
L["Character"] = "Personaggio"
L["Dungeon"] = "Spedizione"
L["Misc"] = "Varie"
L["Quest"] = "Missione"

-- Dungeon
L["autoChooseDelvePower"] = "Seleziona automaticamente il potere di\nimmersione quando c'è solo 1 opzione"

-- Quest
L["ignoreTrivialQuests"] = "Ignora le missioni banali"
L["ignoreDailyQuests"] = "Ignora missioni giornaliere/settimanali"

L["autoQuickLoot"] = "Saccheggio rapido degli oggetti"
