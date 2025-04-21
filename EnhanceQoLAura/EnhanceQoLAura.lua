-- Store the original Blizzard SetupMenu generator for rewrapping
local originalSetupGen
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LAura

local AceGUI = addon.AceGUI

local sUI = false

local function getPowerBarColor(type)
	-- Konvertiere 'Mana' zu 'MANA'
	local powerKey = string.upper(type)
	local color = PowerBarColor[powerKey]
	if color then return color.r, color.g, color.b end
	return 1, 1, 1
end

local frameAnchor = CreateFrame("Frame")
addon.Aura.anchorFrame = frameAnchor

local mainFrame
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
local function createHealthBar()
	mainFrame = CreateFrame("frame", "EQOLResourceFrame", UIParent)
	healthBar = CreateFrame("StatusBar", "EQOLHealthBar", mainFrame, "BackdropTemplate")
	healthBar:SetSize(addon.db["personalResourceBarHealthWidth"], addon.db["personalResourceBarHealthHeight"])
	healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	healthBar:SetPoint(
		addon.db["personalResourceBarHealth"].point or "TOPLEFT",
		UIParent,
		addon.db["personalResourceBarHealth"].point or "BOTTOMLEFT",
		addon.db["personalResourceBarHealth"].x or 0,
		addon.db["personalResourceBarHealth"].y or 0
	)
	healthBar:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	healthBar:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
	healthBar:SetBackdropBorderColor(0, 0, 0, 0)
	healthBar.text = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	healthBar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
	healthBar.text:SetPoint("CENTER", healthBar, "CENTER", 3, 0)

	healthBar:SetMovable(true)
	healthBar:EnableMouse(true)
	healthBar:RegisterForDrag("LeftButton")
	healthBar:SetScript("OnDragStart", function(self)
		if IsShiftKeyDown() then self:StartMoving() end
	end)
	healthBar:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		-- Position speichern
		local point, _, _, xOfs, yOfs = self:GetPoint()
		addon.db["personalResourceBarHealth"].point = point
		addon.db["personalResourceBarHealth"].x = xOfs
		addon.db["personalResourceBarHealth"].y = yOfs
	end)

	local absorbBar = CreateFrame("StatusBar", "EQOLAbsorbBar", healthBar)
	absorbBar:SetAllPoints(healthBar) -- gleicht Größe/Position an
	absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 1) -- über healthBar
	absorbBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	absorbBar:SetStatusBarColor(0.8, 0.8, 0.8, 0.8)
	healthBar.absorbBar = absorbBar

	if addon.db["enableResourceFrame"] then
		healthBar:Show()
	else
		healthBar:Hide()
	end
	updateHealthBar()
end

