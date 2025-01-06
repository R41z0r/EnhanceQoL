local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LMouse

local MaxActuationPoint = 1 -- Minimaler Bewegungsabstand für Trail-Elemente
local duration = 0.3 -- Lebensdauer der Trail-Elemente in Sekunden
local Density = 0.02 -- Zeitdichte für neue Elemente
local ElementCap = 28 -- Maximale Anzahl von Trail-Elementen
local PastCursorX, PastCursorY, PresentCursorX, PresentCursorY = 0, 0, 0, 0

-- Trail-Elemente erstellen
local trailElements = {}
local activeTrailElements = {}

for i = 1, ElementCap do
	trailElements[i] = UIParent:CreateTexture(nil)
	trailElements[i]:Hide()
end

local trailPresets = {
	[1] = {
		MaxActuationPoint = 1.0, -- Minimaler Bewegungsabstand für weniger Elemente
		duration = 0.2, -- Sehr kurze Lebensdauer der Elemente
		Density = 0.03, -- Niedrigere Dichte, weniger neue Elemente
		ElementCap = 15, -- Minimal erlaubte Elemente
	},
	[2] = {
		MaxActuationPoint = 0.7,
		duration = 0.3,
		Density = 0.015,
		ElementCap = 30,
	},
	[3] = {
		MaxActuationPoint = 0.5,
		duration = 0.4,
		Density = 0.01,
		ElementCap = 50,
	},
	[4] = {
		MaxActuationPoint = 0.3, -- Deine bisherigen Ultra-Werte
		duration = 0.5,
		Density = 0.006,
		ElementCap = 100,
	},
	[5] = { -- Neues Ultra High Preset
		MaxActuationPoint = 0.5, -- Sehr schnelle Reaktion auf Bewegungen
		duration = 0.4, -- Längste Lebensdauer der Elemente
		Density = 0.008, -- Höchste Dichte (fast durchgängig)
		ElementCap = 120, -- Sehr viele Elemente erlaubt
	},
}

local function applyPreset(presetName)
	local preset = trailPresets[presetName]
	if not preset then return end
	MaxActuationPoint = preset.MaxActuationPoint
	duration = preset.duration
	Density = preset.Density
	ElementCap = preset.ElementCap
end

local function UpdateMouseTrail()
	local elapsed = 0
	if not PresentCursorX then
		PresentCursorX, PresentCursorY = GetCursorPosition()
		elapsed = 0
	else
		elapsed = Density
		PastCursorX = PresentCursorX
		PastCursorY = PresentCursorY
		PresentCursorX, PresentCursorY = GetCursorPosition()
	end

	local x = PresentCursorX - PastCursorX
	local y = PresentCursorY - PastCursorY
	local ActuationPoint = math.sqrt(x * x + y * y)

	if ActuationPoint >= MaxActuationPoint and #trailElements > 0 then
		local element = table.remove(trailElements)
		table.insert(activeTrailElements, element)

		element.duration = duration
		local scale = UIParent:GetEffectiveScale()
		element.x = PresentCursorX / scale
		element.y = PresentCursorY / scale

		-- Optional: Klassenfarbe oder andere Farboptionen
		local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
		element:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)

		element:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\MouseTrail.tga")
		element:SetSize(35, 35)
		element:SetBlendMode("ADD")
		element:SetPoint("CENTER", UIParent, "BOTTOMLEFT", element.x, element.y)
		element:Show()
	end

	-- Update bestehender Elemente
	for i = #activeTrailElements, 1, -1 do
		local element = activeTrailElements[i]
		element.duration = element.duration - elapsed

		if element.duration <= 0 then
			element:Hide()
			table.insert(trailElements, table.remove(activeTrailElements, i))
		else
			local scale = element.duration / duration
			element:SetSize(30 * scale, 30 * scale)
			element:SetPoint("CENTER", UIParent, "BOTTOMLEFT", element.x, element.y)
		end
	end
end

local function createMouseRing()
	--@debug@
	if not addon.mousePointer then
		local imageFrame = CreateFrame("Frame", "ImageTooltipFrame", UIParent, "BackdropTemplate")
		imageFrame:SetSize(120, 120)
		imageFrame:SetBackdropColor(0, 0, 0, 0)
		imageFrame:SetFrameStrata("TOOLTIP")

		imageFrame:SetScript("OnUpdate", function(self)
			local x, y = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			self:ClearAllPoints()
			self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
			if addon.db["mouseTrailEnabled"] then UpdateMouseTrail() end
		end)

		local texture1 = imageFrame:CreateTexture(nil, "BACKGROUND")
		texture1:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\Mouse.tga")
		texture1:SetSize(70, 70)
		texture1:SetPoint("CENTER", imageFrame, "CENTER", 0, 0)

		local texture2 = imageFrame:CreateTexture(nil, "BACKGROUND")
		texture2:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\Dot.tga")
		texture2:SetSize(10, 10)
		texture2:SetPoint("CENTER", imageFrame, "CENTER", 0, 0)

		imageFrame:Show()
		addon.mousePointer = imageFrame
	end
	--@end-debug@
end

local function removeMouseRing()
	if addon.mousePointer then
		addon.mousePointer:SetScript("OnUpdate", nil)
		addon.mousePointer:Hide()
		addon.mousePointer = nil
	end
end

local function addGeneralFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["mouseRingEnabled"],
			var = "mouseRingEnabled",
			func = function(self, _, value)
				addon.db["mouseRingEnabled"] = value
				if value then
					createMouseRing()
				else
					removeMouseRing()
				end
			end,
		},
		{
			text = L["mouseTrailEnabled"],
			var = "mouseTrailEnabled",
			func = function(self, _, value)
				addon.db["mouseTrailEnabled"] = value
				container:ReleaseChildren()
				addGeneralFrame(container)
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func)
		groupCore:AddChild(cbElement)
	end

	if addon.db["mouseTrailEnabled"] then
		local groupTrail = addon.functions.createContainer("InlineGroup", "List")
		groupTrail:SetTitle(L["Trailinfo"])
		wrapper:AddChild(groupTrail)

		local list, order =
			addon.functions.prepareListForDropdown({ [1] = VIDEO_OPTIONS_LOW, [2] = VIDEO_OPTIONS_MEDIUM, [3] = VIDEO_OPTIONS_HIGH, [4] = VIDEO_OPTIONS_ULTRA, [5] = VIDEO_OPTIONS_ULTRA_HIGH })

		local dropPullTimerType = addon.functions.createDropdownAce(L["mouseTrailDensity"], list, order, function(self, _, value)
			addon.db["mouseTrailDensity"] = value
			applyPreset(addon.db["mouseTrailDensity"])
		end)
		dropPullTimerType:SetValue(addon.db["mouseTrailDensity"])
		dropPullTimerType:SetFullWidth(false)
		dropPullTimerType:SetWidth(200)
		groupTrail:AddChild(dropPullTimerType)
	end
end

addon.variables.statusTable.groups["mouse"] = true
addon.functions.addToTree(nil, {
	value = "mouse",
	text = MOUSE_LABEL,
	children = {
		{ value = "general", text = GENERAL },
	},
})

function addon.Mouse.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	-- Prüfen, welche Gruppe ausgewählt wurde
	if group == "mouse\001general" then addGeneralFrame(container) end
end

if addon.db["mouseRingEnabled"] then createMouseRing() end

applyPreset(addon.db["mouseTrailDensity"])
