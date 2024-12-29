if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

L["Vendor"] = "Vendedor"
L["MerchantWindowClosed"] = "A janela do comerciante está fechada. Interrompendo as vendas"

-- Geral
L["vendorMinIlvlDif"] = "Nível de item mínimo abaixo da minha média para marcar para venda automática"
L["vendorIgnoreBoE"] = "Ignorar itens que se vinculam ao serem equipados"
L["vendorIgnoreWarbound"] = "Ignorar itens vinculados à guerra"
L["vendorIgnoreUpgradable"] = "Ignorar itens atualizáveis"

L["IncludeVendorList"] = "Lista de itens"
L["ExcludeVendorList"] = "Lista de itens"
L["Include"] = "Incluir"
L["Exclude"] = "Excluir"

L["Add"] = "Adicionar"
L["Remove"] = "Remover"
L["Item id or drag item"] = "ID do item ou arraste o item"
L["Item id does not exist"] = "ID do item não existe"
L["vendorAddItemToInclude"] = "Adicione itens a esta lista para incluí-los na venda. IMPORTANTE: Isso ignora todas as outras verificações para este item"
L["vendorAddItemToExclude"] = "Adicione itens a esta lista para excluí-los da venda. IMPORTANTE: A exclusão sempre prevalece, a menos que seja lixo"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
	local value = addon.Vendor.variables.tabNames[key]
	L["labelItemQuality" .. value .. "line"] = "Isso permite que você venda automaticamente itens de qualidade "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r com base em critérios de filtro ao visitar um comerciante."
	L["vendor" .. value .. "Enable"] = "Ativar a venda automática para itens de qualidade " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
	L["labelExplained" .. value .. "line"] = "Isso significa que ele vende automaticamente " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r itens com um nível de item de %s ou inferior %s"
end
