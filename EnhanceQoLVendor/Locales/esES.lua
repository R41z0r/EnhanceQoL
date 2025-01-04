if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

-- Spanisch
L["Vendor"] = "Vendedor"
L["MerchantWindowClosed"] = "La ventana del comerciante está cerrada. Parando ventas"

-- General
L["vendorMinIlvlDif"] = "Nivel de objeto mínimo bajo mi promedio para marcarlo para venta automática"
L["vendorIgnoreBoE"] = "Ignorar objetos que se ligan al equipar"
L["vendorIgnoreWarbound"] = "Ignorar objetos vinculados por guerra"
L["vendorIgnoreUpgradable"] = "Ignorar objetos mejorables"
L["vendorSwapAutoSellShift"] = "Vender automáticamente solo cuando Shift se mantenga presionado al abrir"
L["vendorOnly12Items"] = "Limita el número de objetos vendidos por transacción a 12, permitiendo una recompra más sencilla al comerciante."

L["IncludeVendorList"] = "Lista de artículos"
L["ExcludeVendorList"] = "Lista de artículos"
L["Include"] = "Incluir"
L["Exclude"] = "Excluir"

L["Add"] = "Agregar"
L["Remove"] = "Eliminar"
L["Item id or drag item"] = "ID de artículo o arrastra el artículo"
L["Item id does not exist"] = "La ID del artículo no existe"
L["vendorAddItemToInclude"] = "Agregue artículos a esta lista para incluirlos en la venta. IMPORTANTE: Esto ignora todas las demás verificaciones para este artículo"
L["vendorAddItemToExclude"] = "Agrega artículos a esta lista para excluirlos de la venta. IMPORTANTE: La exclusión siempre tiene prioridad, a menos que sea basura"
L["vendorMinIlvl"] = "Marcar objetos con un ilvl inferior al valor seleccionado para la venta automática"
L["vendorAbsolutIlvl"] = "Usar el ilvl absoluto para vender equipo en lugar del ilvl mínimo equipado"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
	local value = addon.Vendor.variables.tabNames[key]
	L["labelItemQuality" .. value .. "line"] = "Esto te permite vender automáticamente los objetos de calidad "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r en función de criterios de filtro cuando estás en un comerciante."
	L["vendor" .. value .. "Enable"] = "Activar la venta automática para objetos de calidad " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
	L["labelExplained" .. value .. "line"] = "Esto significa que automáticamente vende "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r objetos con un nivel de objeto de %s o inferior %s"
end
