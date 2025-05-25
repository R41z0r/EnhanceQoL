local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")
local AceGUI = addon.AceGUI

addon.Aura.categories = addon.Aura.categories
	or {
		{ text = L["Offensive"], value = "offensive" },
		{ text = L["Defensive"], value = "defensive" },
		{ text = L["External"], value = "external" },
		{ text = L["Utility"], value = "utility" },
		{ text = L["Other"], value = "other" },
	}

local selectedCategory = addon.db["buffTrackerSelectedCategory"] or "offensive"
local newBuffCategory = addon.Aura.categories[1].value
local activeTabContainer

local activeBuffFrames = {}

local anchor = CreateFrame("Frame", "EQOLBuffTrackerAnchor", UIParent, "BackdropTemplate")
anchor:SetSize(addon.db["buffTrackerSize"], addon.db["buffTrackerSize"])
anchor:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
anchor:SetBackdropColor(0, 0, 0, 0.6)
anchor:SetMovable(true)
anchor:EnableMouse(true)
anchor:RegisterForDrag("LeftButton")
anchor.text = anchor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
anchor.text:SetPoint("CENTER", anchor, "CENTER")
anchor.text:SetText(L["DragToPosition"])

local function anchorDragStop(self)
	self:StopMovingOrSizing()
	local point, _, _, xOfs, yOfs = self:GetPoint()
	addon.db["buffTrackerPoint"] = point
	addon.db["buffTrackerX"] = xOfs
	addon.db["buffTrackerY"] = yOfs
end

anchor:SetScript("OnDragStart", anchor.StartMoving)
anchor:SetScript("OnDragStop", anchorDragStop)

local function restorePosition()
	if addon.db["buffTrackerPoint"] then
		anchor:ClearAllPoints()
		anchor:SetPoint(addon.db["buffTrackerPoint"], UIParent, addon.db["buffTrackerPoint"], addon.db["buffTrackerX"], addon.db["buffTrackerY"])
	end
end

anchor:SetScript("OnShow", restorePosition)
restorePosition()

local function updatePositions()
	local point = addon.db["buffTrackerDirection"] or "RIGHT"
	local prev = anchor
	for _, frame in pairs(activeBuffFrames) do
		if frame:IsShown() then
			frame:ClearAllPoints()
			if point == "LEFT" then
				frame:SetPoint("RIGHT", prev, "LEFT", -2, 0)
			elseif point == "UP" then
				frame:SetPoint("BOTTOM", prev, "TOP", 0, 2)
			elseif point == "DOWN" then
				frame:SetPoint("TOP", prev, "BOTTOM", 0, -2)
			else
				frame:SetPoint("LEFT", prev, "RIGHT", 2, 0)
			end
			prev = frame
		end
	end
end

local function applyLockState()
	if addon.db["buffTrackerLocked"] then
		anchor:RegisterForDrag()
		anchor:SetMovable(false)
		anchor:EnableMouse(false)
		anchor:SetScript("OnDragStart", nil)
		anchor:SetScript("OnDragStop", nil)
		anchor:SetBackdropColor(0, 0, 0, 0)
		anchor.text:Hide()
	else
		anchor:RegisterForDrag("LeftButton")
		anchor:SetMovable(true)
		anchor:EnableMouse(true)
		anchor:SetScript("OnDragStart", anchor.StartMoving)
		anchor:SetScript("OnDragStop", anchorDragStop)
		anchor:SetBackdropColor(0, 0, 0, 0.6)
		anchor.text:Show()
	end
end

local function applySize()
	local size = addon.db["buffTrackerSize"]
	anchor:SetSize(size, size)
	for _, frame in pairs(activeBuffFrames) do
		frame:SetSize(size, size)
		frame.cd:SetAllPoints(frame)
	end
	updatePositions()
end

