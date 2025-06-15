local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")
local AceGUI = addon.AceGUI

local selectedCategory = addon.db["buffTrackerSelectedCategory"] or 1

for _, cat in pairs(addon.db["buffTrackerCategories"]) do
	if not cat.trackType then cat.trackType = "BUFF" end
	if not cat.allowedSpecs then cat.allowedSpecs = {} end
	if not cat.allowedClasses then cat.allowedClasses = {} end
end

local anchors = {}
local activeBuffFrames = {}

local LSM = LibStub("LibSharedMedia-3.0")

-- build list of all specialization IDs with their names
local specNames = {}
local classNames = {}
for classID = 1, GetNumClasses() do
	local className = select(1, GetClassInfo(classID))
	local numSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(classID)
	for i = 1, numSpecs do
		local specID, specName = GetSpecializationInfoForClassID(classID, i)
		specNames[specID] = specName .. " (" .. className .. ")"
	end
	local _, classTag = GetClassInfo(classID)
	classNames[classTag] = className
end

local function categoryAllowed(cat)
	if cat.allowedClasses and next(cat.allowedClasses) then
		if not cat.allowedClasses[addon.variables.unitClass] then return false end
	end
	if cat.allowedSpecs and next(cat.allowedSpecs) then
		local specIndex = addon.variables.unitSpec
		if not specIndex then return false end
		local currentSpecID = GetSpecializationInfo(specIndex)
		if not cat.allowedSpecs[currentSpecID] then return false end
	end
	return true
end

function addon.Aura.functions.BuildSoundTable()
	local result = {}

	for name, path in pairs(LSM:HashTable("sound")) do
		result[name] = path
	end
	addon.Aura.sounds = result
end
addon.Aura.functions.BuildSoundTable()

local function getCategory(id) return addon.db["buffTrackerCategories"][id] end

local function ensureAnchor(id)
	if anchors[id] then return anchors[id] end

	local cat = getCategory(id)
	if not cat then return end

	local anchor = CreateFrame("Frame", "EQOLBuffTrackerAnchor" .. id, UIParent, "BackdropTemplate")
	anchor:SetSize(cat.size, cat.size)
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
		cat.point = point
		cat.x = xOfs
		cat.y = yOfs
	end)

	anchor:SetScript("OnShow", function()
		if cat.point then
			anchor:ClearAllPoints()
			anchor:SetPoint(cat.point, UIParent, cat.point, cat.x, cat.y)
		end
	end)
	if cat.point then
		anchor:ClearAllPoints()
		anchor:SetPoint(cat.point, UIParent, cat.point, cat.x, cat.y)
	end
	anchors[id] = anchor
	return anchor
end

local function updatePositions(id)
	local cat = getCategory(id)
	local anchor = ensureAnchor(id)
	local point = cat.direction or "RIGHT"
	local prev = anchor
	activeBuffFrames[id] = activeBuffFrames[id] or {}
	for _, frame in pairs(activeBuffFrames[id]) do
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
	for id, anchor in pairs(anchors) do
		if addon.db["buffTrackerLocked"][id] then
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
			anchor:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				local cat = getCategory(id)
				local point, _, _, xOfs, yOfs = self:GetPoint()
				cat.point = point
				cat.x = xOfs
				cat.y = yOfs
			end)
			anchor:SetBackdropColor(0, 0, 0, 0.6)
			anchor.text:Show()
		end
	end
end

local function applySize(id)
	local cat = getCategory(id)
	local anchor = ensureAnchor(id)
	local size = cat.size
	anchor:SetSize(size, size)
	activeBuffFrames[id] = activeBuffFrames[id] or {}
	for _, frame in pairs(activeBuffFrames[id]) do
		frame:SetSize(size, size)
		frame.cd:SetAllPoints(frame)
	end
	updatePositions(id)
end

local function createBuffFrame(icon, parent, size)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(size, size)
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

local function playBuffSound(catId, id)
	if addon.db["buffTrackerSoundsEnabled"] and addon.db["buffTrackerSoundsEnabled"][catId] and addon.db["buffTrackerSoundsEnabled"][catId][id] then
		local sound = addon.db["buffTrackerSounds"][catId][id]
		if not sound then return end

		local file = addon.Aura.sounds[sound]
		if file then
			PlaySoundFile(file, "Master")
			return
		end
	end
end