local powerbar = {}
local powerfrequent = {}
local powertypeClasses = {
	["DRUID"] = {
		[1] = { --Balance
			["MAIN"] = "LUNAR_POWER",
			["RAGE"] = true,
			["ENERGY"] = true,
			["MANA"] = true,
		},
		[2] = { --Feral
			["MAIN"] = "ENERGY",
			["COMBO_POINTS"] = true,
			["RAGE"] = true,
			["MANA"] = true,
			["LUNAR_POWER"] = true,
		},
		[3] = { --Guardian
			["MAIN"] = "RAGE",
			["ENERGY"] = true,
			["MANA"] = true,
			["LUNAR_POWER"] = true,
		},
		[4] = { --Restoration
			["MAIN"] = "MANA",
			["RAGE"] = true,
			["ENERGY"] = true,
			["LUNAR_POWER"] = true,
		},
	},
	["DEMONHUNTER"] = {
		[1] = {
			["MAIN"] = "FURY",
		},
		[2] = {
			["MAIN"] = "FURY",
		},
	},
	["DEATHKNIGHT"] = {
		[1] = { --Blood
			["MAIN"] = "RUNIC_POWER",
		},
		[2] = { --Frost
			["MAIN"] = "RUNIC_POWER",
		},
		[3] = { --Unholy
			["MAIN"] = "RUNIC_POWER",
		},
	},
	["PALADIN"] = {
		[1] = { --Holy
			["MAIN"] = "HOLY_POWER",
			["MANA"] = true,
		},
		[2] = { --Protection
			["MAIN"] = "HOLY_POWER",
			["MANA"] = true,
		},
		[3] = { --Retribution
			["MAIN"] = "HOLY_POWER",
			["MANA"] = true,
		},
	},
	["HUNTER"] = {
		[1] = { --Beastmaster
			["MAIN"] = "FOCUS",
		},
		[2] = { --Marksmanship
			["MAIN"] = "FOCUS",
		},
		[3] = { --Survival
			["MAIN"] = "FOCUS",
		},
	},
	["ROGUE"] = {

		[1] = { --Assassination
			["MAIN"] = "ENERGY",
			["COMBO_POINTS"] = true,
		},
		[2] = { --Outlaw
			["MAIN"] = "ENERGY",
			["COMBO_POINTS"] = true,
		},
		[3] = { --Subtlety
			["MAIN"] = "ENERGY",
			["COMBO_POINTS"] = true,
		},
	},
	["PRIEST"] = {

		[1] = { --Discipline
			["MAIN"] = "MANA",
		},
		[2] = { --Holy
			["MAIN"] = "MANA",
		},
		[3] = { --Shadow
			["MAIN"] = "INSANITY",
			["MANA"] = true,
		},
	},
	["SHAMAN"] = {
		[1] = { --Elemental
			["MAIN"] = "MAELSTROM",
			["MANA"] = true,
		},
		[2] = { --Enhancement
			["MANA"] = true,
		},
		[3] = { --Restoration
			["MAIN"] = "MANA",
		},
	},
	["MAGE"] = {
		[1] = { --Arcane
			["MAIN"] = "ARCANE_CHARGES",
			["MANA"] = true,
		},
		[2] = { --Fire
			["MAIN"] = "MANA",
		},
		[3] = { --Frost
			["MAIN"] = "MANA",
		},
	},
	["WARLOCK"] = {
		[1] = { --Affliction
			["MAIN"] = "SOUL_SHARDS",
			["MANA"] = true,
		},
		[2] = { --Demonology
			["MAIN"] = "SOUL_SHARDS",
			["MANA"] = true,
		},
		[3] = { --Destruction
			["MAIN"] = "SOUL_SHARDS",
			["MANA"] = true,
		},
	},
	["MONK"] = {
		[1] = { --Brewmaster
			["MAIN"] = "ENERGY",
			["MANA"] = true,
		},
		[2] = { --Mistweaver
			["MAIN"] = "MANA",
		},
		[3] = { --Windwalker
			["MAIN"] = "CHI",
			["ENERGY"] = true,
			["MANA"] = true,
		},
	},
	["EVOKER"] = {
		[1] = { --Devastation
			["MAIN"] = "ESSENCE",
			["MANA"] = true,
		},
		[2] = { --Preservation
			["MAIN"] = "MANA",
			["ESSENCE"] = true,
		},
		[3] = { --Augmentation
			["MAIN"] = "ESSENCE",
			["MANA"] = true,
		},
	},
}
local powerTypeEnums = {}
for i, v in pairs(Enum.PowerType) do
	powerTypeEnums[i:upper()] = v
