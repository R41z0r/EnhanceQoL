if (GAME_LOCALE or GetLocale()) ~= "frFR" then return end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Clé de voûte"
L["Automatically insert keystone"] = "Insérer automatiquement la clé de voûte"
L["Mythic Plus"] = "Mythique+"
L[addonName] = "Mythique+"
L["Close all bags on keystone insert"] = "Fermer tous les sacs,\nlorsque la clé de voûte est insérée"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Vérification\nde préparation..."
L["PullTimer"] = "Pull Timer"
L["Pull"] = "Pull"
L["Cancel"] = "Annuler"
L["Cancel Pull Timer on click"] = "Annuler le minuteur de pull au clic"
L["noChatOnPullTimer"] = "Pas de messages dans le\nchat pour le minuteur de pull"
L["sliderShortTime"] = "Minuteur de pull clic droit"
L["sliderLongTime"] = "Minuteur de pull"
L["Stating"] = "Démarrage..."
L["autoKeyStart"] = "Démarrer automatiquement la clé de voûte\naprès expiration du minuteur de pull"

L["None"] = "Aucun minuteur de pull"
L["Blizzard Pull Timer"] = "Minuteur de pull Blizzard"
L["DBM / BigWigs Pull Timer"] = "Minuteur de pull DBM / BigWigs"
L["Both"] = "Blizzard et DBM / BigWigs"
L["Pull Timer Type"] = "Type de minuteur de pull"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Faites glisser"
L["Potion Tracker"] = "Suivi des potions"
L["Toggle Anchor"] = "Basculer l'ancre"
L["Save Anchor"] = "Enregistrer l'ancre"
L["potionTrackerHeadline"] = "Cela vous permet de suivre le CD des\npotions de combat des membres de votre groupe sous forme de barre déplaçable"
L["potionTracker"] = "Activer le suivi des CD des potions"
L["potionTrackerUpwardsBar"] = "Se développer vers le haut"
L["potionTrackerClassColor"] = "Utiliser les couleurs de classe pour les barres"
L["potionTrackerDisableRaid"] = "Désactiver le suivi des potions en raid"

L["Tinker"] = "Bricoleur"
L["InvisPotion"] = "Invisibilité"
L["potionTrackerShowTooltip"] = "Afficher l'infobulle sur l'icône"
L["HealingPotion"] = "Soins"
L["potionTrackerHealingPotions"] = "Suivre le CD de la potion de soins"
L["potionTrackerOffhealing"] = "Suivi de l'utilisation des CD de soins secondaires"
-- Outils de recherche de groupe

L["DungeonBrowser"] = "Explorateur de donjons"
L["groupfinderAppText"] = 'Masquer le texte du recherche de groupe "Votre groupe est actuellement en formation"'
L["groupfinderSkipRolecheck"] = "Ignorer la vérification de rôle\net utiliser le rôle actuel"

-- Misc Frame
L["Misc"] = "Divers"
L["autoMarkTankInDungeon"] = "Marquer automatiquement le " .. TANK .. " dans les donjons"
L["autoMarkTankInDungeonMarker"] = "Marqueur de tank"
L["Disabled"] = "Désactivé"
L["autoMarkTankExplanation"] = "Le " .. TANK .. " sera marqué s'il n'a pas de marque et ne changera la marque\nque si vous êtes soit " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " ou " .. TANK

-- Teleports
L["Teleports"] = "Téléportations"
L["teleportEnabled"] = "Activer le cadre de téléportation"
L["DungeonCompendium"] = "Compendium de Téléportation"
L["teleportsEnableCompendium"] = "Activer le Compendium de Téléportation"

L["teleportsHeadline"] = "Ajoute un cadre avec les téléportations de donjon à votre fenêtre JcE"
L["portalHideMissing"] = "Masquer les téléportations manquantes"
L["portalShowTooltip"] = "Afficher l'infobulle sur les boutons de téléportation"
L["hideActualSeason"] = "Masquer les téléportations de la saison actuelle dans " .. L["DungeonCompendium"]
