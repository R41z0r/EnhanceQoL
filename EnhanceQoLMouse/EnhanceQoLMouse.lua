local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LMouse
local AceGUI = addon.AceGUI

local MaxActuationPoint = 1 -- Minimaler Bewegungsabstand für Trail-Elemente
local duration = 0.3 -- Lebensdauer der Trail-Elemente in Sekunden
local Density = 0.02 -- Zeitdichte für neue Elemente
local ElementCap = 28 -- Maximale Anzahl von Trail-Elementen
local PastCursorX, PastCursorY, PresentCursorX, PresentCursorY = 0, 0, 0, 0

local trailElements = {}
local activeTrailElements = {}

local trailPresets = {
	[1] = { -- LOW
		MaxActuationPoint = 1.0, -- erzeugt nur bei relativ großen Bewegungen
		duration = 0.2, -- kürzere Lebensdauer
		Density = 0.03, -- selteneres Spawning
		ElementCap = 15,
	},
	[2] = { -- MEDIUM
		MaxActuationPoint = 0.7,
		duration = 0.3,
		Density = 0.015,
		ElementCap = 30,
	},
	[3] = { -- HIGH (Sweet Spot)
		MaxActuationPoint = 0.5,
		duration = 0.4,
		Density = 0.01,
		ElementCap = 50,
	},
	[4] = { -- ULTRA
		MaxActuationPoint = 0.3, -- empfindlicher
		duration = 0.4, -- gleiche Lebensdauer wie HIGH
		Density = 0.007, -- etwas kürzerer Zeitabstand => mehr Elemente
		ElementCap = 70,
	},
	[5] = { -- ULTRA HIGH
		MaxActuationPoint = 0.2, -- sehr empfindlich
		duration = 0.4, -- ebenfalls 0.4, damit’s optisch nicht zu lange bleibt
		Density = 0.005, -- noch häufiger
		ElementCap = 90,
	},
}

local function applyPreset(presetName)
	local preset = trailPresets[presetName]
	if not preset then return end
	MaxActuationPoint = preset.MaxActuationPoint
	duration = preset.duration
	Density = preset.Density
	ElementCap = preset.ElementCap

	trailElements = {}
	activeTrailElements = {}

	for i = 1, ElementCap do
		trailElements[i] = UIParent:CreateTexture(nil)
		trailElements[i]:Hide()
	end
end

local timeAccumulator = 0

