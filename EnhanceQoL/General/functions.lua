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

function addon.functions.createCheckboxAce(text, value, callBack, description)
	local checkbox = AceGUI:Create("CheckBox")

	checkbox:SetLabel(text)
	checkbox:SetValue(value)
	checkbox:SetCallback("OnValueChanged", callBack)
	checkbox:SetFullWidth(true)
	if description then checkbox:SetDescription(string.format("|cffffd700" .. description .. "|r ")) end

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

function addon.functions.getHeightOffset(element)
	local _, _, _, _, headerY = element:GetPoint()
	return headerY - element:GetHeight()
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

local function setItemVisibility(itemButton)
	itemButton:SetAlpha(0.2)
	if itemButton.ItemLevelText then itemButton.ItemLevelText:SetAlpha(0.2) end
	if itemButton.ItemBoundType then itemButton.ItemBoundType:SetAlpha(0.2) end
end

local function updateButtonInfo(itemButton, bag, slot, frameName)
	itemButton:SetAlpha(1)
	if itemButton.ItemLevelText then itemButton.ItemLevelText:SetAlpha(1) end
	if itemButton.ItemBoundType then itemButton.ItemBoundType:SetAlpha(1) end
	local eItem = Item:CreateFromBagAndSlot(bag, slot)
	if eItem and not eItem:IsItemEmpty() then
		eItem:ContinueOnItemLoad(function()
			local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(eItem:GetItemLink())
			local setVisibility = false
			if addon.filterFrame and addon.filterFrame:IsVisible() then
				if addon.itemBagFilters["rarity"] then
					if nil == addon.itemBagFiltersQuality[eItem:GetItemQuality()] or addon.itemBagFiltersQuality[eItem:GetItemQuality()] == false then setVisibility = true end
				end
				if addon.itemBagFilters["equipment"] and (nil == itemEquipLoc or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE") then setVisibility = true end
				if
					addon.itemBagFilters["usableOnly"]
					and (
						C_Item.IsEquippableItem(eItem:GetItemLink()) == false
						or (
							(
								nil == addon.itemBagFilterTypes[addon.variables.unitClass]
								or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec]
								or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec][classID]
								or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec][classID][subclassID]
							) and itemEquipLoc ~= "INVTYPE_CLOAK" -- ignore Cloaks
						)
					)
				then
					setVisibility = true
				end
			end

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
				if nil ~= addon.variables.allowedEquipSlotsBagIlvl[invSlot] then
					local color = eItem:GetItemQualityColor()
					local itemLevelText = eItem:GetCurrentItemLevel()

					itemButton.ItemLevelText:SetFormattedText(itemLevelText)
					itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)

					itemButton.ItemLevelText:Show()

					local bType

					if addon.db["showBindOnBagItems"] then
						local data = C_TooltipInfo.GetBagItem(bag, slot)
						if data and data.lines then
							for i, v in pairs(data.lines) do
								if v.type == 20 then
									if v.leftText == ITEM_BIND_ON_EQUIP then
										bType = "BoE"
									elseif v.leftText == ITEM_ACCOUNTBOUND_UNTIL_EQUIP or v.leftText == ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP then
										bType = "WuE"
									elseif v.leftText == ITEM_ACCOUNTBOUND or v.leftText == ITEM_BIND_TO_BNETACCOUNT then
										bType = "WB"
									end
									break
								end
							end
						end
					end
					if bType then
						if not itemButton.ItemBoundType then
							itemButton.ItemBoundType = itemButton:CreateFontString(nil, "OVERLAY")
							itemButton.ItemBoundType:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
							itemButton.ItemBoundType:SetPoint("BOTTOMLEFT", itemButton, "BOTTOMLEFT", 2, 2)

							itemButton.ItemBoundType:SetShadowOffset(2, 2)
							itemButton.ItemBoundType:SetShadowColor(0, 0, 0, 1)
						end
						itemButton.ItemBoundType:SetFormattedText(bType)
						itemButton.ItemBoundType:Show()
					elseif itemButton.ItemBoundType then
						itemButton.ItemBoundType:Hide()
					end
				elseif itemButton.ItemLevelText then
					if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
					itemButton.ItemLevelText:Hide()
				end
			end
			if setVisibility then setItemVisibility(itemButton) end
		end)
	elseif itemButton.ItemLevelText then
		if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
		itemButton.ItemLevelText:Hide()
	end
end

function addon.functions.updateBank(itemButton, bag, slot) updateButtonInfo(itemButton, bag, slot) end

-- Datenstruktur für das Menü
local filterData = {
	-- {
	-- 	label = "Level Range",
	-- 	child = {
	-- 		{ type = "EditBox", key = "minLevel", label = "Min Level" },
	-- 		{ type = "EditBox", key = "maxLevel", label = "Max Level" },
	-- 	},
	-- },
	{
		label = "Equipment",
		child = {
			{ type = "CheckBox", key = "equipment", label = "Equipment only" },
			{ type = "CheckBox", key = "usableOnly", label = "Usable only" },
		},
	},
	-- {
	-- 	label = "Equipment",
	-- 	child = {
	-- 		{ type = "CheckBox", key = "upgrades", label = "Upgrades Only" },
	-- 		{ type = "CheckBox", key = "usable", label = "Usable Only" },
	-- 	},
	-- },
	{
		label = "Rarity",
		child = {
			-- { type = "CheckBox", key = "poor", label = "|cff9d9d9dPoor", qFilter = 0 },
			-- { type = "CheckBox", key = "common", label = "|cffffffffCommon", qFilter = 1 },
			{ type = "CheckBox", key = "uncommon", label = "|cff1eff00Uncommon", qFilter = 2 },
			{ type = "CheckBox", key = "rare", label = "|cff0070ddRare", qFilter = 3 },
			{ type = "CheckBox", key = "epic", label = "|cffa335eeEpic", qFilter = 4 },
			{ type = "CheckBox", key = "legendary", label = "|cffff8000Legendary", qFilter = 5 },
			-- { type = "CheckBox", key = "artifact", label = "|cffe6cc80Artifact", qFilter = 6 },
		},
	},
}

