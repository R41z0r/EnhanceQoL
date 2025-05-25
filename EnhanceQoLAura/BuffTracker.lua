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

-- ensure default category entries in the database
for _, info in ipairs(addon.Aura.categories) do
	local cat = info.value
	addon.db["buffTrackerCategories"][cat] = addon.db["buffTrackerCategories"][cat]
		or {
			point = addon.db["buffTrackerPoint"],
			x = addon.db["buffTrackerX"],
			y = addon.db["buffTrackerY"],
			size = addon.db["buffTrackerSize"],
			direction = addon.db["buffTrackerDirection"],
			locked = addon.db["buffTrackerLocked"],
			order = {},
		}
end

local function addCategory(name)
	if addon.db["buffTrackerCategories"][name] then return end
	addon.db["buffTrackerCategories"][name] = {
		point = "CENTER",
		x = 0,
		y = 0,
		size = addon.db["buffTrackerSize"],
		direction = "RIGHT",
		locked = false,
		order = {},
	}
	table.insert(addon.Aura.categories, { text = name, value = name })
	anchors[name] = createAnchor(name)
end

local function removeCategory(name)
	addon.db["buffTrackerCategories"][name] = nil
	for i, info in ipairs(addon.Aura.categories) do
		if info.value == name then
			table.remove(addon.Aura.categories, i)
			break
		end
	end
	if anchors[name] then
		anchors[name]:Hide()
		anchors[name] = nil
	end
	for id, data in pairs(addon.db["buffTrackerList"]) do
		if data.type == name then data.type = "other" end
	end
end

local anchors = {}

local function anchorDragStop(self)
	self:StopMovingOrSizing()
	local cfg = addon.db["buffTrackerCategories"][self.category]
	local point, _, _, xOfs, yOfs = self:GetPoint()
	cfg.point, cfg.x, cfg.y = point, xOfs, yOfs
end

local function restorePosition(cat)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local a = anchors[cat]
	if cfg.point then
		a:ClearAllPoints()
		a:SetPoint(cfg.point, UIParent, cfg.point, cfg.x, cfg.y)
	end
end

local function applyLockState(cat)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local a = anchors[cat]
	if cfg.locked then
		a:RegisterForDrag()
		a:SetMovable(false)
		a:EnableMouse(false)
		a:SetScript("OnDragStart", nil)
		a:SetScript("OnDragStop", nil)
		a:SetBackdropColor(0, 0, 0, 0)
		a.text:Hide()
	else
		a:RegisterForDrag("LeftButton")
		a:SetMovable(true)
		a:EnableMouse(true)
		a:SetScript("OnDragStart", a.StartMoving)
		a:SetScript("OnDragStop", anchorDragStop)
		a:SetBackdropColor(0, 0, 0, 0.6)
		a.text:Show()
	end
end

local function applySize(cat)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local a = anchors[cat]
	local size = cfg.size
	a:SetSize(size, size)
	if activeBuffFrames[cat] then
		for _, frame in pairs(activeBuffFrames[cat]) do
			frame:SetSize(size, size)
			frame.cd:SetAllPoints(frame)
		end
	end
	updatePositions(cat)
end

local function createAnchor(cat)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local a = CreateFrame("Frame", "EQOLBuffTrackerAnchor" .. cat, UIParent, "BackdropTemplate")
	a:SetSize(cfg.size, cfg.size)
	a:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
	a:SetBackdropColor(0, 0, 0, 0.6)
	a:SetMovable(true)
	a:EnableMouse(true)
	a:RegisterForDrag("LeftButton")
	a.text = a:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	a.text:SetPoint("CENTER", a, "CENTER")
	a.text:SetText(L["DragToPosition"])
	a.category = cat
	a:SetScript("OnDragStart", a.StartMoving)
	a:SetScript("OnDragStop", anchorDragStop)
	anchors[cat] = a
	a:SetScript("OnShow", function() restorePosition(cat) end)
	restorePosition(cat)
	applyLockState(cat)
	applySize(cat)
	return a
end

