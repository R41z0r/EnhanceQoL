local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Aura.Resources = addon.Aura.Resources or {}
addon.Aura.Resources.functions = addon.Aura.Resources.functions or {}

local Resources = addon.Aura.Resources.functions

local AceGUI = addon.AceGUI

local sUI = false

local function getPowerBarColor(type)
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
		local percentStr = string.format("%.0f", percent)
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
	healthBar:SetBackdropColor(0, 0, 0, 0.8)
	healthBar:SetBackdropBorderColor(0, 0, 0, 0)
	healthBar.text = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	healthBar.text:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
	healthBar.text:SetPoint("CENTER", healthBar, "CENTER", 3, 0)

	healthBar:SetMovable(true)
	healthBar:EnableMouse(true)
	healthBar:RegisterForDrag("LeftButton")
	healthBar:SetScript("OnDragStart", function(self)
		if IsShiftKeyDown() then self:StartMoving() end
	end)
	healthBar:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, _, xOfs, yOfs = self:GetPoint()
		addon.db["personalResourceBarHealth"].point = point
		addon.db["personalResourceBarHealth"].x = xOfs
		addon.db["personalResourceBarHealth"].y = yOfs
	end)

	local absorbBar = CreateFrame("StatusBar", "EQOLAbsorbBar", healthBar)
	absorbBar:SetAllPoints(healthBar)
	absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
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
	DRUID = {
		[1] = { MAIN = "LUNAR_POWER", RAGE = true, ENERGY = true, MANA = true },
		[2] = { MAIN = "ENERGY", COMBO_POINTS = true, RAGE = true, MANA = true, LUNAR_POWER = true },
		[3] = { MAIN = "RAGE", ENERGY = true, MANA = true, LUNAR_POWER = true },
		[4] = { MAIN = "MANA", RAGE = true, ENERGY = true, LUNAR_POWER = true },
	},
	DEMONHUNTER = {
		[1] = { MAIN = "FURY" },
		[2] = { MAIN = "FURY" },
	},
	DEATHKNIGHT = {
		[1] = { MAIN = "RUNIC_POWER" },
		[2] = { MAIN = "RUNIC_POWER" },
		[3] = { MAIN = "RUNIC_POWER" },
	},
	PALADIN = {
		[1] = { MAIN = "HOLY_POWER", MANA = true },
		[2] = { MAIN = "HOLY_POWER", MANA = true },
		[3] = { MAIN = "HOLY_POWER", MANA = true },
	},
	HUNTER = {
		[1] = { MAIN = "FOCUS" },
		[2] = { MAIN = "FOCUS" },
		[3] = { MAIN = "FOCUS" },
	},
	ROGUE = {
		[1] = { MAIN = "ENERGY", COMBO_POINTS = true },
		[2] = { MAIN = "ENERGY", COMBO_POINTS = true },
		[3] = { MAIN = "ENERGY", COMBO_POINTS = true },
	},
	PRIEST = {
		[1] = { MAIN = "MANA" },
		[2] = { MAIN = "MANA" },
		[3] = { MAIN = "INSANITY", MANA = true },
	},
	SHAMAN = {
		[1] = { MAIN = "MAELSTROM", MANA = true },
		[2] = { MANA = true },
		[3] = { MAIN = "MANA" },
	},
	MAGE = {
		[1] = { MAIN = "ARCANE_CHARGES", MANA = true },
		[2] = { MAIN = "MANA" },
		[3] = { MAIN = "MANA" },
	},
	WARLOCK = {
		[1] = { MAIN = "SOUL_SHARDS", MANA = true },
		[2] = { MAIN = "SOUL_SHARDS", MANA = true },
		[3] = { MAIN = "SOUL_SHARDS", MANA = true },
	},
	MONK = {
		[1] = { MAIN = "ENERGY", MANA = true },
		[2] = { MAIN = "MANA" },
		[3] = { MAIN = "CHI", ENERGY = true, MANA = true },
	},
	EVOKER = {
		[1] = { MAIN = "ESSENCE", MANA = true },
		[2] = { MAIN = "MANA", ESSENCE = true },
		[3] = { MAIN = "ESSENCE", MANA = true },
	},
}

local powerTypeEnums = {}
for i, v in pairs(Enum.PowerType) do
	powerTypeEnums[i:upper()] = v
end

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
	bar:SetBackdropColor(0, 0, 0, 0.8)
	bar:SetBackdropBorderColor(0, 0, 0, 0)
	bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bar.text:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
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
	local specIcon = anchor:CreateTexture(nil, "OVERLAY")
	specIcon:SetSize(72, 72)
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
		and powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec].MAIN
	then
		createPowerBar(powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec].MAIN, EQOLHealthBar)
		mainPowerBar = powertypeClasses[addon.variables.unitClass][addon.variables.unitSpec].MAIN
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
				powerfrequent[pType] = true
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
local function eventHandler(self, event, unit, arg1, arg2, ...)
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

for _, event in ipairs(eventsToRegister) do
	-- frameAnchor:RegisterUnitEvent(event, "player")
end

-- frameAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
-- frameAnchor:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
-- frameAnchor:RegisterEvent("TRAIT_CONFIG_UPDATED")

frameAnchor:SetScript("OnEvent", eventHandler)
frameAnchor:Hide()

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

Resources.eventHandler = eventHandler
Resources.addResourceFrame = addResourceFrame
