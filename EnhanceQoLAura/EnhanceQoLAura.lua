local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LAura

addon.functions.addToTree(nil, {
	value = "aura",
	text = L["Aura"],
})
addon.Aura.treeGroupData = {}

local function addTree(parentValue, newElement, noSort)
	-- Sortiere die Knoten alphabetisch nach `text`, rekursiv für alle Kinder
	local function sortChildrenRecursively(children)
		if noSort then return end
		table.sort(children, function(a, b) return string.lower(a.text) < string.lower(b.text) end)
		for _, child in ipairs(children) do
			if child.children then sortChildrenRecursively(child.children) end
		end
	end

	-- Durchlaufe die Baumstruktur, um den Parent-Knoten zu finden
	local function addToTree(tree)
		for _, node in ipairs(tree) do
			if node.value == parentValue then
				node.children = node.children or {}
				table.insert(node.children, newElement)
				sortChildrenRecursively(node.children) -- Sortiere die Kinder nach dem Hinzufügen
				return true
			elseif node.children then
				if addToTree(node.children) then return true end
			end
		end
		return false
	end

	-- Prüfen, ob parentValue `nil` ist (neuer Parent wird benötigt)
	if not parentValue then
		-- Füge einen neuen Parent-Knoten hinzu
		table.insert(addon.Aura.treeGroupData, newElement)
		sortChildrenRecursively(addon.Aura.treeGroupData) -- Sortiere die oberste Ebene
		addon.Aura.treeGroup:SetTree(addon.Aura.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
		addon.Aura.treeGroup:RefreshTree()
		return
	end

	-- Versuche, das Element als Child eines bestehenden Parent-Knotens hinzuzufügen
	if addToTree(addon.Aura.treeGroupData) then
		sortChildrenRecursively(addon.Aura.treeGroupData) -- Sortiere alle Ebenen nach Änderungen
		addon.Aura.treeGroup:SetTree(addon.Aura.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
	end
	addon.Aura.treeGroup:RefreshTree()
end

local AceGUI = addon.AceGUI

local function getCastInfo(unit)
	local name, startC, endC, icon, notInterruptible, spellID, duration, expirationTime, _, castType
	if UnitCastingInfo(unit) then
		name, _, icon, startC, endC, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
		castType = "cast"
	elseif UnitChannelInfo(unit) then
		name, _, icon, startC, endC, _, notInterruptible, spellID = UnitChannelInfo(unit)
		castType = "channel"
	end
	if startC and endC then
		duration = (endC - startC) / 1000
		expirationTime = endC / 1000
	end
	return name, duration, expirationTime, icon, notInterruptible, spellID, castType
end

-- Helper-Funktion: Spell-Liste aktualisieren
local function UpdateSpellList(spellList)
	local mapInfo = 1 -- muss noch angepasst werden
	spellList:ReleaseChildren()
	if addon.db["AuraSafedZones"][mapInfo.mapID] then
		for _, spellID in ipairs(addon.db["AuraSafedZones"][mapInfo.mapID]) do
			local spellLabel = AceGUI:Create("Label")
			spellLabel:SetText("ID: " .. spellID)
			spellList:AddChild(spellLabel)
		end
	end
end

local function getPowerBarColor(type)
	-- Konvertiere 'Mana' zu 'MANA'
	local powerKey = string.upper(type)
	local color = PowerBarColor[powerKey]
	if color then return color.r, color.g, color.b end
	return 1, 1, 1
end

local function addDrinkFrame(container)
	local mainGroup = AceGUI:Create("InlineGroup")
	mainGroup:SetTitle("Zone und AuraTracker")
	mainGroup:SetFullWidth(true)
	mainGroup:SetFullHeight(true)
	mainGroup:SetLayout("Flow")
	container:AddChild(mainGroup)

	local zoneInput = AceGUI:Create("EditBox")
	zoneInput:SetLabel("Add Zone")
	zoneInput:SetCallback("OnEnterPressed", function(widget, event, text)
		local id
		if string.lower(text) == string.lower(WORLD_MAP) then
			id = C_Map.GetBestMapForUnit("player")
		else
			id = tonumber(text)
		end

		if id then
			local mapInfo = C_Map.GetMapInfo(id)
			if mapInfo then
				addon.db["AuraSafedZones"][mapInfo.mapID] = mapInfo.name
				addTree("zone", {
					value = mapInfo.mapID,
					text = mapInfo.name,
				})
			end
		end
		widget:SetText("")
	end)
	mainGroup:AddChild(zoneInput)

	local children = {
		{ value = "any", text = "All" },
	}
	for i, v in pairs(addon.db["AuraSafedZones"]) do
		table.insert(children, { value = i, text = v })
	end

	addon.Aura.treeGroup = AceGUI:Create("TreeGroup")
	addon.Aura.treeGroupData = {}
	addTree(nil, {
		value = "zone",
		text = ZONE,
		children = children,
	})
	addon.Aura.treeGroup:SetLayout("Fill")
	addon.Aura.treeGroup:SetFullWidth(true)
	addon.Aura.treeGroup:SetFullHeight(true)
	addon.Aura.treeGroup:SetTree(addon.Aura.treeGroupData)
	mainGroup:AddChild(addon.Aura.treeGroup)
end

function addon.Aura.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	if group == "aura" then addDrinkFrame(container) end
end

local allowedSpells = {
	[438471] = { "Buster", 4, true, "Bite.ogg" }, --Voracious Bite
	[75136] = { "Buster", 4, true, "Bite.ogg" }, --Voracious Bite
}

local activeBars = {}
local frameAnchor = CreateFrame("StatusBar", nil, UIParent)
addon.Aura.anchorFrame = frameAnchor

function addon.Aura.functions.resetCooldownBars()
	-- Entferne alle aktiven Cooldown-Balken
	for i, bar in ipairs(activeBars) do
		bar:Hide()
	end
	activeBars = {}
end

function addon.Aura.functions.updateBars()
	local yOffset = 0
	local newActiveBars = {}

	table.sort(activeBars, function(a, b) return a:GetValue() < b:GetValue() end)

	for _, bar in ipairs(activeBars) do
		if bar:IsShown() then
			-- Neupositionierung des Balkens
			if addon.db["potionTrackerUpwardsBar"] then
				bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, yOffset)
			else
				bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, -yOffset)
			end
			yOffset = yOffset + bar:GetHeight() + 1 -- 5px Abstand
		end
	end
