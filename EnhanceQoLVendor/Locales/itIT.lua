if (GAME_LOCALE or GetLocale()) ~= "itIT" then
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

L["Vendor"] = "Venditore"
L["MerchantWindowClosed"] = "La finestra del mercante è chiusa. Interruzione delle vendite"

-- Generale
L["vendorMinIlvlDif"] = "Livello oggetto minimo sotto la mia\nmedia per contrassegnarlo per la vendita automatica"
L["vendorIgnoreBoE"] = "Ignora oggetti che si vincolano quando equipaggiati"
L["vendorIgnoreWarbound"] = "Ignora oggetti vincolati da guerra"
L["vendorIgnoreUpgradable"] = "Ignora gli oggetti aggiornabili"

L["IncludeVendorList"] = "Elenco articoli"
L["ExcludeVendorList"] = "Elenco articoli"
L["Include"] = "Includi"
L["Exclude"] = "Escludi"

L["Add"] = "Aggiungi"
L["Remove"] = "Rimuovi"
L["Item id or drag item"] = "ID articolo o trascina l'articolo"
L["Item id does not exist"] = "L'ID dell'articolo non esiste"
L["vendorAddItemToInclude"] = "Aggiungi articoli a questo elenco per includerli nella vendita.\nIMPORTANTE: Questo ignora tutti gli altri controlli per questo articolo"
L["vendorAddItemToExclude"] = "Aggiungi articoli a questo elenco per escluderli dalla vendita.\nIMPORTANTE: L'esclusione prevale sempre, a meno che non si tratti di spazzatura"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] =
        "Questo ti consente di vendere automaticamente gli oggetti di qualità " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r in base ai criteri di filtro quando sei da un mercante."
    L["vendor" .. value .. "Enable"] = "Abilita la vendita automatica per oggetti di qualità " ..
                                           ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
    L["labelExplained" .. value .. "line"] =
        "Ciò significa che vende automaticamente " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r gli oggetti con un livello di oggetto di %s e inferiore %s"
end
