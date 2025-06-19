local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")
local AceGUI = addon.AceGUI

--[[
Sample consumables. IDs should be replaced with actual item and buff IDs.
--]]
local consumables = {
	weapon = {
		{ item = 191939, buff = 393438, rank = 3, name = "Sophic Devotion" },
		{ item = 191940, buff = 393438, rank = 2, name = "Sophic Writ" },
		{ item = 191941, buff = 393438, rank = 1, name = "Sophic Spell" },
	},
	food = {
		{ item = 197781, buff = 400933, rank = 3, name = "Feast of Glacial Fury" },
		{ item = 197782, buff = 382146, rank = 2, name = "Sizzling Seafood" },
		{ item = 197783, buff = 382147, rank = 1, name = "Timely Demise" },
	},
	flask = {
		{ item = 191329, buff = 371354, rank = 3, name = "Phial of Chaos" },
		{ item = 191330, buff = 371386, rank = 2, name = "Phial of Icy" },
		{ item = 191331, buff = 371172, rank = 1, name = "Phial of Versatility" },
	},
	augment = {
		{ item = 204975, buff = 393438, rank = 3, name = "Draconic Augment Rune" },
		{ item = 201325, buff = 393438, rank = 2, name = "Valdrakken Augment Rune" },
	},
}

local locations = { OUTDOOR = L["Outdoor"], DUNGEON = L["Dungeon"], RAID = L["Raid"] }
local orderLocations = { "OUTDOOR", "DUNGEON", "RAID" }

local anchor
local icons = {}
local iconOrder = { "weapon", "food", "flask", "augment" }

local function ensureAnchor()
	if anchor then return anchor end
	anchor = CreateFrame("Frame", "EQOLConsumableReminderAnchor", UIParent, "BackdropTemplate")
	anchor:SetSize(addon.db.consumableReminderSize or 36, addon.db.consumableReminderSize or 36)
	anchor:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
	anchor:SetBackdropColor(0, 0, 0, 0.6)
	anchor:SetMovable(true)
	anchor:EnableMouse(true)
	anchor:RegisterForDrag("LeftButton")
	anchor.text = anchor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	anchor.text:SetPoint("CENTER", anchor, "CENTER")
	anchor.text:SetText(L["DragToPosition"])
	anchor:SetScript("OnDragStart", anchor.StartMoving)
	anchor:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, _, xOfs, yOfs = self:GetPoint()
		addon.db.consumableReminderPoint = point
		addon.db.consumableReminderX = xOfs
		addon.db.consumableReminderY = yOfs
	end)
	anchor:SetScript("OnShow", function()
		if addon.db.consumableReminderPoint then
			anchor:ClearAllPoints()
			anchor:SetPoint(addon.db.consumableReminderPoint, UIParent, addon.db.consumableReminderPoint, addon.db.consumableReminderX or 0, addon.db.consumableReminderY or 0)
		end
	end)
	if addon.db.consumableReminderPoint then
		anchor:ClearAllPoints()
		anchor:SetPoint(addon.db.consumableReminderPoint, UIParent, addon.db.consumableReminderPoint, addon.db.consumableReminderX or 0, addon.db.consumableReminderY or 0)
	else
		anchor:SetPoint("CENTER", UIParent, "CENTER")
	end
	return anchor
end

local function ensureIcon(key)
	if icons[key] then return icons[key] end
	local frame = CreateFrame("Frame", nil, ensureAnchor())
	frame:SetSize(addon.db.consumableReminderSize or 36, addon.db.consumableReminderSize or 36)
	frame:SetFrameStrata("DIALOG")
	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints(frame)
	frame.icon = tex
	frame:Hide()
	icons[key] = frame
	return frame
end

local function updatePositions()
	local prev = ensureAnchor()
	for _, key in ipairs(iconOrder) do
		local frame = icons[key]
		if frame and frame:IsShown() then
			frame:ClearAllPoints()
			frame:SetPoint("LEFT", prev, "RIGHT", 2, 0)
			prev = frame
		end
	end
end

local function bestItem(list)
	local result
	for _, info in ipairs(list) do
		if C_Item.GetItemCount(info.item, false, false) > 0 then
			if not result or info.rank > result.rank then result = info end
		end
	end
	return result
