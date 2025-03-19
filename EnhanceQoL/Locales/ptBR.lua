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
L["landingPageHide"] = "Ative esta opção para ocultar o botão da página de expansão no minimapa."
L["automaticallyOpenContainer"] = "Abrir automaticamente os itens de contêiner na bolsa"

L["showIlvlOnBankFrame"] = "Mostrar o nível do item no Banco"
L["showIlvlOnMerchantframe"] = "Exibir o nível do item na janela do mercador"
L["showIlvlOnCharframe"] = "Exibir nível do item no quadro de equipamentos do personagem"
L["showGemsOnCharframe"] = "Exibir slots de gemas no quadro de equipamentos do personagem"
L["showBindOnBagItems"] = "Exibe "
	.. _G.ITEM_BIND_ON_EQUIP
	.. " (BoE), "
	.. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
	.. " (WuE) e "
	.. _G.ITEM_BNETACCOUNTBOUND
	.. " (WB) como adição ao nível do item nos itens"
L["showGemsTooltipOnCharframe"] = "Exibir os slots de gemas na moldura de equipamentos do personagem"
L["showEnchantOnCharframe"] = "Exibir encantamentos no quadro de equipamentos do personagem"
L["showCatalystChargesOnCharframe"] = "Mostrar cargas do catalisador no quadro de equipamento do personagem"
L["showIlvlOnBagItems"] = "Exibir o nível de item no equipamento em todas as bolsas"
L["showDurabilityOnCharframe"] = "Exibir durabilidade no quadro de equipamento do personagem"
L["hideOrderHallBar"] = "Ocultar barra de comando do Salão da Ordem"
L["showInfoOnInspectFrame"] = "Mostrar informações adicionais na janela de inspeção (Experimental)"
L["MissingEnchant"] = "Encantamento"
L["hideHitIndicatorPlayer"] = "隱藏角色頭上的浮動戰鬥文字（傷害和治療）"
L["hideHitIndicatorPet"] = "隱藏寵物頭上的浮動戰鬥文字（傷害和治療）"
L["UnitFrame"] = "單位框架"
L["SellJunkIgnoredBag"] = "Você desativou a venda de itens inúteis em %d bolsas.\nIsso pode impedir a venda automática de todos os itens inúteis."

L["deleteItemFillDialog"] = 'Adicionar "' .. DELETE_ITEM_CONFIRM_STRING .. '" ao "Popup de confirmação de exclusão"'
L["confirmPatronOrderDialog"] = "Confirma automaticamente o uso de materiais próprios em encomendas de " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC
L["autoChooseQuest"] = "Aceitar e completar missões automaticamente"
L["confirmTimerRemovalTrade"] = "Confirmar automaticamente a venda de saques negociáveis durante o período de troca"

L["General"] = "Geral"
L["Character"] = "Personagem"
L["Dungeon"] = "Masmorra"
L["Misc"] = "Diversos"
L["Quest"] = "Missão"

L["hideBagsBar"] = "Ocultar barra de sacolas"
L["hideMicroMenu"] = "Ocultar micro menu"
-- Dungeon
L["autoChooseDelvePower"] = "Selecionar automaticamente o poder de incursão quando houver apenas 1 opção"
L["lfgSortByRio"] = "Classificar candidatos de masmorras míticas pelo placar mítico"

-- Quest
L["ignoreTrivialQuests"] = "Não tratar automaticamente as " .. QUESTS_LABEL .. " triviais"
L["ignoreDailyQuests"] = "Não tratar automaticamente as " .. QUESTS_LABEL .. " diárias/semanais"
L["ignoreWarbandCompleted"] = "Não tratar automaticamente as " .. QUESTS_LABEL .. " " .. ACCOUNT_COMPLETED_QUEST_LABEL

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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

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
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "Ativar desmontagem automática ao usar habilidades" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "Ativar desmontagem automática ao voar" },
	["chatMouseScroll"] = { description = "Ativar rolagem do mouse no chat", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "Desativar efeitos de morte", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "Ativar desvanecimento do mapa ao se mover" },
	["scriptErrors"] = { description = "Mostrar erros de LUA na interface", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "Mostrar cores de classe nas placas de identificação", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "Mostrar a barra de lançamento do alvo" },
	["showTutorials"] = { description = "Desativar tutoriais", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "Ativar dicas de ferramentas avançadas", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "Mostrar guilda nos jogadores" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "Mostrar título nos jogadores" },
	["WholeChatWindowClickable"] = { description = "Tornar toda a janela de chat clicável", trueValue = "1", falseValue = "0" },
}