local function updatePositions(cat)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local a = anchors[cat]
	local frames = activeBuffFrames[cat] or {}
	local order = cfg.order or {}
	local point = cfg.direction or "RIGHT"
	local prev = a
	local function place(f)
		f:ClearAllPoints()
		if point == "LEFT" then
			f:SetPoint("RIGHT", prev, "LEFT", -2, 0)
		elseif point == "UP" then
			f:SetPoint("BOTTOM", prev, "TOP", 0, 2)
		elseif point == "DOWN" then
			f:SetPoint("TOP", prev, "BOTTOM", 0, -2)
		else
			f:SetPoint("LEFT", prev, "RIGHT", 2, 0)
		end
		prev = f
	end
	for _, id in ipairs(order) do
		local frame = frames[id]
		if frame and frame:IsShown() then place(frame) end
	end
	for id, frame in pairs(frames) do
		if not tContains(order, id) and frame:IsShown() then place(frame) end
	end
end

local function createBuffFrame(cat, icon)
	local cfg = addon.db["buffTrackerCategories"][cat]
	local frame = CreateFrame("Frame", nil, anchors[cat])
	frame:SetSize(cfg.size, cfg.size)
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
	local info = addon.db["buffTrackerList"][id]
	if not info then return end
	local cat = info.type or "other"
	local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)

	local frames = activeBuffFrames[cat]
	if not frames then
		frames = {}
		activeBuffFrames[cat] = frames
	end
	local frame = frames[id]
	local wasShown = frame and frame:IsShown()
	if aura then
		local icon = aura.icon
		if not frame then
			frame = createBuffFrame(cat, icon)
			frames[id] = frame
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
	for id, data in pairs(addon.db["buffTrackerList"]) do
		if not addon.db["buffTrackerHidden"][id] then
			updateBuff(id)
		else
			local cat = data.type or "other"
			if activeBuffFrames[cat] and activeBuffFrames[cat][id] then activeBuffFrames[cat][id]:Hide() end
		end
	end
	for cat in pairs(addon.db["buffTrackerCategories"]) do
		updatePositions(cat)
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, unit)
	if event == "PLAYER_ENTERING_WORLD" or unit == "player" then scanBuffs() end
end)
eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

for cat in pairs(addon.db["buffTrackerCategories"]) do
	anchors[cat] = anchors[cat] or createAnchor(cat)
	if addon.db["buffTrackerEnabled"] then
		anchors[cat]:Show()
	else
		anchors[cat]:Hide()
	end
end

addon.Aura.buffAnchors = anchors
addon.Aura.scanBuffs = scanBuffs

local function moveTrackedBuff(id, direction)
	local cat = addon.db["buffTrackerList"][id].type or "other"
	local list = addon.db["buffTrackerCategories"][cat].order
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
	updatePositions(cat)
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

	local catList, catOrder = {}, {}
	for k in pairs(addon.db["buffTrackerCategories"]) do
		table.insert(catOrder, k)
		catList[k] = k
	end
	table.sort(catOrder)
	local drop = addon.functions.createDropdownAce(L["BuffType"], catList, catOrder, function(self, _, val)
		local old = addon.db["buffTrackerList"][id].type or "other"
		if old ~= val then
			addon.db["buffTrackerList"][id].type = val
			-- remove from old order
			local oldOrder = addon.db["buffTrackerCategories"][old].order
			for i, v in ipairs(oldOrder) do
				if v == id then
					table.remove(oldOrder, i)
					break
				end
			end
			-- add to new order
			local newOrder = addon.db["buffTrackerCategories"][val].order
			if not tContains(newOrder, id) then table.insert(newOrder, id) end
			scanBuffs()
		end
	end)
	drop:SetValue(addon.db["buffTrackerList"][id].type or "other")
	frame:AddChild(drop)
end

local function addBuff(id, category)
	-- get spell name and icon once
	local spellData = C_Spell.GetSpellInfo(id)
	if not spellData then return end

	local cat = category or "other"
	addon.db["buffTrackerList"][id] = { name = spellData.name, icon = spellData.iconID, type = cat }

	local order = addon.db["buffTrackerCategories"][cat].order
	if not tContains(order, id) then table.insert(order, id) end

	-- make sure the buff is not hidden
	addon.db["buffTrackerHidden"][id] = nil

	scanBuffs()
end