end
-- Alle möglichen Ressourcen für Druiden
-- Alle möglichen Ressourcen für alle Klassen
local classPowerTypes = {
	"RAGE",
	"ESSENCE",
	"FOCUS",
	"ENERGY",
	"FURY",
	"COMBO_POINTS",
	"RUNIC_POWER",
	"SOUL_SHARDS",
	"LUNAR_POWER",
	"HOLY_POWER",
	"MAELSTROM",
	"CHI",
	"INSANITY",
	"ARCANE_CHARGES",
	"MANA",
}
local function updatePowerBar(type)
	if powerbar[type] and powerbar[type]:IsVisible() then
		local pType = powerTypeEnums[type:gsub("_", "")]

		local maxPower = UnitPowerMax("player", pType)
		local curPower = UnitPower("player", pType)

		local percentStr
		if type == "MANA" then
			local percent = (curPower / maxPower) * 100
			percentStr = percent
			percentStr = string.format("%.0f", percent)
		else
			percentStr = curPower .. " / " .. maxPower
		end
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

	local bar = CreateFrame("StatusBar", "EQOL" .. type .. "Bar", mainFrame, "BackdropTemplate")
	bar:SetSize(addon.db["personalResourceBarManaWidth"], addon.db["personalResourceBarManaHeight"])
	bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	if anchor then
		if sUI and anchor.specIcon then
			bar:SetPoint("LEFT", anchor.specIcon, "RIGHT", 0, 0)
		else
			bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
		end
	else
		bar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -40)
	end
	bar:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	bar:SetBackdropColor(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 50% Transparenz
	bar:SetBackdropBorderColor(0, 0, 0, 0)
	bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
	bar.text:SetPoint("CENTER", bar, "CENTER", 3, 0)
	bar:SetStatusBarColor(getPowerBarColor(type))

	powerbar[type] = bar
	bar:Show()
	updatePowerBar(type)
end

local function createSpecIcon(anchor)
	if not sUI then return end
	local specID = GetSpecialization()
	if not specID or not anchor then return end
	local _, _, _, iconPath = GetSpecializationInfo(specID)

	if anchor.specIcon then anchor.specIcon:Hide() end
	-- neues Icon anlegen
	local specIcon = anchor:CreateTexture(nil, "OVERLAY")
	specIcon:SetSize(72, 72) -- bei Bedarf anpassen
	specIcon:SetTexture("Interface\\AddOns\\EnhanceQoLAura\\Textures\\Classes\\" .. addon.variables.unitClass .. "_" .. specID .. ".tga" or iconPath)

	anchor.specIcon = specIcon
	specIcon:SetPoint("LEFT", anchor, "RIGHT", 0, 0)
end

local eventsToRegister = {
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_POWER_UPDATE",
	"UNIT_POWER_FREQUENT",
	"UNIT_DISPLAYPOWER",
	"UNIT_MAXPOWER",
}

local function setPowerbars()
	local _, powerToken = UnitPowerType("player")
	powerfrequent = {}
	local mainPowerBar
	local lastBar
	if
		powertypeClasses[addon.variables.unitClass]
		and powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec]
		and powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec]["MAIN"]
	then
		createPowerBar(powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec]["MAIN"], EQOLHealthBar)
		mainPowerBar = powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec]["MAIN"]
		lastBar = mainPowerBar
		if powerbar[mainPowerBar] then powerbar[mainPowerBar]:Show() end
	end

	for _, pType in ipairs(classPowerTypes) do
		if powerbar[pType] then powerbar[pType]:Hide() end
		if
			mainPowerBar == pType
			or (
				powertypeClasses[addon.variables.unitClass]
				and powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec]
				and powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec][pType]
			)
		then
			if addon.variables.unitClass == "DRUID" then
				if pType == mainPowerBar and powerbar[pType] then powerbar[pType]:Show() end
				if pType ~= mainPowerBar and pType == "MANA" then
					createPowerBar(pType, powerbar[lastBar] or EQOLHealthBar)
					lastBar = pType
					if powerbar[pType] then powerbar[pType]:Show() end
				elseif powerToken ~= mainPowerBar then
					if powerToken == pType then
						createPowerBar(pType, powerbar[lastBar] or EQOLHealthBar)
						lastBar = pType
						if powerbar[pType] then powerbar[pType]:Show() end
					end
				end
			else
				powerfrequent[pType] = true
				if mainPowerBar ~= pType then
					createPowerBar(pType, powerbar[lastBar] or EQOLHealthBar)
					lastBar = pType
				end
				if powerbar[pType] then powerbar[pType]:Show() end
			end
		end
	end
end