local function checkActiveQualityFilter()
	for _, value in pairs(addon.itemBagFiltersQuality) do
		if value == true then
			addon.itemBagFilters["rarity"] = true
			return
		end
	end
	addon.itemBagFilters["rarity"] = false
end

-- Funktion zum Erstellen des Filtermenüs mit AceGUI
local function CreateFilterMenu()
	-- Haupt-Frame für das Filtermenü
	-- local frame = AceGUI:Create("Frame")
	-- frame:SetTitle("Item Filter")
	-- frame:SetLayout("Fill")
	-- frame:SetWidth(220)
	-- frame:SetHeight(300)
	-- frame:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -10, 0)
	-- frame:Hide()
	-- frame.frame:SetParent(ContainerFrameCombinedBags)
	-- frame.frame:SetFrameStrata("HIGH")

	local frame = CreateFrame("Frame", "InventoryFilterPanel", ContainerFrameCombinedBags, "BackdropTemplate")
	frame:SetSize(220, 300) -- Feste Größe
	frame:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -10, 0)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:Hide() -- Standardmäßig ausblenden
	frame:SetFrameStrata("HIGH")
	frame:SetMovable(false)
	frame:EnableMouse(true)

	-- Scrollbarer Bereich
	local scrollContainer = AceGUI:Create("ScrollFrame")
	scrollContainer:SetLayout("Flow")
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)

	scrollContainer.frame:SetParent(frame)
	scrollContainer.frame:ClearAllPoints()
	scrollContainer.frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
	scrollContainer.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)

	-- Dynamisch die UI-Elemente aus `filterData` erstellen
	for _, section in ipairs(filterData) do
		-- Überschrift für jede Sektion
		local label = AceGUI:Create("Label")
		label:SetText("|cffffd100" .. section.label .. "|r") -- Goldene Überschrift
		label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
		label:SetFullWidth(true)
		scrollContainer:AddChild(label)

		-- Füge die Kind-Elemente hinzu
		for _, item in ipairs(section.child) do
			local widget

			if item.type == "CheckBox" then
				widget = AceGUI:Create("CheckBox")
				widget:SetLabel(item.label)
				widget:SetValue(addon.itemBagFilters[item.key])
				widget:SetCallback("OnValueChanged", function(_, _, value)
					addon.itemBagFilters[item.key] = value
					if item.qFilter then
						addon.itemBagFiltersQuality[item.qFilter] = value
						checkActiveQualityFilter()
					end
					-- Hier könnte man die Filterlogik triggern, z. B.:
					-- UpdateInventoryDisplay()
					addon.functions.updateBags(ContainerFrameCombinedBags)
					for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
						addon.functions.updateBags(frame)
					end
				end)
			elseif item.type == "EditBox" then
				widget = AceGUI:Create("EditBox")
				widget:SetLabel(item.label)
				widget:SetWidth(100)
				widget:SetText(addon.itemBagFilters[item.key] or "")
				widget:SetCallback("OnEnterPressed", function(_, _, text)
					addon.itemBagFilters[item.key] = tonumber(text)
					-- Hier könnte man die Filterlogik triggern
				end)
			end

			if widget then
				widget:SetFullWidth(true)
				scrollContainer:AddChild(widget)
			end
		end
	end
	return frame
end

-- **Funktion zum Ein-/Ausblenden des Menüs über einen Button**
local function ToggleFilterMenu(self)
	if not addon.filterFrame then addon.filterFrame = CreateFilterMenu() end
	if addon.filterFrame:IsVisible() then
		addon.filterFrame:Hide()
		self:SetText("Filter off")
	else
		addon.filterFrame:Show()
		self:SetText("Filter on")
		addon.filterFrame:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -10, 0)
	end

	addon.functions.updateBags(ContainerFrameCombinedBags)
	for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
		addon.functions.updateBags(frame)
	end
end

-- **Button zum Öffnen/Schließen des Menüs neben dem Suchfeld**
local function CreateFilterToggleButton()
	local button = CreateFrame("Button", "InventoryFilterToggleButton", ContainerFrameCombinedBags, "UIPanelButtonTemplate")
	button:SetSize(60, 20)
	button:SetPoint("RIGHT", BagItemSearchBox, "LEFT", -5, 0)
	button:SetText("Filter off")
	button:SetScript("OnClick", ToggleFilterMenu)
	addon.filterButton = button
end

-- Initialisierung beim Laden des UI
local function InitializeFilterUI()
	if nil == InventoryFilterToggleButton then CreateFilterToggleButton() end
end

function addon.functions.updateBags(frame)
	--@debug@
	if addon.db["showIlvlOnBagItems"] then InitializeFilterUI() end
	--@end-debug@
	if nil == knownButtons[frame:GetName()] then
		knownButtons[frame:GetName()] = {}
	else
		for i, v in pairs(knownButtons[frame:GetName()]) do
			if v.ItemLevelText then v.ItemLevelText:Hide() end
		end
	end
	knownButtons[frame:GetName()] = {} -- clear the list again
	for _, itemButton in frame:EnumerateValidItems() do
		if itemButton then
			if addon.db["showIlvlOnBagItems"] then
				updateButtonInfo(itemButton, itemButton:GetBagID(), itemButton:GetID(), frame:GetName())
			elseif itemButton.ItemLevelText then
				itemButton.ItemLevelText:Hide()
			end
		end
	end
end