local function createBuffFrame(icon)
	local frame = CreateFrame("Frame", nil, anchor)
	frame:SetSize(addon.db["buffTrackerSize"], addon.db["buffTrackerSize"])
	frame:SetFrameStrata("DIALOG")

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints(frame)
	tex:SetTexture(icon)
	frame.icon = tex

	local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cd:SetAllPoints(frame)
	cd:SetDrawEdge(false)
	frame.cd = cd

	return frame
end

local function playBuffSound(id)
	local sound = addon.db["buffTrackerSounds"][id]
	if not sound then return end
	if tonumber(sound) then
		PlaySound(tonumber(sound), "Master")
	else
		PlaySoundFile(sound, "Master")
	end
end

local function updateBuff(id)
	local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)

	local frame = activeBuffFrames[id]
	local wasShown = frame and frame:IsShown()
	if aura then
		local icon = aura.icon
		if not frame then
			frame = createBuffFrame(icon)
			activeBuffFrames[id] = frame
		end
		frame.icon:SetTexture(icon)
		if aura.duration and aura.duration > 0 then
			frame.cd:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
		else
			frame.cd:Clear()
		end
		if not wasShown then playBuffSound(id) end
		frame:Show()
	else
		if frame then frame:Hide() end
	end
end

local function scanBuffs()
	for id in pairs(addon.db["buffTrackerList"]) do
		if not addon.db["buffTrackerHidden"][id] then
			updateBuff(id)
		elseif activeBuffFrames[id] then
			activeBuffFrames[id]:Hide()
		end
	end
	updatePositions()
end

anchor:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_ENTERING_WORLD" or unit == "player" then scanBuffs() end
end)

anchor:RegisterUnitEvent("UNIT_AURA", "player")
anchor:RegisterEvent("PLAYER_ENTERING_WORLD")

if addon.db["buffTrackerEnabled"] then
	anchor:Show()
else
	anchor:Hide()
end

addon.Aura.buffAnchor = anchor
addon.Aura.scanBuffs = scanBuffs

