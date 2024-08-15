if (GAME_LOCALE or GetLocale()) ~= "frFR" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscription rapide"
L["Persist LFG signup note"] = "Conserver la note d'inscription LFG"
L["Select an option"] = "Sélectionner une option"
L["Save"] = "Enregistrer"
L["Hide Minimap Button"] = "Cacher le bouton de la minicarte"
L["Left-Click to show options"] = "Clic gauche pour afficher les options"

L["Hide Raid Tools"] = "Masquer les outils de raid en groupe"
L["repairCost"] = "Objets réparés pour "
L["autoRepair"] = "Réparer automatiquement tous les objets"