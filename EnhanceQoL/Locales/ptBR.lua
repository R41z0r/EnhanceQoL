if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "Inscrição rápida"
L["Persist LFG signup note"] = "Persistir nota de inscrição LFG"
L["Select an option"] = "Selecione uma opção"
L["Save"] = "Salvar"
L["Hide Minimap Button"] = "Ocultar botão do minimapa"
L["Left-Click to show options"] = "Clique com o botão esquerdo para mostrar opções"

L["Hide Raid Tools"] = "Ocultar ferramentas de raid no grupo"
L["repairCost"] = "Itens reparados por "
L["autoRepair"] = "Reparar automaticamente todos os itens"
L["sellAllJunk"] = "Vender automaticamente todos os itens inúteis"
L["ignoreTalkingHead"] = "Ocultar automaticamente o quadro Talking Head"

L["showIlvlOnCharframe"] = "Exibir nível do item no quadro de equipamentos do personagem"
L["showGemsOnCharframe"] = "Exibir slots de gemas no quadro de equipamentos do personagem"
L["showEnchantOnCharframe"] = "Exibir encantamentos no quadro de equipamentos do personagem"
L["showCatalystChargesOnCharframe"] = "Mostrar cargas do catalisador no quadro de equipamento do personagem"
L["showIlvlOnBagItems"] = "Exibir o nível de item no equipamento em todas as bolsas"
L["showDurabilityOnCharframe"] = "Exibir durabilidade no quadro de equipamento do personagem"
L["hideOrderHallBar"] = "Ocultar barra de comando do Salão da Ordem"

L["deleteItemFillDialog"] = "Adicionar \"" .. DELETE_ITEM_CONFIRM_STRING ..
                                "\" ao \"Popup de confirmação de exclusão\""
L["autoChooseQuest"] = "Aceitar e completar missões automaticamente"

L["General"] = "Geral"
L["Character"] = "Personagem"
L["Dungeon"] = "Masmorra"
L["Misc"] = "Diversos"
L["Quest"] = "Missão"

L["hideBagsBar"] = "Ocultar barra de sacolas"

-- Dungeon
L["autoChooseDelvePower"] = "Selecionar automaticamente o poder de\nincursão quando houver apenas 1 opção"
L["lfgSortByRio"] = "Classificar candidatos de masmorras míticas pelo placar mítico"

-- Quest
L["ignoreTrivialQuests"] = "Ignorar missões triviais"
L["ignoreDailyQuests"] = "Ignorar missões diárias/semanal"

L["autoQuickLoot"] = "Saque rápido de itens"
L["openCharframeOnUpgrade"] = "Abrir painel de personagem ao melhorar itens com o vendedor"

L["headerClassInfo"] = "Essas configurações só se aplicam a " .. select(1, UnitClass("player"))

-- Cavaleiro da Morte
L["deathknight_HideRuneFrame"] = "Ocultar barra de runas"

-- Evocador
L["evoker_HideEssence"] = "Ocultar barra de essência"

-- Monge
L["monk_HideHarmonyBar"] = "Ocultar barra de harmonia"

-- Paladino
L["paladin_HideHolyPower"] = "Ocultar barra de poder sagrado"

-- Ladino
L["rogue_HideComboPoint"] = "Ocultar barra de pontos de combo"

-- Xamã
L["shaman_HideTotem"] = "Ocultar barra de totens"

-- Bruxo
L["warlock_HideSoulShardBar"] = "Ocultar barra de fragmentos de alma"

L["questAddNPCToExclude"] = "Adicionar o PNJ selecionado/janela de diálogo aberta à lista de exclusão"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Recarregamento da interface necessário"
L["bReloadInterface"] = "Você precisa recarregar sua interface para aplicar as alterações"

L["CVarOptions"] = {
    ["autoDismount"] = {trueValue = "1", falseValue = "0", description = "Ativar desmontagem automática ao usar habilidades"},
    ["autoDismountFlying"] = {trueValue = "1", falseValue = "0", description = "Ativar desmontagem automática ao voar"},
    ["chatMouseScroll"] = {description = "Ativar rolagem do mouse no chat", trueValue = "1", falseValue = "0"},
    ["ffxDeath"] = {description = "Desativar efeitos de morte", trueValue = "0", falseValue = "1"},
    ["mapFade"] = {trueValue = "1", falseValue = "0", description = "Ativar desvanecimento do mapa ao se mover"},
    ["scriptErrors"] = {description = "Mostrar erros de LUA na interface", trueValue = "1", falseValue = "0"},
    ["ShowClassColorInNameplate"] = {description = "Mostrar cores de classe nas placas de identificação", trueValue = "1", falseValue = "0"},
    ["ShowTargetCastbar"] = {trueValue = "1", falseValue = "0", description = "Mostrar a barra de lançamento do alvo"},
    ["showTutorials"] = {description = "Desativar tutoriais", trueValue = "0", falseValue = "1"},
    ["UberTooltips"] = {description = "Ativar dicas de ferramentas avançadas", trueValue = "1", falseValue = "0"},
    ["UnitNamePlayerGuild"] = {trueValue = "1", falseValue = "0", description = "Mostrar guilda nos jogadores"},
    ["UnitNamePlayerPVPTitle"] = {trueValue = "1", falseValue = "0", description = "Mostrar título nos jogadores"},
    ["WholeChatWindowClickable"] = {description = "Tornar toda a janela de chat clicável", trueValue = "1", falseValue = "0"},
}