local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LTooltip
local AceGUI = addon.AceGUI

local frameLoad = CreateFrame("Frame")

local function prettyFormatNumber(value)
	if value >= 1e6 then
		return string.format("%.1fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%.1fK", value / 1e3)
	else
		return tostring(value)
	end
end

local function GetNPCIDFromGUID(guid)
	if guid then
		local type, _, _, _, _, npcID = strsplit("-", guid)
		if type == "Creature" or type == "Vehicle" then return tonumber(npcID) end
	end
	return nil
end

local function checkSpell(tooltip, id, name)
	if addon.db["TooltipShowSpellID"] then
		if id then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(name, id)
		end
	end
	if addon.db["TooltipSpellHideType"] == 1 then return end -- only hide when ON
	if addon.db["TooltipSpellHideInDungeon"] and select(1, IsInInstance()) == false then return end -- only hide in dungeons
	if addon.db["TooltipSpellHideInCombat"] and UnitAffectingCombat("player") == false then return end -- only hide in combat
	tooltip:Hide()
end

local function checkAdditionalTooltip(tooltip)
	local unit = "mouseover"
	if addon.db["TooltipShowNPCID"] and not UnitPlayerControlled("mouseover") then
		local id = GetNPCIDFromGUID(UnitGUID("mouseover"))
		if id then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(L["NPCID"], id)
		end
	end
	if addon.db["TooltipShowClassColor"] and UnitPlayerControlled("mouseover") then
		local classDisplayName, class, classID = UnitClass("mouseover")
		if classDisplayName then
			local r, g, b = GetClassColor(class)
			for i = 1, tooltip:NumLines() do
				local line = _G[tooltip:GetName() .. "TextLeft" .. i]
				local text = line:GetText()
				if text and text:find(classDisplayName) then
					line:SetTextColor(r, g, b)
					break
				end
			end
		end
	end
	if addon.db["TooltipShowMythicScore"] and UnitCanAttack("player", "mouseover") == false and addon.Tooltip.variables.maxLevel == UnitLevel("mouseover") then
		local name, _, timeLimit
		local rating = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("mouseover")
		if rating then
			local r, g, b = C_ChallengeMode.GetDungeonScoreRarityColor(rating.currentSeasonScore):GetRGB()
			local bestDungeon
			for _, key in pairs(rating.runs) do
				name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(key.challengeModeID)
				if nil == bestDungeon then
					bestDungeon = key
				else
					if bestDungeon.mapScore < key.mapScore then bestDungeon = key end
				end
			end
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(L["Mythic+ Score"], rating.currentSeasonScore, 1, 1, 0, r, g, b)
			if bestDungeon and bestDungeon.mapScore > 0 then
				name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(bestDungeon.challengeModeID)
				r, g, b = C_ChallengeMode.GetKeystoneLevelRarityColor(bestDungeon.bestRunLevel):GetRGB()
				local stars = ""
				local hexColor = string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
				if bestDungeon.finishedSuccess then
					local bestRunDuration = bestDungeon.bestRunDurationMS / 1000
					local timeForPlus3 = timeLimit * 0.6
					local timeForPlus2 = timeLimit * 0.8
					local timeForPlus1 = timeLimit
					if bestRunDuration <= timeForPlus3 then
						stars = "+++"
					elseif bestRunDuration <= timeForPlus2 then
						stars = "++"
					elseif bestRunDuration <= timeForPlus1 then
						stars = "+"
					end
					stars = stars .. bestDungeon.bestRunLevel
				else
					stars = bestDungeon.bestRunLevel
				end
				tooltip:AddDoubleLine(L["BestMythic+run"], hexColor .. stars .. "|r " .. name, 1, 1, 0, 1, 1, 1)
			end
		end
	end
end

