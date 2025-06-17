local addonName, addon = ...

addon.functions = {}
local AceGUI = LibStub("AceGUI-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")

local GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetItemInfoInstant = C_Item.GetItemInfoInstant
local GetItemInfo = C_Item.GetItemInfo
local GetBagItem = C_TooltipInfo.GetBagItem
local IsEquippableItem = C_Item.IsEquippableItem
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid

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

local GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
local SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
local COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

function addon.functions.formatMoney(copper, type)
	local COPPER_PER_SILVER = 100
	local COPPER_PER_GOLD = 10000

	local gold = math.floor(copper / COPPER_PER_GOLD)
	local silver = math.floor((copper % COPPER_PER_GOLD) / COPPER_PER_SILVER)
	local bronze = copper % COPPER_PER_SILVER

	local parts = {}

	if gold > 0 then table.insert(parts, string.format("%s%s", BreakUpLargeNumbers(gold), GOLD_ICON)) end
	if nil == type or (type and type == "tracker" and addon.db["showOnlyGoldOnMoney"] == false) then
		if gold > 0 or silver > 0 then table.insert(parts, string.format("%02d%s", silver, SILVER_ICON)) end
		table.insert(parts, string.format("%02d%s", bronze, COPPER_ICON))
	end

	return table.concat(parts, " ")
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

function addon.functions.formatTextTabs(tabs)
	if tabs and tabs.tabs then
		for i = 1, #tabs.tabs do
			if tabs.tabs[i].Text and type(tabs.tabs[i].Text.SetFont) == "function" then tabs.tabs[i].Text:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
		end
	end
end

function addon.functions.createContainer(typ, layout)
	local element = AceGUI:Create(typ)
	element:SetFullWidth(true)
	if layout then element:SetLayout(layout) end
	if element.titletext and type(element.titletext.SetFont) == "function" then element.titletext:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end

	return element
end

function addon.functions.createCheckboxAce(text, value, callBack, description)
	local checkbox = AceGUI:Create("CheckBox")

	checkbox:SetLabel(text)
	if checkbox.text and type(checkbox.text.SetFont) == "function" then checkbox.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	checkbox:SetValue(value)
	checkbox:SetCallback("OnValueChanged", callBack)
	checkbox:SetFullWidth(true)
	if description then checkbox:SetDescription(string.format("|cffffd700" .. description .. "|r ")) end

	return checkbox
end

function addon.functions.createEditboxAce(label, text, OnEnterPressed, OnTextChanged)
	local editbox = AceGUI:Create("EditBox")

	editbox:SetLabel(label)
	if editbox.editbox and type(editbox.editbox.SetFont) == "function" then editbox.editbox:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if editbox.label and type(editbox.label.SetFont) == "function" then editbox.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if editbox.button and type(editbox.button.SetFont) == "function" then editbox.button:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end

	if text then editbox:SetText(text) end
	if OnEnterPressed then editbox:SetCallback("OnEnterPressed", OnEnterPressed) end
	if OnTextChanged then editbox:SetCallback("OnTextChanged", OnTextChanged) end
	return editbox
end

function addon.functions.createSliderAce(text, value, min, max, step, callBack)
	local slider = AceGUI:Create("Slider")

	slider:SetLabel(text)
	if slider.lowtext and type(slider.lowtext.SetFont) == "function" then slider.lowtext:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if slider.hightext and type(slider.hightext.SetFont) == "function" then slider.hightext:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if slider.editbox and type(slider.editbox.SetFont) == "function" then slider.editbox:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if slider.label and type(slider.label.SetFont) == "function" then slider.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
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
	if type(label.label.SetFont) == "function" then label.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if color then label:SetColor(color.r, color.g, color.b) end

	label:SetFont(font or addon.variables.defaultFont, fontSize, "OUTLINE")
	return label
end

function addon.functions.createButtonAce(text, width, callBack)
	local button = AceGUI:Create("Button")
	button:SetText(text)
	if button.text and type(button.text.SetFont) == "function" then button.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	button:SetWidth(width or 100)
	if callBack then button:SetCallback("OnClick", callBack) end
	return button
end

