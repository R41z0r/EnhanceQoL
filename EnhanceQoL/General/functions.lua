local addonName, addon = ...

addon.functions = {}
local AceGUI = LibStub("AceGUI-3.0")

function addon.functions.InitDBValue(key, defaultValue)
	if addon.db[key] == nil then addon.db[key] = defaultValue end
end

function addon.functions.getIDFromGUID(unitId)
	local _, _, _, _, _, npcID = strsplit("-", unitId)
	npcID = tonumber(npcID)
	return npcID
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

function addon.functions.createEditboxAce(label, text, OnEnterPressed, OnTextChanged)
	local editbox = AceGUI:Create("EditBox")

	editbox:SetLabel(label)
	if text then editbox:SetText(text) end
	if OnEnterPressed then editbox:SetCallback("OnEnterPressed", OnEnterPressed) end
	if OnTextChanged then editbox:SetCallback("OnTextChanged", OnTextChanged) end
	return editbox
end

function addon.functions.createSliderAce(text, value, min, max, step, callBack)
	local slider = AceGUI:Create("Slider")

	slider:SetLabel(text)
	slider:SetValue(value)
	slider:SetSliderValues(min, max, step)
	if callBack then slider:SetCallback("OnValueChanged", callBack) end
	slider:SetFullWidth(true)

	return slider
end

function addon.functions.createSpacerAce()
	local spacer = addon.functions.createLabelAce(" ")
	spacer:SetFullWidth(true)
	return spacer
end

function addon.functions.createLabelAce(text, color, font, fontSize)
	if nil == fontSize then fontSize = 12 end
	local label = AceGUI:Create("Label")

	label:SetText(text)
	if color then label:SetColor(color.r, color.g, color.b) end
	if font then
		label:SetFont(font, fontSize, "OUTLINE") -- Du kannst hier eine Schriftgröße und OUTLINE anpassen
	else
		label:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE") -- Standard-Schriftart von WoW
	end
	return label
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

function addon.functions.addToTree(parentValue, newElement, noSort)
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
		table.insert(addon.treeGroupData, newElement)
		sortChildrenRecursively(addon.treeGroupData) -- Sortiere die oberste Ebene
		addon.treeGroup:SetTree(addon.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
		addon.treeGroup:RefreshTree()
		return
	end

	-- Versuche, das Element als Child eines bestehenden Parent-Knotens hinzuzufügen
	if addToTree(addon.treeGroupData) then
		sortChildrenRecursively(addon.treeGroupData) -- Sortiere alle Ebenen nach Änderungen
		addon.treeGroup:SetTree(addon.treeGroupData) -- Aktualisiere die TreeGroup mit der neuen Struktur
	end
	addon.treeGroup:RefreshTree()
end

local function updateButtonInfo(itemButton, bag, slot)
	local eItem = Item:CreateFromBagAndSlot(bag, slot)
	if eItem and not eItem:IsItemEmpty() then
		eItem:ContinueOnItemLoad(function()
			if not itemButton.ItemLevelText then
				itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
				itemButton.ItemLevelText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
				itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -2)

				itemButton.ItemLevelText:SetShadowOffset(2, -2)
				itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
			end
			local link = eItem:GetItemLink()
			local invSlot = select(4, GetItemInfoInstant(link))
			if nil == addon.variables.allowedEquipSlotsBagIlvl[invSlot] then return end

			local color = eItem:GetItemQualityColor()
			local itemLevelText = eItem:GetCurrentItemLevel()

			itemButton.ItemLevelText:SetFormattedText(itemLevelText)
			itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)

			itemButton.ItemLevelText:Show()
		end)
	elseif itemButton.ItemLevelText then
		itemButton.ItemLevelText:Hide()
	end
end

function addon.functions.updateBags(frame)
	for _, itemButton in frame:EnumerateValidItems() do
		if addon.db["showIlvlOnBagItems"] then
			updateButtonInfo(itemButton, itemButton:GetBagID(), itemButton:GetID())
		elseif itemButton.ItemLevelText then
			itemButton.ItemLevelText:Hide()
		end
	end
end
