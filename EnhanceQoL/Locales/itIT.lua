if (GAME_LOCALE or GetLocale()) ~= "itIT" then
    return
end

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