local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Accessibility")
local AceGUI = addon.AceGUI
local LSM = LibStub("LibSharedMedia-3.0")

addon.variables.statusTable.groups["accessibility"] = true

local fonts = {
	["Friz Quadrata"] = "Fonts\\FRIZQT__.TTF",
	["Arial Narrow"] = "Fonts\\ARIALN.TTF",
	["Morpheus"] = "Fonts\\MORPHEUS.ttf",
	["Skurri"] = "Fonts\\skurri.ttf",
}
for name, path in pairs(LSM:HashTable("font")) do
	fonts[name] = path
end
addon.Accessibility.fonts = fonts

-- apply saved font
local savedFont = addon.db["accessibilityFont"]
if savedFont and fonts[savedFont] then addon.variables.defaultFont = fonts[savedFont] end

if addon.db["lfgListingColor"] and not addon.db["lfgListingColorActivity"] then
	addon.db["lfgListingColorActivity"] = addon.db["lfgListingColor"]
	addon.db["lfgListingColorCustom"] = addon.db["lfgListingColor"]
end

local function colorRegions(frame, c)
	if not frame then return end
	for i = 1, select("#", frame:GetRegions()) do
		local reg = select(i, frame:GetRegions())
		if reg and reg:IsObjectType("Texture") then reg:SetVertexColor(c.r, c.g, c.b) end
	end
end

local function updateLFGBackground()
	if not LFGListFrame or not LFGListFrame.SearchPanel then return end
	local c
	if addon.db["lfgAccessibilityEnabled"] then
		c = { r = 0, g = 0, b = 0 }
	else
		c = { r = 1, g = 1, b = 1 }
	end
	colorRegions(LFGListFrame.SearchPanel, c)
	if LFGListFrame.SearchPanel.ScrollBox then colorRegions(LFGListFrame.SearchPanel.ScrollBox, c) end
end

local function addFontFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local group = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(group)

	-- Build a list that uses the font name for both key and value so the
	-- dropdown shows the name instead of the font path
	local fontsList = {}
	for name in pairs(fonts) do
		fontsList[name] = name
	end
	local list, order = addon.functions.prepareListForDropdown(fontsList, true)
	local drop = addon.functions.createDropdownAce(L["Default Font"], list, order, function(self, _, key)
		addon.db["accessibilityFont"] = key
		addon.variables.defaultFont = fonts[key]
	end)
	drop:SetCallback("OnOpened", function()
		for _, item in drop.pullout:IterateItems() do
			item.text:SetFont(fonts[item.userdata.value], 12, "OUTLINE")
		end
	end)
	drop:SetValue(addon.db["accessibilityFont"])
	drop:SetWidth(250)
	group:AddChild(drop)
end

local function applyListingColor(entry)
	if not addon.db["lfgAccessibilityEnabled"] or not entry then return end
	local act = addon.db["lfgListingColorActivity"]
	local name = addon.db["lfgListingColorCustom"]
	if entry.ActivityName and act then entry.ActivityName:SetTextColor(act.r, act.g, act.b) end
	if entry.Name and name then entry.Name:SetTextColor(name.r, name.g, name.b) end
end

hooksecurefunc("LFGListSearchEntry_Update", applyListingColor)
if LFGListFrame and LFGListFrame.SearchPanel then LFGListFrame.SearchPanel:HookScript("OnShow", updateLFGBackground) end

local function addLFGFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local group = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(group)

	local cb = addon.functions.createCheckboxAce(L["Enable Dungeon Browser tweaks"], addon.db["lfgAccessibilityEnabled"], function(self, _, value)
		addon.db["lfgAccessibilityEnabled"] = value
		updateLFGBackground()
		container:ReleaseChildren()
		addLFGFrame(container)
	end)
	group:AddChild(cb)

	if not addon.db["lfgAccessibilityEnabled"] then return end

	group:AddChild(addon.functions.createSpacerAce())

	local cp1 = AceGUI:Create("ColorPicker")
	cp1:SetLabel(L["Listing activity name color"])
	local c1 = addon.db["lfgListingColorActivity"] or { r = 1, g = 1, b = 1 }
	cp1:SetColor(c1.r, c1.g, c1.b)
	cp1:SetCallback("OnValueChanged", function(widget, event, r, g, b) addon.db["lfgListingColorActivity"] = { r = r, g = g, b = b } end)
	group:AddChild(cp1)

	local cp2 = AceGUI:Create("ColorPicker")
	cp2:SetLabel(L["Listing custom text color"])
	local c2 = addon.db["lfgListingColorCustom"] or { r = 1, g = 1, b = 1 }
	cp2:SetColor(c2.r, c2.g, c2.b)
	cp2:SetCallback("OnValueChanged", function(widget, event, r, g, b) addon.db["lfgListingColorCustom"] = { r = r, g = g, b = b } end)
	group:AddChild(cp2)
end

addon.functions.addToTree(nil, {
	value = "accessibility",
	text = L["Accessibility"],
	children = {
		{ value = "font", text = L["Font"] },
		{ value = "lfg", text = L["Dungeon Browser"] },
	},
})

function addon.Accessibility.functions.treeCallback(container, group)
	container:ReleaseChildren()
	if group == "accessibility\001font" then
		addFontFrame(container)
	elseif group == "accessibility\001lfg" then
		addLFGFrame(container)
	end
end

updateLFGBackground()
