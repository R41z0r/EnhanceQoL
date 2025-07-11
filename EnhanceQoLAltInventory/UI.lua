local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_AltInventory")

local AceGUI = addon.AceGUI

local frame
local tabGroup
local AltInventory = addon.AltInventory or {}

local function getItemInfoFromLink(link)
	if not link then return end
	local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(link)
	return itemName, itemTexture, itemQuality
end

local function buildByItem(container)
	local aggregated = {}
	for guid, items in pairs(addon.db.altInventory or {}) do
		for link, count in pairs(items) do
			if not aggregated[link] then aggregated[link] = { total = 0, chars = {} } end
			aggregated[link].total = aggregated[link].total + count
			aggregated[link].chars[guid] = count
		end
	end

	local tree = {}
	for link, data in pairs(aggregated) do
		local name, icon, quality = getItemInfoFromLink(link)
		local colorHex = select(4, GetItemQualityColor(quality or 1))
		local text = string.format("|T%s:0|t |c%s%s|r x%d", icon or "", colorHex, name or link, data.total)
		local node = { value = link, text = text, children = {} }
		for guid, count in pairs(data.chars) do
			local charName = addon.db.altInventoryNames and addon.db.altInventoryNames[guid] or guid
			table.insert(node.children, { value = link .. guid, text = string.format("%s x%d", charName, count) })
		end
		table.sort(node.children, function(a, b) return a.text < b.text end)
		table.insert(tree, node)
	end
	table.sort(tree, function(a, b) return a.text < b.text end)

	local tg = AceGUI:Create("TreeGroup")
	tg:SetFullWidth(true)
	tg:SetFullHeight(true)
	tg:SetTree(tree)
	container:AddChild(tg)
end

local function buildByChar(container)
	local tree = {}
	for guid, items in pairs(addon.db.altInventory or {}) do
		local charName = addon.db.altInventoryNames and addon.db.altInventoryNames[guid] or guid
		local node = { value = guid, text = charName, children = {} }
		for link, count in pairs(items) do
			local name, icon, quality = getItemInfoFromLink(link)
			local colorHex = select(4, GetItemQualityColor(quality or 1))
			local childText = string.format("|T%s:0|t |c%s%s|r x%d", icon or "", colorHex, name or link, count)
			table.insert(node.children, { value = guid .. link, text = childText })
		end
		table.sort(node.children, function(a, b) return a.text < b.text end)
		table.insert(tree, node)
	end
	table.sort(tree, function(a, b) return a.text < b.text end)

	local tg = AceGUI:Create("TreeGroup")
	tg:SetFullWidth(true)
	tg:SetFullHeight(true)
	tg:SetTree(tree)
	container:AddChild(tg)
end

local function buildTab(container, group)
	container:ReleaseChildren()
	if group == "byitem" then
		buildByItem(container)
	else
		buildByChar(container)
	end
end

function AltInventory:CreateFrame()
	if frame then return frame end
	frame = AceGUI:Create("Frame")
	frame:SetTitle("Alt Inventory")
	frame:SetWidth(500)
	frame:SetHeight(600)
	frame:SetLayout("Fill")
	frame.frame:Hide()

	tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = "By Item", value = "byitem" }, { text = "By Character", value = "bychar" } })
	tabGroup:SetCallback("OnGroupSelected", buildTab)
	frame:AddChild(tabGroup)
	tabGroup:SelectTab("byitem")
	return frame
end

function AltInventory:ToggleFrame()
	if not frame then self:CreateFrame() end
	if frame.frame:IsShown() then
		frame.frame:Hide()
	else
		frame.frame:Show()
		buildTab(tabGroup, tabGroup:GetSelectedTab() or "byitem")
	end
end

print("drin")