local function UpdateMouseTrail(delta)
	-- Delta = Zeit seit letztem Frame

	-- Ersten Maus-Frame sauber initialisieren
	if not PresentCursorX then
		PresentCursorX, PresentCursorY = GetCursorPosition()
		return -- nichts weiter tun, wir haben jetzt erst mal nur eine "Start-Position"
	end

	-- Zeit hochzählen
	timeAccumulator = timeAccumulator + delta

	-- Aktuelle Mausposition holen, Distanz ermitteln
	PastCursorX, PastCursorY = PresentCursorX, PresentCursorY
	PresentCursorX, PresentCursorY = GetCursorPosition()

	local dx = PresentCursorX - PastCursorX
	local dy = PresentCursorY - PastCursorY
	local actuationPoint = math.sqrt(dx * dx + dy * dy)

	-- Trails updaten (Lebensdauer verkürzen, ggf. Element zurück in Pool)
	for i = #activeTrailElements, 1, -1 do
		local element = activeTrailElements[i]
		element.duration = element.duration - delta

		if element.duration <= 0 then
			element:Hide()
			table.insert(trailElements, table.remove(activeTrailElements, i))
		else
			-- sanftes Ausblenden oder Skalieren
			local scale = element.duration / duration
			element:SetSize(30 * scale, 30 * scale)
			-- Position bleibt dieselbe (festgefroren),
			-- wir könnten aber sogar leicht "nachziehen", wenn gewünscht
		end
	end

	-- Check: genug Zeit vergangen (timeAccumulator >= Density) UND Maus weit genug bewegt?

	if timeAccumulator >= Density and actuationPoint >= MaxActuationPoint then
		timeAccumulator = 0 -- Zeit-Akku leeren

		-- Neues Trail-Element
		if #trailElements > 0 then
			local element = table.remove(trailElements)
			table.insert(activeTrailElements, element)

			element.duration = duration
			local scale = UIParent:GetEffectiveScale()
			element.x = PresentCursorX / scale
			element.y = PresentCursorY / scale

			-- Farbe (z.B. Klassenfarbe)
			local color = addon.db["mouseTrailColor"]
			if color then
				element:SetVertexColor(color.r, color.g, color.b, color.a or 1)
			else
				-- Wenn der Nutzer keine Custom-Farbe eingestellt hat, nutze deine Standardfarbe
				element:SetVertexColor(1, 1, 1, 1)
			end

			element:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\MouseTrail.tga")
			element:SetSize(35, 35)
			element:SetBlendMode("ADD")
			element:SetPoint("CENTER", UIParent, "BOTTOMLEFT", element.x, element.y)
			element:Show()
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

		imageFrame:SetScript("OnUpdate", function(self, delta)
			local x, y = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			self:ClearAllPoints()
			self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)

			if addon.db["mouseTrailEnabled"] then UpdateMouseTrail(delta) end
		end)

		local texture1 = imageFrame:CreateTexture(nil, "BACKGROUND")
		texture1:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\Mouse.tga")
		texture1:SetSize(70, 70)
		texture1:SetPoint("CENTER", imageFrame, "CENTER", 0, 0)
		local color = addon.db["mouseRingColor"]
		if color then
			texture1:SetVertexColor(color.r, color.g, color.b, color.a or 1)
		else
			-- Wenn der Nutzer keine Custom-Farbe eingestellt hat, nutze deine Standardfarbe
			texture1:SetVertexColor(1, 1, 1, 1)
		end

		local texture2 = imageFrame:CreateTexture(nil, "BACKGROUND")
		texture2:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Icons\\Dot.tga")
		texture2:SetSize(10, 10)
		texture2:SetPoint("CENTER", imageFrame, "CENTER", 0, 0)

		imageFrame:Show()
		addon.mousePointer = imageFrame
		addon.mousePointer.texture1 = texture1
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

	if addon.db["mouseRingEnabled"] then
		groupCore:AddChild(addon.functions.createSpacerAce())

		-- Direkt hinter dem DropDown:
		local colorPicker = AceGUI:Create("ColorPicker")
		colorPicker:SetLabel(L["Ring Color"])
		-- colorPicker:SetHasAlpha(true) -- Falls du Transparenz erlauben willst
		-- Alte Werte (falls gesetzt) aus dem SavedVariables laden:
		if addon.db["mouseRingColor"] then
			local c = addon.db["mouseRingColor"]
			colorPicker:SetColor(c.r, c.g, c.b, c.a or 1)
		else
			-- Falls keine Custom-Farbe gesetzt ist, könntest du z.B. Weiß nehmen
			colorPicker:SetColor(1, 1, 1, 1)
		end

		colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a)
			addon.db["mouseRingColor"] = { r = r, g = g, b = b, a = a }
			if addon.mousePointer and addon.mousePointer.texture1 then addon.mousePointer.texture1:SetVertexColor(r, g, b, a) end
		end)

		groupCore:AddChild(colorPicker)

		local groupTrail = addon.functions.createContainer("InlineGroup", "List")
		groupTrail:SetTitle(L["Trailinfo"])
		wrapper:AddChild(groupTrail)

		local cbElement = addon.functions.createCheckboxAce(L["mouseTrailEnabled"], addon.db["mouseTrailEnabled"], function(self, _, value)
			addon.db["mouseTrailEnabled"] = value
			container:ReleaseChildren()
			addGeneralFrame(container)
		end)
		groupTrail:AddChild(cbElement)

		if addon.db["mouseTrailEnabled"] then
			local list, order = addon.functions.prepareListForDropdown(
				{ [1] = VIDEO_OPTIONS_LOW, [2] = VIDEO_OPTIONS_MEDIUM, [3] = VIDEO_OPTIONS_HIGH, [4] = VIDEO_OPTIONS_ULTRA, [5] = VIDEO_OPTIONS_ULTRA_HIGH },
				true
			)

			local dropPullTimerType = addon.functions.createDropdownAce(L["mouseTrailDensity"], list, order, function(self, _, value)
				addon.db["mouseTrailDensity"] = value
				applyPreset(addon.db["mouseTrailDensity"])
			end)
			dropPullTimerType:SetValue(addon.db["mouseTrailDensity"])
			dropPullTimerType:SetFullWidth(false)
			dropPullTimerType:SetWidth(200)
			groupTrail:AddChild(dropPullTimerType)

			groupTrail:AddChild(addon.functions.createSpacerAce())

			-- Direkt hinter dem DropDown:
			local colorPicker = AceGUI:Create("ColorPicker")
			colorPicker:SetLabel(L["Trail Color"])
			colorPicker:SetHasAlpha(true) -- Falls du Transparenz erlauben willst
			-- Alte Werte (falls gesetzt) aus dem SavedVariables laden:
			if addon.db["mouseTrailColor"] then
				local c = addon.db["mouseTrailColor"]
				colorPicker:SetColor(c.r, c.g, c.b, c.a or 1)
			else
				-- Falls keine Custom-Farbe gesetzt ist, könntest du z.B. Weiß nehmen
				colorPicker:SetColor(1, 1, 1, 1)
			end

			colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) addon.db["mouseTrailColor"] = { r = r, g = g, b = b, a = a } end)

			groupTrail:AddChild(colorPicker)
		end
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