local function updateBuff(catId, id)
	local cat = getCategory(catId)
	local buff = cat and cat.buffs and cat.buffs[id]
	local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)
	if not aura and buff and buff.altIDs then
		for _, altId in ipairs(buff.altIDs) do
			aura = C_UnitAuras.GetPlayerAuraBySpellID(altId)
			if aura then break end
		end
	end
	if aura then
		if cat and cat.trackType == "DEBUFF" and not aura.isHarmful then
			aura = nil
		elseif cat and cat.trackType == "BUFF" and not aura.isHelpful then
			aura = nil
		end
	end

	activeBuffFrames[catId] = activeBuffFrames[catId] or {}
	local frame = activeBuffFrames[catId][id]
	local wasShown = frame and frame:IsShown()
	if buff and buff.showWhenMissing then
		if aura then
			if frame then frame:Hide() end
		else
			local icon = buff.icon
			if not frame then
				frame = createBuffFrame(icon, ensureAnchor(catId), getCategory(catId).size)
				activeBuffFrames[catId][id] = frame
			end
			frame.icon:SetTexture(icon)
			frame.cd:Clear()
			if not wasShown then playBuffSound(catId, id) end
			frame:Show()
		end
	else
		if aura then
			local icon = buff and buff.icon or aura.icon
			if not frame then
				frame = createBuffFrame(icon, ensureAnchor(catId), getCategory(catId).size)
				activeBuffFrames[catId][id] = frame
			end
			frame.icon:SetTexture(icon)
			if aura.duration and aura.duration > 0 then
				frame.cd:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
			else
				frame.cd:Clear()
			end
			if not wasShown then playBuffSound(catId, id) end
			frame:Show()
		else
			if frame then frame:Hide() end
		end
	end
end

local function scanBuffs()
	for catId, cat in pairs(addon.db["buffTrackerCategories"]) do
		if addon.db["buffTrackerEnabled"][catId] and categoryAllowed(cat) then
			for id in pairs(cat.buffs) do
				if not addon.db["buffTrackerHidden"][id] then
					updateBuff(catId, id)
				elseif activeBuffFrames[catId] and activeBuffFrames[catId][id] then
					activeBuffFrames[catId][id]:Hide()
				end
			end
			updatePositions(catId)
			if anchors[catId] then anchors[catId]:Show() end
		else
			if anchors[catId] then anchors[catId]:Hide() end
			if activeBuffFrames[catId] then
				for _, frame in pairs(activeBuffFrames[catId]) do
					frame:Hide()
				end
			end
		end
	end
end

addon.Aura.buffAnchors = anchors
addon.Aura.scanBuffs = scanBuffs

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
		for id, anchor in pairs(anchors) do
			local cat = getCategory(id)
			if addon.db["buffTrackerEnabled"][id] and categoryAllowed(cat) then
				anchor:Show()
			else
				anchor:Hide()
			end
		end
		if event == "PLAYER_LOGIN" then addon.Aura.functions.BuildSoundTable() end
	end
	scanBuffs()
end)
eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

local function moveTrackedBuff(catId, id, direction)
	if nil == addon.db["buffTrackerOrder"][catId] then addon.db["buffTrackerOrder"][catId] = {} end
	local list = addon.db["buffTrackerOrder"][catId]
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

local openedFrames = {}

