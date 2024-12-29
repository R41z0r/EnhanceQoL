if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Piedra angular"
L["Automatically insert keystone"] = "Insertar automáticamente la piedra angular"
L["Mythic Plus"] = "Mítico+"
L[addonName] = "Mítico+"
L["Close all bags on keystone insert"] = "Cerrar todas las bolsas al insertar la piedra angular"
L["ReadyCheck"] = "Ready Check"
L["ReadyCheckWaiting"] = "Comprobando preparación..."
L["PullTimer"] = "Pull Timer"
L["Pull"] = "Pull"
L["Cancel"] = "Cancelar"
L["Cancel Pull Timer on click"] = "Cancelar el temporizador de pull al hacer clic"
L["noChatOnPullTimer"] = "Sin mensajes en el chat para el temporizador de pull"
L["sliderShortTime"] = "Temporizador de pull clic derecho"
L["sliderLongTime"] = "Temporizador de pull"
L["Stating"] = "Iniciando..."
L["autoKeyStart"] = "Iniciar la piedra angular automáticamente después del temporizador de pull"

L["None"] = "Sin temporizador de pull"
L["Blizzard Pull Timer"] = "Temporizador de pull de Blizzard"
L["DBM / BigWigs Pull Timer"] = "Temporizador de pull de DBM / BigWigs"
L["Both"] = "Blizzard y DBM / BigWigs"
L["Pull Timer Type"] = "Tipo de temporizador de pull"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Arrástrame"
L["Potion Tracker"] = "Rastreador de pociones"
L["Toggle Anchor"] = "Alternar ancla"
L["Save Anchor"] = "Guardar ancla"
L["potionTrackerHeadline"] = "Esto te permite rastrear el CD de las pociones de combate de los miembros de tu grupo como una barra móvil"
L["potionTracker"] = "Habilitar rastreador de enfriamiento de pociones"
L["potionTrackerUpwardsBar"] = "Crecer hacia arriba"
L["potionTrackerClassColor"] = "Usar colores de clase para las barras"
L["potionTrackerDisableRaid"] = "Desactivar rastreador de pociones en incursiones"

L["Tinker"] = "Ingeniero"
L["InvisPotion"] = "Invisibilidad"
L["potionTrackerShowTooltip"] = "Mostrar información en el icono"
L["HealingPotion"] = "Curación"
L["potionTrackerHealingPotions"] = "Rastrear CD de poción de salud"
L["potionTrackerOffhealing"] = "Rastrear uso de CD de sanación secundaria"
-- Herramientas de Buscador de Mazmorras

L["DungeonBrowser"] = "Explorador de mazmorras"
L["groupfinderAppText"] = 'Ocultar el texto del buscador de grupos "Tu grupo se está formando actualmente"'
L["groupfinderSkipRolecheck"] = "Omitir la verificación de rol y usar el rol actual"

-- Misc Frame
L["Misc"] = "Misceláneo"
L["autoMarkTankInDungeon"] = "Marcar automáticamente al " .. TANK .. " en mazmorras"
L["autoMarkTankInDungeonMarker"] = "Marcador de tanque"
L["Disabled"] = "Desactivado"
L["autoMarkTankExplanation"] = "El " .. TANK .. " será marcado cuando no tenga una marca y solo cambiará la marca si eres " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " o " .. TANK

-- Teleports
L["Teleports"] = "Teletransportes"
L["teleportEnabled"] = "Habilitar marco de teletransporte"
L["DungeonCompendium"] = "Compendio de Teletransporte"
L["teleportsEnableCompendium"] = "Habilitar Compendio de Teletransporte"

L["teleportsHeadline"] = "Añade un marco con teletransportes de mazmorras a tu ventana JcE"
L["portalHideMissing"] = "Ocultar teletransportes faltantes"
L["portalShowTooltip"] = "Mostrar información emergente en los botones de teletransporte"
L["hideActualSeason"] = "Ocultar los teletransportes de la temporada actual en " .. L["DungeonCompendium"]
