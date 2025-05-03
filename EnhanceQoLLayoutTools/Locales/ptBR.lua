if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Tooltip"
L[addonName] = "Tooltip"
L["None"] = "Nenhum"
L["Enemies"] = "Inimigos"
L["Friendly"] = "Amigáveis"
L["Both"] = "Ambos"
L["TooltipOFF"] = "DESLIGADO"
L["TooltipON"] = "LIGADO"
L["TooltipAnchorType"] = "Posição do Tooltip"
L["CursorCenter"] = "Centralizado no cursor"
L["CursorLeft"] = "À esquerda do cursor"
L["CursorRight"] = "À direita do cursor"
L["TooltipAnchorOffsetX"] = "Deslocamento horizontal"
L["TooltipAnchorOffsetY"] = "Deslocamento vertical"

-- Tabs
L["Unit"] = "Unidade"
L["Spell"] = "Feitiço"
L["Item"] = "Item"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Buff_Debuff"] = L["Buff"] .. "/" .. L["Debuff"]

-- Buff
L["TooltipBuffHideType"] = "Ocultar tooltip em " .. L["Buff_Debuff"]
L["TooltipBuffHideInCombat"] = "Ocultar apenas em combate"
L["TooltipBuffHideInDungeon"] = "Ocultar apenas em masmorras"

-- Debuff
L["TooltipDebuffHideType"] = "Ocultar tooltip em debuffs"
L["TooltipDebuffHideInCombat"] = "Ocultar apenas em combate"
L["TooltipDebuffHideInDungeon"] = "Ocultar apenas em masmorras"

-- Unit
L["TooltipUnitHideType"] = "Ocultar tooltip em unidades"
L["TooltipUnitHideInCombat"] = "Ocultar apenas em combate"
L["TooltipUnitHideInDungeon"] = "Ocultar apenas em masmorras"
L["BestMythic+run"] = "Melhor corrida"
L["TooltipShowMythicScore"] = "Mostrar " .. DUNGEON_SCORE .. " no Tooltip"
L["TooltipShowClassColor"] = "Mostrar cor da classe na dica de ferramenta"
L["TooltipShowNPCID"] = "Mostrar ID do NPC"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "Ocultar tooltip em feitiços"

L["TooltipSpellHideInCombat"] = "Ocultar apenas em combate"
L["TooltipSpellHideInDungeon"] = "Ocultar apenas em masmorras"

L["TooltipShowSpellID"] = "Mostrar ID do feitiço na dica de tela"
L["SpellID"] = "ID do feitiço"
L["MacroID"] = "ID do macro"

-- Item
L["TooltipItemHideType"] = "Ocultar tooltip em itens"

L["TooltipItemHideInCombat"] = "Ocultar apenas em combate"
L["TooltipItemHideInDungeon"] = "Ocultar apenas em masmorras"

L["ItemID"] = "ID do item"
L["TooltipShowItemID"] = "Mostrar ID do item na dica de tela"

L["TooltipShowItemCount"] = "Mostrar contagem de itens na dica de ferramenta"
L["TooltipShowSeperateItemCount"] = "Mostrar contagem de itens separada por local"
L["Reagentbank"] = "Banco de Reagentes"
L["Bank"] = "Banco"
L["Bag"] = "Bolsa"
L["Itemcount"] = "Contagem de itens"

L["TooltipShowQuestID"] = "Mostrar ID da missão"

L["TooltipShowCurrencyAccountWide"] = "Mostrar a moeda da conta na dica de tela"
