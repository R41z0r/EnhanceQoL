if (GAME_LOCALE or GetLocale()) ~= "frFR" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscription rapide"
L["interruptWithShift"] = "Maintenez la touche Maj enfoncée pour interrompre cette fonctionnalité"

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
L["landingPageHide"] = "Activez cette option pour masquer le bouton de la page d'expansion sur la mini-carte."
L["automaticallyOpenContainer"] = "Ouvrir automatiquement les objets contenant dans le sac"

L["bagFilterDockFrameUnlock"] = "Cliquez pour désancrer la fenêtre de filtre de vos sacs"
L["bagFilterDockFrameLock"] = "Cliquez pour ancrer la fenêtre de filtre à vos sacs"
L["enableMoneyTracker"] = "Activer le suivi de votre or sur tous les personnages"
L["enableMoneyTrackerDesc"] = "Survolez votre or dans vos sacs pour voir l'or de tous vos personnages"
L["showOnlyGoldOnMoney"] = "Afficher uniquement l’or du compte (masquer l’argent et le cuivre)"
L["moneyTrackerRemovePlayer"] = "Tous les personnages connus"
L["showBagFilterMenu"] = "Activer le filtre d’objets dans les sacs"
L["showBagFilterMenuDesc"] = ("Utilisable uniquement si Sacs combinés est activé. Maintenez %s pour déplacer la fenêtre"):format(SHIFT_KEY_TEXT)
L["fadeBagQualityIcons"] = "Activer l’estompage des icônes de qualité de métier lors de la recherche et du filtrage"
L["bagFilterSpec"] = "Recommandé pour la spécialisation"
L["bagFilterEquip"] = "Équipement uniquement"
L["showIlvlOnBankFrame"] = "Afficher le niveau d'objet dans la banque"
L["showIlvlOnMerchantframe"] = "Afficher le niveau d'objet dans la fenêtre du marchand"
L["showIlvlOnCharframe"] = "Afficher le niveau d'objet sur l'équipement du personnage"
L["showGemsOnCharframe"] = "Afficher les emplacements de gemmes sur l'équipement du personnage"
L["showBindOnBagItems"] = "Affiche "
	.. _G.ITEM_BIND_ON_EQUIP
	.. " (BoE), "
	.. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
	.. " (WuE) et "
	.. _G.ITEM_BNETACCOUNTBOUND
	.. " (WB) en plus du niveau d’objet sur les objets"
L["showGemsTooltipOnCharframe"] = "Afficher les emplacements de gemmes dans l'équipement du personnage"
L["showEnchantOnCharframe"] = "Afficher les enchantements sur l'équipement du personnage"
L["showCatalystChargesOnCharframe"] = "Afficher les charges du Catalyseur dans le cadre de l'équipement du personnage"
L["showIlvlOnBagItems"] = "Afficher le niveau d'objet sur l'équipement dans tous les sacs"
L["showDurabilityOnCharframe"] = "Afficher la durabilité sur la fenêtre d'équipement du personnage"
L["hideOrderHallBar"] = "Masquer la barre de commande de domaine"
L["showInfoOnInspectFrame"] = "Afficher des informations supplémentaires dans la fenêtre d'inspection"
L["MissingEnchant"] = "Enchantement"
L["hideHitIndicatorPlayer"] = "Masquer le texte flottant de combat (dégâts et soins) au-dessus de votre personnage"
L["hideHitIndicatorPet"] = "Masquer le texte flottant de combat (dégâts et soins) au-dessus de votre familier"
L["UnitFrame"] = "Cadre d'unité"
L["SellJunkIgnoredBag"] = "Vous avez désactivé la vente des objets inutiles dans %d sacs.\nCela peut empêcher la vente automatique de tous les objets inutiles."

L["deleteItemFillDialog"] = 'Ajouter "' .. DELETE_ITEM_CONFIRM_STRING .. '" au "Popup de confirmation de suppression"'
L["confirmPatronOrderDialog"] = "Confirme automatiquement l'utilisation de vos propres matériaux pour les commandes de " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Accepter et compléter les quêtes automatiquement"
L["confirmTimerRemovalTrade"] = "Confirmer automatiquement la vente du butin échangeable pendant la période d'échange"

L["General"] = "Général"
L["Character"] = "Personnage"
L["Dungeon"] = "Donjon"
L["Misc"] = "Divers"
L["Quest"] = "Quête"