local firstStart = true
-- Funktion zur Verarbeitung der Events
local function eventHandler(self, event, unit, arg1, arg2, ...)
	-- Nur für bestimmte Einheiten filtern
	-- if not unit or (not string.match(unit, "^nameplate") and not string.match(unit, "^boss")) then return end
	if firstStart and event == "PLAYER_ENTERING_WORLD" then
		firstStart = false
		C_Timer.After(1, function()
			createHealthBar()
			createSpecIcon(EQOLHealthBar)
			setPowerbars()
			frameAnchor:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end)
	end

	if (event == "UNIT_DISPLAYPOWER") and unit == "player" then
		setPowerbars()
	elseif event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
		C_Timer.After(0.2, function()
			setPowerbars()
			createSpecIcon(EQOLHealthBar)
		end)
	elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
		updateHealthBar()
	elseif event == "UNIT_POWER_UPDATE" and powerbar[arg1] and not powerfrequent[arg1] then
		updatePowerBar(arg1)
	elseif event == "UNIT_POWER_FREQUENT" and powerbar[arg1] and powerfrequent[arg1] then
		updatePowerBar(arg1)
	elseif event == "UNIT_MAXPOWER" and powerbar[arg1] then
		updatePowerBar(arg1)
	end
end

-- Events beim Frame registrieren
for _, event in ipairs(eventsToRegister) do
	frameAnchor:RegisterUnitEvent(event, "player")
end

frameAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
frameAnchor:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

-- Event-Handler setzen
frameAnchor:SetScript("OnEvent", eventHandler)
frameAnchor:Hide()

-- Das funktioniert für das Hiden und Shown des Party Frames
-- local last_solo
-- local noSolo = false
-- function manage_raid_frame()
-- 	if noSolo then return end
-- 	local solo = 1
-- 	if IsInGroup() or IsInRaid() then solo = 0 end

-- 	if solo == 0 and last_solo == 0 then return end

-- 	CompactPartyFrame:SetShown(solo)
-- 	last_solo = solo
-- end

-- hooksecurefunc(CompactPartyFrame, "UpdateVisibility", manage_raid_frame)

-- function addon.functions.testy()
-- 	noSolo = not noSolo
-- 	if noSolo then
-- 		if not IsInGroup() and not IsInRaid() and CompactPartyFrame:IsShown() then
-- 		CompactPartyFrame:Hide()
-- 		end
-- 	else
-- 		CompactPartyFrame:Show()
-- 	end
-- end

local function addResourceFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = "Enable Resource frame",
			var = "enableResourceFrame",
			func = function(self, _, value)
				addon.db["enableResourceFrame"] = value
				if mainFrame then
					if value then
						mainFrame:Show()
					else
						mainFrame:Hide()
					end
				end
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local uFunc = function(self, _, value) addon.db[cbData.var] = value end
		if cbData.func then uFunc = cbData.func end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], uFunc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["enableResourceFrame"] then
		local data = {
			{
				text = "Healthbar Width",
				var = "personalResourceBarHealthWidth",
				func = function(self, _, value)
					addon.db["personalResourceBarHealthWidth"] = value
					healthBar:SetSize(addon.db["personalResourceBarHealthWidth"], addon.db["personalResourceBarHealthHeight"])
				end,
				min = 1,
				max = 2000,
			},
			{
				text = "Healthbar Height",
				var = "personalResourceBarHealthHeight",
				func = function(self, _, value)
					addon.db["personalResourceBarHealthHeight"] = value
					healthBar:SetSize(addon.db["personalResourceBarHealthWidth"], addon.db["personalResourceBarHealthHeight"])
				end,
				min = 1,
				max = 2000,
			},
			{
				text = "Manabar Width",
				var = "personalResourceBarManaWidth",
				func = function(self, _, value)
					addon.db["personalResourceBarManaWidth"] = value
					for i, v in pairs(powerbar) do
						powerbar[i]:SetSize(addon.db["personalResourceBarManaWidth"], addon.db["personalResourceBarManaHeight"])
					end
				end,
				min = 1,
				max = 2000,
			},
			{
				text = "Manabar Height",
				var = "personalResourceBarManaHeight",
				func = function(self, _, value)
					addon.db["personalResourceBarManaHeight"] = value
					for i, v in pairs(powerbar) do
						powerbar[i]:SetSize(addon.db["personalResourceBarManaWidth"], addon.db["personalResourceBarManaHeight"])
					end
				end,
				min = 1,
				max = 100,
			},
		}

		for _, cbData in ipairs(data) do
			local uFunc = function(self, _, value) addon.db[cbData.var] = value end
			if cbData.func then uFunc = cbData.func end

			local healthBarWidth = addon.functions.createSliderAce(cbData.text, addon.db[cbData.var], cbData.min, cbData.max, 1, uFunc)
			healthBarWidth:SetFullWidth(true)
			groupCore:AddChild(healthBarWidth)

			groupCore:AddChild(addon.functions.createSpacerAce())
		end
	end