local function checkUnit(tooltip)
	if addon.db["TooltipUnitHideInDungeon"] and select(1, IsInInstance()) == false then
		checkAdditionalTooltip(tooltip)
		return
	end -- only hide in dungeons
	if addon.db["TooltipUnitHideInCombat"] and UnitAffectingCombat("player") == false then
		checkAdditionalTooltip(tooltip)
		return
	end -- only hide in combat
	if addon.db["TooltipUnitHideType"] == 1 then
		checkAdditionalTooltip(tooltip)
		return
	end -- hide never
	if addon.db["TooltipUnitHideType"] == 4 then tooltip:Hide() end -- hide always because we selected BOTH
	if addon.db["TooltipUnitHideType"] == 2 and UnitCanAttack("player", "mouseover") then tooltip:Hide() end
	if addon.db["TooltipUnitHideType"] == 3 and UnitCanAttack("player", "mouseover") == false then tooltip:Hide() end
	checkAdditionalTooltip(tooltip)
end

local function CheckReagentBankCount(itemID)
	local count = 0
	if IsReagentBankUnlocked() then
		for i = 1, C_Container.GetContainerNumSlots(REAGENTBANK_CONTAINER) do
			local itemInSlot = C_Container.GetContainerItemID(REAGENTBANK_CONTAINER, i)
			if itemInSlot == itemID then
				local info = C_Container.GetContainerItemInfo(REAGENTBANK_CONTAINER, i)
				count = count + info.stackCount
			end
		end
	end
	return count
end

local function checkItem(tooltip, id, name)
	if addon.db["TooltipShowItemID"] then
		if id then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(name, id)
		end
	end
	if addon.db["TooltipShowItemCount"] then
		if id then
			local rBankCount = CheckReagentBankCount(id)
			local bagCount = C_Item.GetItemCount(id)
			local bankCount = C_Item.GetItemCount(id, true)
			local totalCount = rBankCount + bankCount

			if addon.db["TooltipShowSeperateItemCount"] then
				if bagCount > 0 then
					bankCount = bankCount - bagCount
					tooltip:AddDoubleLine(L["Bag"], bagCount)
				end
				if bankCount > 0 then tooltip:AddDoubleLine(L["Bank"], bankCount) end
				if rBankCount > 0 then tooltip:AddDoubleLine(L["Reagentbank"], rBankCount) end
			else
				tooltip:AddDoubleLine(L["Itemcount"], totalCount)
			end
		end
	end
	if addon.db["TooltipItemHideType"] == 1 then return end -- only hide when ON
	if addon.db["TooltipItemHideInDungeon"] and select(1, IsInInstance()) == false then return end -- only hide in dungeons
	if addon.db["TooltipItemHideInCombat"] and UnitAffectingCombat("player") == false then return end -- only hide in combat
	tooltip:Hide()
end

local function checkAura(tooltip, id, name)
	if addon.db["TooltipShowSpellID"] then
		if id then
			tooltip:AddLine(" ")
			tooltip:AddDoubleLine(name, id)
		end
	end
	if addon.db["TooltipBuffHideType"] == 1 then return end -- only hide when ON
	if addon.db["TooltipBuffHideInDungeon"] and select(1, IsInInstance()) == false then return end -- only hide in dungeons
	if addon.db["TooltipBuffHideInCombat"] and UnitAffectingCombat("player") == false then return end -- only hide in combat
	tooltip:Hide()
end

if TooltipDataProcessor then
	TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
		if not data or not data.type then return end

		local id, name, _, timeLimit
		local kind = addon.Tooltip.variables.kindsByID[tonumber(data.type)]
		if kind ~= "unit" then
			if tooltip.healthBar then
				tooltip.healthBar:Hide()
				tooltip.healthBar = nil
			end
			if tooltip.healthUpdateFrame then
				tooltip.healthUpdateFrame:Hide()
				tooltip.healthUpdateFrame = nil
			end
		end
		if kind == "spell" then
			id = data.id
			name = L["SpellID"]
			checkSpell(tooltip, id, name)
			return
		elseif kind == "macro" then
			id = data.id
			name = L["MacroID"]
			checkSpell(tooltip, id, name)
			return
		elseif kind == "unit" then
			checkUnit(tooltip)
			return
		elseif kind == "item" then
			id = data.id
			name = L["ItemID"]
			checkItem(tooltip, id, name)
			return
		elseif kind == "aura" then
			id = data.id
			name = L["SpellID"]
			checkAura(tooltip, id, name)
		end
	end)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(s, p)
	if addon.db["TooltipAnchorType"] == 1 then return end
	local anchor
	if addon.db["TooltipAnchorType"] == 2 then anchor = "ANCHOR_CURSOR" end
	if addon.db["TooltipAnchorType"] == 3 then anchor = "ANCHOR_CURSOR_LEFT" end
	if addon.db["TooltipAnchorType"] == 4 then anchor = "ANCHOR_CURSOR_RIGHT" end
	local xOffset = addon.db["TooltipAnchorOffsetX"]
	local yOffset = addon.db["TooltipAnchorOffsetY"]
	s:SetOwner(p, anchor, xOffset, yOffset)