local function openBuffConfig(catId, id)
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(L["BuffTracker"])
	frame:SetWidth(400)
	frame:SetHeight(180)
	frame:SetLayout("List")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		openedFrames[catId][id] = nil
	end)
	openedFrames[catId] = openedFrames[catId] or {}
	openedFrames[catId][id] = true

	local function rebuild()
		frame:ReleaseChildren()

		local buff = addon.db["buffTrackerCategories"][catId]["buffs"][id]

		local label = AceGUI:Create("Label")
		local name = buff.name
		label:SetText((name or "") .. " (" .. id .. ")")
		frame:AddChild(label)

		addon.db["buffTrackerSounds"][catId] = addon.db["buffTrackerSounds"][catId] or {}
		addon.db["buffTrackerSoundsEnabled"][catId] = addon.db["buffTrackerSoundsEnabled"][catId] or {}

               local cbElement = addon.functions.createCheckboxAce(
                       L["buffTrackerSoundsEnabled"],
                       addon.db["buffTrackerSoundsEnabled"][catId][id],
                       function(_, _, val)
                               addon.db["buffTrackerSoundsEnabled"][catId][id] = val
                       end
               )
		frame:AddChild(cbElement)

		local soundList = {}
		for sname in pairs(addon.Aura.sounds or {}) do
			soundList[sname] = sname
		end
		local list, order = addon.functions.prepareListForDropdown(soundList)
		local dropSound = addon.functions.createDropdownAce(L["SoundFile"], list, order, function(self, _, val)
			addon.db["buffTrackerSounds"][catId][id] = val
			self:SetValue(val)
			local file = addon.Aura.sounds and addon.Aura.sounds[val]
			if file then PlaySoundFile(file, "Master") end
		end)
		dropSound:SetValue(addon.db["buffTrackerSounds"][catId][id])

		frame:AddChild(dropSound)

               local cbMissing = addon.functions.createCheckboxAce(
                       L["buffTrackerShowWhenMissing"],
                       buff.showWhenMissing,
                       function(_, _, val)
                               buff.showWhenMissing = val
                               scanBuffs()
                       end
               )
		frame:AddChild(cbMissing)

		-- alternative spell ids
		buff.altIDs = buff.altIDs or {}
		for _, altId in ipairs(buff.altIDs) do
			local row = addon.functions.createContainer("SimpleGroup", "Flow")
			row:SetFullWidth(true)
			local lbl = AceGUI:Create("Label")
			lbl:SetText(L["AltSpellIDs"] .. ": " .. altId)
			lbl:SetRelativeWidth(0.7)
			row:AddChild(lbl)

			local removeIcon = AceGUI:Create("Icon")
			removeIcon:SetLabel("")
			removeIcon:SetImage("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			removeIcon:SetImageSize(16, 16)
			removeIcon:SetRelativeWidth(0.3)
			removeIcon:SetHeight(16)
			removeIcon:SetCallback("OnClick", function()
				for i, v in ipairs(buff.altIDs) do
					if v == altId then
						table.remove(buff.altIDs, i)
						break
					end
				end
				rebuild()
			end)
			row:AddChild(removeIcon)

			frame:AddChild(row)
		end

		local altEdit = addon.functions.createEditboxAce(L["AddAltSpellID"], nil, function(self, _, text)
			local alt = tonumber(text)
			if alt then
				if not tContains(buff.altIDs, alt) then table.insert(buff.altIDs, alt) end
				self:SetText("")
				rebuild()
			end
		end)
		frame:AddChild(altEdit)

		frame:AddChild(addon.functions.createSpacerAce())
		frame:DoLayout()
	end

	rebuild()
end

local function addBuff(catId, id)
	-- get spell name and icon once
	local spellData = C_Spell.GetSpellInfo(id)
	if not spellData then return end

	local cat = getCategory(catId)
	if not cat then return end

	cat.buffs[id] = { name = spellData.name, icon = spellData.iconID, altIDs = {}, showWhenMissing = false }

	if nil == addon.db["buffTrackerOrder"][catId] then addon.db["buffTrackerOrder"][catId] = {} end
	if not tContains(addon.db["buffTrackerOrder"][catId], id) then table.insert(addon.db["buffTrackerOrder"][catId], id) end

	-- make sure the buff is not hidden
	addon.db["buffTrackerHidden"][id] = nil

	scanBuffs()
end

local function removeBuff(catId, id)
	local cat = getCategory(catId)
	if not cat then return end
	cat.buffs[id] = nil
	addon.db["buffTrackerHidden"][id] = nil
	addon.db["buffTrackerSounds"][catId][id] = nil
	if nil == addon.db["buffTrackerOrder"][catId] then addon.db["buffTrackerOrder"][catId] = {} end
	for i, v in ipairs(addon.db["buffTrackerOrder"][catId]) do
		if v == id then
			table.remove(addon.db["buffTrackerOrder"][catId], i)
			break
		end
	end
	if activeBuffFrames[catId] and activeBuffFrames[catId][id] then
		activeBuffFrames[catId][id]:Hide()
		activeBuffFrames[catId][id] = nil
	end
	scanBuffs()
end

local function getCategoryTabs()
	local tabs = {}
	for id, cat in pairs(addon.db["buffTrackerCategories"]) do
		table.insert(tabs, { value = id, text = cat.name })
	end
	table.sort(tabs, function(a, b) return a.value < b.value end)
	return tabs
end

function addon.Aura.functions.buildCategoryOptions(tabContainer, catId, groupTabs, scroll)
	local cat = getCategory(catId)
	local core = addon.functions.createContainer("InlineGroup", "Flow")
	tabContainer:AddChild(core)

	local enableCB = addon.functions.createCheckboxAce(L["EnableBuffTracker"], addon.db["buffTrackerEnabled"][catId], function(self, _, val)
		addon.db["buffTrackerEnabled"][catId] = val
		for id, anchor in pairs(anchors) do
			if addon.db["buffTrackerEnabled"][id] then
				anchor:Show()
			else
				anchor:Hide()
			end
		end
	end)
	core:AddChild(enableCB)

	local lockCB = addon.functions.createCheckboxAce(L["buffTrackerLocked"], addon.db["buffTrackerLocked"][catId], function(self, _, val)
		addon.db["buffTrackerLocked"][catId] = val
		applyLockState()
	end)
	core:AddChild(lockCB)

	local nameEdit = addon.functions.createEditboxAce(L["CategoryName"], cat.name, function(self, _, text)
		if text ~= "" then cat.name = text end
		groupTabs:SetTabs(getCategoryTabs())
		groupTabs:SelectTab(catId)
	end)
	core:AddChild(nameEdit)

	local sizeSlider = addon.functions.createSliderAce(L["buffTrackerIconSizeHeadline"] .. ": " .. cat.size, cat.size, 0, 100, 1, function(self, _, val)
		cat.size = val
		self:SetLabel(L["buffTrackerIconSizeHeadline"] .. ": " .. val)
		applySize(catId)
	end)
	core:AddChild(sizeSlider)

	local dirDrop = addon.functions.createDropdownAce(L["GrowthDirection"], { LEFT = "LEFT", RIGHT = "RIGHT", UP = "UP", DOWN = "DOWN" }, nil, function(self, _, val)
		cat.direction = val
		updatePositions(catId)
	end)
	dirDrop:SetValue(cat.direction)
	dirDrop:SetRelativeWidth(0.4)
	core:AddChild(dirDrop)

	local typeDrop = addon.functions.createDropdownAce(L["TrackType"], { BUFF = L["Buff"], DEBUFF = L["Debuff"] }, nil, function(self, _, val)
		cat.trackType = val
		if activeBuffFrames[catId] then
			for _, frame in pairs(activeBuffFrames[catId]) do
				frame:Hide()
			end
		end
		scanBuffs()
	end)
	typeDrop:SetValue(cat.trackType or "BUFF")
	typeDrop:SetRelativeWidth(0.4)
	core:AddChild(typeDrop)

	local specDrop = addon.functions.createDropdownAce(L["ShowForSpec"], specNames, nil, function(self, event, key, checked)
		cat.allowedSpecs = cat.allowedSpecs or {}
		cat.allowedSpecs[key] = checked or nil
		scanBuffs()
	end)
	specDrop:SetMultiselect(true)
	for specID, val in pairs(cat.allowedSpecs or {}) do
		if val then specDrop:SetItemValue(specID, true) end
	end
	specDrop:SetRelativeWidth(0.5)
	core:AddChild(specDrop)

	local classDrop = addon.functions.createDropdownAce(L["ShowForClass"], classNames, nil, function(self, event, key, checked)
		cat.allowedClasses = cat.allowedClasses or {}
		cat.allowedClasses[key] = checked or nil
		scanBuffs()
	end)
	classDrop:SetMultiselect(true)
	for c, val in pairs(cat.allowedClasses or {}) do
		if val then classDrop:SetItemValue(c, true) end
	end
	classDrop:SetRelativeWidth(0.5)
	core:AddChild(classDrop)

	local spellEdit = addon.functions.createEditboxAce(L["SpellID"], nil, function(self, _, text)
		local id = tonumber(text)
		if id then
			addBuff(catId, id)
			tabContainer:ReleaseChildren()
			addon.Aura.functions.buildTabContent(tabContainer, catId, scroll, groupTabs)
			scroll:DoLayout()
		end
		self:SetText("")
	end)
	core:AddChild(spellEdit)

	local delBtn = addon.functions.createButtonAce(L["DeleteCategory"], 150, function()
		addon.db["buffTrackerCategories"][catId] = nil
		addon.db["buffTrackerOrder"][catId] = nil
		if anchors[catId] then
			anchors[catId]:Hide()
			anchors[catId] = nil
		end
		selectedCategory = next(addon.db["buffTrackerCategories"]) or 1
		groupTabs:SetTabs(getCategoryTabs())
		groupTabs:SelectTab(selectedCategory)
	end)
	core:AddChild(delBtn)

	return core
end

function addon.Aura.functions.buildTabContent(tabContainer, catId, scroll, groupTabs)
	local listGroup = addon.functions.createContainer("InlineGroup", "List")
	listGroup:SetTitle(L["TrackedBuffs"])

	tabContainer:AddChild(listGroup)

	local buffData = {}
	local cat = getCategory(catId)
	if cat then
		for id, data in pairs(cat.buffs) do
			table.insert(buffData, { id = id, name = data.name, icon = data.icon })
		end
	end
	if nil == addon.db["buffTrackerOrder"][catId] then addon.db["buffTrackerOrder"][catId] = {} end
	local orderIndex = {}
	for idx, bid in ipairs(addon.db["buffTrackerOrder"][catId]) do
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
				updateBuff(catId, info.id)
			elseif activeBuffFrames[catId] and activeBuffFrames[catId][info.id] then
				activeBuffFrames[catId][info.id]:Hide()
				updatePositions(catId)
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
				moveTrackedBuff(catId, info.id, -1)
				tabContainer:ReleaseChildren()
				addon.Aura.functions.buildTabContent(tabContainer, catId, scroll, groupTabs)
				scroll:DoLayout()
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
				moveTrackedBuff(catId, info.id, 1)
				tabContainer:ReleaseChildren()
				addon.Aura.functions.buildTabContent(tabContainer, catId, scroll, groupTabs)
				scroll:DoLayout()
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
		gearIcon:SetCallback("OnClick", function()
			if openedFrames[catId] and openedFrames[catId][info.id] then return end
			openBuffConfig(catId, info.id)
		end)
		row:AddChild(gearIcon)

		local removeIcon = AceGUI:Create("Icon")
		removeIcon:SetLabel("")
		removeIcon:SetImage("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		removeIcon:SetImageSize(16, 16)
		removeIcon:SetRelativeWidth(0.1)
		removeIcon:SetHeight(16)
		removeIcon:SetCallback("OnClick", function()
			removeBuff(catId, info.id)
			tabContainer:ReleaseChildren()
			addon.Aura.functions.buildTabContent(tabContainer, catId, scroll, groupTabs)
			scroll:DoLayout()
		end)
		row:AddChild(removeIcon)
	end

	addon.Aura.functions.buildCategoryOptions(tabContainer, catId, groupTabs, scroll)

	tabContainer:DoLayout()
	scroll:DoLayout()
end

function addon.Aura.functions.addBuffTrackerOptions(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupHeader = addon.functions.createContainer("SimpleGroup", "Flow")
	groupHeader:SetFullWidth(true)
	wrapper:AddChild(groupHeader)

	local groupTabs = addon.functions.createContainer("TabGroup", "Flow")
	groupTabs:SetTabs(getCategoryTabs())
	groupTabs:SetCallback("OnGroupSelected", function(tabContainer, event, group)
		selectedCategory = group
		addon.db["buffTrackerSelectedCategory"] = group
		tabContainer:ReleaseChildren()
		addon.Aura.functions.buildTabContent(tabContainer, group, scroll, groupTabs)
	end)
	groupTabs:SetRelativeWidth(0.9)
	groupHeader:AddChild(groupTabs)

	local addIcon = AceGUI:Create("Icon")
	addIcon:SetImage("Interface\\Buttons\\UI-PlusButton-Up")
	addIcon:SetImageSize(24, 24)
	addIcon:SetRelativeWidth(0.1)
	addIcon:SetCallback("OnClick", function()
		local newId = (#addon.db["buffTrackerCategories"] or 0) + 1
		addon.db["buffTrackerCategories"][newId] = {
			name = "New",
			point = "CENTER",
			x = 0,
			y = 0,
			size = 36,
			direction = "RIGHT",
			trackType = "BUFF",
			allowedSpecs = {},
			allowedClasses = {},
			buffs = {},
		}
		ensureAnchor(newId)
		groupTabs:SetTabs(getCategoryTabs())
		groupTabs:SelectTab(newId)
	end)
	groupHeader:AddChild(addIcon)

	groupTabs:SelectTab(selectedCategory)
	scroll:DoLayout()
end

for id in pairs(addon.db["buffTrackerCategories"]) do
	applySize(id)
end
applyLockState()