end

addon.variables.statusTable.groups["aura"] = true
addon.functions.addToTree(nil, {
	value = "aura",
	text = L["Aura"],
	children = {
		{ value = "resourcebar", text = DISPLAY_PERSONAL_RESOURCE },
	},
})

function addon.Aura.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	if group == "aura\001resourcebar" then addResourceFrame(container) end
end

local LUST_CLASSES = { SHAMAN = true, MAGE = true, HUNTER = true, EVOKER = true }
local BR_CLASSES = { DRUID = true, WARLOCK = true, DEATHKNIGHT = true, PALADIN = true }

local playerIsLust = LUST_CLASSES[addon.variables.unitClass]
local playerIsBR = BR_CLASSES[addon.variables.unitClass]

local drop = LFGListFrame.SearchPanel.FilterButton

-- Reset custom menu hook on specialization change to reapply generator
local titleScore1 = LFGListFrame:CreateFontString(nil, "OVERLAY")
titleScore1:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
titleScore1:SetPoint("TOP", PVEFrameLeftInset, "TOP", 0, -10)

-- Reset wrapper so custom menu entries reapply on next open
drop:HookScript("OnHide", function()
	originalSetupGen = nil
	titleScore1:Hide()
end)

local specFrame = CreateFrame("Frame")
specFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specFrame:SetScript("OnEvent", function()
	if drop then drop.eqolWrapped = nil end
end)

hooksecurefunc(drop, "SetupMenu", function(self, blizzGen)
	if originalSetupGen and blizzGen ~= originalSetupGen then return end
	originalSetupGen = originalSetupGen or blizzGen

	local function EQOL_Generator(menu, root)
		blizzGen(menu, root)

		root:CreateTitle(addonName)
		root:CreateCheckbox("Partyfit", function() return addon.Aura.variables.partyFit end, function() addon.Aura.variables.partyFit = not addon.Aura.variables.partyFit end)
		if not playerIsLust then
			root:CreateCheckbox(
				"Bloodlust Available",
				function() return addon.Aura.variables.bloodlustAvailable end,
				function() addon.Aura.variables.bloodlustAvailable = not addon.Aura.variables.bloodlustAvailable end
			)
		end
		if not playerIsBR then
			root:CreateCheckbox(
				"Battle-Res Available",
				function() return addon.Aura.variables.battleResAvailable end,
				function() addon.Aura.variables.battleResAvailable = not addon.Aura.variables.battleResAvailable end
			)
		end
	end
	self:SetupMenu(EQOL_Generator)
end)

