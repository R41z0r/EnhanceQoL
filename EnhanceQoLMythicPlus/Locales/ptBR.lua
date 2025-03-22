if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "Pedra-chave"
L["NoKeystone"] = "Sem informação"
L["Automatically insert keystone"] = "Inserir a chave automaticamente"
L["Mythic Plus"] = "Mítica+"
L[addonName] = "Mítica+"
L["Close all bags on keystone insert"] = "Fechar todas as bolsas ao inserir a chave"
L["ReadyCheck"] = "Verificação de prontidão"
L["ReadyCheckWaiting"] = "Verificando prontidão..."
L["PullTimer"] = "Cronômetro de pull"
L["Pull"] = "Pull"
L["Cancel"] = "Cancelar"
L["Cancel Pull Timer on click"] = "Cancelar cronômetro de pull ao clicar"
L["noChatOnPullTimer"] = "Nenhuma mensagem no chat durante o cronômetro de pull"
L["sliderShortTime"] = "Cronômetro de pull clique direito"
L["sliderLongTime"] = "Cronômetro de pull"
L["Stating"] = "Iniciando..."
L["autoKeyStart"] = "Iniciar a chave automaticamente após o cronômetro de pull"
L["mythicPlusTruePercent"] = "Mostrar o valor decimal das Forças Inimigas"
L["mythicPlusChestTimer"] = "Mostrar os temporizadores de baús"

L["None"] = "Nenhum cronômetro de pull"
L["Blizzard Pull Timer"] = "Cronômetro de pull da Blizzard"
L["DBM / BigWigs Pull Timer"] = "Cronômetro de pull do DBM / BigWigs"
L["Both"] = "Blizzard e DBM / BigWigs"
L["Pull Timer Type"] = "Tipo de cronômetro de pull"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "Arraste-me"
L["Potion Tracker"] = "Rastreador de Poções"
L["Toggle Anchor"] = "Alternar Âncora"
L["Save Anchor"] = "Salvar Âncora"
L["potionTrackerHeadline"] = "Isso permite rastrear o CD das poções de combate dos membros do seu grupo como uma barra móvel"
L["potionTracker"] = "Ativar rastreador de tempo de recarga de poções"
L["potionTrackerUpwardsBar"] = "Crescer para cima"
L["potionTrackerClassColor"] = "Usar cores de classe para as barras"
L["potionTrackerDisableRaid"] = "Desativar rastreador de poções em raids"

L["Tinker"] = "Engenheiro"
L["InvisPotion"] = "Invisibilidade"
L["potionTrackerShowTooltip"] = "Mostrar tooltip no ícone"
L["HealingPotion"] = "Cura"
L["potionTrackerHealingPotions"] = "Rastrear CD de poção de cura"
L["potionTrackerOffhealing"] = "Acompanhar o uso de CD de cura secundária"
-- Ferramentas LFG

L["DungeonBrowser"] = "Explorador de Masmorras"
L["groupfinderAppText"] = 'Ocultar o texto do buscador de grupos "Seu grupo está se formando atualmente"'
L["groupfinderMoveResetButton"] = "Mova o botão de redefinição de filtro do Localizador de Masmorras para o lado esquerdo."
L["groupfinderShowDungeonScoreFrame"] = "Exibir o quadro " .. DUNGEON_SCORE .. " ao lado do Localizador de Masmorras"
L["groupfinderSkipRoleSelect"] = "Pular seleção de função"
L["groupfinderSkipRolecheckHeadline"] = "Atribuição automática de função"
L["groupfinderSkipRolecheckUseSpec"] = "Use a função da sua especialização (ex. Cavaleiro da Morte (Sangue) = Tanque)"
L["groupfinderSkipRolecheckUseLFD"] = "Use as funções do Localizador de Masmorras"
L["groupfinderShowPartyKeystone"] = "Exibir as informações de pedra-chave Mítica dos membros do grupo"

-- Misc Frame
L["Misc"] = "Diversos"
L["autoMarkTankInDungeon"] = "Marcar automaticamente o " .. TANK .. " em masmorras"
L["autoMarkTankInDungeonMarker"] = "Marcador de tanque"
L["Disabled"] = "Desativado"
L["autoMarkTankExplanation"] = "O " .. TANK .. " será marcado quando não tiver uma marca e só mudará a marca se você for " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " ou " .. TANK
L["mythicPlusIgnoreMythic"] = "Não aplicar um marcador de raide em masmorras " .. PLAYER_DIFFICULTY6
L["mythicPlusIgnoreHeroic"] = "Não aplicar um marcador de raide em masmorras " .. PLAYER_DIFFICULTY2
L["mythicPlusIgnoreEvent"] = "Não aplicar um marcador de raide em masmorras " .. BATTLE_PET_SOURCE_7
L["mythicPlusIgnoreNormal"] = "Não aplicar um marcador de raide em masmorras " .. PLAYER_DIFFICULTY1
L["mythicPlusIgnoreTimewalking"] = "Não aplicar um marcador de raide em masmorras " .. PLAYER_DIFFICULTY_TIMEWALKER

-- Teleports
L["Teleports"] = "Teleportes"
L["teleportEnabled"] = "Habilitar painel de teleporte"
L["DungeonCompendium"] = "Compêndio de Teleporte"
L["teleportsEnableCompendium"] = "Habilitar Compêndio de Teleporte"
L["teleportCompendiumHeadline"] = "Ocultar teletransportes de expansões específicas"

L["teleportsHeadline"] = "Adiciona um painel com teleportes de masmorras à sua janela JxA"
L["portalHideMissing"] = "Ocultar teleportes ausentes"
L["portalShowTooltip"] = "Mostrar dica nos botões de teleporte"
L["hideActualSeason"] = "Ocultar os teletransportes da temporada atual em " .. L["DungeonCompendium"]
L["teleportCompendiumAdditionHeadline"] = "Opções adicionais de portal"
L["portalShowDungeonTeleports"] = "Mostrar teletransportes de masmorra"
L["portalShowRaidTeleports"] = "Mostrar teletransportes de raide"
L["portalShowToyHearthstones"] = "Mostrar itens e brinquedos de teletransporte (ex.: Pedras de Regresso)"
L["portalShowEngineering"] = "Mostrar teletransportes de Engenharia (requer Engenharia)"
L["portalShowClassTeleport"] = "Mostrar teletransportes específicos de classe (apenas se a classe possuir)"
L["portalShowMagePortal"] = "Mostrar portais de Mago (apenas para Magos)"

-- BR Tracker
L["BRTracker"] = "Ressurreição em combate"
L["brTrackerHeadline"] = "Adiciona um rastreador de ressurreição em combate em masmorras Míticas+"
L["mythicPlusBRTrackerEnabled"] = "Habilitar rastreador de ressurreição em combate"
L["mythicPlusBRTrackerLocked"] = "Travar a posição do rastreador"
L["mythicPlusBRButtonSizeHeadline"] = "Tamanho do botão"
