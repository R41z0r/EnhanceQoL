if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

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
L["noChatOnPullTimer"] = "Nenhuma mensagem no chat durante\no cronômetro de pull"
L["sliderShortTime"] = "Cronômetro de pull clique direito"
L["sliderLongTime"] = "Cronômetro de pull"
L["Stating"] = "Iniciando..."
L["autoKeyStart"] = "Iniciar a chave automaticamente após\no cronômetro de pull"

L["None"] = "Nenhum cronômetro de pull"
L["Blizzard Pull Timer"] = "Cronômetro de pull da Blizzard"
L["DBM / BigWigs Pull Timer"] = "Cronômetro de pull do DBM / BigWigs"
L["Both"] = "Blizzard e DBM / BigWigs"
L["Pull Timer Type"] = "Tipo de cronômetro de pull"

--Potion Tracker
L["Drag me to position Cooldownbars"] = "Arraste-me"
L["Potion Tracker"] = "Rastreador de Poções"
L["Toggle Anchor"] = "Alternar Âncora"
L["Save Anchor"] = "Salvar Âncora"
L["potionTrackerHeadline"] = "Isso permite rastrear o CD das\npoções de combate dos membros do seu grupo como uma barra móvel"
L["potionTracker"] = "Ativar rastreador de tempo de recarga de poções"
L["potionTrackerUpwardsBar"] = "Crescer para cima"
L["potionTrackerClassColor"] = "Usar cores de classe para as barras"
L["potionTrackerDisableRaid"] = "Desativar rastreador de poções em raids"

L["Tinker"] = "Engenheiro"
L["InvisPotion"] = "Invisibilidade"
L["potionTrackerShowTooltip"] = "Mostrar tooltip no ícone"
L["HealingPotion"] = "Cura"
L["potionTrackerHealingPotions"] = "Rastrear CD de poção de cura"