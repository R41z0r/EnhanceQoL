if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then
    return
end
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
L["vendorMinIlvlDif"] = "Nivel de objeto mínimo bajo mi\npromedio para marcarlo para venta automática"
L["vendorIgnoreBoE"] = "Ignorar objetos que se ligan al equipar"
L["vendorIgnoreWarbound"] = "Ignorar objetos vinculados por guerra"
L["vendorIgnoreUpgradable"] = "Ignorar objetos mejorables"

L["IncludeVendorList"] = "Lista de artículos"
L["ExcludeVendorList"] = "Lista de artículos"
L["Include"] = "Incluir"
L["Exclude"] = "Excluir"

L["Add"] = "Agregar"
L["Remove"] = "Eliminar"
L["Item id or drag item"] = "ID de artículo o arrastra el artículo"
L["Item id does not exist"] = "La ID del artículo no existe"
L["vendorAddItemToInclude"] = "Agregue artículos a esta lista para incluirlos en la venta.\nIMPORTANTE: Esto ignora todas las demás verificaciones para este artículo"
L["vendorAddItemToExclude"] = "Agrega artículos a esta lista para excluirlos de la venta.\nIMPORTANTE: La exclusión siempre tiene prioridad, a menos que sea basura"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] = "Esto te permite vender automáticamente\nlos objetos de calidad " ..
                                                   ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                   "|r\nen función de criterios de filtro cuando estás en un comerciante."
    L["vendor" .. value .. "Enable"] = "Activar la venta automática para\nobjetos de calidad " ..
                                           ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
    L["labelExplained" .. value .. "line"] = "Esto significa que automáticamente vende " ..
                                                 ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                 "|r\nobjetos con un nivel de objeto de %s o inferior\n%s"
end
