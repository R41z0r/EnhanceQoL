if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

-- Russisch
L["Vendor"] = "Продавец"
L["MerchantWindowClosed"] = "Окно торговца закрыто. Остановка продаж"

-- Общее
L["vendorMinIlvlDif"] = "Минимальный уровень предмета ниже моего\nсреднего, чтобы отметить его для автоматической продажи"
L["vendorIgnoreBoE"] = "Игнорировать предметы, привязываемые при надевании"
L["vendorIgnoreWarbound"] = "Игнорировать военные предметы"
L["vendorIgnoreUpgradable"] = "Игнорировать улучшаемые предметы"

L["IncludeVendorList"] = "Список предметов"
L["ExcludeVendorList"] = "Список предметов"
L["Include"] = "Включить"
L["Exclude"] = "Исключить"

L["Add"] = "Добавить"
L["Remove"] = "Удалить"
L["Item id or drag item"] = "ID предмета или перетащите предмет"
L["Item id does not exist"] = "ID предмета не существует"
L["vendorAddItemToInclude"] =
	"Добавьте предметы в этот список, чтобы включить их в продажу.\nВАЖНО: Это игнорирует все остальные проверки для этого предмета"
L["vendorAddItemToExclude"] =
	"Добавьте предметы в этот список, чтобы исключить их из продажи.\nВАЖНО: Исключение всегда побеждает, если только это не хлам"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
	local value = addon.Vendor.variables.tabNames[key]
	L["labelItemQuality" .. value .. "line"] = "Это позволяет автоматически продавать предметы качества "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r на основе критериев фильтра при посещении торговца."
	L["vendor" .. value .. "Enable"] = "Включить автоматическую продажу предметов качества " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r"
	L["labelExplained" .. value .. "line"] = "Это означает, что автоматически продаются "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r предметы с уровнем предмета %s и ниже %s"
end
