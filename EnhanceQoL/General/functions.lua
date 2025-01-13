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

function addon.functions.prepareListForDropdown(tList, sortKey)
	local order = {}
	local sortedList = {}
	-- Tabelle in eine Liste umwandeln
	for key, value in pairs(tList) do
		table.insert(sortedList, { key = key, value = value })
	end
	-- Sortieren nach `value`
	if sortKey then
		table.sort(sortedList, function(a, b) return a.key < b.key end)
	else
		table.sort(sortedList, function(a, b) return a.value < b.value end)
	end
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

	local wrapper = addon.functions.createContainer("SimpleGroup", "Fill")
	wrapper:SetFullWidth(true)
	wrapper:SetFullHeight(true)
	container:AddChild(wrapper)

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	wrapper:AddChild(scroll)

	local scrollInner = addon.functions.createContainer("SimpleGroup", "Flow")
	scrollInner:SetFullWidth(true)
	scrollInner:SetFullHeight(true)
	scroll:AddChild(scrollInner)

	for _, parent in ipairs(sortedParentKeys) do
		local groupData = sortedParents[parent]

		table.sort(groupData, function(a, b)
			local textA = a.text or L[a.var]
			local textB = b.text or L[b.var]
			return textA < textB
		end)

		local group = AceGUI:Create("InlineGroup")
		group:SetLayout("List")
		group:SetFullWidth(true)
		group:SetTitle(parent)
		scrollInner:AddChild(group)

		for _, checkboxData in ipairs(groupData) do
			local widget = AceGUI:Create(checkboxData.type)

			if checkboxData.type == "CheckBox" then
				widget:SetLabel(checkboxData.text or L[checkboxData.var])
				widget:SetValue(checkboxData.value or addon.db[checkboxData.var])
				widget:SetCallback("OnValueChanged", checkboxData.callback)
				widget:SetFullWidth(true)
				group:AddChild(widget)

				if checkboxData.desc then
					local subtext = AceGUI:Create("Label")
					subtext:SetText(checkboxData.desc)
					subtext:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
					subtext:SetFullWidth(true)
					subtext:SetColor(1, 1, 1)
					group:AddChild(subtext)
				end
			elseif checkboxData.type == "Button" then
				widget:SetText(checkboxData.text)
				widget:SetWidth(checkboxData.width or 100)
				if checkboxData.callback then widget:SetCallback("OnClick", checkboxData.callback) end
				group:AddChild(widget)
			elseif checkboxData.type == "Dropdown" then
				widget:SetLabel(checkboxData.text or "")
				if checkboxData.order then
					widget:SetList(checkboxData.list, checkboxData.order)
				else
					widget:SetList(checkboxData.list)
				end
				widget:SetFullWidth(true)
				if checkboxData.callback then widget:SetCallback("OnValueChanged", checkboxData.callback) end
				group:AddChild(widget)
			end
			if checkboxData.gv then addon.elements[checkboxData.gv] = widget end
		end
	end
	scroll:DoLayout()
	scrollInner:DoLayout()
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

local knownButtons = {}

local function updateButtonInfo(itemButton, bag, slot, frameName)
	local eItem = Item:CreateFromBagAndSlot(bag, slot)
	if eItem and not eItem:IsItemEmpty() then
		eItem:ContinueOnItemLoad(function()
			local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(eItem:GetItemLink())

			if
				(itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" or (classID == 4 and subclassID == 0)) and not (classID == 4 and subclassID == 5) -- Cosmetic
			then
				if not itemButton.ItemLevelText then
					itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
					itemButton.ItemLevelText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
					itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -2)

					itemButton.ItemLevelText:SetShadowOffset(2, -2)
					itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
				end
				if frameName then table.insert(knownButtons[frameName], itemButton) end
				local link = eItem:GetItemLink()
				local invSlot = select(4, GetItemInfoInstant(link))
				if nil == addon.variables.allowedEquipSlotsBagIlvl[invSlot] then return end

				local color = eItem:GetItemQualityColor()
				local itemLevelText = eItem:GetCurrentItemLevel()

				itemButton.ItemLevelText:SetFormattedText(itemLevelText)
				itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)

				itemButton.ItemLevelText:Show()
			elseif itemButton.ItemLevelText then
				itemButton.ItemLevelText:Hide()
			end
		end)
	elseif itemButton.ItemLevelText then
		itemButton.ItemLevelText:Hide()
	end
end

function addon.functions.updateBank(itemButton, bag, slot) updateButtonInfo(itemButton, bag, slot) end

function addon.functions.updateBags(frame)
	if nil == knownButtons[frame:GetName()] then
		knownButtons[frame:GetName()] = {}
	else
		for i, v in pairs(knownButtons[frame:GetName()]) do
			if v.ItemLevelText then v.ItemLevelText:Hide() end
		end
	end
	knownButtons[frame:GetName()] = {} -- clear the list again
	for _, itemButton in frame:EnumerateValidItems() do
		if addon.db["showIlvlOnBagItems"] then
			updateButtonInfo(itemButton, itemButton:GetBagID(), itemButton:GetID(), frame:GetName())
		elseif itemButton.ItemLevelText then
			itemButton.ItemLevelText:Hide()
		end
	end
end