local function moveTrackedBuff(id, direction)
	local list = addon.db["buffTrackerOrder"]
	local oldIndex
	for i, v in ipairs(list) do
		if v == id then
			oldIndex = i
			break
		end
	end
	if not oldIndex then
		table.insert(list, id)
		oldIndex = #list
	end

	local newIndex = math.max(1, math.min(#list, oldIndex + direction))
	table.remove(list, oldIndex)
	table.insert(list, newIndex, id)
end

local function openBuffConfig(id)
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(L["BuffTracker"])
	frame:SetWidth(400)
	frame:SetHeight(180)
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

	local label = AceGUI:Create("Label")
	label:SetText(addon.db["buffTrackerList"][id].name .. " (" .. id .. ")")
	frame:AddChild(label)

	local edit = addon.functions.createEditboxAce(L["SoundFile"], addon.db["buffTrackerSounds"][id] or "", function(self, _, text)
		if text == "" then
			addon.db["buffTrackerSounds"][id] = nil
		else
			addon.db["buffTrackerSounds"][id] = text
		end
	end)
	frame:AddChild(edit)

	local playButton = addon.functions.createButtonAce(L["Play"], 80, function() playBuffSound(id) end)
	frame:AddChild(playButton)
end

local function addBuff(id, category)
	-- get spell name and icon once
	local spellData = C_Spell.GetSpellInfo(id)
	if not spellData then return end

	addon.db["buffTrackerList"][id] = { name = spellData.name, icon = spellData.iconID, type = category or "other" }

	if not tContains(addon.db["buffTrackerOrder"], id) then table.insert(addon.db["buffTrackerOrder"], id) end

	-- make sure the buff is not hidden
	addon.db["buffTrackerHidden"][id] = nil

	scanBuffs()
end

local function removeBuff(id)
	addon.db["buffTrackerList"][id] = nil
	addon.db["buffTrackerHidden"][id] = nil
	addon.db["buffTrackerSounds"][id] = nil
	for i, v in ipairs(addon.db["buffTrackerOrder"]) do
		if v == id then
			table.remove(addon.db["buffTrackerOrder"], i)
			break
		end
	end
	if activeBuffFrames[id] then
		activeBuffFrames[id]:Hide()
		activeBuffFrames[id] = nil
	end
	scanBuffs()
end

local function buildTabContent(tabContainer, category, scroll)
	activeTabContainer = tabContainer

	local function refresh()
		tabContainer:ReleaseChildren()
		buildTabContent(tabContainer, category, scroll)
		scroll:DoLayout()
	end

	local listGroup = addon.functions.createContainer("InlineGroup", "List")
	listGroup:SetTitle(L["TrackedBuffs"])

	tabContainer:AddChild(listGroup)

	local buffData = {}
	for id, data in pairs(addon.db["buffTrackerList"]) do
		if (data.type or "other") == category then table.insert(buffData, { id = id, name = data.name, icon = data.icon }) end
	end

	local orderIndex = {}
	for idx, bid in ipairs(addon.db["buffTrackerOrder"]) do
		orderIndex[bid] = idx
	end

	table.sort(buffData, function(a, b)
		local idxA = orderIndex[a.id] or math.huge
		local idxB = orderIndex[b.id] or math.huge
		if idxA ~= idxB then return idxA < idxB end
		return a.name < b.name
	end)

	for _, info in ipairs(buffData) do
		local row = addon.functions.createContainer("SimpleGroup", "Flow")

		row:SetFullWidth(true)

		local spellIconTexture = info.icon
		if not spellIconTexture then
			local spellData = C_Spell.GetSpellInfo(info.id)
			info.icon = spellData.iconID
		end

		listGroup:AddChild(row)

		local cbSpell = addon.functions.createCheckboxAce(info.name .. " (" .. info.id .. ")", not addon.db["buffTrackerHidden"][info.id], function(self, _, val)
			addon.db["buffTrackerHidden"][info.id] = not val
			if val then
				updateBuff(info.id)
			elseif activeBuffFrames[info.id] then
				activeBuffFrames[info.id]:Hide()
				updatePositions()
			end
		end)
		if spellIconTexture then cbSpell:SetImage(spellIconTexture) end
		cbSpell:SetRelativeWidth(0.6)
		cbSpell.frame:HookScript("OnEnter", function()
			GameTooltip:SetOwner(cbSpell.frame, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(info.id)
			GameTooltip:Show()
		end)
		cbSpell.frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
		row:AddChild(cbSpell)

		local upIcon = AceGUI:Create("Icon")
		upIcon:SetLabel("")
		upIcon:SetImage("Interface\\AddOns\\" .. addonName .. "\\Textures\\up.blp")
		upIcon:SetImageSize(20, 20)
		upIcon:SetRelativeWidth(0.05)
		upIcon:SetHeight(20)
		if #buffData > 1 and info ~= buffData[1] then
			upIcon:SetCallback("OnClick", function()
				moveTrackedBuff(info.id, -1)
				refresh()
			end)
		else
			upIcon:SetDisabled(true)
		end
		row:AddChild(upIcon)

		local downIcon = AceGUI:Create("Icon")
		downIcon:SetLabel("")
		downIcon:SetImage("Interface\\AddOns\\" .. addonName .. "\\Textures\\down.blp")
		downIcon:SetImageSize(20, 20)
		downIcon:SetRelativeWidth(0.05)
		downIcon:SetHeight(20)
		if #buffData > 1 and info ~= buffData[#buffData] then
			downIcon:SetCallback("OnClick", function()
				moveTrackedBuff(info.id, 1)
				refresh()
			end)
		else
			downIcon:SetDisabled(true)
		end
		row:AddChild(downIcon)

		local gearIcon = AceGUI:Create("Icon")
		gearIcon:SetLabel("")
		gearIcon:SetImage("Interface\\Icons\\INV_Misc_Gear_01")
		gearIcon:SetImageSize(16, 16)
		gearIcon:SetRelativeWidth(0.1)
		gearIcon:SetHeight(16)
		gearIcon:SetCallback("OnClick", function() openBuffConfig(info.id) end)
		row:AddChild(gearIcon)

		local removeIcon = AceGUI:Create("Icon")
		removeIcon:SetLabel("")
		removeIcon:SetImage("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		removeIcon:SetImageSize(16, 16)
		removeIcon:SetRelativeWidth(0.1)
		removeIcon:SetHeight(16)
		removeIcon:SetCallback("OnClick", function()
			removeBuff(info.id)
			refresh()
		end)
		row:AddChild(removeIcon)
	end

	tabContainer:DoLayout()
	scroll:DoLayout()
end
local function buildTopOptions(container, scroll)
	local core = addon.functions.createContainer("InlineGroup", "Flow")
	container:AddChild(core)

	local cb = addon.functions.createCheckboxAce(L["EnableBuffTracker"], addon.db["buffTrackerEnabled"], function(self, _, val)
		addon.db["buffTrackerEnabled"] = val
		if val then
			anchor:Show()
			applyLockState()
			applySize()
		else
			anchor:Hide()
		end
	end)
	core:AddChild(cb)

	local lockCB = addon.functions.createCheckboxAce(L["buffTrackerLocked"], addon.db["buffTrackerLocked"], function(self, _, val)
		addon.db["buffTrackerLocked"] = val
		applyLockState()
	end)
	core:AddChild(lockCB)

	local sizeSlider = addon.functions.createSliderAce(L["buffTrackerIconSizeHeadline"] .. ": " .. addon.db["buffTrackerSize"], addon.db["buffTrackerSize"], 20, 100, 1, function(self, _, val)
		addon.db["buffTrackerSize"] = val
		self:SetLabel(L["buffTrackerIconSizeHeadline"] .. ": " .. val)
		applySize()
	end)
	core:AddChild(sizeSlider)

	local dirDrop = addon.functions.createDropdownAce(L["GrowthDirection"], { LEFT = "LEFT", RIGHT = "RIGHT", UP = "UP", DOWN = "DOWN" }, nil, function(self, _, val)
		addon.db["buffTrackerDirection"] = val
		updatePositions()
	end)
	dirDrop:SetValue(addon.db["buffTrackerDirection"])
	dirDrop:SetRelativeWidth(0.4)
	core:AddChild(dirDrop)

	local list, order = {}, {}
	for _, info in ipairs(addon.Aura.categories) do
		list[info.value] = info.text
		table.insert(order, info.value)
	end
	local typeDrop = addon.functions.createDropdownAce(L["BuffType"], list, order, function(self, _, val) newBuffCategory = val end)
	typeDrop:SetValue(newBuffCategory)
	typeDrop:SetRelativeWidth(0.4)
	core:AddChild(typeDrop)

	local edit = addon.functions.createEditboxAce(L["SpellID"], nil, function(self, _, text)
		local id = tonumber(text)
		if id then
			addBuff(id, newBuffCategory)
			if activeTabContainer then
				activeTabContainer:ReleaseChildren()
				buildTabContent(activeTabContainer, selectedCategory, scroll)
			end
		end
		self:SetText("")
	end)
	core:AddChild(edit)

	return core
end

function addon.Aura.functions.addBuffTrackerOptions(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	buildTopOptions(wrapper, scroll)

	local groupTabs = addon.functions.createContainer("TabGroup", "Flow")
	groupTabs:SetTabs(addon.Aura.categories)
	groupTabs:SetCallback("OnGroupSelected", function(tabContainer, event, group)
		selectedCategory = group
		addon.db["buffTrackerSelectedCategory"] = group
		tabContainer:ReleaseChildren()
		buildTabContent(tabContainer, group, scroll)
	end)
	groupTabs:SetFullWidth(true)
	wrapper:AddChild(groupTabs)

	groupTabs:SelectTab(selectedCategory)
	scroll:DoLayout()
end

applyLockState()
applySize()
