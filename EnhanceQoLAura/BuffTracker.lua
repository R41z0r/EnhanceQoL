local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")
local AceGUI = addon.AceGUI

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

local function updateBuff(id)
	local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)

	local frame = activeBuffFrames[id]
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

local function addBuff(id)
	-- get spell name and icon once
	local spellData = C_Spell.GetSpellInfo(id)
	if not spellData then return end

	addon.db["buffTrackerList"][id] = { name = spellData.name, icon = spellData.iconID }

	-- make sure the buff is not hidden
	addon.db["buffTrackerHidden"][id] = nil

	scanBuffs()
end

local function removeBuff(id)
	addon.db["buffTrackerList"][id] = nil
	addon.db["buffTrackerHidden"][id] = nil
	if activeBuffFrames[id] then
		activeBuffFrames[id]:Hide()
		activeBuffFrames[id] = nil
	end
	scanBuffs()
end

function addon.Aura.functions.addBuffTrackerOptions(container)
	local function refresh()
		container:ReleaseChildren()
		addon.Aura.functions.addBuffTrackerOptions(container)
	end

	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local core = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(core)

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
	core:AddChild(dirDrop)

	local edit
	edit = addon.functions.createEditboxAce(L["SpellID"], nil, function(self, _, text)
		local id = tonumber(text)
		if id then
			addBuff(id)
			refresh()
		end
		self:SetText("")
	end)
	core:AddChild(edit)

	local listGroup = addon.functions.createContainer("InlineGroup", "List")
	listGroup:SetTitle(L["TrackedBuffs"])

	wrapper:AddChild(listGroup)

	local buffData = {}
	for id, data in pairs(addon.db["buffTrackerList"]) do
		table.insert(buffData, { id = id, name = data.name, icon = data.icon })
	end
	table.sort(buffData, function(a, b) return a.name < b.name end)

	for _, info in ipairs(buffData) do
		local row = addon.functions.createContainer("SimpleGroup", "Flow")

		row:SetFullWidth(true)

		-- spell icon
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
		cbSpell:SetRelativeWidth(0.85)
		row:AddChild(cbSpell)

		local removeIcon = AceGUI:Create("Icon")
		removeIcon:SetLabel("")
		removeIcon:SetImage("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		removeIcon:SetImageSize(16, 16)
		removeIcon:SetRelativeWidth(0.15)
		removeIcon:SetHeight(16)
		removeIcon:SetCallback("OnClick", function()
			removeBuff(info.id)
			refresh()
		end)
		row:AddChild(removeIcon)
	end

	scroll:DoLayout()
end

applyLockState()
applySize()
