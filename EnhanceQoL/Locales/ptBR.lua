if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
    return
  end

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