local function removeBuff(id)
	addon.db["buffTrackerList"][id] = nil
	addon.db["buffTrackerHidden"][id] = nil
	addon.db["buffTrackerSounds"][id] = nil
	for _, catCfg in pairs(addon.db["buffTrackerCategories"]) do
		for i, v in ipairs(catCfg.order) do
			if v == id then
				table.remove(catCfg.order, i)
				break
			end
		end
	end
	for cat, frames in pairs(activeBuffFrames) do
		if frames[id] then
			frames[id]:Hide()
			frames[id] = nil
		end
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
	for idx, bid in ipairs(addon.db["buffTrackerCategories"][category].order) do
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
			local cat = addon.db["buffTrackerList"][info.id].type or "other"
			if val then
				updateBuff(info.id)
			elseif activeBuffFrames[cat] and activeBuffFrames[cat][info.id] then
				activeBuffFrames[cat][info.id]:Hide()
				updatePositions(cat)
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
local function buildTopOptions(container, scroll, category)
	local core = addon.functions.createContainer("InlineGroup", "Flow")
	container:AddChild(core)

	local cb = addon.functions.createCheckboxAce(L["EnableBuffTracker"], addon.db["buffTrackerEnabled"], function(self, _, val)
		addon.db["buffTrackerEnabled"] = val
		for cat, anc in pairs(anchors) do
			if val then
				anc:Show()
				applyLockState(cat)
				applySize(cat)
			else
				anc:Hide()
			end
		end
	end)
	core:AddChild(cb)

	local cfg = addon.db["buffTrackerCategories"][category]

	local lockCB = addon.functions.createCheckboxAce(L["buffTrackerLocked"], cfg.locked, function(self, _, val)
		cfg.locked = val
		applyLockState(category)
	end)
	core:AddChild(lockCB)

	local sizeSlider = addon.functions.createSliderAce(L["buffTrackerIconSizeHeadline"] .. ": " .. cfg.size, cfg.size, 20, 100, 1, function(self, _, val)
		cfg.size = val
		self:SetLabel(L["buffTrackerIconSizeHeadline"] .. ": " .. val)
		applySize(category)
	end)
	core:AddChild(sizeSlider)

	local dirDrop = addon.functions.createDropdownAce(L["GrowthDirection"], { LEFT = "LEFT", RIGHT = "RIGHT", UP = "UP", DOWN = "DOWN" }, nil, function(self, _, val)
		cfg.direction = val
		updatePositions(category)
	end)
	dirDrop:SetValue(cfg.direction)
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

	buildTopOptions(wrapper, scroll, selectedCategory)

	-- category management controls
	local addCat = addon.functions.createEditboxAce("Add Category", nil, function(self, _, text)
		if text and text ~= "" then
			addCategory(text)
			groupTabs:SetTabs(addon.Aura.categories)
			self:SetText("")
		end
	end)
	wrapper:AddChild(addCat)

	local delBtn = addon.functions.createButtonAce("Delete Category", 120, function()
		if selectedCategory and addon.db["buffTrackerCategories"][selectedCategory] then
			removeCategory(selectedCategory)
			groupTabs:SetTabs(addon.Aura.categories)
			selectedCategory = addon.Aura.categories[1].value
			addon.db["buffTrackerSelectedCategory"] = selectedCategory
			groupTabs:SelectTab(selectedCategory)
		end
	end)
	wrapper:AddChild(delBtn)

	local groupTabs = addon.functions.createContainer("TabGroup", "Flow")
	groupTabs:SetTabs(addon.Aura.categories)
	groupTabs:SetCallback("OnGroupSelected", function(tabContainer, event, group)
		selectedCategory = group
		addon.db["buffTrackerSelectedCategory"] = group
		wrapper:ReleaseChildren()
		buildTopOptions(wrapper, scroll, group)
		wrapper:AddChild(groupTabs)
		tabContainer:ReleaseChildren()
		buildTabContent(tabContainer, group, scroll)
	end)
	groupTabs:SetFullWidth(true)
	wrapper:AddChild(groupTabs)

	groupTabs:SelectTab(selectedCategory)
	scroll:DoLayout()
end

for cat in pairs(addon.db["buffTrackerCategories"]) do
	applyLockState(cat)
	applySize(cat)
end
