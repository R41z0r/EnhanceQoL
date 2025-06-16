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
	addon.db["lfgListingColorName"] = addon.db["lfgListingColor"]
	addon.db["lfgListingColorComment"] = addon.db["lfgListingColor"]
end

local function updateLFGBackground()
	if not addon.db["lfgAccessibilityEnabled"] then
		if addon.Accessibility.bgFrame then addon.Accessibility.bgFrame:Hide() end
		return
	end
	local c = addon.db["lfgBackgroundColor"] or { r = 0, g = 0, b = 0 }
	if not addon.Accessibility.bgFrame and LFGListFrame and LFGListFrame.SearchPanel then
		local f = CreateFrame("Frame", nil, LFGListFrame.SearchPanel)
		f:SetAllPoints()
		f:SetFrameLevel(LFGListFrame.SearchPanel:GetFrameLevel() - 1)
		local tex = f:CreateTexture(nil, "BACKGROUND")
		tex:SetAllPoints()
		addon.Accessibility.bgFrame = f
		addon.Accessibility.bgTexture = tex
	end
	if addon.Accessibility.bgTexture then
		addon.Accessibility.bgTexture:SetColorTexture(c.r, c.g, c.b, 1)
		addon.Accessibility.bgFrame:Show()
	end
end

local function addFontFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local group = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(group)

	local list, order = addon.functions.prepareListForDropdown(fonts, true)
	local drop = addon.functions.createDropdownAce(L["Default Font"], list, order, function(self, _, key)
		addon.db["accessibilityFont"] = key
		addon.variables.defaultFont = fonts[key]
		addon.variables.requireReload = true
		addon.functions.checkReloadFrame()
	end)
	drop:SetValue(addon.db["accessibilityFont"])
	drop:SetWidth(250)
	group:AddChild(drop)
end

local function applyListingColor(entry)
	if not addon.db["lfgAccessibilityEnabled"] or not entry then return end
	local act = addon.db["lfgListingColorActivity"]
	local name = addon.db["lfgListingColorName"]
	local comment = addon.db["lfgListingColorComment"]
	if entry.ActivityName and act then entry.ActivityName:SetTextColor(act.r, act.g, act.b) end
	if entry.Name and name then entry.Name:SetTextColor(name.r, name.g, name.b) end
	if entry.Comment and comment then entry.Comment:SetTextColor(comment.r, comment.g, comment.b) end
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
	cp2:SetLabel(L["Listing player name color"])
	local c2 = addon.db["lfgListingColorName"] or { r = 1, g = 1, b = 1 }
	cp2:SetColor(c2.r, c2.g, c2.b)
	cp2:SetCallback("OnValueChanged", function(widget, event, r, g, b) addon.db["lfgListingColorName"] = { r = r, g = g, b = b } end)
	group:AddChild(cp2)

	local cp3 = AceGUI:Create("ColorPicker")
	cp3:SetLabel(L["Listing comment color"])
	local c3 = addon.db["lfgListingColorComment"] or { r = 1, g = 1, b = 1 }
	cp3:SetColor(c3.r, c3.g, c3.b)
	cp3:SetCallback("OnValueChanged", function(widget, event, r, g, b) addon.db["lfgListingColorComment"] = { r = r, g = g, b = b } end)
	group:AddChild(cp3)

	local cpBg = AceGUI:Create("ColorPicker")
	cpBg:SetLabel(L["Listing background color"])
	local cBg = addon.db["lfgBackgroundColor"] or { r = 0, g = 0, b = 0 }
	cpBg:SetColor(cBg.r, cBg.g, cBg.b)
	cpBg:SetCallback("OnValueChanged", function(widget, event, r, g, b)
		addon.db["lfgBackgroundColor"] = { r = r, g = g, b = b }
		updateLFGBackground()
	end)
	group:AddChild(cpBg)
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