end

local healthBar
local function updateHealthBar()
	if healthBar and healthBar:IsVisible() then
		local maxHealth = UnitHealthMax("player")
		local curHealth = UnitHealth("player")
		local absorb = UnitGetTotalAbsorbs("player") or 0

		local percent = (curHealth / maxHealth) * 100
		local percentStr = percent
		-- if percent ~= 100 then percentStr = string.format("%.0f", percent) end
		percentStr = string.format("%.0f", percent)
		healthBar:SetMinMaxValues(0, maxHealth)
		healthBar:SetValue(curHealth)
		if healthBar.text then healthBar.text:SetText(percentStr) end
		if percent >= 60 then
			healthBar:SetStatusBarColor(0, 0.7, 0)
		elseif percent >= 40 then
			healthBar:SetStatusBarColor(0.7, 0.7, 0)
		else
			healthBar:SetStatusBarColor(0.7, 0, 0)
		end

		-- 2) Absorb-Bar
		local combined = absorb
		if combined > maxHealth then combined = maxHealth end
		healthBar.absorbBar:SetMinMaxValues(0, maxHealth)
		healthBar.absorbBar:SetValue(combined)
	end
end
local function createHealthBar(anchor)
	healthBar = CreateFrame("StatusBar", "EQOLHealthBar", UIParent, "BackdropTemplate")
	healthBar:SetSize(405, 20) -- Größe des Balkens
	healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	if anchor then
		healthBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
	else
		healthBar:SetPoint("TOPLEFT", frameAnchor, "BOTTOMLEFT", 0, 0)
	end
	healthBar:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	healthBar:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
	healthBar.text = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	healthBar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
	healthBar.text:SetPoint("CENTER", healthBar, "CENTER", 3, 0)

	local absorbBar = CreateFrame("StatusBar", "EQOLAbsorbBar", healthBar)
	absorbBar:SetAllPoints(healthBar) -- gleicht Größe/Position an
	absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 1) -- über healthBar
	absorbBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	absorbBar:SetStatusBarColor(0.8, 0.8, 0.8, 0.8)
	healthBar.absorbBar = absorbBar

	updateHealthBar()
end