end)

addon.variables.statusTable.groups["tooltip"] = true

addon.functions.addToTree(nil, {
	value = "tooltip",
	text = L["Tooltip"],
	children = {
		{ value = "general", text = GENERAL },
		{ value = "buff_debuff", text = L["Buff_Debuff"] },
		{ value = "item", text = L["Item"] },
		{ value = "spell", text = L["Spell"] },
		{ value = "unit", text = L["Unit"] },
	},
})

local function addBuffDebuffFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["TooltipOFF"], [2] = L["TooltipON"] })

	local dropTooltipBuffHideType = addon.functions.createDropdownAce(L["TooltipBuffHideType"], list, order, function(self, _, value) addon.db["TooltipBuffHideType"] = self:GetValue() end)
	dropTooltipBuffHideType:SetValue(addon.db["TooltipBuffHideType"])
	dropTooltipBuffHideType:SetFullWidth(false)
	dropTooltipBuffHideType:SetWidth(150)
	groupCore:AddChild(dropTooltipBuffHideType)

	local data = {
		{ text = L["TooltipBuffHideInCombat"], var = "TooltipBuffHideInCombat" },
		{ text = L["TooltipBuffHideInDungeon"], var = "TooltipBuffHideInDungeon" },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value) addon.db[cbData.var] = value end)
		groupCore:AddChild(cbElement)
	end
end

local function addItemFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["TooltipOFF"], [2] = L["TooltipON"] })

	local dropTooltipItemHideType = addon.functions.createDropdownAce(L["TooltipItemHideType"], list, order, function(self, _, value) addon.db["TooltipItemHideType"] = self:GetValue() end)
	dropTooltipItemHideType:SetValue(addon.db["TooltipItemHideType"])
	dropTooltipItemHideType:SetFullWidth(false)
	dropTooltipItemHideType:SetWidth(150)
	groupCore:AddChild(dropTooltipItemHideType)

	local data = {
		{ text = L["TooltipItemHideInCombat"], var = "TooltipItemHideInCombat" },
		{ text = L["TooltipItemHideInDungeon"], var = "TooltipItemHideInDungeon" },
		{ text = L["TooltipShowItemID"], var = "TooltipShowItemID" },
		{ text = L["TooltipShowItemCount"], var = "TooltipShowItemCount" },
		{ text = L["TooltipShowSeperateItemCount"], var = "TooltipShowSeperateItemCount" },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value) addon.db[cbData.var] = value end)
		groupCore:AddChild(cbElement)
	end
end

local function addSpellFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["TooltipOFF"], [2] = L["TooltipON"] })

	local dropTooltipSpellHideType = addon.functions.createDropdownAce(L["TooltipSpellHideType"], list, order, function(self, _, value) addon.db["TooltipSpellHideType"] = self:GetValue() end)
	dropTooltipSpellHideType:SetValue(addon.db["TooltipSpellHideType"])
	dropTooltipSpellHideType:SetFullWidth(false)
	dropTooltipSpellHideType:SetWidth(150)
	groupCore:AddChild(dropTooltipSpellHideType)

	local data = {
		{ text = L["TooltipSpellHideInCombat"], var = "TooltipSpellHideInCombat" },
		{ text = L["TooltipSpellHideInDungeon"], var = "TooltipSpellHideInDungeon" },
		{ text = L["TooltipShowSpellID"], var = "TooltipShowSpellID" },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value) addon.db[cbData.var] = value end)
		groupCore:AddChild(cbElement)
	end