local function MyCustomFilter(info)
	-- Count group roles
	local groupTankCount, groupHealerCount, groupDPSCount = 0, 0, 0
	local hasLust, hasBR = false, false
	for i = 1, info.numMembers do
		local mData = C_LFGList.GetSearchResultPlayerInfo(info.searchResultID, i)
		if mData.assignedRole == "TANK" then
			groupTankCount = groupTankCount + 1
		elseif mData.assignedRole == "HEALER" then
			groupHealerCount = groupHealerCount + 1
		elseif mData.assignedRole == "DAMAGER" then
			groupDPSCount = groupDPSCount + 1
		end
		if LUST_CLASSES[mData.classFilename] then
			hasLust = true
		elseif BR_CLASSES[mData.classFilename] then
			hasBR = true
		end
	end

	if addon.Aura.variables.partyFit then
		-- Party-queue role availability check
		local needTanks, needHealers, needDPS = 0, 0, 0
		local partySize = GetNumGroupMembers()
		if partySize > 1 then
			-- Count roles in the player's party
			for i = 1, partySize do
				local unit = (i == 1) and "player" or ("party" .. (i - 1))
				local role = UnitGroupRolesAssigned(unit)
				if role == "TANK" then
					needTanks = needTanks + 1
				elseif role == "HEALER" then
					needHealers = needHealers + 1
				elseif role == "DAMAGER" then
					needDPS = needDPS + 1
				end
			end
		else
			-- solo or solo party also nur meine Rolle mit reinnehmen
			local role = addon.variables.unitRole
			if role == "TANK" then
				needTanks = needTanks + 1
			elseif role == "HEALER" then
				needHealers = needHealers + 1
			elseif role == "DAMAGER" then
				needDPS = needDPS + 1
			end
		end

		-- check for basic group requirement
		if needTanks > 1 then return false end
		if needHealers > 1 then return false end
		if needDPS > 3 then return false end

		if (1 - groupTankCount) < needTanks then return false end
		if (1 - groupHealerCount) < needHealers then return false end
		if (3 - groupDPSCount) < needDPS then return false end
		local freeSlots = 5 - info.numMembers
		if freeSlots < partySize then return false end
	end

	local partyHasLust, partyHasBR = false, false
	for i = 1, GetNumGroupMembers() do
		local unit = (i == 1) and "player" or ("party" .. (i - 1))
		local _, class = UnitClass(unit)
		if class and LUST_CLASSES[class] then partyHasLust = true end
		if class and BR_CLASSES[class] then partyHasBR = true end
	end

	local missingProviders = 0
	if addon.Aura.variables.bloodlustAvailable then
		if not hasLust and not partyHasLust then
			if groupTankCount == 0 then missingProviders = missingProviders + 1 end
			missingProviders = missingProviders + 1
		end
	end
	if addon.Aura.variables.battleResAvailable then
		if not hasBR and not partyHasBR then missingProviders = missingProviders + 1 end
	end

	local slotsAfterJoin = 5 - info.numMembers - 1
	if slotsAfterJoin < missingProviders then return false end
	return true
end

local initialAllEntries = {}
local removedResults = {}

local function ApplyEQOLFilters(isInitial)
	if not addon.Aura.variables.bloodlustAvailable and not addon.Aura.variables.battleResAvailable and not addon.Aura.variables.partyFit then
		titleScore1:Hide()
		return
	end
	local panel = LFGListFrame.SearchPanel
	if panel.categoryID ~= 2 then
		titleScore1:Hide()
		return
	end
	local dp = panel.ScrollBox and panel.ScrollBox:GetDataProvider()
	if not dp then return end

	-- On initial call, record total entries before removal
	if isInitial or not initialAllEntries then
		initialAllEntries = {}
		removedResults = {}
		for _, element in dp:EnumerateEntireRange() do
			local resultID = element.resultID or element.id
			if resultID then initialAllEntries[resultID] = true end
		end
	end

	-- ElementData beim ScrollBox‑DP sind unveränderliche Tabellen,
	-- deshalb zuerst markieren – dann in zweiter Schleife entfernen
	local toRemove = {}

	for _, element in dp:EnumerateEntireRange() do
		local resultID = element.resultID or element.id
		if resultID then
			if resultID then initialAllEntries[resultID] = true end
			local info = C_LFGList.GetSearchResultInfo(resultID)
			if info and not MyCustomFilter(info) then
				table.insert(toRemove, element)
				if not removedResults[resultID] then removedResults[resultID] = true end
			end
		end
	end
	for _, element in ipairs(toRemove) do
		dp:Remove(element) -- Eintrag streichen
		local resultID = element.resultID or element.id
		if resultID then initialAllEntries[resultID] = false end
	end
	local removedCount = 0
	for _, v in pairs(initialAllEntries) do
		if v == false then removedCount = removedCount + 1 end
	end
	titleScore1:SetFormattedText(("Filtered %d Entries"):format(removedCount))
	titleScore1:Show()
	-- ScrollBox sofort neu zeichnen
	panel.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end

local f = CreateFrame("Frame")
f:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED") -- Liste fertig
f:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED") -- Details nachgeladen
f:SetScript("OnEvent", function(_, event, ...)
	if event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
		ApplyEQOLFilters(true)
	elseif event == "LFG_LIST_SEARCH_RESULT_UPDATED" then
		-- Einzelnes Ergebnis bekam neue Infos → nachfiltern
		local resultID = ...
		local info = C_LFGList.GetSearchResultInfo(resultID)
		if info and not MyCustomFilter(info) then
			ApplyEQOLFilters(false) -- reicht, DP neu zu bauen
		end
	end
end)