local powerbar = {}
local powerfrequent = {
	"ENERGY",
}
local function updatePowerBar(type)
	if powerbar[type] and powerbar[type]:IsVisible() then
		local pType = type:sub(1, 1):upper() .. type:sub(2):lower()

		local maxPower = UnitPowerMax("player", Enum.PowerType[pType])
		local curPower = UnitPower("player", Enum.PowerType[pType])

		local percent = (curPower / maxPower) * 100
		local percentStr = percent
		percentStr = string.format("%.0f", percent)
		local bar = powerbar[type]
		bar:SetMinMaxValues(0, maxPower)
		bar:SetValue(curPower)
		if bar.text then bar.text:SetText(percentStr) end
	end
end
local function createPowerBar(type, anchor)
	if powerbar[type] then
		powerbar[type]:Hide()
		powerbar[type]:SetParent(nil)
		powerbar[type] = nil
	end

	local bar = CreateFrame("StatusBar", "EQOL" .. type .. "Bar", UIParent, "BackdropTemplate")
	bar:SetSize(405, 20) -- Größe des Balkens
	bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	if anchor then
		bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
	else
		bar:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, -40)
	end
	bar:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	bar:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
	bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
	bar.text:SetPoint("CENTER", bar, "CENTER", 3, 0)
	bar:SetStatusBarColor(getPowerBarColor(type))

	powerbar[type] = bar
	bar:Show()
	updatePowerBar(type)
end

local function createCooldownBar(unit)
	local name, duration, expirationTime, icon, notInterruptible, spellID, castType = getCastInfo(unit)

	if spellID then
		local frame = CreateFrame("StatusBar", nil, UIParent, "BackdropTemplate")
		frame:SetSize(frameAnchor:GetWidth() - addon.db["CooldownTrackerBarHeight"], addon.db["CooldownTrackerBarHeight"]) -- Größe des Balkens
		frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		frame:SetMinMaxValues(0, duration)
		frame:SetValue(expirationTime - GetTime())
		frame:SetPoint("TOPLEFT", frameAnchor, "TOPLEFT", 0, 0)
		frame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 3,
			insets = { left = 0, right = 0, top = 0, bottom = 0 },
		})
		if notInterruptible == false then frame:SetStatusBarColor(0, 1, 0) end
		frame:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
		local _, spellIcon
		if icon then
			spellIcon = icon
		else
			-- Zaubername und Restzeit anzeigen
			if C_Spell and C_Spell.GetSpellInfo then
				local spellInfo = C_Spell.GetSpellInfo(spellID)
				spellIcon = spellInfo.iconID
			else
				_, _, spellIcon = GetSpellInfo(spellID)
			end
		end
		frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		frame.text:SetPoint("LEFT", frame, "LEFT", 3, 0)
		frame.text:SetText(name)

		frame.time = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		frame.time:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

		-- Spell-Icon hinzufügen
		frame.icon = frame:CreateTexture(nil, "OVERLAY")
		frame.icon:SetSize(addon.db["AuraCooldownTrackerBarHeight"], addon.db["AuraCooldownTrackerBarHeight"]) -- Größe des Icons
		frame.icon:SetPoint("RIGHT", frame, "LEFT", 0, 0) -- Position am rechten Ende des Balkens
		frame.icon:SetTexture(spellIcon) -- Setzt das Icon des Spells

		-- Timer Update
		frame:SetScript("OnUpdate", function(self, elapsed)
			local currentTime = GetTime() -- Aktuelle Zeit
			local timeLeft = expirationTime - currentTime

			if timeLeft > 0 then
				self:SetValue(timeLeft)
				local timeText
				if timeLeft > 60 then
					local minutes = math.floor(timeLeft / 60)
					local seconds = math.floor(timeLeft % 60)
					timeText = string.format("%d:%02d", minutes, seconds)
				else
					timeText = string.format("%.1f", timeLeft)
				end
				self.time:SetText(timeText)
			else
				self:SetScript("OnUpdate", nil) -- Stoppe das OnUpdate
				self:Hide() -- Verstecke die Leiste
				-- addon.Aura.functions.updateBars()
			end
		end)
		return frame
	end
end

-- Main
frameAnchor:SetSize(200, 30) -- Größe des Balkens
frameAnchor:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
frameAnchor:SetStatusBarColor(0, 0.65, 0) -- Green color
frameAnchor:SetMinMaxValues(0, 10)
frameAnchor:SetValue(10)
frameAnchor:ClearAllPoints()
frameAnchor:SetMovable(true)
frameAnchor:EnableMouse(true)
frameAnchor:RegisterForDrag("LeftButton")
frameAnchor:SetPoint("CENTER", UIParent, "CENTER")
frameAnchor.text = frameAnchor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frameAnchor.text:SetPoint("CENTER", frameAnchor, "CENTER")
frameAnchor.text:SetText(L["DragToPosition"])
frameAnchor:SetScript("OnDragStart", frameAnchor.StartMoving)
frameAnchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	-- Position speichern
	local point, _, _, xOfs, yOfs = self:GetPoint()
	addon.db["AuraCooldownTrackerPoint"] = point
	addon.db["AuraCooldownTrackerX"] = xOfs
	addon.db["AuraCooldownTrackerY"] = yOfs
