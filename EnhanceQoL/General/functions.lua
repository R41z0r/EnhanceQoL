local addonName, addon = ...

addon.functions = {}
local AceGUI = LibStub("AceGUI-3.0")

function addon.functions.InitDBValue(key, defaultValue)
	if addon.db[key] == nil then addon.db[key] = defaultValue end
end

-- Checkboxen erstellen
function addon.functions.createCheckbox(name, parent, label, x, y)
	local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", x, y)
	checkbox:SetChecked(addon.db["" .. name])
	checkbox:SetScript("OnClick", function(self) addon.db["" .. name] = self:GetChecked() end)
	getglobal(checkbox:GetName() .. "Text"):SetText(label)
	table.insert(addon.checkboxes, checkbox)
	return checkbox
end

function addon.functions.createCheckboxNoDB(name, parent, label, x, y)
	local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", x, y)
	checkbox:SetScript("OnClick", function(self) addon.db["" .. name] = self:GetChecked() end)
	getglobal(checkbox:GetName() .. "Text"):SetText(label)
	return checkbox
end

function addon.functions.createSlider(id, parent, label, x, y, initial, min, max, addText)
	local slider = CreateFrame("Slider", id, parent, "OptionsSliderTemplate")
	slider:SetOrientation("HORIZONTAL")
	slider:SetSize(200, 20)
	slider:SetMinMaxValues(min, max)
	if nil == initial then initial = 50 end
	slider:SetValue(initial)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:ClearAllPoints()
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -x, y)

	_G[slider:GetName() .. "Low"]:SetText("" .. min .. addText)
	_G[slider:GetName() .. "High"]:SetText(max .. addText)
	_G[slider:GetName() .. "Text"]:SetText(label .. ": " .. initial .. addText)

	slider:SetScript("OnValueChanged", function(self, value)
		value = math.floor(value)
		_G[self:GetName() .. "Text"]:SetText(label .. ": " .. value .. addText)
		addon.db[id] = value
	end)
	return slider
end

function addon.functions.createHeader(parent, label, x, y)
	local header = parent:CreateFontString(nil, "OVERLAY")
	header:SetFontObject("GameFontHighlightLarge")
	header:SetPoint("TOP", parent, "TOP", x, y)
	header:SetText(label)
	return header
end

