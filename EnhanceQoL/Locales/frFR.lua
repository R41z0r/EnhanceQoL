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
L["sellAllJunk"] = "Vendre automatiquement tous les objets inutiles"
L["ignoreTalkingHead"] = "Masquer automatiquement le cadre Talking Head"

L["showIlvlOnCharframe"] = "Afficher le niveau d'objet sur l'équipement du personnage"
L["showGemsOnCharframe"] = "Afficher les emplacements de gemmes sur l'équipement du personnage"
L["showEnchantOnCharframe"] = "Afficher les enchantements sur l'équipement du personnage"

L["deleteItemFillDialog"] = "Ajouter \"" .. COMMUNITIES_DELETE_CONFIRM_STRING ..
                                "\" au \"Popup de confirmation de suppression\""
L["autoChooseGossip"] = "Choisir automatiquement le potin lorsqu'une seule réponse est disponible"