end

local function addUnitFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)
	local list, order = addon.functions.prepareListForDropdown({ [1] = L["None"], [2] = L["Enemies"], [3] = L["Friendly"], [4] = L["Both"] })

	local dropTooltipUnitHideType = addon.functions.createDropdownAce(L["TooltipUnitHideType"], list, order, function(self, _, value) addon.db["TooltipUnitHideType"] = self:GetValue() end)
	dropTooltipUnitHideType:SetValue(addon.db["TooltipUnitHideType"])
	dropTooltipUnitHideType:SetFullWidth(false)
	dropTooltipUnitHideType:SetWidth(150)
	groupCore:AddChild(dropTooltipUnitHideType)

	local data = {
		{ text = L["TooltipUnitHideInCombat"], var = "TooltipUnitHideInCombat" },
		{ text = L["TooltipUnitHideInDungeon"], var = "TooltipUnitHideInDungeon" },
		{ text = L["TooltipShowMythicScore"], var = "TooltipShowMythicScore" },
		{ text = L["TooltipShowClassColor"], var = "TooltipShowClassColor" },
		{ text = L["TooltipShowNPCID"], var = "TooltipShowNPCID" },
		-- { text = L["TooltipUnitShowHealthText"], var = "TooltipUnitShowHealthText" },
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value) addon.db[cbData.var] = value end)
		groupCore:AddChild(cbElement)
	end
end

local function addGeneralFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local list, order = addon.functions.prepareListForDropdown({ [1] = DEFAULT, [2] = L["CursorCenter"], [3] = L["CursorLeft"], [4] = L["CursorRight"] })

	local dropTooltipUnitHideType = addon.functions.createDropdownAce(L["TooltipAnchorType"], list, order, function(self, _, value)
		addon.db["TooltipAnchorType"] = self:GetValue()
		addGeneralFrame(container)
	end)
	dropTooltipUnitHideType:SetValue(addon.db["TooltipAnchorType"])
	dropTooltipUnitHideType:SetFullWidth(false)
	dropTooltipUnitHideType:SetWidth(200)
	groupCore:AddChild(dropTooltipUnitHideType)

	if addon.db["TooltipAnchorType"] > 1 then
		local sliderOffsetX = addon.functions.createSliderAce(
			L["TooltipAnchorOffsetX"] .. ": " .. addon.db["TooltipAnchorOffsetX"],
			addon.db["TooltipAnchorOffsetX"],
			-300,
			300,
			1,
			function(self, _, value2)
				addon.db["TooltipAnchorOffsetX"] = value2
				self:SetLabel(L["TooltipAnchorOffsetX"] .. ": " .. value2)
			end
		)
		groupCore:AddChild(sliderOffsetX)

		local sliderOffsetY = addon.functions.createSliderAce(
			L["TooltipAnchorOffsetY"] .. ": " .. addon.db["TooltipAnchorOffsetY"],
			addon.db["TooltipAnchorOffsetY"],
			-300,
			300,
			1,
			function(self, _, value2)
				addon.db["TooltipAnchorOffsetY"] = value2
				self:SetLabel(L["TooltipAnchorOffsetY"] .. ": " .. value2)
			end
		)
		groupCore:AddChild(sliderOffsetY)
	end
end

function addon.Tooltip.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	-- Prüfen, welche Gruppe ausgewählt wurde
	if group == "tooltip\001buff_debuff" then
		addBuffDebuffFrame(container)
	elseif group == "tooltip\001item" then
		addItemFrame(container)
	elseif group == "tooltip\001spell" then
		addSpellFrame(container)
	elseif group == "tooltip\001unit" then
		addUnitFrame(container)
	elseif group == "tooltip\001general" then
		addGeneralFrame(container)
	else
		-- local label = AceGUI:Create("Label")
		-- label:SetText("No content defined for this section.")
		-- container:AddChild(label)
	end
end