function addon.functions.createDropdownAce(text, list, order, callBack)
	local dropdown = AceGUI:Create("Dropdown")
	dropdown:SetLabel(text or "")
	if dropdown.label and type(dropdown.label.SetFont) == "function" then dropdown.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
	if dropdown.text and type(dropdown.text.SetFont) == "function" then dropdown.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end

	if order then
		dropdown:SetList(list, order)
	else
		dropdown:SetList(list)
	end
	dropdown:SetFullWidth(true)
	if callBack then dropdown:SetCallback("OnValueChanged", callBack) end
	dropdown:SetCallback("OnOpened", function()
		for _, item in dropdown.pullout:IterateItems() do
			item.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
		end
        end)
        return dropdown
end

function addon.functions.updateTreeGroupFonts(tree)
       if not tree or not tree.buttons then return end
       for _, btn in ipairs(tree.buttons) do
               if btn.text and type(btn.text.SetFont) == "function" then
                       btn.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
               end
       end
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
					subtext:SetText(string.format("|cffffd700" .. checkboxData.desc .. "|r "))
					subtext:SetFont(addon.variables.defaultFont, 10, "OUTLINE")
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
			if widget.text and type(widget.text.SetFont) == "function" then widget.text:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
			if widget.label and type(widget.label.SetFont) == "function" then widget.label:SetFont(addon.variables.defaultFont, 14, "OUTLINE") end
			if checkboxData.gv then addon.elements[checkboxData.gv] = widget end
		end
	end
	scroll:DoLayout()
	scrollInner:DoLayout()
	return wrapper
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
	itemButton:SetAlpha(1)
	itemButton:SetMatchesSearch(true) -- set all to visible on start

	if itemButton.ItemLevelText then itemButton.ItemLevelText:SetAlpha(1) end
	if itemButton.ItemBoundType then
		itemButton.ItemBoundType:SetAlpha(1)
		itemButton.ItemBoundType:SetText("")
	end
	local eItem = Item:CreateFromBagAndSlot(bag, slot)
	if eItem and not eItem:IsItemEmpty() then
		eItem:ContinueOnItemLoad(function()
			local _, _, _, _, _, _, _, _, itemEquipLoc, _, sellPrice, classID, subclassID, _, expId = GetItemInfo(eItem:GetItemLink())
			local bType, bKey, upgradeKey, bAuc
			local data
			if addon.db["showBindOnBagItems"] or addon.itemBagFilters["bind"] or addon.itemBagFilters["upgrade"] or addon.itemBagFilters["misc_auctionhouse_sellable"] then
				data = GetBagItem(bag, slot)
				if data and data.lines then
					for i, v in pairs(data.lines) do
						if v.type == 20 then
							bAuc = true
							if v.leftText == ITEM_BIND_ON_EQUIP then
								bType = "BoE"
								bKey = "boe"
								bAuc = false
							elseif v.leftText == ITEM_ACCOUNTBOUND_UNTIL_EQUIP or v.leftText == ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP then
								bType = "WuE"
								bKey = "wue"
							elseif v.leftText == ITEM_ACCOUNTBOUND or v.leftText == ITEM_BIND_TO_BNETACCOUNT then
								bType = "WB"
								bKey = "wb"
							end
						elseif v.type == 42 then
							local text = v.rightText or v.leftText
							if text then
								local tier = text:gsub(".+:%s?", ""):gsub("%s?%d/%d", "")
								if tier then upgradeKey = string.lower(tier) end
							end
						elseif v.type == 0 and v.leftText == ITEM_CONJURED then
							bAuc = true
						end
					end
				end
			end
			local setVisibility = false

			if addon.filterFrame then
				if classID == 15 and subclassID == 0 then bAuc = true end -- ignore lockboxes etc.
				local cInfo = GetContainerItemInfo(bag, slot)
				if cInfo and cInfo.isFiltered then setVisibility = true end
				if addon.filterFrame:IsVisible() then
					if addon.itemBagFilters["rarity"] then
						if nil == addon.itemBagFiltersQuality[eItem:GetItemQuality()] or addon.itemBagFiltersQuality[eItem:GetItemQuality()] == false then setVisibility = true end
					end
					local cilvl = eItem:GetCurrentItemLevel()
					if addon.itemBagFilters["minLevel"] and (cilvl < addon.itemBagFilters["minLevel"] or (nil == itemEquipLoc or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE")) then
						setVisibility = true
					end
					if addon.itemBagFilters["maxLevel"] and (cilvl > addon.itemBagFilters["maxLevel"] or (nil == itemEquipLoc or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE")) then
						setVisibility = true
					end
					if addon.itemBagFilters["currentExpension"] and LE_EXPANSION_LEVEL_CURRENT ~= expId then setVisibility = true end
					if addon.itemBagFilters["equipment"] and (nil == itemEquipLoc or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE") then setVisibility = true end
					if addon.itemBagFilters["bind"] then
						if nil == addon.itemBagFiltersBound[bKey] or addon.itemBagFiltersBound[bKey] == false then setVisibility = true end
					end
					if addon.itemBagFilters["misc_auctionhouse_sellable"] then
						if bAuc then setVisibility = true end
					end
					if addon.itemBagFilters["upgrade"] then
						if nil == addon.itemBagFiltersUpgrade[upgradeKey] or addon.itemBagFiltersUpgrade[upgradeKey] == false then setVisibility = true end
					end
					if addon.itemBagFilters["misc_sellable"] then
						if addon.itemBagFilters["misc_sellable"] == true and (not sellPrice or sellPrice == 0) then setVisibility = true end
					end
					if
						addon.itemBagFilters["usableOnly"]
						and (
							IsEquippableItem(eItem:GetItemLink()) == false
							or (
								(
									nil == addon.itemBagFilterTypes[addon.variables.unitClass]
									or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec]
									or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec][classID]
									or nil == addon.itemBagFilterTypes[addon.variables.unitClass][addon.variables.unitSpec][classID][subclassID]
									or itemEquipLoc == "INVTYPE_TABARD" -- ignore Tabards
								) and itemEquipLoc ~= "INVTYPE_CLOAK" -- ignore Cloaks
							)
						)
					then
						setVisibility = true
					end
				end
			end

			if
				(itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" or (classID == 4 and subclassID == 0)) and not (classID == 4 and subclassID == 5) -- Cosmetic
			then
				if not itemButton.OverlayFilter then itemButton.OverlayFilter = itemButton:CreateFontString(nil, "ARTWORK") end
				if not itemButton.ItemLevelText then
					-- Create behind Blizzard's search overlay so it fades automatically
					itemButton.ItemLevelText = itemButton:CreateFontString(nil, "ARTWORK")
					itemButton.ItemLevelText:SetDrawLayer("ARTWORK", 1)
					itemButton.ItemLevelText:SetFont(addon.variables.defaultFont, 13, "OUTLINE")
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

					if addon.db["showBindOnBagItems"] and bType then
						if not itemButton.ItemBoundType then
							-- Position behind Blizzard's overlay
							itemButton.ItemBoundType = itemButton:CreateFontString(nil, "ARTWORK")
							itemButton.ItemBoundType:SetDrawLayer("ARTWORK", 1)
							itemButton.ItemBoundType:SetFont(addon.variables.defaultFont, 10, "OUTLINE")
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
			-- itemButton:SetMatchesSearch(not setVisibility)
			if setVisibility then
				itemButton:SetAlpha(0.1)
				if itemButton.ItemContextOverlay then
					itemButton.ItemContextOverlay:Show()
					itemButton.ItemContextOverlay:SetColorTexture(0, 0, 0, 0.8)
				end

				if itemButton.ItemLevelText then itemButton.ItemLevelText:SetAlpha(0.1) end
				if itemButton.ItemBoundType then itemButton.ItemBoundType:SetAlpha(0.1) end
				if itemButton.ProfessionQualityOverlay and addon.db["fadeBagQualityIcons"] then itemButton.ProfessionQualityOverlay:SetAlpha(0.1) end
			else
				itemButton:SetAlpha(1)
				if itemButton.ItemContextOverlay then itemButton.ItemContextOverlay:Hide() end
				if itemButton.ItemLevelText then itemButton.ItemLevelText:SetAlpha(1) end
				if itemButton.ItemBoundType then itemButton.ItemBoundType:SetAlpha(1) end
				if itemButton.ProfessionQualityOverlay and addon.db["fadeBagQualityIcons"] then itemButton.ProfessionQualityOverlay:SetAlpha(1) end
			end
		end)
	elseif itemButton.ItemLevelText then
		if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
		itemButton.ItemLevelText:Hide()
	end
end

function addon.functions.updateBank(itemButton, bag, slot) updateButtonInfo(itemButton, bag, slot) end

local filterData = {
	{
		label = BAG_FILTER_EQUIPMENT,
		child = {
			{ type = "CheckBox", key = "equipment", label = L["bagFilterEquip"] },
			{ type = "CheckBox", key = "usableOnly", label = L["bagFilterSpec"] },
		},
	},
	{
		label = AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE,
		child = {
			{ type = "EditBox", key = "minLevel", label = MINIMUM },
			{ type = "EditBox", key = "maxLevel", label = MAXIMUM },
		},
		ignoreSort = true,
	},
	{
		label = EXPANSION_FILTER_TEXT,
		child = {
			{ type = "CheckBox", key = "currentExpension", label = REFORGE_CURRENT, tooltip = L["currentExpensionMythicPlusWarning"] },
		},
	},
	{
		label = L["bagFilterBindType"],
		child = {
			{ type = "CheckBox", key = "boe", label = ITEM_BIND_ON_EQUIP, bFilter = "boe" },
			{ type = "CheckBox", key = "wue", label = ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP, bFilter = "wue" },
			{ type = "CheckBox", key = "wb", label = ITEM_BIND_TO_ACCOUNT, bFilter = "wb" },
		},
	},
	{
		label = L["bagFilterUpgradeLevel"],
		child = {
			{ type = "CheckBox", key = "upgrade_veteran", label = L["upgradeLevelVeteran"], uFilter = L["upgradeLevelVeteran"] },
			{ type = "CheckBox", key = "upgrade_champion", label = L["upgradeLevelChampion"], uFilter = L["upgradeLevelChampion"] },
			{ type = "CheckBox", key = "upgrade_hero", label = L["upgradeLevelHero"], uFilter = L["upgradeLevelHero"] },
			{ type = "CheckBox", key = "upgrade_mythic", label = L["upgradeLevelMythic"], uFilter = L["upgradeLevelMythic"] },
		},
	},
	{
		label = RARITY,
		child = {
			{ type = "CheckBox", key = "poor", label = "|cff9d9d9d" .. ITEM_QUALITY0_DESC, qFilter = 0 },
			{ type = "CheckBox", key = "common", label = "|cffffffff" .. ITEM_QUALITY1_DESC, qFilter = 1 },
			{ type = "CheckBox", key = "uncommon", label = "|cff1eff00" .. ITEM_QUALITY2_DESC, qFilter = 2 },
			{ type = "CheckBox", key = "rare", label = "|cff0070dd" .. ITEM_QUALITY3_DESC, qFilter = 3 },
			{ type = "CheckBox", key = "epic", label = "|cffa335ee" .. ITEM_QUALITY4_DESC, qFilter = 4 },
			{ type = "CheckBox", key = "legendary", label = "|cffff8000" .. ITEM_QUALITY5_DESC, qFilter = 5 },
			{ type = "CheckBox", key = "artifact", label = "|cffe6cc80" .. ITEM_QUALITY6_DESC, qFilter = 6 },
			{ type = "CheckBox", key = "heirloom", label = "|cff00ccff" .. ITEM_QUALITY7_DESC, qFilter = 7 },
		},
	},
	{
		label = HUD_EDIT_MODE_SETTINGS_CATEGORY_TITLE_MISC,
		child = {
			{ type = "CheckBox", key = "misc_sellable", label = L["misc_sellable"] },
			{ type = "CheckBox", key = "misc_auctionhouse_sellable", label = L["misc_auctionhouse_sellable"] },
		},
	},
}
table.sort(filterData, function(a, b)
	if a.ignoreSort and not b.ignoreSort then return true end
	if b.ignoreSort and not a.ignoreSort then return false end
	return a.label < b.label
end)

local function checkActiveQualityFilter()
	for _, value in pairs(addon.itemBagFiltersQuality) do
		if value == true then
			addon.itemBagFilters["rarity"] = true
			return
		end
	end
	addon.itemBagFilters["rarity"] = false
end

local function checkActiveBindFilter()
	for _, value in pairs(addon.itemBagFiltersBound) do
		if value == true then
			addon.itemBagFilters["bind"] = true
			return
		end
	end
	addon.itemBagFilters["bind"] = false
end

local function checkActiveUpgradeFilter()
	for _, value in pairs(addon.itemBagFiltersUpgrade) do
		if value == true then
			addon.itemBagFilters["upgrade"] = true
			return
		end
	end
	addon.itemBagFilters["upgrade"] = false
end

local function CreateFilterMenu()
	local frame = CreateFrame("Frame", "InventoryFilterPanel", ContainerFrameCombinedBags, "BackdropTemplate")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:Hide() -- Standardmäßig ausblenden
	frame:SetFrameStrata("HIGH")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if addon.db["bagFilterDockFrame"] then return end
		if not IsShiftKeyDown() then return end
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		-- Position speichern
		local point, _, parentPoint, xOfs, yOfs = self:GetPoint()
		addon.db["bagFilterFrameData"].point = point
		addon.db["bagFilterFrameData"].parentPoint = parentPoint
		addon.db["bagFilterFrameData"].x = xOfs
		addon.db["bagFilterFrameData"].y = yOfs
	end)
	if
		not addon.db["bagFilterDockFrame"]
		and addon.db["bagFilterFrameData"].point
		and addon.db["bagFilterFrameData"].parentPoint
		and addon.db["bagFilterFrameData"].x
		and addon.db["bagFilterFrameData"].y
	then
		frame:SetPoint(addon.db["bagFilterFrameData"].point, UIParent, addon.db["bagFilterFrameData"].parentPoint, addon.db["bagFilterFrameData"].x, addon.db["bagFilterFrameData"].y)
	else
		frame:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -10, 0)
	end

	-- Scrollbarer Bereich
	local scrollContainer = AceGUI:Create("ScrollFrame")
	scrollContainer:SetLayout("Flow")
	scrollContainer:SetFullWidth(true)
	scrollContainer:SetFullHeight(true)

	scrollContainer.frame:SetParent(frame)
	scrollContainer.frame:ClearAllPoints()
	scrollContainer.frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
	scrollContainer.frame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)

	frame.widgets = {}

	local function AnyFilterActive()
		for _, v in pairs(addon.itemBagFilters) do
			if v then return true end
		end
		for _, tbl in ipairs({ addon.itemBagFiltersQuality, addon.itemBagFiltersBound, addon.itemBagFiltersUpgrade }) do
			for _, v in pairs(tbl) do
				if v then return true end
			end
		end
		return false
	end

	local function UpdateResetButton()
		if frame.btnReset then
			if AnyFilterActive() then
				frame.btnReset:Show()
			else
				frame.btnReset:Hide()
			end
		end
	end

	local longestWidth = 200
	local math_max = math.max
	-- Dynamisch die UI-Elemente aus `filterData` erstellen
	for _, section in ipairs(filterData) do
		-- Überschrift für jede Sektion
		local label = AceGUI:Create("Label")
		label:SetText("|cffffd100" .. section.label .. "|r") -- Goldene Überschrift
		label:SetFont(addon.variables.defaultFont, 12, "OUTLINE")
		label:SetFullWidth(true)
		scrollContainer:AddChild(label)

		longestWidth = math_max(label.label:GetStringWidth(), longestWidth)

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
					if item.bFilter then
						addon.itemBagFiltersBound[item.bFilter] = value
						checkActiveBindFilter()
					end
					if item.uFilter then
						addon.itemBagFiltersUpgrade[string.lower(item.uFilter)] = value
						checkActiveUpgradeFilter()
					end
					-- Hier könnte man die Filterlogik triggern, z. B.:
					-- UpdateInventoryDisplay()
					addon.functions.updateBags(ContainerFrameCombinedBags)
					for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
						addon.functions.updateBags(frame)
					end

					if BankFrame and BankFrame:IsShown() and addon.db["showIlvlOnBankFrame"] then
						for slot = 1, NUM_BANKGENERIC_SLOTS do
							local itemButton = _G["BankFrameItem" .. slot]
							if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
						end
					end
					if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end

					UpdateResetButton()
				end)
				if item.tooltip then
					widget:SetCallback("OnEnter", function(self)
						GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT")
						GameTooltip:ClearLines()
						GameTooltip:AddLine(item.tooltip)
						GameTooltip:Show()
					end)
					widget:SetCallback("OnLeave", function(self) GameTooltip:Hide() end)
				end
			elseif item.type == "EditBox" then
				-- separate label so it aligns nicely above half‑width boxes
				local eLabel = AceGUI:Create("Label")
				eLabel:SetText(item.label)
				eLabel:SetRelativeWidth(0.48)
				scrollContainer:AddChild(eLabel)
				widget = AceGUI:Create("EditBox")
				-- widget:SetLabel(item.label) -- REMOVED: label now handled by separate label above
				widget:SetWidth(50)
				widget:SetText(addon.itemBagFilters[item.key] or "")
				-- Show Min/Max boxes side‑by‑side, half width each
				if item.key == "minLevel" or item.key == "maxLevel" then
					-- keep some margin, 0.48 looks good in Flow layout
					widget:SetRelativeWidth(0.48)
				end

				widget:SetCallback("OnTextChanged", function(self, _, text)
					local caret = self.editbox:GetCursorPosition()
					local numeric = text:gsub("%D", "")
					if numeric ~= text then
						self:SetText(numeric)
						local newPos = math.max(0, caret - (text:len() - numeric:len()))
						self.editbox:SetCursorPosition(newPos)
					end
				end)

				widget:SetCallback("OnEnterPressed", function(self, _, text)
					addon.itemBagFilters[item.key] = tonumber(text)
					addon.functions.updateBags(ContainerFrameCombinedBags)
					for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
						addon.functions.updateBags(frame)
					end

					if BankFrame and BankFrame:IsShown() and addon.db["showIlvlOnBankFrame"] then
						for slot = 1, NUM_BANKGENERIC_SLOTS do
							local itemButton = _G["BankFrameItem" .. slot]
							if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
						end
					end
					if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end

					UpdateResetButton()
					self:ClearFocus()
				end)
			end

			if widget then
				if item.type ~= "EditBox" or (item.key ~= "minLevel" and item.key ~= "maxLevel") then widget:SetFullWidth(true) end
				scrollContainer:AddChild(widget)
				table.insert(frame.widgets, widget)
				if widget.text and widget.text.GetStringWidth then longestWidth = math_max(widget.text:GetStringWidth(), longestWidth) end
			end
		end
	end
	frame:SetSize(longestWidth + 60, 280) -- Feste Größe

	local btnDock = CreateFrame("Button", "InventoryFilterPanelDock", frame)
	btnDock:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -5)
	btnDock:SetText("Dock")
	btnDock.isDocked = addon.db["bagFilterDockFrame"]
	btnDock:SetScript("OnClick", function(self)
		self.isDocked = not self.isDocked
		addon.db["bagFilterDockFrame"] = self.isDocked
		if self.isDocked then
			frame:ClearAllPoints()
			frame:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -10, 0)
			self.icon:SetTexture("Interface\\Addons\\EnhanceQoL\\Icons\\ClosedLock.tga")
		else
			self.icon:SetTexture("Interface\\Addons\\EnhanceQoL\\Icons\\OpenLock.tga")
		end
	end)
	btnDock:SetSize(16, 16)
	btnDock:Show()

	local icon = btnDock:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(btnDock)
	if addon.db["bagFilterDockFrame"] then
		icon:SetTexture("Interface\\Addons\\EnhanceQoL\\Icons\\ClosedLock.tga")
	else
		icon:SetTexture("Interface\\Addons\\EnhanceQoL\\Icons\\OpenLock.tga")
	end
	btnDock.icon = icon
	-- Tooltip: zeigt dem Spieler, was der Button macht
	btnDock:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.isDocked then
			GameTooltip:SetText(L["bagFilterDockFrameUnlock"])
		else
			GameTooltip:SetText(L["bagFilterDockFrameLock"])
		end
		GameTooltip:Show()
	end)
	btnDock:SetScript("OnLeave", function() GameTooltip:Hide() end)

	local btnReset = CreateFrame("Button", "InventoryFilterPanelReset", frame)
	btnReset:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -50, -5)
	btnReset:SetSize(16, 16)
	btnReset:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
	btnReset:Hide()
	frame.btnReset = btnReset
	btnReset:SetScript("OnClick", function()
		addon.itemBagFilters = {}
		addon.itemBagFiltersQuality = {}
		addon.itemBagFiltersBound = {}
		addon.itemBagFiltersUpgrade = {}

		for _, widget in ipairs(frame.widgets) do
			if widget.SetValue then widget:SetValue(false) end
			if widget.SetText then widget:SetText("") end
		end

		addon.functions.updateBags(ContainerFrameCombinedBags)
		for _, cframe in ipairs(ContainerFrameContainer.ContainerFrames) do
			addon.functions.updateBags(cframe)
		end

		if BankFrame and BankFrame:IsShown() and addon.db["showIlvlOnBankFrame"] then
			for slot = 1, NUM_BANKGENERIC_SLOTS do
				local itemButton = _G["BankFrameItem" .. slot]
				if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
			end
		end
		if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end

		UpdateResetButton()
	end)
	btnReset:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["bagFilterResetFilters"])
		GameTooltip:Show()
	end)
	btnReset:SetScript("OnLeave", function() GameTooltip:Hide() end)

	UpdateResetButton()
	return frame