L["hideBagsBar"] = "Masquer la barre des sacs"
L["hideMicroMenu"] = "Masquer le micro-menu"
L["MicroMenu"] = "Micro-menu"
L["BagsBar"] = "Barre des sacs"
-- Dungeon
L["autoChooseDelvePower"] = "Choisir automatiquement la puissance de plongée lorsqu'il n'y a qu'une seule option"
L["lfgSortByRio"] = "Trier les candidats aux donjons mythiques par score mythique"
L["DungeonBrowser"] = "Explorateur de donjons"
L["groupfinderAppText"] = 'Masquer le texte du recherche de groupe "Votre groupe est actuellement en formation"'
L["groupfinderMoveResetButton"] = "Déplacez le bouton de réinitialisation du navigateur de donjons sur le côté gauche."
L["groupfinderSkipRoleSelect"] = "Ignorer la sélection de rôle"
L["groupfinderSkipRolecheckHeadline"] = "Affectation automatique de rôle"
L["groupfinderSkipRolecheckUseSpec"] = "Utiliser le rôle de votre spécialisation actuelle (ex. Chevalier de la mort (Sang) = Tank)"
L["groupfinderSkipRolecheckUseLFD"] = "Utiliser les rôles de l’outil Donjons"

-- Quest
L["ignoreTrivialQuests"] = "Ne pas gérer automatiquement les " .. QUESTS_LABEL .. " triviales"
L["ignoreDailyQuests"] = "Ne pas gérer automatiquement les " .. QUESTS_LABEL .. " journalières/hebdomadaires"
L["ignoreWarbandCompleted"] = "Ne pas gérer automatiquement les " .. QUESTS_LABEL .. " " .. ACCOUNT_COMPLETED_QUEST_LABEL

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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- Chaman
L["shaman_HideTotem"] = "Masquer la barre de totems"

-- Démoniste
L["warlock_HideSoulShardBar"] = "Masquer la barre de fragments d'âme"

L["questAddNPCToExclude"] = "Ajouter le PNJ ciblé/fenêtre de dialogue ouverte à la liste d'exclusion"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Rechargement de l'interface requis"
L["bReloadInterface"] = "Vous devez recharger votre interface pour appliquer les modifications"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Activer la descente automatique lors de l'utilisation des capacités" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Activer la descente automatique en vol" },
	["chatMouseScroll"] = { description = "Activer le défilement de la souris dans le chat", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Désactiver les effets de mort", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Activer l'estompage de la carte en déplacement" },
	["scriptErrors"] = { description = "Afficher les erreurs LUA sur l'interface", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Afficher les couleurs des classes sur les barres de noms", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Afficher la barre de lancement de votre cible" },
	["showTutorials"] = { description = "Désactiver les tutoriels", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Activer les info-bulles avancées", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Afficher la guilde sur les joueurs" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Afficher le titre sur les joueurs" },
	["WholeChatWindowClickable"] = { description = "Rendre toute la fenêtre de chat cliquable", trueValue = "1", falseValue = "0" },
}

L["autoAcceptGroupInvite"] = "Accepter automatiquement les invitations de groupe"
L["autoAcceptGroupInviteGuildOnly"] = "Membres de la guilde"
L["autoAcceptGroupInviteFriendOnly"] = "Amis"
L["autoAcceptGroupInviteOptions"] = "Accepter les invitations de..."

L["showLeaderIconRaidFrame"] = "Afficher l’icône de chef sur les cadres de groupe en mode raid"
L["showPartyFrameInSoloContent"] = "Afficher le cadre de groupe en contenu solo"

L["ActionbarHideExplain"] = 'Définissez la barre d’actions comme masquée et visible au survol. Cela ne fonctionne que si votre barre d’actions est réglée sur "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"]
	.. '" et "'
	.. _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"]
	.. '" dans '
	.. _G["HUD_EDIT_MODE_MENU"]
	.. "."

L["enableMinimapButtonBin"] = "Activer la collecte de boutons de la minicarte"
L["enableMinimapButtonBinDesc"] = "Regroupe tous les boutons de la minicarte en un seul bouton"
L["ignoreMinimapSinkHole"] = "Ignorer les boutons de la minicarte suivants pour la collecte..."
L["useMinimapButtonBinIcon"] = "Utiliser un bouton de minicarte pour la collecte"
L["useMinimapButtonBinMouseover"] = "Afficher un cadre déplaçable pour la collecte au survol de la souris"
L["lockMinimapButtonBin"] = "Verrouiller le cadre de collecte"

L["UnitFrameHideExplain"] = "Masquer l’élément et ne l’afficher qu’au survol de la souris"
L["chatFrameFadeEnabled"] = "Activer l’estompage du chat"
L["chatFrameFadeTimeVisibleText"] = "Le texte reste visible pendant"
L["chatFrameFadeDurationText"] = "Durée de l’animation d’estompage"

L["enableLootspecQuickswitch"] = "Activer le changement rapide de spé de butin et spé active sur la minicarte"
L["enableLootspecQuickswitchDesc"] = "Clic gauche sur une spécialisation pour définir la spé de butin, clic droit pour changer de spécialisation active."

L["Profiles"] = "Profils"
L["currentExpensionMythicPlusWarning"] = "Pour les objets Mythique+ issus d’anciens donjons, les résultats peuvent être inexacts."

L["persistAuctionHouseFilter"] = "Conserver les filtres de l'hôtel des ventes pendant toute la session"