function addon.functions.createTabButton(parent, id, text)
	local tab = CreateFrame("Button", nil, parent, C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
	tab:SetID(id)
	tab:SetText(text)
	tab:SetScript("OnClick", function(self)
		PanelTemplates_SetTab(parent, self:GetID())
		parent:ShowTab(self:GetID())
	end)
	return tab
end

function addon.functions.createTabFrame(text)
	addon.variables.numOfTabs = addon.variables.numOfTabs + 1
	local tab1 = addon.functions.createTabButton(addon.frame, addon.variables.numOfTabs, text)
	tab1:SetPoint("TOPLEFT", addon.frame, "BOTTOMLEFT", 5, 7)

	PanelTemplates_SetNumTabs(addon.frame, addon.variables.numOfTabs)
	PanelTemplates_SetTab(addon.frame, 1)

	addon.frame.tabs[addon.variables.numOfTabs] = CreateFrame("Frame", nil, addon.frame, "InsetFrameTemplate")
	addon.frame.tabs[addon.variables.numOfTabs]:SetSize((addon.frame:GetWidth() - 8), (addon.frame:GetHeight() - 20))
	addon.frame.tabs[addon.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -20)

	if addon.variables.numOfTabs == 1 then
		addon.frame.tabs[addon.variables.numOfTabs]:Show()
	else
		addon.frame.tabs[addon.variables.numOfTabs]:Hide()
	end
	return addon.frame.tabs[addon.variables.numOfTabs]
end

function addon.functions.createTabFrameDynamic(frame, text)
	addon.gossip.variables.numOfTabs = addon.gossip.variables.numOfTabs + 1
	local tabWidth = 100 -- Breite eines Tabs
	local spacing = 5 -- Abstand zwischen Tabs
	local maxRowWidth = frame:GetWidth() - 10 -- Maximale Breite für Tabs in einer Reihe
	local tabsPerRow = math.floor(maxRowWidth / (tabWidth + spacing)) -- Wie viele Tabs in eine Reihe passen
	local currentRow = math.ceil(addon.gossip.variables.numOfTabs / tabsPerRow) -- Bestimmen der aktuellen Reihe
	local tabIndexInRow = addon.gossip.variables.numOfTabs % tabsPerRow -- Position in der Reihe

	if tabIndexInRow == 0 then tabIndexInRow = tabsPerRow end

	local tab1 = addon.functions.createTabButton(frame, addon.gossip.variables.numOfTabs, text)
	tab1:SetSize(tabWidth, 25)
	tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 5 + (tabIndexInRow - 1) * (tabWidth + spacing), 7 + (currentRow - 1) * (tab1:GetHeight() + spacing))

	PanelTemplates_SetNumTabs(frame, addon.gossip.variables.numOfTabs)
	PanelTemplates_SetTab(frame, 1)

	frame.tabs[addon.gossip.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	frame.tabs[addon.gossip.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
	frame.tabs[addon.gossip.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -20)

	if addon.gossip.variables.numOfTabs == 1 then
		frame.tabs[addon.gossip.variables.numOfTabs]:Show()
	else
		frame.tabs[addon.gossip.variables.numOfTabs]:Hide()
	end

	return frame.tabs[addon.gossip.variables.numOfTabs]
end

function addon.functions.createTabFrameMain(text, frame)
	addon.general.variables.numOfTabs = addon.general.variables.numOfTabs + 1
	local tab1 = addon.functions.createTabButton(frame, addon.general.variables.numOfTabs, text)
	tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	PanelTemplates_SetNumTabs(frame, addon.general.variables.numOfTabs)
	PanelTemplates_SetTab(frame, 1)

	frame.tabs[addon.general.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	frame.tabs[addon.general.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
	frame.tabs[addon.general.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -2 - (tab1:GetHeight()))

	if addon.general.variables.numOfTabs == 1 then
		frame.tabs[addon.general.variables.numOfTabs]:Show()
	else
		frame.tabs[addon.general.variables.numOfTabs]:Hide()
	end
	return frame.tabs[addon.general.variables.numOfTabs]
end

function addon.functions.getHeightOffset(element)
	local _, _, _, _, headerY = element:GetPoint()
	return headerY - element:GetHeight()
end

function addon.functions.createLabel(frame, text, x, y, anchor, point)
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint(point, frame, anchor, x, y)
	label:SetText(text)
	return label
end

function addon.functions.createDropdown(id, frame, items, width, text, x, y, initial)
	-- Erstelle ein Label
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
	label:SetText(text)

	-- Erstelle ein Dropdown-Menü
	local dropdown = CreateFrame("Frame", "MyDropdown", frame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -10) -- Position relativ zum Label

	-- Initialisiere das Dropdown-Menü
	UIDropDownMenu_SetWidth(dropdown, width)
	UIDropDownMenu_SetText(dropdown, addon.L["Select an option"])
	dropdown:SetFrameStrata("DIALOG")

	-- Funktion zum Erstellen der Menüeinträge
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
		addon.db[id] = self.value
	end

	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for i = 1, #items do
			info.text = items[i].text
			info.value = items[i].value
			info.func = OnClick
			info.arg1 = items[i].value
			info.checked = nil
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_SetSelectedID(dropdown, initial)
	UIDropDownMenu_SetText(dropdown, items[initial].text)
	-- Initialisiere das Dropdown-Menü
	UIDropDownMenu_Initialize(dropdown, Initialize)
	return label, dropdown
end

function addon.functions.createDropdownNoInitial(id, frame, items, width, text, x, y)
	table.sort(items, function(a, b) return a.text < b.text end)

	-- Erstelle ein Label
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
	label:SetText(text)

	-- Erstelle ein Dropdown-Menü
	local dropdown = CreateFrame("Frame", "MyDropdown", frame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -10) -- Position relativ zum Label

	-- Initialisiere das Dropdown-Menü
	UIDropDownMenu_SetWidth(dropdown, 180)
	dropdown:SetFrameStrata("DIALOG")

	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for i, item in ipairs(items) do
			info.text = item.text
			info.value = item.value
			info.checked = nil
			info.func = function(self) UIDropDownMenu_SetSelectedID(dropdown, i) end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	UIDropDownMenu_SetText(dropdown, "")
	-- Initialisiere das Dropdown-Menü
	UIDropDownMenu_Initialize(dropdown, Initialize)
	return dropdown
end

function addon.functions.getIDFromGUID(unitId)
	local _, _, _, _, _, npcID = strsplit("-", unitId)
	npcID = tonumber(npcID)
	return npcID
end

function addon.functions.addDropdownItem(dropdown, items, newItem)
	-- Füge das neue Item zur Items-Tabelle hinzu
	table.insert(items, newItem)

	table.sort(items, function(a, b) return a.text < b.text end)
	-- Neuinitialisiere das Dropdown-Menü
	local function Initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for i, item in ipairs(items) do
			info.text = item.text
			info.value = item.value
			info.checked = nil
			info.func = function(self) UIDropDownMenu_SetSelectedID(dropdown, i) end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	UIDropDownMenu_Initialize(dropdown, Initialize)
end

function addon.functions.createButton(parent, x, y, width, height, text, script)
	local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
	button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	button:SetSize(width, height)
	button:SetText(text)
	button:SetFrameStrata("DIALOG")
	button:SetNormalFontObject("GameFontNormalLarge")
	button:SetHighlightFontObject("GameFontHighlightLarge")
	button:SetScript("OnClick", script)
	return button
end

function addon.functions.toggleRaidTools(value, self)
	if value == false and (UnitInParty("player") or UnitInRaid("player")) then
		self:Show()
	elseif UnitInParty("player") then
		self:Hide()
	end
end

function addon.functions.formatMoney(copper)
	local gold = math.floor(copper / 10000)
	local silver = math.floor((copper % 10000) / 100)
	local bronze = copper % 100

	local formatted = ""

	if gold > 0 then formatted = string.format("%d|cffffd700g|r ", gold) end

	if silver > 0 or gold > 0 then formatted = formatted .. string.format("%d|cffc7c7cfs|r ", silver) end

	formatted = formatted .. string.format("%d|cffeda55fc|r", bronze)

	return formatted
end

function addon.functions.toggleLandingPageButton(title, state)
	local button = _G["ExpansionLandingPageMinimapButton"] -- Hole den Button
	if not button then return end

	-- Prüfen, ob der Button zu der gewünschten ID passt
	if button.title == title then
		if state then
			button:Hide()
		else
			button:Show()
		end
	end
end

function addon.functions.prepareListForDropdown(tList)
	local order = {}
	local sortedList = {}
	-- Tabelle in eine Liste umwandeln
	for key, value in pairs(tList) do
		table.insert(sortedList, { key = key, value = value })
	end
	-- Sortieren nach `value`
	table.sort(sortedList, function(a, b) return a.value < b.value end)
	-- Zurückkonvertieren für SetList
	local dropdownList = {}
	for _, item in ipairs(sortedList) do
		dropdownList[item.key] = item.value
		table.insert(order, item.key)
	end
	return dropdownList, order
end

function addon.functions.createContainer(type, layout)
	local element = AceGUI:Create(type)
	element:SetFullWidth(true)
	if layout then element:SetLayout(layout) end
	return element
end

function addon.functions.createCheckboxAce(text, value, callBack)
	local checkbox = AceGUI:Create("CheckBox")

	checkbox:SetLabel(text)
	checkbox:SetValue(value)
	checkbox:SetCallback("OnValueChanged", callBack)
	checkbox:SetFullWidth(true)

	return checkbox
end

function addon.functions.createButtonAce(text, width, callBack)
	local button = AceGUI:Create("Button")
	button:SetText(text)
	button:SetWidth(width or 100)
	if callBack then button:SetCallback("OnClick", callBack) end
	return button
end

function addon.functions.createDropdownAce(text, list, order, callBack)
	local dropdown = AceGUI:Create("Dropdown")
	dropdown:SetLabel(text or "")

	if order then
		dropdown:SetList(list, order)
	else
		dropdown:SetList(list)
	end
	dropdown:SetFullWidth(true)
	if callBack then dropdown:SetCallback("OnValueChanged", callBack) end
	return dropdown
end

function addon.functions.createWrapperData(data, container, L)
	local sortedParents = {}
	for _, checkbox in ipairs(data) do
		if not sortedParents[checkbox.parent] then sortedParents[checkbox.parent] = {} end
		table.insert(sortedParents[checkbox.parent], checkbox)
	end

	local sortedParentKeys = {}
	for parent in pairs(sortedParents) do
		table.insert(sortedParentKeys, parent)
	end
	table.sort(sortedParentKeys)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	-- Füge Inline-Gruppen und Checkboxen hinzu
	for _, parent in ipairs(sortedParentKeys) do
		local groupData = sortedParents[parent]

		-- Sortiere die Elemente innerhalb der Gruppe basierend auf `L[var]`
		table.sort(groupData, function(a, b)
			local textA = a.var
			local textB = b.var
			if a.text then
				textA = a.text
			else
				textA = L[a.var]
			end
			if b.text then
				textB = b.text
			else
				textB = L[b.var]
			end
			return textA < textB
		end)

		-- Erstelle die Inline-Gruppe
		local group = addon.functions.createContainer("InlineGroup", "List")
		group:SetTitle(parent) -- Titel basierend auf `parent`
		wrapper:AddChild(group)

		-- Füge Checkboxen in die Inline-Gruppe ein
		for _, checkboxData in ipairs(groupData) do
			local checkbox = AceGUI:Create(checkboxData.type)

			if checkboxData.type == "CheckBox" then
				if checkboxData.text then
					checkbox:SetLabel(checkboxData.text)
				else
					checkbox:SetLabel(L[checkboxData.var])
				end
				if checkboxData.value then
					checkbox:SetValue(checkboxData.value)
				else
					checkbox:SetValue(addon.db[checkboxData.var])
				end
				checkbox:SetCallback("OnValueChanged", checkboxData.callback)
				checkbox:SetFullWidth(true)
				group:AddChild(checkbox)

				if checkboxData.desc then
					local subtext = AceGUI:Create("Label")
					subtext:SetText(checkboxData.desc)
					subtext:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE") -- Schriftart und Größe anpassen
					subtext:SetFullWidth(true)
					subtext:SetColor(1, 1, 1) -- Farbe (weiß in diesem Beispiel)
					group:AddChild(subtext)
				end
			elseif checkboxData.type == "Button" then
				local button = AceGUI:Create("Button")
				button:SetText(checkboxData.text)
				button:SetWidth(checkboxData.width or 100)
				if checkboxData.callback then button:SetCallback("OnClick", checkboxData.callback) end
				group:AddChild(button)
			elseif checkboxData.type == "Dropdown" then
				local dropdown = AceGUI:Create("Dropdown")
				dropdown:SetLabel(checkboxData.text or "")

				if checkboxData.order then
					dropdown:SetList(checkboxData.list, checkboxData.order)
				else
					dropdown:SetList(checkboxData.list)
				end
				dropdown:SetFullWidth(true)
				if checkboxData.callback then dropdown:SetCallback("OnValueChanged", checkboxData.callback) end
				group:AddChild(dropdown)
			end
			if checkboxData.gv then addon.elements[checkboxData.gv] = checkbox end
		end
	end
end

function addon.functions.addToTree(parentValue, newElement)
	-- Durchlaufe die Baumstruktur, um den Parent-Knoten zu finden
	local function addToTree(tree)
		for _, node in ipairs(tree) do
			if node.value == parentValue then
				node.children = node.children or {}
				table.insert(node.children, newElement)
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
		table.insert(addon.treeGroupData, newElement)
		addon.treeGroup:SetTree(addon.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
		print("Added new parent node:", newElement.value)
		return
	end

	-- Versuche, das Element als Child eines bestehenden Parent-Knotens hinzuzufügen
	if addToTree(addon.treeGroupData) then
		addon.treeGroup:SetTree(addon.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
		print("Added child to parent node:", parentValue)
	else
		print("Parent node not found:", parentValue)
	end
end