end

local function checkLocation(cfg)
	if not cfg or not next(cfg) then return false end
	if IsInRaid() then return cfg.RAID end
	if IsInGroup() then return cfg.DUNGEON end
	return cfg.OUTDOOR
end

local function scanConsumables()
	local specID = PlayerUtil.GetCurrentSpecID()
	local cfg = addon.db.consumableReminderSetup and addon.db.consumableReminderSetup[specID]
	if not cfg or not checkLocation(cfg.locations) then
		for _, f in pairs(icons) do
			f:Hide()
		end
		ensureAnchor():Hide()
		return
	end

	local showAnchor = false
	for _, key in ipairs(iconOrder) do
		local itemID = cfg[key]
		local frame = ensureIcon(key)
		if itemID then
			local list = consumables[key]
			local chosen
			for _, info in ipairs(list) do
				if info.item == itemID then
					chosen = info
					break
				end
			end
			if chosen then
				local best = bestItem(list)
				if best and best.rank >= chosen.rank then chosen = best end
				local count = C_Item.GetItemCount(chosen.item, false, false)
				local aura = C_UnitAuras.GetPlayerAuraBySpellID(chosen.buff)
				if count > 0 and not aura then
					frame.icon:SetTexture(GetItemIcon(chosen.item))
					frame:Show()
					showAnchor = true
				else
					frame:Hide()
				end
			else
				frame:Hide()
			end
		else
			frame:Hide()
		end
	end
	updatePositions()
	if showAnchor then
		ensureAnchor():Show()
	else
		ensureAnchor():Hide()
	end
end

local events = CreateFrame("Frame")
local function onEvent(_, event)
	if event == "PLAYER_LOGIN" then ensureAnchor():Hide() end
	scanConsumables()
end

events:SetScript("OnEvent", onEvent)
for _, e in ipairs({ "PLAYER_LOGIN", "UNIT_AURA", "BAG_UPDATE_DELAYED", "ACTIVE_PLAYER_SPECIALIZATION_CHANGED", "PLAYER_ENTERING_WORLD" }) do
	events:RegisterEvent(e)
end

-- UI Options
local function buildSpecOptions(container, specID)
	container:ReleaseChildren()
	addon.db.consumableReminderSetup = addon.db.consumableReminderSetup or {}
	addon.db.consumableReminderSetup[specID] = addon.db.consumableReminderSetup[specID] or { locations = {} }
	local cfg = addon.db.consumableReminderSetup[specID]

	local function createDropdown(labelKey, key, list)
		local values, order = {}, {}
		for _, info in ipairs(list) do
			values[info.item] = info.name
			table.insert(order, info.item)
		end
		local drop = addon.functions.createDropdownAce(L[labelKey], values, order, function(self, _, value) cfg[key] = value end)
		if cfg[key] then drop:SetValue(cfg[key]) end
		container:AddChild(drop)
	end

	createDropdown("WeaponEnchant", "weapon", consumables.weapon)
	createDropdown("Food", "food", consumables.food)
	createDropdown("Flask", "flask", consumables.flask)
	createDropdown("AugmentRune", "augment", consumables.augment)

	local locDrop = addon.functions.createDropdownAce(L["Locations"], locations, orderLocations, function(self, event, item, checked) cfg.locations[item] = checked or nil end)
	locDrop:SetMultiselect(true)
	for k, v in pairs(cfg.locations) do
		if v then locDrop:SetItemValue(k, true) end
	end
	container:AddChild(locDrop)
end

function addon.Aura.functions.addConsumableReminderOptions(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local tabs = {}
	for i = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(addon.variables.unitClassID) do
		local specID, specName, _, icon = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
		table.insert(tabs, { text = string.format("|T%s:14:14|t %s", icon, specName), value = specID })
	end

	local group = addon.functions.createContainer("TabGroup", "Flow")
	group:SetTabs(tabs)
	group:SetCallback("OnGroupSelected", function(tabContainer, _, groupID) buildSpecOptions(tabContainer, groupID) end)
	wrapper:AddChild(group)
	if tabs[1] then group:SelectTab(tabs[1].value) end
end