end

local function ToggleFilterMenu(self)
	if not addon.filterFrame then addon.filterFrame = CreateFilterMenu() end
	addon.filterFrame:Show()

	addon.functions.updateBags(ContainerFrameCombinedBags)
	for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
		addon.functions.updateBags(frame)
	end

	if BankFrame and BankFrame:IsShown() and addon.db["showIlvlOnBankFrame"] then
		for slot = 1, NUM_BANKGENERIC_SLOTS do
			local itemButton = _G["BankFrameItem" .. slot]
			if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
		end
	end
	if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end
end

local function InitializeFilterUI()
	if nil == addon.filterFrame then ToggleFilterMenu() end
end

function addon.functions.updateBags(frame)
	if addon.db["showBagFilterMenu"] then
		InitializeFilterUI()
	elseif addon.filterFrame then
		addon.filterFrame:SetParent(nil)
		addon.filterFrame:Hide()
		addon.filterFrame = nil
		addon.itemBagFilters = {}
		addon.itemBagFiltersQuality = {}
		addon.itemBagFiltersBound = {}
		addon.itemBagFiltersUpgrade = {}
	end
	if not frame:IsShown() then return end
	if nil == knownButtons[frame:GetName()] then
		knownButtons[frame:GetName()] = {}
	else
		for i, v in pairs(knownButtons[frame:GetName()]) do
			if v.ItemLevelText then v.ItemLevelText:Hide() end
		end
	end
	knownButtons[frame:GetName()] = {} -- clear the list again

	if frame:GetName() == "AccountBankPanel" then
		for itemButton in frame:EnumerateValidItems() do
			if addon.db["showIlvlOnBankFrame"] then
				local bag = itemButton:GetBankTabID()
				local slot = itemButton:GetContainerSlotID()
				if bag and slot then updateButtonInfo(itemButton, bag, slot, frame:GetName()) end
			elseif itemButton.ItemLevelText then
				itemButton.ItemLevelText:Hide()
			end
		end
	else
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
end

