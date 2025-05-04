local L = LibStub("AceLocale-3.0"):NewLocale("EnhanceQoL_Vendor", "deDE")
if not L then return end

--@localization(locale="deDE", namespace="Vendor", format="lua_additive_table")@

L["Vendor"] = "Händler"
L["MerchantWindowClosed"] = "Händlerfenster geschlossen. Verkauf gestoppt"

-- Allgemein
L["vendorMinIlvlDif"] = "Min. Gegenstandsstufe unter meinem Durchschnitt zum automatischen Verkaufen"
L["vendorIgnoreBoE"] = "Bind-on-Equip-Gegenstände ignorieren"
L["vendorIgnoreWarbound"] = "Kriegsgebundene Gegenstände ignorieren"
L["vendorIgnoreUpgradable"] = "Aufrüstbare Gegenstände ignorieren"
L["vendorSwapAutoSellShift"] = "Nur automatisch verkaufen, wenn Shift beim Öffnen gehalten wird"
L["vendorOnly12Items"] = "Begrenzt die Anzahl verkaufter Gegenstände pro Vorgang auf 12, um leichter zurückkaufen zu können"

L["IncludeVendorList"] = "Gegenstandsliste"
L["ExcludeVendorList"] = "Gegenstandsliste"
L["Include"] = "Einschließen"
L["Exclude"] = "Ausschließen"

L["Add"] = "Hinzufügen"
L["Remove"] = "Entfernen"
L["Item id or drag item"] = "Item-ID oder Gegenstand ziehen"
L["Item id does not exist"] = "Item-ID existiert nicht"
L["vendorAddItemToInclude"] = "Füge Gegenstände hinzu, die immer verkauft werden sollen. WICHTIG: Alle anderen Prüfungen werden dabei ignoriert."
L["vendorAddItemToExclude"] = "Füge Gegenstände hinzu, die niemals verkauft werden sollen. WICHTIG: Ausschluss hat immer Vorrang, außer bei Grauschrott."
L["vendorMinIlvl"] = "Markiert Gegenstände mit einer Gegenstandsstufe unter dem gewählten Wert zum automatischen Verkauf"
L["vendorAbsolutIlvl"] = "Absolute Gegenstandsstufe zum Verkaufen verwenden statt minimal ausgerüsteter Gegenstandsstufe"

L["labelItemQualityline"] = "Ermöglicht das automatische Verkaufen von %s-Gegenständen anhand von Filterkriterien beim Händler"
L["vendorEnable"] = "Automatischen Verkauf für %s-Gegenstände aktivieren"
L["labelExplainedline"] = "Das bedeutet: Es verkauft automatisch %s‑Gegenstände mit einer Gegenstandsstufe von %s oder niedriger %s"
