if (GAME_LOCALE or GetLocale()) ~= "frFR" then
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

L["Vendor"] = "Vendeur"
L["MerchantWindowClosed"] = "La fenêtre du marchand est fermée. Arrêt de la vente"

-- Général
L["vendorMinIlvlDif"] = "Niveau d'objet minimum sous ma moyenne\npour être marqué pour la vente automatique"
L["vendorIgnoreBoE"] = "Ignorer les objets liés quand équipés"
L["vendorIgnoreWarbound"] = "Ignorer les objets liés par la guerre"
L["vendorIgnoreUpgradable"] = "Ignorer les objets améliorables"

L["IncludeVendorList"] = "Liste d'articles"
L["ExcludeVendorList"] = "Liste d'articles"
L["Include"] = "Inclure"
L["Exclude"] = "Exclure"

L["Add"] = "Ajouter"
L["Remove"] = "Supprimer"
L["Item id or drag item"] = "ID de l'article ou faites glisser l'article"
L["Item id does not exist"] = "L'ID de l'article n'existe pas"
L["vendorAddItemToInclude"] = "Ajoutez des articles à cette liste pour les inclure dans la vente.\nIMPORTANT : Cela ignore toutes les autres vérifications pour cet article"
L["vendorAddItemToExclude"] = "Ajoutez des objets à cette liste pour les exclure de la vente.\nIMPORTANT : L'exclusion l'emporte toujours, sauf s'il s'agit de camelote"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] = "Cela vous permet de vendre automatiquement les objets\nde qualité " ..
                                                   ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                   "|r en fonction de critères de filtre\nlors de la visite d'un marchand."
    L["vendor" .. value .. "Enable"] = "Activer la vente automatique\npour les objets de qualité " ..
                                           ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
    L["labelExplained" .. value .. "line"] =
        "Cela signifie qu'il vend automatiquement " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r\nles objets avec un niveau d'objet de %s et inférieur\n%s"
end