function addon.functions.IsQuestRepeatableType(questID)
	if C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then return true end
	if C_QuestLog.IsRepeatableQuest and C_QuestLog.IsRepeatableQuest(questID) then return true end
	local classification
	if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then classification = C_QuestInfoSystem.GetQuestClassification(questID) end
	return classification == Enum.QuestClassification.Recurring or classification == Enum.QuestClassification.Calling
end

local function handleWayCommand(msg)
	local args = {}
	msg = (msg or ""):gsub(",", " ")
	for token in string.gmatch(msg, "%S+") do
		table.insert(args, token)
	end

	local mapID, x, y
	if #args >= 2 then
		local first = args[1]
		if first:sub(1, 1) == "#" then first = first:sub(2) end
		if tonumber(first) and args[3] then
			mapID = tonumber(first)
			x = tonumber(args[2])
			y = tonumber(args[3])
		else
			x = tonumber(args[1])
			y = tonumber(args[2])
			mapID = C_Map.GetBestMapForUnit("player")
		end
	end

	if not mapID or not x or not y then
		print("|cff00ff98Enhance QoL|r: " .. L["wayUsage"])
		return
	end

	local mInfo = C_Map.GetMapInfo(mapID)
	if not mInfo or nil == mInfo then
		print("|cff00ff98Enhance QoL|r: " .. L["wayError"]:format(mapID))
		return
	end

	if not C_Map.CanSetUserWaypointOnMap(mapID) then
		print("|cff00ff98Enhance QoL|r: " .. L["wayErrorPlacePing"])
		return
	end

	x = x / 100
	y = y / 100

	local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
	C_Map.SetUserWaypoint(point)
	C_SuperTrack.SetSuperTrackedUserWaypoint(true)

	print("|cff00ff98Enhance QoL|r: " .. string.format(L["waySet"], mInfo.name, x * 100, y * 100))
end

function addon.functions.registerWayCommand()
	if SlashCmdList["WAY"] or _G.SLASH_WAY1 then return end
	SLASH_EQOLWAY1 = "/way"
	SlashCmdList["EQOLWAY"] = handleWayCommand
end
