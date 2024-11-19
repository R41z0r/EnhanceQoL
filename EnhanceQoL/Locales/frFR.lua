if (GAME_LOCALE or GetLocale()) ~= "frFR" then return end

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
L["showCatalystChargesOnCharframe"] = "Afficher les charges du Catalyseur dans le cadre de l'équipement du personnage"
L["showIlvlOnBagItems"] = "Afficher le niveau d'objet sur l'équipement dans tous les sacs"
L["showDurabilityOnCharframe"] = "Afficher la durabilité sur la fenêtre d'équipement du personnage"

L["deleteItemFillDialog"] = "Ajouter \"" .. DELETE_ITEM_CONFIRM_STRING ..
                                "\" au \"Popup de confirmation de suppression\""
L["autoChooseQuest"] = "Accepter et compléter les quêtes automatiquement"

L["General"] = "Général"
L["Character"] = "Personnage"
L["Dungeon"] = "Donjon"
L["Misc"] = "Divers"
L["Quest"] = "Quête"

L["hideBagsBar"] = "Masquer la barre des sacs"

-- Dungeon
L["autoChooseDelvePower"] = "Choisir automatiquement la puissance de plongée\nlorsqu'il n'y a qu'une seule option"
L["lfgSortByRio"] = "Trier les candidats aux donjons mythiques par score mythique"

-- Quest
L["ignoreTrivialQuests"] = "Ignorer les quêtes triviales"
L["ignoreDailyQuests"] = "Ignorer les quêtes journalières/hebdomadaires"

L["autoQuickLoot"] = "Butin rapide des objets"
L["openCharframeOnUpgrade"] = "Ouvrir le cadre de personnage lors de l'amélioration d'objet chez le marchand"

L["headerClassInfo"] = "Ces paramètres s'appliquent uniquement à " .. select(1, UnitClass("player"))

-- Chevalier de la mort
L["deathknight_HideRuneFrame"] = "Masquer la barre des runes"

-- Évocateur
L["evoker_HideEssence"] = "Masquer la barre d'essence"

-- Moine
L["monk_HideHarmonyBar"] = "Masquer la barre d'harmonie"

-- Paladin
L["paladin_HideHolyPower"] = "Masquer la barre de puissance sacrée"

-- Voleur
L["rogue_HideComboPoint"] = "Masquer la barre de points de combo"

-- Chaman
L["shaman_HideTotem"] = "Masquer la barre de totems"

-- Démoniste
L["warlock_HideSoulShardBar"] = "Masquer la barre de fragments d'âme"