end)
-- Frame-Position wiederherstellen
local function RestorePosition()
	if addon.db["AuraCooldownTrackerPoint"] and addon.db["AuraCooldownTrackerX"] and addon.db["AuraCooldownTrackerY"] then
		frameAnchor:ClearAllPoints()
		frameAnchor:SetPoint(addon.db["AuraCooldownTrackerPoint"], UIParent, addon.db["AuraCooldownTrackerPoint"], addon.db["AuraCooldownTrackerX"], addon.db["AuraCooldownTrackerY"])
	end
end

-- Frame wiederherstellen und überprüfen, wenn das Addon geladen wird
frameAnchor:SetScript("OnShow", function() RestorePosition() end)
RestorePosition()

local function createBar(arg1, arg3)
	-- Finde die Position des neuen Balkens
	local yOffset = 0
	for _, bar in pairs(activeBars) do
		if bar:IsVisible() then
			yOffset = yOffset + bar:GetHeight() + 5 -- 5px Abstand
		end
	end
	-- Erstelle und positioniere den neuen Balken
	local bar = createCooldownBar(arg3, frameAnchor, select(1, UnitName(arg1)), arg1)
	if nil ~= bar then
		table.insert(activeBars, bar)
		bar:Show()
		addon.MythicPlus.functions.updateBars()
	end
end

-- Liste der Standard-Events

local function addBar(unit)
	local bar = createCooldownBar(unit)
	if nil ~= bar then
		activeBars[unit] = bar
		bar:Show()
		addon.Aura.functions.updateBars()
	end
end
local function removeBar(unit)
	if activeBars[unit] then
		activeBars[unit]:Hide()
		activeBars[unit]:SetScript("OnUpdate", nil)
		addon.Aura.functions.updateBars()
	end
end

local eventsToRegister = {
	-- "UNIT_SPELLCAST_START",
	-- "UNIT_SPELLCAST_STOP",
	-- "UNIT_SPELLCAST_CHANNEL_START",
	-- "UNIT_SPELLCAST_CHANNEL_STOP",
	-- "NAME_PLATE_UNIT_ADDED",
	-- "NAME_PLATE_UNIT_REMOVED",
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_POWER_UPDATE",
	"UNIT_POWER_FREQUENT",
	"PLAYER_ENTERING_WORLD",
}
local firstStart = true
-- Funktion zur Verarbeitung der Events
local function eventHandler(self, event, unit, arg1, arg2, ...)
	-- Nur für bestimmte Einheiten filtern
	-- if not unit or (not string.match(unit, "^nameplate") and not string.match(unit, "^boss")) then return end

	if firstStart and event == "PLAYER_ENTERING_WORLD" then
		firstStart = false
		createHealthBar(MultiBar5)
		createPowerBar("MANA", EQOLHealthBar)
		createPowerBar("ENERGY", powerbar["MANA"])
	end
	if unit ~= "player" then return end
	-- print(event, unit, arg1, arg2, ...)
	-- 	addBar(unit)
	-- elseif event == "UNIT_SPELLCAST_STOP" then
	-- 	removeBar(unit)
	-- elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
	-- 	addBar(unit)
	-- elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
	-- 	removeBar(unit)
	-- elseif event == "NAME_PLATE_UNIT_ADDED" then
	-- elseif event == "NAME_PLATE_UNIT_REMOVED" then
	-- 	removeBar(unit)
	if event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		updateHealthBar()
	elseif event == "UNIT_POWER_UPDATE" and powerbar[arg1] and not powerfrequent[arg1] then
		updatePowerBar(arg1)
	elseif event == "UNIT_POWER_FREQUENT" and powerbar[arg1] and powerfrequent[arg1] then
		updatePowerBar(arg1)
	end
end

-- Events beim Frame registrieren
for _, event in ipairs(eventsToRegister) do
	frameAnchor:RegisterEvent(event)
end

-- Event-Handler setzen
frameAnchor:SetScript("OnEvent", eventHandler)
frameAnchor:Hide()
