-- luacheck: globals DefaultCompactUnitFrameSetup CompactUnitFrame_UpdateAuras
local addonName, addon = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDlg = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local defaults = { profile = {} }

addon.AceGUI = AceGUI
local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")

local LFGListFrame = _G.LFGListFrame
local GetContainerItemInfo = C_Container.GetContainerItemInfo

local EQOL = select(2, ...)
EQOL.C = {}

-- localeadditions
local headerClassInfo = L["headerClassInfo"]:format(select(1, UnitClass("player")))
local hookedATT = false -- need to hook ATT because of the way the minimap button is created

hooksecurefunc("LFGListSearchEntry_OnClick", function(s, button)
	local panel = LFGListFrame.SearchPanel
	if button ~= "RightButton" and LFGListSearchPanelUtil_CanSelectResult(s.resultID) and panel.SignUpButton:IsEnabled() then
		if panel.selectedResult ~= s.resultID then LFGListSearchPanel_SelectResult(panel, s.resultID) end
		LFGListSearchPanel_SignUp(panel)
	end
end)

local function checkBagIgnoreJunk()
	if addon.db["sellAllJunk"] then
		local counter = 0
		for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
			if C_Container.GetBagSlotFlag(bag, Enum.BagSlotFlags.ExcludeJunkSell) then counter = counter + 1 end
		end
		if counter > 0 then
			local message = string.format(L["SellJunkIgnoredBag"], counter)

			StaticPopupDialogs["SellJunkIgnoredBag"] = {
				text = message,
				button1 = "OK",
				timeout = 15,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
				OnShow = function(self) self:SetFrameStrata("TOOLTIP") end,
			}
			StaticPopup_Show("SellJunkIgnoredBag")
		end
	end
end

local function toggleGroupApplication(value)
	if value then
		-- Hide overlay and text label
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Label:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Background:Hide()
		-- Hide the 3 animated texture icons
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:Hide()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:Hide()
	else
		-- Hide overlay and text label
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Label:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Background:Show()
		-- Hide the 3 animated texture icons
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:Show()
		_G.LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:Show()
	end
end

local function skipRolecheck()
	if addon.db["groupfinderSkipRoleSelectOption"] == 1 then
		local tank, healer, dps = false, false, false
		local role = UnitGroupRolesAssigned("player")
		if role == "NONE" then role = GetSpecializationRole(GetSpecialization()) end
		if role == "TANK" then
			tank = true
		elseif role == "DAMAGER" then
			dps = true
		elseif role == "HEALER" then
			healer = true
		end
		if LFDRoleCheckPopupRoleButtonTank.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonTank.checkButton:SetChecked(tank) end
		if LFDRoleCheckPopupRoleButtonHealer.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonHealer.checkButton:SetChecked(healer) end
		if LFDRoleCheckPopupRoleButtonDPS.checkButton:IsEnabled() then LFDRoleCheckPopupRoleButtonDPS.checkButton:SetChecked(dps) end
	elseif addon.db["groupfinderSkipRoleSelectOption"] == 2 then
		if LFDQueueFrameRoleButtonTank and LFDQueueFrameRoleButtonTank:IsEnabled() then
			LFGListApplicationDialog.TankButton.CheckButton:SetChecked(LFDQueueFrameRoleButtonTank.checkButton:GetChecked())
		end
		if LFDQueueFrameRoleButtonHealer and LFDQueueFrameRoleButtonHealer:IsEnabled() then
			LFGListApplicationDialog.HealerButton.CheckButton:SetChecked(LFDQueueFrameRoleButtonHealer.checkButton:GetChecked())
		end
		if LFDQueueFrameRoleButtonDPS and LFDQueueFrameRoleButtonDPS:IsEnabled() then
			LFGListApplicationDialog.DamagerButton.CheckButton:SetChecked(LFDQueueFrameRoleButtonDPS.checkButton:GetChecked())
		end
	else
		return
	end

	LFDRoleCheckPopupAcceptButton:Enable()
	LFDRoleCheckPopupAcceptButton:Click()
end

local lfgPoint, lfgRelativeTo, lfgRelativePoint, lfgXOfs, lfgYOfs

local function toggleLFGFilterPosition()
	if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.FilterButton and LFGListFrame.SearchPanel.FilterButton.ResetButton then
		if addon.db["groupfinderMoveResetButton"] then
			LFGListFrame.SearchPanel.FilterButton.ResetButton:ClearAllPoints()
			LFGListFrame.SearchPanel.FilterButton.ResetButton:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.FilterButton, "TOPLEFT", -7, 13)
		else
			LFGListFrame.SearchPanel.FilterButton.ResetButton:ClearAllPoints()
			LFGListFrame.SearchPanel.FilterButton.ResetButton:SetPoint(lfgPoint, lfgRelativeTo, lfgRelativePoint, lfgXOfs, lfgYOfs)
		end
	end
end

LFGListApplicationDialog:HookScript("OnShow", function(self)
	if not addon.db.skipSignUpDialog then return end
	if self.SignUpButton:IsEnabled() and not IsShiftKeyDown() then self.SignUpButton:Click() end
end)

local didApplyPatch = false
local originalFunc = LFGListApplicationDialog_Show
local patchedFunc = function(self, resultID)
	if resultID then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)

		self.resultID = resultID
		self.activityID = searchResultInfo.activityID
	end
	LFGListApplicationDialog_UpdateRoles(self)
	StaticPopupSpecial_Show(self)
end

function EQOL.PersistSignUpNote()
	if addon.db.persistSignUpNote then
		-- overwrite function with patched func missing the call to ClearApplicationTextFields
		LFGListApplicationDialog_Show = patchedFunc
		didApplyPatch = true
	elseif didApplyPatch then
		-- restore previously overwritten function
		LFGListApplicationDialog_Show = originalFunc
	end
end

local function setLeaderIcon()
	for i = 1, 5 do
		if _G["CompactPartyFrameMember" .. i] and _G["CompactPartyFrameMember" .. i]:IsShown() and _G["CompactPartyFrameMember" .. i].unit then
			if UnitIsGroupLeader(_G["CompactPartyFrameMember" .. i].unit) then
				if not addon.variables.leaderFrame then
					addon.variables.leaderFrame = CreateFrame("Frame", nil, CompactPartyFrame)
					addon.variables.leaderFrame.leaderIcon = addon.variables.leaderFrame:CreateTexture(nil, "OVERLAY")
					addon.variables.leaderFrame.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
					addon.variables.leaderFrame.leaderIcon:SetSize(16, 16)
				end
				addon.variables.leaderFrame.leaderIcon:ClearAllPoints()
				addon.variables.leaderFrame.leaderIcon:SetPoint("TOPRIGHT", _G["CompactPartyFrameMember" .. i], "TOPRIGHT", 5, 6)
				return
			end
		end
	end
end

local function removeLeaderIcon()
	if addon.variables.leaderFrame then
		addon.variables.leaderFrame:SetParent(nil)
		addon.variables.leaderFrame:Hide()
		addon.variables.leaderFrame = nil
	end
end

local function GameTooltipActionButton(button)
	button:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent) -- Use default positioning
		GameTooltip.default = 1

		if self.action then
			GameTooltip:SetAction(self.action) -- Displays the action of the button (spell, item, etc.)
		else
			GameTooltip:Hide() -- Hide the tooltip if no action is assigned
		end

		GameTooltip:Show()
	end)
	button:HookScript("OnLeave", function(self) GameTooltip:Hide() end)
end

local function genericHoverOutCheck(frame, cbData)
	if frame and frame:IsVisible() then
		if not MouseIsOver(frame) then
			frame:SetAlpha(0)
			if cbData.children then
				for _, v in pairs(cbData.children) do
					v:SetAlpha(0)
				end
			end
			if cbData.hideChildren then
				for _, v in pairs(cbData.hideChildren) do
					v:Hide()
				end
			end
		else
			C_Timer.After(0.3, function() genericHoverOutCheck(frame, cbData) end)
		end
	end
end

local hookedUnitFrames = {}
local function UpdateUnitFrameMouseover(barName, cbData)
	local enable = addon.db[cbData.var]

	if enable and cbData.disableSetting then
		for i, v in pairs(cbData.disableSetting) do
			addon.db[v] = false
		end
	end

	local uf = _G[barName]

	if enable then
		if not hookedUnitFrames[uf] then
			if uf.OnEnter or uf:GetScript("OnEnter") then
				uf:HookScript("OnEnter", function(self)
					self:SetAlpha(1)
					if cbData.children then
						for _, v in pairs(cbData.children) do
							v:SetAlpha(1)
						end
					end
					if cbData.hideChildren then
						for _, v in pairs(cbData.hideChildren) do
							v:Show()
						end
					end
				end)
				hookedUnitFrames[uf] = true
			else
				uf:SetScript("OnEnter", function(self)
					self:SetAlpha(1)
					if cbData.children then
						for _, v in pairs(cbData.children) do
							v:SetAlpha(1)
						end
					end
					if cbData.hideChildren then
						for _, v in pairs(cbData.hideChildren) do
							v:Show()
						end
					end
				end)
			end
			if uf.OnLeave or uf:GetScript("OnLeave") then
				uf:HookScript("OnLeave", function(self) genericHoverOutCheck(self, cbData) end)
			else
				uf:SetScript("OnLeave", function(self) genericHoverOutCheck(self, cbData) end)
			end
			uf:SetAlpha(0)
			if cbData.children then
				for _, v in ipairs(cbData.children) do
					if cbData.revealAllChilds then
						v:HookScript("OnEnter", function(self)
							uf:SetAlpha(1)
							for _, sv in ipairs(cbData.children) do
								sv:SetAlpha(1)
							end
						end)
						v:HookScript("OnLeave", function(self) genericHoverOutCheck(uf, cbData) end)
					end
					v:SetAlpha(0)
				end
			end
			if cbData.hideChildren then
				for _, v in ipairs(cbData.hideChildren) do
					v:Hide()
				end
			end
		end
	else
		if not hookedUnitFrames[uf] then
			uf:SetScript("OnEnter", nil)
			uf:SetScript("OnLeave", nil)
		end
		uf:SetAlpha(1)
		if cbData.children then
			for _, v in pairs(cbData.children) do
				v:SetAlpha(1)
			end
		end
		if cbData.hideChildren then
			for _, v in pairs(cbData.hideChildren) do
				v:Show()
			end
		end
		if cbData.revealAllChilds then
			-- to completely remove the hookscript we need a full reload
			addon.variables.requireReload = true
		end
	end
end

local hookedButtons = {}
-- Action Bars
local function UpdateActionBarMouseover(barName, enable, variable)
	local bar = _G[barName]
	if not bar then return end

	local btnPrefix
	if barName == "MainMenuBar" then
		btnPrefix = "ActionButton"
	elseif barName == "PetActionBar" then
		btnPrefix = "PetActionButton"
	elseif barName == "StanceBar" then
		btnPrefix = "StanceButton"
	else
		btnPrefix = barName .. "Button"
	end

	if enable then
		bar:SetAlpha(0)
		-- bar:EnableMouse(true)
		bar:SetScript("OnEnter", function(self) bar:SetAlpha(1) end)
		bar:SetScript("OnLeave", function(self) bar:SetAlpha(0) end)
		for i = 1, 12 do
			local button = _G[btnPrefix .. i]
			if button and not hookedButtons[button] then
				if button.OnEnter then
					button:HookScript("OnEnter", function(self)
						if addon.db[variable] then bar:SetAlpha(1) end
					end)
					hookedButtons[button] = true
				else
					-- button:EnableMouse(true)
					button:SetScript("OnEnter", function(self) bar:SetAlpha(1) end)
				end
				if button.OnLeave then
					button:HookScript("OnLeave", function(self)
						if addon.db[variable] then bar:SetAlpha(0) end
					end)
				else
					button:EnableMouse(true)
					button:SetScript("OnLeave", function(self)
						bar:SetAlpha(0)
						GameTooltip:Hide()
					end)
				end
				if not hookedButtons[button] then GameTooltipActionButton(button) end
			end
		end
	else
		bar:SetAlpha(1)
		-- bar:EnableMouse(true)
		bar:SetScript("OnEnter", nil)
		bar:SetScript("OnLeave", nil)
		for i = 1, 12 do
			local button = _G[btnPrefix .. i]
			if button and not hookedButtons[button] then
				-- button:EnableMouse(true)
				button:SetScript("OnEnter", nil)
				button:SetScript("OnLeave", nil)
				GameTooltipActionButton(button)
			end
		end
	end
end

local doneHook = false
local inspectDone = {}
local inspectUnit = nil
local function CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement, attempts)
	attempts = attempts or 1 -- Anzahl der Versuche
	if attempts > 10 then -- Abbruch nach 5 Versuchen, um Endlosschleifen zu vermeiden
		return
	end

	for i = 1, emptySocketsCount do
		local gemName, gemLink = C_Item.GetItemGem(itemLink, i)
		element.gems[i]:SetScript("OnEnter", nil)

		if gemName then
			local icon = C_Item.GetItemIconByID(gemLink)
			element.gems[i].icon:SetTexture(icon)
			element.gems[i]:SetScript("OnEnter", function(self)
				if gemLink and addon.db["showGemsTooltipOnCharframe"] then
					local anchor = "ANCHOR_CURSOR"
					if addon.db["TooltipAnchorType"] == 3 then anchor = "ANCHOR_CURSOR_LEFT" end
					if addon.db["TooltipAnchorType"] == 4 then anchor = "ANCHOR_CURSOR_RIGHT" end
					local xOffset = addon.db["TooltipAnchorOffsetX"] or 0
					local yOffset = addon.db["TooltipAnchorOffsetY"] or 0
					GameTooltip:SetOwner(self, anchor, xOffset, yOffset)
					GameTooltip:SetHyperlink(gemLink)
					GameTooltip:Show()
				end
			end)
		else
			-- Wiederhole die Überprüfung nach einer Verzögerung, wenn der Edelstein noch nicht geladen ist
			C_Timer.After(0.1, function() CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement, attempts + 1) end)
			return -- Abbrechen, damit wir auf die nächste Überprüfung warten
		end
	end
end

local function GetUnitFromGUID(targetGUID)
	if IsInGroup() then
		for i = 1, 4 do
			local unit = "party" .. i
			if UnitGUID(unit) == targetGUID then
				return unit -- Gibt "partyN" zurück
			end
		end
	end

	if IsInRaid() then
		for i = 1, 40 do
			local unit = "raid" .. i
			if UnitGUID(unit) == targetGUID then
				return unit -- Gibt "raidN" zurück
			end
		end
	end

	return nil
end

local itemCount = 0
local ilvlSum = 0
local function removeInspectElements()
	if nil == InspectPaperDollFrame then return end
	itemCount = 0
	ilvlSum = 0
	if InspectPaperDollFrame.ilvl then InspectPaperDollFrame.ilvl:SetText("") end
	local itemSlotsInspectList = {
		[1] = InspectHeadSlot,
		[2] = InspectNeckSlot,
		[3] = InspectShoulderSlot,
		[15] = InspectBackSlot,
		[5] = InspectChestSlot,
		[9] = InspectWristSlot,
		[10] = InspectHandsSlot,
		[6] = InspectWaistSlot,
		[7] = InspectLegsSlot,
		[8] = InspectFeetSlot,
		[11] = InspectFinger0Slot,
		[12] = InspectFinger1Slot,
		[13] = InspectTrinket0Slot,
		[14] = InspectTrinket1Slot,
		[16] = InspectMainHandSlot,
		[17] = InspectSecondaryHandSlot,
	}
	for key, element in pairs(itemSlotsInspectList) do
		if element.ilvl then element.ilvl:SetFormattedText("") end
		if element.ilvlBackground then element.ilvlBackground:Hide() end
		if element.enchant then element.enchant:SetText("") end
		if element.borderGradient then element.borderGradient:Hide() end
		if element.gems and #element.gems > 0 then
			for i = 1, #element.gems do
				element.gems[i]:UnregisterAllEvents()
				element.gems[i]:SetScript("OnUpdate", nil)
				element.gems[i]:Hide()
			end
		end
	end
	collectgarbage("collect")
end

local function onInspect(arg1)
	if nil == InspectFrame then return end
	local unit = InspectFrame.unit
	if nil == unit then return end

	if UnitGUID(InspectFrame.unit) ~= arg1 then return end

	local pdElement = InspectPaperDollFrame
	if not doneHook then
		doneHook = true
		InspectFrame:HookScript("OnHide", function(self)
			inspectDone = {}
			removeInspectElements()
		end)
	end
	if inspectUnit ~= InspectFrame.unit then
		inspectUnit = InspectFrame.unit
		inspectDone = {}
	end
	if not addon.db["showIlvlOnCharframe"] and pdElement.ilvl then pdElement.ilvl:SetText("") end
	if not pdElement.ilvl and addon.db["showIlvlOnCharframe"] then
		pdElement.ilvlBackground = pdElement:CreateTexture(nil, "BACKGROUND")
		pdElement.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
		pdElement.ilvlBackground:SetPoint("TOPRIGHT", pdElement, "TOPRIGHT", -2, -28)
		pdElement.ilvlBackground:SetSize(20, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

		pdElement.ilvl = pdElement:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		pdElement.ilvl:SetPoint("TOPRIGHT", pdElement.ilvlBackground, "TOPRIGHT", -1, -1) -- Position des Textes im Zentrum des Hintergrunds
		pdElement.ilvl:SetFont(addon.variables.defaultFont, 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

		pdElement.ilvl:SetFormattedText("")
		pdElement.ilvl:SetTextColor(1, 1, 1, 1)

		local textWidth = pdElement.ilvl:GetStringWidth()
		pdElement.ilvlBackground:SetSize(textWidth + 6, pdElement.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit
	end
	local itemSlotsInspectList = {
		[1] = InspectHeadSlot,
		[2] = InspectNeckSlot,
		[3] = InspectShoulderSlot,
		[15] = InspectBackSlot,
		[5] = InspectChestSlot,
		[9] = InspectWristSlot,
		[10] = InspectHandsSlot,
		[6] = InspectWaistSlot,
		[7] = InspectLegsSlot,
		[8] = InspectFeetSlot,
		[11] = InspectFinger0Slot,
		[12] = InspectFinger1Slot,
		[13] = InspectTrinket0Slot,
		[14] = InspectTrinket1Slot,
		[16] = InspectMainHandSlot,
		[17] = InspectSecondaryHandSlot,
	}

	for key, element in pairs(itemSlotsInspectList) do
		if nil == inspectDone[key] then
			if element.ilvl then element.ilvl:SetFormattedText("") end
			if element.ilvlBackground then element.ilvlBackground:Hide() end
			if element.enchant then element.enchant:SetText("") end
			local itemLink = GetInventoryItemLink(unit, key)
			if itemLink then
				local eItem = Item:CreateFromItemLink(itemLink)
				if eItem and not eItem:IsItemEmpty() then
					eItem:ContinueOnItemLoad(function()
						inspectDone[key] = true
						if addon.db["showGemsOnCharframe"] then
							local hasSockets = false
							local emptySocketsCount = 0
							local itemStats = C_Item.GetItemStats(itemLink)
							for statName, statValue in pairs(itemStats) do
								if (statName:find("EMPTY_SOCKET") or statName:find("empty_socket")) and addon.variables.allowedSockets[statName] then
									hasSockets = true
									emptySocketsCount = emptySocketsCount + statValue
								end
							end

							if hasSockets then
								if element.gems and #element.gems > emptySocketsCount then
									for i = emptySocketsCount + 1, #element.gems do
										element.gems[i]:UnregisterAllEvents()
										element.gems[i]:SetScript("OnUpdate", nil)
										element.gems[i]:Hide()
									end
								end
								if not element.gems then element.gems = {} end
								for i = 1, emptySocketsCount do
									if not element.gems[i] then
										element.gems[i] = CreateFrame("Frame", nil, pdElement)
										element.gems[i]:SetSize(16, 16) -- Setze die Größe des Icons
										if addon.variables.itemSlotSide[key] == 0 then
											element.gems[i]:SetPoint("TOPLEFT", element, "TOPRIGHT", 5 + (i - 1) * 16, -1) -- Verschiebe jedes Icon um 20px
										elseif addon.variables.itemSlotSide[key] == 1 then
											element.gems[i]:SetPoint("TOPRIGHT", element, "TOPLEFT", -5 - (i - 1) * 16, -1)
										else
											element.gems[i]:SetPoint("BOTTOM", element, "TOPLEFT", -1, 5 + (i - 1) * 16)
										end

										element.gems[i]:SetFrameStrata("DIALOG")
										element.gems[i]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

										element.gems[i].icon = element.gems[i]:CreateTexture(nil, "OVERLAY")
										element.gems[i].icon:SetAllPoints(element.gems[i])
									end
									element.gems[i].icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic") -- Setze die erhaltene Textur

									element.gems[i]:Show()
								end
								CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement)
							else
								if element.gems then
									for i = 1, #element.gems do
										element.gems[i]:UnregisterAllEvents()
										element.gems[i]:SetScript("OnUpdate", nil)
										element.gems[i]:Hide()
									end
								end
							end
						else
							if element.gems and #element.gems > 0 then
								for i = 1, #element.gems do
									element.gems[i]:UnregisterAllEvents()
									element.gems[i]:SetScript("OnUpdate", nil)
									element.gems[i]:Hide()
								end
							end
						end

						if addon.db["showIlvlOnCharframe"] then
							itemCount = itemCount + 1
							if not element.ilvlBackground then
								element.ilvlBackground = element:CreateTexture(nil, "BACKGROUND")
								element.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
								element.ilvlBackground:SetPoint("TOPRIGHT", element, "TOPRIGHT", 1, 1)
								element.ilvlBackground:SetSize(30, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

								-- Text für das Item-Level
								element.ilvl = element:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
								element.ilvl:SetPoint("TOPRIGHT", element.ilvlBackground, "TOPRIGHT", -1, -2) -- Position des Textes im Zentrum des Hintergrunds
								element.ilvl:SetFont(addon.variables.defaultFont, 14, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
							end

							local color = eItem:GetItemQualityColor()
							local itemLevelText = eItem:GetCurrentItemLevel()

							-- Getting real ilvl from tooltip - Heirlooms sometimes are wrong so use tooltip information instead
							for i, v in pairs(C_TooltipInfo.GetHyperlink(itemLink).lines) do
								if v.type == 41 then
									local num = v.leftText:match(addon.variables.itemLevelPattern)
									if num then itemLevelText = tonumber(num) end
								end
							end

							ilvlSum = ilvlSum + itemLevelText
							element.ilvl:SetFormattedText(itemLevelText)
							element.ilvl:SetTextColor(color.r, color.g, color.b, 1)

							local textWidth = element.ilvl:GetStringWidth()
							element.ilvlBackground:SetSize(textWidth + 6, element.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit
						end
						if addon.db["showEnchantOnCharframe"] then
							if not element.enchant then
								element.enchant = element:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
								if addon.variables.itemSlotSide[key] == 0 then
									element.enchant:SetPoint("BOTTOMLEFT", element, "BOTTOMRIGHT", 2, 1)
								elseif addon.variables.itemSlotSide[key] == 2 then
									element.enchant:SetPoint("TOPLEFT", element, "TOPRIGHT", 2, -1)
								else
									element.enchant:SetPoint("BOTTOMRIGHT", element, "BOTTOMLEFT", -2, 1)
								end
								if addon.variables.shouldEnchanted[key] or addon.variables.shouldEnchantedChecks[key] then
									element.borderGradient = element:CreateTexture(nil, "ARTWORK")
									element.borderGradient:SetPoint("TOPLEFT", element, "TOPLEFT", -2, 2)
									element.borderGradient:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 2, -2)
									element.borderGradient:SetColorTexture(1, 0, 0, 0.6) -- Grundfarbe Rot
									element.borderGradient:SetGradient("VERTICAL", CreateColor(1, 0, 0, 1), CreateColor(1, 0.3, 0.3, 0.5))
									element.borderGradient:Hide()
								end
								element.enchant:SetFont(addon.variables.defaultFont, 12, "OUTLINE")
							end
							if element.borderGradient then
								local data = C_TooltipInfo.GetHyperlink(itemLink)
								local foundEnchant = false
								local foundIcon = nil
								for i, v in pairs(data.lines) do
									if v.type == 15 then
										foundEnchant = true
										local r, g, b = v.leftColor:GetRGB()
										local colorHex = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)

										local text = strmatch(gsub(gsub(gsub(v.leftText, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1"), "[&+] ?", ""), addon.variables.enchantString)
										local icons = {}
										v.leftText:gsub("(|A.-|a)", function(iconString) table.insert(icons, iconString) end)
										if #icons > 0 then foundIcon = icons[1] end
										foundEnchant = true
										local enchantText = text:gsub("(%d+)", "%1")
										enchantText = enchantText:gsub("(%a%a%a)%a+", "%1")
										enchantText = enchantText:gsub("%%", "%%%%")
										if foundIcon then enchantText = enchantText .. foundIcon end
										element.enchant:SetFormattedText(colorHex .. enchantText .. "|r")
									end
								end

								if foundEnchant == false and UnitLevel(inspectUnit) == addon.variables.maxLevel then
									element.enchant:SetText("")
									if
										nil == addon.variables.shouldEnchantedChecks[key]
										or (nil ~= addon.variables.shouldEnchantedChecks[key] and addon.variables.shouldEnchantedChecks[key].func(eItem:GetCurrentItemLevel()))
									then
										if key == 17 then
											local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
											if addon.variables.allowedEnchantTypesForOffhand[itemEquipLoc] then
												element.borderGradient:Show()
												element.enchant:SetFormattedText(("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
											end
										else
											element.borderGradient:Show()
											element.enchant:SetFormattedText(("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
										end
									end
								end
							end
						else
							if element.borderGradient then element.borderGradient:Hide() end
							if element.enchant then element.enchant:SetText("") end
						end
					end)
				end
			end
		end
	end
	if addon.db["showIlvlOnCharframe"] and ilvlSum > 0 and itemCount > 0 then pdElement.ilvl:SetText("" .. (math.floor((ilvlSum / itemCount) * 100 + 0.5) / 100)) end
end

local function setIlvlText(element, slot)
	-- Hide all gemslots
	if element then
		if element.gems then
			for i = 1, 3 do
				if element.gems[i] then
					element.gems[i]:Hide()
					element.gems[i].icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
					element.gems[i]:SetScript("OnEnter", nil)
				end
			end
		end

		if element.borderGradient then element.borderGradient:Hide() end
		if addon.db["showGemsOnCharframe"] == false and addon.db["showIlvlOnCharframe"] == false and addon.db["showEnchantOnCharframe"] == false then
			element.ilvl:SetFormattedText("")
			element.enchant:SetText("")
			element.ilvlBackground:Hide()
			return
		end

		local eItem = Item:CreateFromEquipmentSlot(slot)
		if eItem and not eItem:IsItemEmpty() then
			eItem:ContinueOnItemLoad(function()
				local link = eItem:GetItemLink()
				local _, itemID, enchantID = string.match(link, "item:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)")
				if addon.db["showGemsOnCharframe"] then
					local hasSockets = false
					local emptySocketsCount = 0
					local itemStats = C_Item.GetItemStats(link)
					for statName, statValue in pairs(itemStats) do
						if (statName:find("EMPTY_SOCKET") or statName:find("empty_socket")) and addon.variables.allowedSockets[statName] then
							hasSockets = true
							emptySocketsCount = emptySocketsCount + statValue
						end
					end

					if hasSockets then
						for i = 1, emptySocketsCount do
							element.gems[i]:Show()
							local gemName, gemLink = C_Item.GetItemGem(link, i)
							if gemName then
								local icon = C_Item.GetItemIconByID(gemLink)
								element.gems[i].icon:SetTexture(icon)
								element.gems[i]:SetScript("OnEnter", function(self)
									if gemLink and addon.db["showGemsTooltipOnCharframe"] then
										local anchor = "ANCHOR_CURSOR"
										if addon.db["TooltipAnchorType"] == 3 then anchor = "ANCHOR_CURSOR_LEFT" end
										if addon.db["TooltipAnchorType"] == 4 then anchor = "ANCHOR_CURSOR_RIGHT" end
										local xOffset = addon.db["TooltipAnchorOffsetX"] or 0
										local yOffset = addon.db["TooltipAnchorOffsetY"] or 0
										GameTooltip:SetOwner(self, anchor, xOffset, yOffset)
										GameTooltip:SetHyperlink(gemLink)
										GameTooltip:Show()
									end
								end)
								emptySocketsCount = emptySocketsCount - 1
							end
						end
					end
				end

				if addon.db["showIlvlOnCharframe"] then
					local color = eItem:GetItemQualityColor()
					local itemLevelText = eItem:GetCurrentItemLevel()

					element.ilvl:SetFormattedText(itemLevelText)
					element.ilvl:SetTextColor(color.r, color.g, color.b, 1)

					local textWidth = element.ilvl:GetStringWidth()
					element.ilvlBackground:SetSize(textWidth + 6, element.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit
				else
					element.ilvl:SetFormattedText("")
					element.ilvlBackground:Hide()
				end

				if addon.db["showEnchantOnCharframe"] and element.borderGradient then
					local data = C_TooltipInfo.GetHyperlink(link)

					local foundEnchant = false
					local foundIcon = nil
					for i, v in pairs(data.lines) do
						if v.type == 15 then
							foundEnchant = true
							local r, g, b = v.leftColor:GetRGB()
							local colorHex = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)

							local text = strmatch(gsub(gsub(gsub(v.leftText, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1"), "[&+] ?", ""), addon.variables.enchantString)
							local icons = {}
							v.leftText:gsub("(|A.-|a)", function(iconString) table.insert(icons, iconString) end)
							if #icons > 0 then foundIcon = icons[1] end
							foundEnchant = true
							local enchantText = text:gsub("(%d+)", "%1")
							enchantText = enchantText:gsub("(%a%a%a)%a+", "%1")
							enchantText = enchantText:gsub("%%", "%%%%")
							if foundIcon then enchantText = enchantText .. foundIcon end
							element.enchant:SetFormattedText(colorHex .. enchantText .. "|r")
						end
					end

					if foundEnchant == false and UnitLevel("player") == addon.variables.maxLevel then
						element.enchant:SetText("")
						if
							nil == addon.variables.shouldEnchantedChecks[slot]
							or (nil ~= addon.variables.shouldEnchantedChecks[slot] and addon.variables.shouldEnchantedChecks[slot].func(eItem:GetCurrentItemLevel()))
						then
							if slot == 17 then
								local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(link)
								if addon.variables.allowedEnchantTypesForOffhand[itemEquipLoc] then
									element.borderGradient:Show()
									element.enchant:SetFormattedText(("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
								end
							else
								element.borderGradient:Show()
								element.enchant:SetFormattedText(("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
							end
						end
					end
				else
					element.enchant:SetText("")
				end
			end)
		else
			element.ilvl:SetFormattedText("")
			element.ilvlBackground:Hide()
			element.enchant:SetText("")
			if element.borderGradient then element.borderGradient:Hide() end
		end
	end
end

local function IsIndestructible(link)
	local itemParts = { strsplit(":", link) }
	for i = 13, #itemParts do
		local bonusID = tonumber(itemParts[i])
		if bonusID and bonusID == 43 then return true end
	end
	return false
end

local function calculateDurability()
	local maxDur = 0 -- combined value of durability
	local currentDura = 0
	local critDura = 0 -- counter of items under 50%

	for key, _ in pairs(addon.variables.itemSlots) do
		local eItem = Item:CreateFromEquipmentSlot(key)
		if eItem and not eItem:IsItemEmpty() then
			eItem:ContinueOnItemLoad(function()
				local link = eItem:GetItemLink()
				if link then
					if IsIndestructible(link) == false then
						local current, maximum = GetInventoryItemDurability(key)
						if nil ~= current then
							local fDur = tonumber(string.format("%." .. 0 .. "f", current * 100 / maximum))
							maxDur = maxDur + maximum
							currentDura = currentDura + current
							if fDur < 50 then critDura = critDura + 1 end
						end
					end
				end
			end)
		end
	end

	-- When we only have full durable items so fake the numbers to show 100%
	if maxDur == 0 and currentDura == 0 then
		maxDur = 100
		currentDura = 100
	end

	local durValue = currentDura / maxDur * 100

	addon.variables.durabilityCount = tonumber(string.format("%." .. 0 .. "f", durValue)) .. "%"
	addon.general.durabilityIconFrame.count:SetText(addon.variables.durabilityCount)

	if tonumber(string.format("%." .. 0 .. "f", durValue)) > 80 then
		addon.general.durabilityIconFrame.count:SetTextColor(1, 1, 1)
	elseif tonumber(string.format("%." .. 0 .. "f", durValue)) > 50 then
		addon.general.durabilityIconFrame.count:SetTextColor(1, 1, 0)
	else
		addon.general.durabilityIconFrame.count:SetTextColor(1, 0, 0)
	end
end

local function UpdateItemLevel()
	local statFrame = CharacterStatsPane.ItemLevelFrame
	if statFrame and statFrame.Value then
		local avgItemLevel, equippedItemLevel = GetAverageItemLevel()
		local customItemLevel = equippedItemLevel
		statFrame.Value:SetText(string.format("%.2f", customItemLevel))
	end
end

hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unit) UpdateItemLevel() end)

local function setCharFrame()
	UpdateItemLevel()
	if not addon.general.iconFrame then addon.functions.catalystChecks() end
	if addon.db["showCatalystChargesOnCharframe"] and addon.variables.catalystID and addon.general.iconFrame then
		local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
		addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
	end
	if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	for key, value in pairs(addon.variables.itemSlots) do
		setIlvlText(value, key)
	end
end

local function addChatFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			var = "chatFrameFadeEnabled",
			text = L["chatFrameFadeEnabled"],
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["chatFrameFadeEnabled"] = value
				if ChatFrame1 then ChatFrame1:SetFading(value) end
				container:ReleaseChildren()
				addChatFrame(container)
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["chatFrameFadeEnabled"] then
		local sliderTimeVisible = addon.functions.createSliderAce(
			L["chatFrameFadeTimeVisibleText"] .. ": " .. addon.db["chatFrameFadeTimeVisible"] .. "s",
			addon.db["chatFrameFadeTimeVisible"],
			1,
			300,
			1,
			function(self, _, value2)
				addon.db["chatFrameFadeTimeVisible"] = value2
				if ChatFrame1 then ChatFrame1:SetTimeVisible(value2) end
				self:SetLabel(L["chatFrameFadeTimeVisibleText"] .. ": " .. value2 .. "s")
			end
		)
		groupCore:AddChild(sliderTimeVisible)

		groupCore:AddChild(addon.functions.createSpacerAce())

		local sliderFadeDuration = addon.functions.createSliderAce(
			L["chatFrameFadeDurationText"] .. ": " .. addon.db["chatFrameFadeDuration"] .. "s",
			addon.db["chatFrameFadeDuration"],
			1,
			60,
			1,
			function(self, _, value2)
				addon.db["chatFrameFadeDuration"] = value2
				if ChatFrame1 then ChatFrame1:SetFadeDuration(value2) end
				self:SetLabel(L["chatFrameFadeDurationText"] .. ": " .. value2 .. "s")
			end
		)
		groupCore:AddChild(sliderFadeDuration)
	end

	local groupCoreSetting = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCoreSetting)
	data = {
		{
			var = "enableChatIM",
			text = L["enableChatIM"],
			type = "CheckBox",
			desc = L["enableChatIMDesc"],
			func = function(self, _, value)
				addon.db["enableChatIM"] = value
				if addon.ChatIM and addon.ChatIM.SetEnabled then addon.ChatIM:SetEnabled(value) end
				if not value then addon.variables.requireReload = true end
				container:ReleaseChildren()
				addChatFrame(container)
			end,
		},
	}

	if addon.db["enableChatIM"] then
		table.insert(data, {
			var = "enableChatIMFade",
			text = L["enableChatIMFade"],
			type = "CheckBox",
			desc = L["enableChatIMFadeDesc"],
			func = function(self, _, value)
				addon.db["enableChatIMFade"] = value
				if addon.ChatIM and addon.ChatIM.SetEnabled then addon.ChatIM:UpdateAlpha() end
				container:ReleaseChildren()
				addChatFrame(container)
			end,
		})
		table.insert(data, {
			var = "enableChatIMRaiderIO",
			text = L["enableChatIMRaiderIO"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["enableChatIMRaiderIO"] = value end,
		})
		table.insert(data, {
			var = "enableChatIMWCL",
			text = L["enableChatIMWCL"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["enableChatIMWCL"] = value end,
		})
		table.insert(data, {
			var = "chatIMUseCustomSound",
			text = L["enableChatIMCustomSound"],
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["chatIMUseCustomSound"] = value
				container:ReleaseChildren()
				addChatFrame(container)
			end,
		})
		table.insert(data, {
			var = "chatIMHideInCombat",
			text = L["chatIMHideInCombat"],
			type = "CheckBox",
			desc = L["chatIMHideInCombatDesc"],
			func = function(self, _, value)
				addon.db["chatIMHideInCombat"] = value
				if addon.ChatIM and addon.ChatIM.SetEnabled then addon.ChatIM:SetEnabled(true) end
			end,
		})
		table.insert(data, {
			var = "chatIMUseAnimation",
			text = L["chatIMUseAnimation"],
			type = "CheckBox",
			desc = L["chatIMUseAnimationDesc"],
			func = function(self, _, value) addon.db["chatIMUseAnimation"] = value end,
		})
	end
	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCoreSetting:AddChild(cbElement)
	end

	if addon.db["enableChatIM"] then
		groupCoreSetting:AddChild(addon.functions.createSpacerAce())

		if addon.db["chatIMUseCustomSound"] then
			local soundList = {}
			for name in pairs(addon.ChatIM.availableSounds or {}) do
				soundList[name] = name
			end
			local list, order = addon.functions.prepareListForDropdown(soundList)
			local dropSound = addon.functions.createDropdownAce(L["ChatIMCustomSound"], list, order, function(self, _, val)
				addon.db["chatIMCustomSoundFile"] = val
				self:SetValue(val)
				local file = addon.ChatIM.availableSounds and addon.ChatIM.availableSounds[val]
				if file then PlaySoundFile(file, "Master") end
			end)
			dropSound:SetValue(addon.db["chatIMCustomSoundFile"])
			groupCoreSetting:AddChild(dropSound)
			groupCoreSetting:AddChild(addon.functions.createSpacerAce())
		end

		local sliderHistory = addon.functions.createSliderAce(L["ChatIMHistoryLimit"] .. ": " .. addon.db["chatIMMaxHistory"], addon.db["chatIMMaxHistory"], 0, 1000, 1, function(self, _, value)
			addon.db["chatIMMaxHistory"] = value
			if addon.ChatIM and addon.ChatIM.SetMaxHistoryLines then addon.ChatIM:SetMaxHistoryLines(value) end
			self:SetLabel(L["ChatIMHistoryLimit"] .. ": " .. value)
		end)
		groupCoreSetting:AddChild(sliderHistory)

		local historyList = {}
		for name in pairs(EnhanceQoL_IMHistory or {}) do
			historyList[name] = name
		end
		local list, order = addon.functions.prepareListForDropdown(historyList)
		local dropHistory = addon.functions.createDropdownAce(L["ChatIMHistoryPlayer"], list, order, function(self, _, val) self:SetValue(val) end)
		local btnDelete = addon.functions.createButtonAce(L["ChatIMHistoryDelete"], 140, function()
			local target = dropHistory:GetValue()
			if not target then return end
			StaticPopupDialogs["EQOL_DELETE_IM_HISTORY"] = StaticPopupDialogs["EQOL_DELETE_IM_HISTORY"]
				or {
					text = L["ChatIMHistoryDeleteConfirm"],
					button1 = YES,
					button2 = CANCEL,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
			StaticPopupDialogs["EQOL_DELETE_IM_HISTORY"].OnAccept = function()
				EnhanceQoL_IMHistory[target] = nil
				if addon.ChatIM and addon.ChatIM.history then addon.ChatIM.history[target] = nil end
				container:ReleaseChildren()
				addChatFrame(container)
			end
			StaticPopup_Show("EQOL_DELETE_IM_HISTORY", target)
		end)

		local btnClear = addon.functions.createButtonAce(L["ChatIMHistoryClearAll"], 140, function()
			StaticPopupDialogs["EQOL_CLEAR_IM_HISTORY"] = StaticPopupDialogs["EQOL_CLEAR_IM_HISTORY"]
				or {
					text = L["ChatIMHistoryClearConfirm"],
					button1 = YES,
					button2 = CANCEL,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
			StaticPopupDialogs["EQOL_CLEAR_IM_HISTORY"].OnAccept = function()
				wipe(EnhanceQoL_IMHistory)
				if addon.ChatIM then addon.ChatIM.history = EnhanceQoL_IMHistory end
				container:ReleaseChildren()
				addChatFrame(container)
			end
			StaticPopup_Show("EQOL_CLEAR_IM_HISTORY")
		end)

		groupCoreSetting:AddChild(dropHistory)
		groupCoreSetting:AddChild(btnDelete)
		groupCoreSetting:AddChild(btnClear)

		groupCoreSetting:AddChild(addon.functions.createSpacerAce())

		local hint = AceGUI:Create("Label")
		hint:SetFullWidth(true)
		hint:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
		hint:SetText("|cffffd700" .. L["RightClickCloseTab"] .. "|r ")
		groupCoreSetting:AddChild(hint)
	end
	scroll:DoLayout()
end

local function addMinimapFrame(container)
	local data = {
		{
			parent = "",
			var = "enableLootspecQuickswitch",
			type = "CheckBox",
			desc = L["enableLootspecQuickswitchDesc"],
			callback = function(self, _, value)
				addon.db["enableLootspecQuickswitch"] = value
				if value then
					addon.functions.createLootspecFrame()
				else
					addon.functions.removeLootspecframe()
				end
			end,
		},
		{
			parent = "",
			var = "enableMinimapButtonBin",
			type = "CheckBox",
			desc = L["enableMinimapButtonBinDesc"],
			callback = function(self, _, value)
				addon.db["enableMinimapButtonBin"] = value
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		},
		{
			parent = "",
			var = "enableSquareMinimap",
			text = L["enableSquareMinimap"],
			desc = L["enableSquareMinimapDesc"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["enableSquareMinimap"] = value
				addon.variables.requireReload = true
				addon.functions.checkReloadFrame()
			end,
		},
	}

	if addon.db["enableMinimapButtonBin"] then
		table.insert(data, {
			parent = "",
			var = "useMinimapButtonBinIcon",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["useMinimapButtonBinIcon"] = value
				if value then addon.db["useMinimapButtonBinMouseover"] = false end
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		})
		table.insert(data, {
			parent = "",
			var = "useMinimapButtonBinMouseover",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["useMinimapButtonBinMouseover"] = value
				if value then addon.db["useMinimapButtonBinIcon"] = false end
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		})
		if not addon.db["useMinimapButtonBinIcon"] then
			table.insert(data, {
				parent = "",
				var = "lockMinimapButtonBin",
				type = "CheckBox",
				callback = function(self, _, value)
					addon.db["lockMinimapButtonBin"] = value
					addon.functions.toggleButtonSink()
				end,
			})
		end

		for i, _ in pairs(addon.variables.bagButtonState) do
			table.insert(data, {
				parent = MINIMAP_LABEL .. ": " .. L["ignoreMinimapSinkHole"],
				var = "ignoreMinimapButtonBin_" .. i,
				text = i,
				type = "CheckBox",
				value = addon.db["ignoreMinimapButtonBin_" .. i] or false,
				callback = function(self, _, value)
					addon.db["ignoreMinimapButtonBin_" .. i] = value
					addon.functions.LayoutButtons()
				end,
			})
		end
	end
	for id in pairs(addon.variables.landingPageType) do
		local actValue = false
		local page = addon.variables.landingPageType[id]
		if addon.db["hiddenLandingPages"][id] then actValue = true end

		table.insert(data, {
			parent = L["landingPageHide"],
			var = "landingPageType_" .. id,
			type = "CheckBox",
			value = actValue,
			id = id,
			text = page.checkbox,
			title = page.title,
			callback = function(self, _, value)
				addon.db["hiddenLandingPages"][id] = value
				addon.functions.toggleLandingPageButton(page.title, value)
			end,
		})
	end

	addon.functions.createWrapperData(data, container, L)
end

local function addUnitFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupHitIndicator = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupHitIndicator)
	groupHitIndicator:SetTitle(COMBAT_TEXT_LABEL)

	local data = {
		{
			var = "hideHitIndicatorPlayer",
			text = L["hideHitIndicatorPlayer"],
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["hideHitIndicatorPlayer"] = value
				if value then
					PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide()
				else
					PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Show()
				end
			end,
		},
		{
			text = L["hideHitIndicatorPet"],
			var = "hideHitIndicatorPet",
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["hideHitIndicatorPet"] = value
				if value and PetHitIndicator then PetHitIndicator:Hide() end
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupHitIndicator:AddChild(cbElement)
	end

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local labelHeadline = addon.functions.createLabelAce("|cffffd700" .. L["UnitFrameHideExplain"] .. "|r", nil, nil, 14)
	labelHeadline:SetFullWidth(true)
	groupCore:AddChild(labelHeadline)

	groupCore:AddChild(addon.functions.createSpacerAce())

	for _, cbData in ipairs(addon.variables.unitFrameNames) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value)
			if cbData.var and cbData.name then
				addon.db[cbData.var] = value
				UpdateUnitFrameMouseover(cbData.name, cbData)
			end
		end, desc)
		groupCore:AddChild(cbElement)
	end
end

local function addDynamicFlightFrame(container)
	local data = {
		{
			parent = "",
			var = "hideDynamicFlightBar",
			text = L["hideDynamicFlightBar"]:format(DYNAMIC_FLIGHT),
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideDynamicFlightBar"] = value
				addon.functions.toggleDynamicFlightBar(addon.db["hideDynamicFlightBar"])
			end,
		},
	}

	addon.functions.createWrapperData(data, container, L)
end

local function addAuctionHouseFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["persistAuctionHouseFilter"],
			var = "persistAuctionHouseFilter",
			func = function(self, _, value) addon.db["persistAuctionHouseFilter"] = value end,
		},
	}
	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end
end

local function addActionBarFrame(container, d)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local labelHeadline = addon.functions.createLabelAce(
		"|cffffd700"
			.. L["ActionbarHideExplain"]:format(_G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"], _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"], _G["HUD_EDIT_MODE_MENU"])
			.. "|r",
		nil,
		nil,
		14
	)
	labelHeadline:SetFullWidth(true)
	groupCore:AddChild(labelHeadline)

	groupCore:AddChild(addon.functions.createSpacerAce())

	for _, cbData in ipairs(addon.variables.actionBarNames) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value)
			if cbData.var and cbData.name then
				addon.db[cbData.var] = value
				UpdateActionBarMouseover(cbData.name, value, cbData.var)
			end
		end, desc)
		groupCore:AddChild(cbElement)
	end
end

local function addDungeonFrame(container, d)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["groupfinderAppText"],
			var = "groupfinderAppText",
			func = function(self, _, value)
				addon.db["groupfinderAppText"] = value
				toggleGroupApplication(value)
			end,
		},
		{
			text = L["groupfinderMoveResetButton"],
			var = "groupfinderMoveResetButton",
			func = function(self, _, value)
				addon.db["groupfinderMoveResetButton"] = value
				toggleLFGFilterPosition()
			end,
		},
		{
			text = L["groupfinderSkipRoleSelect"],
			var = "groupfinderSkipRoleSelect",
			func = function(self, _, value)
				addon.db["groupfinderSkipRoleSelect"] = value
				container:ReleaseChildren()
				addDungeonFrame(container)
			end,
			desc = L["interruptWithShift"],
		},
		{
			parent = DELVES_LABEL,
			var = "autoChooseDelvePower",
			text = L["autoChooseDelvePower"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["autoChooseDelvePower"] = value end,
		},
		{
			parent = DUNGEONS,
			var = "persistSignUpNote",
			text = L["Persist LFG signup note"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["persistSignUpNote"] = value end,
		},
		{
			parent = DUNGEONS,
			var = "skipSignUpDialog",
			text = L["Quick signup"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["skipSignUpDialog"] = value end,
		},
		{
			parent = DUNGEONS,
			var = "lfgSortByRio",
			text = L["lfgSortByRio"],
			type = "CheckBox",
			func = function(self, _, value) addon.db["lfgSortByRio"] = value end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["groupfinderSkipRoleSelect"] then
		local list, order = addon.functions.prepareListForDropdown({ [1] = L["groupfinderSkipRolecheckUseSpec"], [2] = L["groupfinderSkipRolecheckUseLFD"] }, true)

		local dropRoleSelect = addon.functions.createDropdownAce("", list, order, function(self, _, value) addon.db["groupfinderSkipRoleSelectOption"] = value end)
		dropRoleSelect:SetValue(addon.db["groupfinderSkipRoleSelectOption"])

		local groupSkipRole = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupSkipRole)
		groupSkipRole:SetTitle(L["groupfinderSkipRolecheckHeadline"])
		groupSkipRole:AddChild(dropRoleSelect)
	end
end

local function addTotemHideToggle(dbValue, data)
	table.insert(data, {
		parent = headerClassInfo,
		var = dbValue,
		text = L["shaman_HideTotem"],
		type = "CheckBox",
		callback = function(self, _, value)
			addon.db[dbValue] = value
			if value then
				TotemFrame:Hide()
			else
				TotemFrame:Show()
			end
		end,
	})
end

local function addCVarFrame(container, d)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = addon.variables.cvarOptions

	local cvarList = {}
	for key, optionData in pairs(data) do
		table.insert(cvarList, {
			key = key,
			description = optionData.description,
			trueValue = optionData.trueValue,
			falseValue = optionData.falseValue,
			register = optionData.register or nil,
		})
	end

	table.sort(cvarList, function(a, b) return (a.description or "") < (b.description or "") end)

	for _, entry in ipairs(cvarList) do
		local cvarKey = entry.key
		local cvarDesc = entry.description
		local cvarTrue = entry.trueValue
		local cvarFalse = entry.falseValue

		if entry.register and nil == GetCVar(cvarKey) then C_CVar.RegisterCVar(cvarKey, cvarTrue) end

		local actValue = (GetCVar(cvarKey) == cvarTrue)

		local cbElement = addon.functions.createCheckboxAce(cvarDesc, actValue, function(self, _, value)
			addon.variables.requireReload = true
			if value then
				SetCVar(cvarKey, cvarTrue)
			else
				SetCVar(cvarKey, cvarFalse)
			end
		end)
		cbElement.trueValue = cvarTrue
		cbElement.falseValue = cvarFalse

		groupCore:AddChild(cbElement)
	end
end

local function addPartyFrame(container)
	local data = {
		{
			parent = "",
			var = "autoAcceptGroupInvite",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["autoAcceptGroupInvite"] = value
				container:ReleaseChildren()
				addPartyFrame(container)
			end,
		},
		{
			parent = "",
			var = "showLeaderIconRaidFrame",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showLeaderIconRaidFrame"] = value
				if value == true then
					setLeaderIcon()
				else
					removeLeaderIcon()
				end
			end,
		},

		{
			parent = "",
			var = "hideRaidFrameBuffs",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideRaidFrameBuffs"] = value
				addon.functions.updateRaidFrameBuffs()
				addon.variables.requireReload = true
			end,
		},
		{
			parent = "",
			var = "showPartyFrameInSoloContent",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showPartyFrameInSoloContent"] = value
				addon.variables.requireReload = true
				container:ReleaseChildren()
				addPartyFrame(container)
				addon.functions.togglePlayerFrame(addon.db["hidePlayerFrame"])
			end,
		},
	}

	if addon.db["showPartyFrameInSoloContent"] then
		table.insert(data, {
			parent = "",
			var = "hidePlayerFrame",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hidePlayerFrame"] = value
				addon.functions.togglePlayerFrame(addon.db["hidePlayerFrame"])
			end,
		})
	end

	if addon.db["autoAcceptGroupInvite"] == true then
		table.insert(data, {
			parent = L["autoAcceptGroupInviteOptions"],
			var = "autoAcceptGroupInviteGuildOnly",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["autoAcceptGroupInviteGuildOnly"] = value end,
		})
		table.insert(data, {
			parent = L["autoAcceptGroupInviteOptions"],
			var = "autoAcceptGroupInviteFriendOnly",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["autoAcceptGroupInviteFriendOnly"] = value end,
		})
	end

	addon.functions.createWrapperData(data, container, L)
end

local function addUIFrame(container)
	local data = {
		{
			parent = "",
			var = "ignoreTalkingHead",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["ignoreTalkingHead"] = value end,
		},
		{
			parent = "",
			var = "hideBagsBar",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideBagsBar"] = value
				addon.functions.toggleBagsBar(addon.db["hideBagsBar"])
				if value and addon.db["unitframeSettingBagsBar"] then
					addon.db["unitframeSettingBagsBar"] = false
					addon.variables.requireReload = true
				end
			end,
		},
		{
			parent = "",
			var = "hideQuickJoinToast",
			text = HIDE .. " " .. COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_QUICK_JOIN_LABEL,
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideQuickJoinToast"] = value
				addon.functions.toggleQuickJoinToastButton(addon.db["hideQuickJoinToast"])
			end,
		},
		{
			parent = "",
			var = "hideMicroMenu",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideMicroMenu"] = value
				addon.functions.toggleMicroMenu(addon.db["hideMicroMenu"])
				if value and addon.db["unitframeSettingMicroMenu"] then
					addon.db["unitframeSettingMicroMenu"] = false
					addon.variables.requireReload = true
				end
			end,
		},
		{
			parent = "",
			var = "hideMinimapButton",
			text = L["Hide Minimap Button"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideMinimapButton"] = value
				addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
			end,
		},
		{
			parent = "",
			var = "hideRaidTools",
			text = L["Hide Raid Tools"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideRaidTools"] = value
				addon.functions.toggleRaidTools(addon.db["hideRaidTools"], _G.CompactRaidFrameManager)
			end,
		},
	}

	addon.functions.createWrapperData(data, container, L)
end

local function addBagFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			parent = BAGSLOT,
			var = "showIlvlOnMerchantframe",
			text = L["showIlvlOnMerchantframe"],
			type = "CheckBox",
			callback = function(self, _, value) addon.db["showIlvlOnMerchantframe"] = value end,
		},
		{
			parent = BAGSLOT,
			var = "showIlvlOnBagItems",
			text = L["showIlvlOnBagItems"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showIlvlOnBagItems"] = value
				for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
					if frame:IsShown() then addon.functions.updateBags(frame) end
				end
				if ContainerFrameCombinedBags:IsShown() then addon.functions.updateBags(ContainerFrameCombinedBags) end
			end,
		},
		{
			parent = BAGSLOT,
			var = "showBagFilterMenu",
			text = L["showBagFilterMenu"],
			desc = (L["showBagFilterMenuDesc"]):format(SHIFT_KEY_TEXT),
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showBagFilterMenu"] = value
				for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
					if frame:IsShown() then addon.functions.updateBags(frame) end
				end
				if ContainerFrameCombinedBags:IsShown() then addon.functions.updateBags(ContainerFrameCombinedBags) end
				if value then
					if BankFrame:IsShown() then
						for slot = 1, NUM_BANKGENERIC_SLOTS do
							local itemButton = _G["BankFrameItem" .. slot]
							if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
						end
					end
				else
					for slot = 1, NUM_BANKGENERIC_SLOTS do
						local itemButton = _G["BankFrameItem" .. slot]
						if itemButton and itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
					end
				end
			end,
		},
		{
			parent = BAGSLOT,
			var = "enableMoneyTracker",
			text = L["enableMoneyTracker"],
			desc = L["enableMoneyTrackerDesc"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["enableMoneyTracker"] = value
				container:ReleaseChildren()
				addBagFrame(container)
			end,
		},
		{
			parent = BAGSLOT,
			var = "showIlvlOnBankFrame",
			text = L["showIlvlOnBankFrame"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showIlvlOnBankFrame"] = value
				if value then
					if BankFrame:IsShown() then
						for slot = 1, NUM_BANKGENERIC_SLOTS do
							local itemButton = _G["BankFrameItem" .. slot]
							if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
						end
					end
				else
					for slot = 1, NUM_BANKGENERIC_SLOTS do
						local itemButton = _G["BankFrameItem" .. slot]
						if itemButton and itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
					end
				end
			end,
		},
		{
			parent = BAGSLOT,
			var = "showBindOnBagItems",
			text = L["showBindOnBagItems"]:format(_G.ITEM_BIND_ON_EQUIP, _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP, _G.ITEM_BNETACCOUNTBOUND),
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showBindOnBagItems"] = value
				for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
					if frame:IsShown() then addon.functions.updateBags(frame) end
				end
				if ContainerFrameCombinedBags:IsShown() then addon.functions.updateBags(ContainerFrameCombinedBags) end
			end,
		},
		{
			parent = BAGSLOT,
			var = "fadeBagQualityIcons",
			text = L["fadeBagQualityIcons"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["fadeBagQualityIcons"] = value
				for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
					if frame:IsShown() then addon.functions.updateBags(frame) end
				end
				if ContainerFrameCombinedBags:IsShown() then addon.functions.updateBags(ContainerFrameCombinedBags) end
				if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end
			end,
		},
	}
	table.sort(data, function(a, b)
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
	for _, checkboxData in ipairs(data) do
		local desc
		if checkboxData.desc then desc = checkboxData.desc end
		local cbautoChooseQuest = addon.functions.createCheckboxAce(checkboxData.text, addon.db[checkboxData.var], checkboxData.callback, desc)
		groupCore:AddChild(cbautoChooseQuest)
	end

	if addon.db["enableMoneyTracker"] then
		local groupMoney = addon.functions.createContainer("InlineGroup", "List")
		groupMoney:SetTitle(MONEY)
		wrapper:AddChild(groupMoney)

		local data = {
			{
				var = "showOnlyGoldOnMoney",
				text = L["showOnlyGoldOnMoney"],
				type = "CheckBox",
				callback = function(self, _, value) addon.db["showOnlyGoldOnMoney"] = value end,
			},
		}
		table.sort(data, function(a, b)
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
		for _, checkboxData in ipairs(data) do
			local desc
			if checkboxData.desc then desc = checkboxData.desc end
			local cbautoChooseQuest = addon.functions.createCheckboxAce(checkboxData.text, addon.db[checkboxData.var], checkboxData.callback, desc)
			groupMoney:AddChild(cbautoChooseQuest)
		end

		local tList = {}

		for i, v in pairs(addon.db["moneyTracker"]) do
			if i ~= UnitGUID("player") then
				local col = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[v.class] or { r = 1, g = 1, b = 1 }
				local displayName
				displayName = string.format("|cff%02x%02x%02x%s-%s|r", col.r * 255, col.g * 255, col.b * 255, v.name, v.realm)
				tList[i] = displayName
			end
		end

		local list, order = addon.functions.prepareListForDropdown(tList)
		local dropIncludeList = addon.functions.createDropdownAce(L["moneyTrackerRemovePlayer"], list, order, nil)
		local btnRemoveNPC = addon.functions.createButtonAce(REMOVE, 100, function(self, _, value)
			local selectedValue = dropIncludeList:GetValue()
			if selectedValue then
				if addon.db["moneyTracker"][selectedValue] then
					addon.db["moneyTracker"][selectedValue] = nil
					local tList = {}
					for i, v in pairs(addon.db["moneyTracker"]) do
						if i ~= UnitGUID("player") then
							local col = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[v.class] or { r = 1, g = 1, b = 1 }
							local displayName
							displayName = string.format("|cff%02x%02x%02x%s-%s|r", col.r * 255, col.g * 255, col.b * 255, v.name, v.realm)
							tList[i] = displayName
						end
					end
					local list, order = addon.functions.prepareListForDropdown(tList)
					dropIncludeList:SetList(list, order)
					dropIncludeList:SetValue(nil)
				end
			end
		end)
		groupMoney:AddChild(dropIncludeList)
		groupMoney:AddChild(btnRemoveNPC)
	end
end

local function addCharacterFrame(container)
	local data = {

		{
			parent = INFO,
			var = "showIlvlOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showIlvlOnCharframe"] = value
				setCharFrame()
			end,
		},
		{
			parent = INFO,
			var = "showGemsTooltipOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["showGemsTooltipOnCharframe"] = value end,
		},
		{
			parent = INFO,
			var = "showGemsOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showGemsOnCharframe"] = value
				setCharFrame()
			end,
		},
		{
			parent = INFO,
			var = "showEnchantOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showEnchantOnCharframe"] = value
				setCharFrame()
			end,
		},
		{
			parent = INFO,
			var = "showDurabilityOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showDurabilityOnCharframe"] = value
				calculateDurability()
				if value then
					addon.general.durabilityIconFrame:Show()
				else
					addon.general.durabilityIconFrame:Hide()
				end
			end,
		},
		{
			parent = INFO,
			var = "hideOrderHallBar",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideOrderHallBar"] = value
				if OrderHallCommandBar then
					if value then
						OrderHallCommandBar:Hide()
					else
						OrderHallCommandBar:Show()
					end
				end
			end,
		},
		{
			parent = INSPECT,
			var = "showInfoOnInspectFrame",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showInfoOnInspectFrame"] = value
				removeInspectElements()
			end,
		},
		{
			parent = INFO,
			var = "showCatalystChargesOnCharframe",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["showCatalystChargesOnCharframe"] = value
				if value and addon.variables.catalystID then
					local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
					addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
					addon.general.iconFrame:Show()
				else
					addon.general.iconFrame:Hide()
				end
			end,
		},

		{
			parent = AUCTION_CATEGORY_GEMS,
			var = "enableGemHelper",
			type = "CheckBox",
			desc = L["enableGemHelperDesc"],
			callback = function(self, _, value)
				addon.db["enableGemHelper"] = value
				if not value and EnhanceQoLGemHelper then
					EnhanceQoLGemHelper:Hide()
					EnhanceQoLGemHelper = nil
				end
			end,
		},
	}

	local classname = select(2, UnitClass("player"))
	-- Classspecific stuff
	if classname == "DEATHKNIGHT" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "deathknight_HideRuneFrame",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["deathknight_HideRuneFrame"] = value
				if value then
					RuneFrame:Hide()
				else
					RuneFrame:Show()
				end
			end,
		})
		addTotemHideToggle("deathknight_HideTotemBar", data)
	elseif classname == "DRUID" then
		addTotemHideToggle("druid_HideTotemBar", data)
		table.insert(data, {
			parent = headerClassInfo,
			var = "druid_HideComboPoint",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["druid_HideComboPoint"] = value
				if value then
					DruidComboPointBarFrame:Hide()
				else
					DruidComboPointBarFrame:Show()
				end
			end,
		})
	elseif classname == "EVOKER" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "evoker_HideEssence",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["evoker_HideEssence"] = value
				if value then
					EssencePlayerFrame:Hide()
				else
					EssencePlayerFrame:Show()
				end
			end,
		})
	elseif classname == "MAGE" then
		addTotemHideToggle("mage_HideTotemBar", data)
	elseif classname == "MONK" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "monk_HideHarmonyBar",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["monk_HideHarmonyBar"] = value
				if value then
					MonkHarmonyBarFrame:Hide()
				else
					MonkHarmonyBarFrame:Show()
				end
			end,
		})
		addTotemHideToggle("monk_HideTotemBar", data)
	elseif classname == "PRIEST" then
		addTotemHideToggle("priest_HideTotemBar", data)
	elseif classname == "SHAMAN" then
		addTotemHideToggle("shaman_HideTotem", data)
	elseif classname == "ROGUE" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "rogue_HideComboPoint",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["rogue_HideComboPoint"] = value
				if value then
					RogueComboPointBarFrame:Hide()
				else
					RogueComboPointBarFrame:Show()
				end
			end,
		})
	elseif classname == "PALADIN" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "paladin_HideHolyPower",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["paladin_HideHolyPower"] = value
				if value then
					PaladinPowerBarFrame:Hide()
				else
					PaladinPowerBarFrame:Show()
				end
			end,
		})
		addTotemHideToggle("paladin_HideTotemBar", data)
	elseif classname == "WARLOCK" then
		table.insert(data, {
			parent = headerClassInfo,
			var = "warlock_HideSoulShardBar",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["warlock_HideSoulShardBar"] = value
				if value then
					WarlockPowerFrame:Hide()
				else
					WarlockPowerFrame:Show()
				end
			end,
		})
		addTotemHideToggle("warlock_HideTotemBar", data)
	end

	addon.functions.createWrapperData(data, container, L)
end

local function addMiscFrame(container, d)
	local data = {
		--@debug@
		{
			parent = "",
			var = "automaticallyOpenContainer",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["automaticallyOpenContainer"] = value end,
		},
		--@end-debug@
		{
			parent = "",
			var = "autoRepair",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["autoRepair"] = value end,
		},
		{
			parent = "",
			var = "sellAllJunk",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["sellAllJunk"] = value
				if value then checkBagIgnoreJunk() end
			end,
		},
		{
			parent = "",
			var = "deleteItemFillDialog",
			text = L["deleteItemFillDialog"]:format(DELETE_ITEM_CONFIRM_STRING),
			type = "CheckBox",
			callback = function(self, _, value) addon.db["deleteItemFillDialog"] = value end,
		},
		{
			parent = "",
			var = "confirmPatronOrderDialog",
			text = (L["confirmPatronOrderDialog"]):format(PROFESSIONS_CRAFTER_ORDER_TAB_NPC),
			type = "CheckBox",
			callback = function(self, _, value) addon.db["confirmPatronOrderDialog"] = value end,
		},
		{
			parent = "",
			var = "confirmTimerRemovalTrade",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["confirmTimerRemovalTrade"] = value end,
		},

		{
			parent = "",
			var = "openCharframeOnUpgrade",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["openCharframeOnUpgrade"] = value end,
		},
		{
			parent = "",
			var = "autoQuickLoot",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["autoQuickLoot"] = value end,
		},
		{
			parent = "",
			var = "instantCatalystEnabled",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["instantCatalystEnabled"] = value
				addon.functions.toggleInstantCatalystButton(value)
			end,
		},
	}

	addon.functions.createWrapperData(data, container, L)
end

local function addQuestFrame(container, d)
	local list, order = addon.functions.prepareListForDropdown(addon.db["ignoredQuestNPC"])

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local groupData = {
		{
			parent = "",
			var = "autoChooseQuest",
			text = L["autoChooseQuest"],
			type = "CheckBox",
			callback = function(self, _, value) addon.db[self.var] = value end,
			desc = L["interruptWithShift"],
		},
		{
			parent = "",
			var = "ignoreDailyQuests",
			text = L["ignoreDailyQuests"]:format(QUESTS_LABEL),
			type = "CheckBox",
			callback = function(self, _, value) addon.db[self.var] = value end,
		},
		{
			parent = "",
			var = "ignoreWarbandCompleted",
			text = L["ignoreWarbandCompleted"]:format(ACCOUNT_COMPLETED_QUEST_LABEL, QUESTS_LABEL),
			type = "CheckBox",
			callback = function(self, _, value) addon.db[self.var] = value end,
		},
		{
			parent = "",
			var = "ignoreTrivialQuests",
			text = L["ignoreTrivialQuests"]:format(QUESTS_LABEL),
			type = "CheckBox",
			callback = function(self, _, value) addon.db[self.var] = value end,
		},
	}
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
	for _, checkboxData in ipairs(groupData) do
		local desc
		if checkboxData.desc then desc = checkboxData.desc end
		local cbautoChooseQuest = addon.functions.createCheckboxAce(checkboxData.text, addon.db[checkboxData.var], function(self, _, value) addon.db[checkboxData.var] = value end, desc)
		groupCore:AddChild(cbautoChooseQuest)
	end

	local groupNPC = addon.functions.createContainer("InlineGroup", "List")
	groupNPC:SetTitle(L["questAddNPCToExclude"])
	wrapper:AddChild(groupNPC)

	local dropIncludeList = addon.functions.createDropdownAce(L["Excluded NPCs"], list, order, nil)
	local btnAddNPC = addon.functions.createButtonAce(ADD, 100, function(self, _, value)
		local guid = nil
		local name = nil
		local type = nil
		local unitType = nil

		if nil ~= UnitGUID("npc") then
			type = "npc"
		elseif nil ~= UnitGUID("target") then
			type = "target"
		else
			return
		end

		guid = UnitGUID(type)
		name = UnitName(type)
		unitType = strsplit("-", guid)

		if UnitCanAttack(type, "player") or (UnitPlayerControlled(type) and not unitType == "Vehicle") then return end -- ignore attackable and player types

		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID and not unitType == "Vehicle" then
			local mapInfo = C_Map.GetMapInfo(mapID)
			if mapInfo and mapInfo.name then name = name .. " (" .. mapInfo.name .. ")" end
		end

		guid = addon.functions.getIDFromGUID(guid)
		if addon.db["ignoredQuestNPC"][guid] then return end -- no duplicates

		print(ADD .. ":", guid, name)

		addon.db["ignoredQuestNPC"][guid] = name
		local list, order = addon.functions.prepareListForDropdown(addon.db["ignoredQuestNPC"])

		dropIncludeList:SetList(list, order)
	end)
	local btnRemoveNPC = addon.functions.createButtonAce(REMOVE, 100, function(self, _, value)
		local selectedValue = dropIncludeList:GetValue() -- Hole den aktuellen Wert des Dropdowns
		if selectedValue then
			if addon.db["ignoredQuestNPC"][selectedValue] then
				addon.db["ignoredQuestNPC"][selectedValue] = nil -- Entferne aus der Datenbank
				-- Aktualisiere die Dropdown-Liste
				local list, order = addon.functions.prepareListForDropdown(addon.db["ignoredQuestNPC"])
				dropIncludeList:SetList(list, order)
				dropIncludeList:SetValue(nil) -- Setze die Auswahl zurück
			end
		end
	end)
	groupNPC:AddChild(btnAddNPC)
	groupNPC:AddChild(dropIncludeList)
	groupNPC:AddChild(btnRemoveNPC)
end

local function addMapFrame(container)
	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	container:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local cbElement = addon.functions.createCheckboxAce(L["enableWayCommand"], addon.db["enableWayCommand"], function(self, _, value)
		addon.db["enableWayCommand"] = value
		if value then
			addon.functions.registerWayCommand()
		else
			addon.variables.requireReload = true
		end
	end, L["enableWayCommandDesc"])
	groupCore:AddChild(cbElement)
end

local function updateBankButtonInfo()
	if not addon.db["showIlvlOnBankFrame"] then return end

	local function setBankInfo(itemButton, bag, slot)
		local eItem = Item:CreateFromBagAndSlot(bag, slot)
		if eItem and not eItem:IsItemEmpty() then
			eItem:ContinueOnItemLoad(function()
				local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(eItem:GetItemLink())

				if
					(itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" or (classID == 4 and subclassID == 0)) and not (classID == 4 and subclassID == 5) -- Cosmetic
				then
					-- Falls keine Textanzeige vorhanden ist, erstelle eine neue
					if not itemButton.ItemLevelText then
						itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
						itemButton.ItemLevelText:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
						itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -2)
						itemButton.ItemLevelText:SetShadowOffset(1, -1)
						itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
					end

					local color = eItem:GetItemQualityColor()
					itemButton.ItemLevelText:SetText(eItem:GetCurrentItemLevel())
					itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)
					itemButton.ItemLevelText:Show()
				elseif itemButton and itemButton.ItemLevelText then
					itemButton.ItemLevelText:Hide()
				end
			end)
		elseif itemButton and itemButton.ItemLevelText then
			itemButton.ItemLevelText:Hide()
		end
	end
end

BankFrame:HookScript("OnShow", updateBankButtonInfo)

local function updateMerchantButtonInfo()
	if addon.db["showIlvlOnMerchantframe"] then
		local itemsPerPage = MERCHANT_ITEMS_PER_PAGE or 10 -- Anzahl der Items pro Seite (Standard 10)
		local currentPage = MerchantFrame.page or 1 -- Aktuelle Seite
		local startIndex = (currentPage - 1) * itemsPerPage + 1 -- Startindex basierend auf der aktuellen Seite

		for i = 1, itemsPerPage do
			local itemIndex = startIndex + i - 1
			local itemButton = _G["MerchantItem" .. i .. "ItemButton"]
			local itemLink = GetMerchantItemLink(itemIndex)

			if itemButton then
				if itemLink and itemLink:find("item:") then
					local eItem = Item:CreateFromItemLink(itemLink)
					eItem:ContinueOnItemLoad(function()
						-- local itemName, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
						local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(itemLink)

						if
							(itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" or (classID == 4 and subclassID == 0)) and not (classID == 4 and subclassID == 5) -- Cosmetic
						then
							local link = eItem:GetItemLink()
							local invSlot = select(4, C_Item.GetItemInfoInstant(link))
							if nil == addon.variables.allowedEquipSlotsBagIlvl[invSlot] then
								if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
								if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
								return
							end

							if not itemButton.ItemLevelText then
								itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
								itemButton.ItemLevelText:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
								itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", -1, -1)
								itemButton.ItemLevelText:SetShadowOffset(1, -1)
								itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
							end

							local color = eItem:GetItemQualityColor()
							itemButton.ItemLevelText:SetText(eItem:GetCurrentItemLevel())
							itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)
							itemButton.ItemLevelText:Show()
							local bType

							if addon.db["showBindOnBagItems"] then
								local data = C_TooltipInfo.GetMerchantItem(itemIndex)
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
							if bType then
								if not itemButton.ItemBoundType then
									itemButton.ItemBoundType = itemButton:CreateFontString(nil, "OVERLAY")
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
						else
							if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
							if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
						end
					end)
				else
					if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
					if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
				end
			end
		end
	end
end

local function updateBuybackButtonInfo()
       if not addon.db["showIlvlOnMerchantframe"] then return end

       local itemsPerPage = BUYBACK_ITEMS_PER_PAGE or 12
       for i = 1, itemsPerPage do
               local itemButton = _G["MerchantItem" .. i .. "ItemButton"]
               local itemLink = GetBuybackItemLink(i)

               if itemButton then
                       if itemLink and itemLink:find("item:") then
                               local eItem = Item:CreateFromItemLink(itemLink)
                               eItem:ContinueOnItemLoad(function()
                                       local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = C_Item.GetItemInfo(itemLink)

                                       if
                                               (itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" or (classID == 4 and subclassID == 0))
                                               and not (classID == 4 and subclassID == 5)
                                       then
                                               local link = eItem:GetItemLink()
                                               local invSlot = select(4, C_Item.GetItemInfoInstant(link))
                                               if nil == addon.variables.allowedEquipSlotsBagIlvl[invSlot] then
                                                       if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
                                                       if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
                                                       return
                                               end

                                               if not itemButton.ItemLevelText then
                                                       itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
                                                       itemButton.ItemLevelText:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
                                                       itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", -1, -1)
                                                       itemButton.ItemLevelText:SetShadowOffset(1, -1)
                                                       itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
                                               end

                                               local color = eItem:GetItemQualityColor()
                                               itemButton.ItemLevelText:SetText(eItem:GetCurrentItemLevel())
                                               itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)
                                               itemButton.ItemLevelText:Show()

                                               local bType
                                               if addon.db["showBindOnBagItems"] then
                                                       local data = C_TooltipInfo.GetBuybackItem(i)
                                                       for _, v in pairs(data.lines) do
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
                                               if bType then
                                                       if not itemButton.ItemBoundType then
                                                               itemButton.ItemBoundType = itemButton:CreateFontString(nil, "OVERLAY")
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
                                       else
                                               if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
                                               if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
                                       end
                               end)
                       else
                               if itemButton.ItemBoundType then itemButton.ItemBoundType:Hide() end
                               if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
                       end
               end
       end
end

local function updateFlyoutButtonInfo(button)
	if not button then return end

	if addon.db["showIlvlOnCharframe"] then
		local location = button.location
		if not location then return end

		local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)

		local itemLink
		if bags then
			itemLink = C_Container.GetContainerItemLink(bag, slot)
		elseif not bags then
			itemLink = GetInventoryItemLink("player", slot)
		end

		if itemLink then
			local eItem = Item:CreateFromItemLink(itemLink)
			if eItem and not eItem:IsItemEmpty() then
				eItem:ContinueOnItemLoad(function()
					local itemLevel = eItem:GetCurrentItemLevel()
					local quality = eItem:GetItemQualityColor()

					if not button.ItemLevelText then
						button.ItemLevelText = button:CreateFontString(nil, "OVERLAY")
						button.ItemLevelText:SetFont(addon.variables.defaultFont, 16, "OUTLINE")
						button.ItemLevelText:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
					end

					-- Setze den Text und die Farbe
					button.ItemLevelText:SetText(itemLevel)
					button.ItemLevelText:SetTextColor(quality.r, quality.g, quality.b, 1)
					button.ItemLevelText:Show()

					local bType
					if bag and slot then
						if addon.db["showBindOnBagItems"] then
							local data = C_TooltipInfo.GetBagItem(bag, slot)
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
						if not button.ItemBoundType then
							button.ItemBoundType = button:CreateFontString(nil, "OVERLAY")
							button.ItemBoundType:SetFont(addon.variables.defaultFont, 10, "OUTLINE")
							button.ItemBoundType:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)

							button.ItemBoundType:SetShadowOffset(2, 2)
							button.ItemBoundType:SetShadowColor(0, 0, 0, 1)
						end
						button.ItemBoundType:SetFormattedText(bType)
						button.ItemBoundType:Show()
					elseif button.ItemBoundType then
						button.ItemBoundType:Hide()
					end
				end)
			end
		elseif button.ItemLevelText then
			if button.ItemBoundType then button.ItemBoundType:Hide() end
			button.ItemLevelText:Hide()
		end
	elseif button.ItemLevelText then
		if button.ItemBoundType then button.ItemBoundType:Hide() end
		button.ItemLevelText:Hide()
	end
end

local function initDungeon()
	addon.functions.InitDBValue("autoChooseDelvePower", false)
	addon.functions.InitDBValue("lfgSortByRio", false)
	addon.functions.InitDBValue("groupfinderSkipRoleSelect", false)

	if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.FilterButton and LFGListFrame.SearchPanel.FilterButton.ResetButton then
		lfgPoint, lfgRelativeTo, lfgRelativePoint, lfgXOfs, lfgYOfs = LFGListFrame.SearchPanel.FilterButton.ResetButton:GetPoint()
	end
	if addon.db["groupfinderMoveResetButton"] then toggleLFGFilterPosition() end
end

local function initActionBars()
	for _, cbData in ipairs(addon.variables.actionBarNames) do
		if cbData.var and cbData.name then
			if addon.db[cbData.var] then UpdateActionBarMouseover(cbData.name, addon.db[cbData.var], cbData.var) end
		end
	end
end

local function initParty()
	addon.functions.InitDBValue("autoAcceptGroupInvite", false)
	addon.functions.InitDBValue("autoAcceptGroupInviteFriendOnly", false)
	addon.functions.InitDBValue("autoAcceptGroupInviteGuildOnly", false)
	addon.functions.InitDBValue("showLeaderIconRaidFrame", false)
	addon.functions.InitDBValue("showPartyFrameInSoloContent", false)

	if CompactUnitFrame_SetUnit then
		hooksecurefunc("CompactUnitFrame_SetUnit", function(s, type)
			if addon.db["showLeaderIconRaidFrame"] then
				if type then
					if _G["CompactPartyFrame"]:IsShown() and strmatch(type, "party%d") then
						if UnitInParty("player") and not UnitInRaid("player") then setLeaderIcon() end
					end
				end
			end
		end)
	end

	local last_solo
	local function manage_raid_frame()
		if not addon.db["showPartyFrameInSoloContent"] then return end
		local solo = 1
		if IsInGroup() or IsInRaid() then solo = 0 end

		if solo == 0 and last_solo == 0 then return end

		CompactPartyFrame:SetShown(solo)
		last_solo = solo
	end

	hooksecurefunc(CompactPartyFrame, "UpdateVisibility", manage_raid_frame)
end

local function initQuest()
	addon.functions.InitDBValue("autoChooseQuest", false)
	addon.functions.InitDBValue("ignoreTrivialQuests", false)
	addon.functions.InitDBValue("ignoreDailyQuests", false)
	addon.functions.InitDBValue("ignoredQuestNPC", {})
	addon.functions.InitDBValue("autogossipID", {})
end

local function initMisc()
	addon.functions.InitDBValue("confirmTimerRemovalTrade", false)
	addon.functions.InitDBValue("confirmPatronOrderDialog", false)
	addon.functions.InitDBValue("deleteItemFillDialog", false)
	addon.functions.InitDBValue("hideRaidTools", false)
	addon.functions.InitDBValue("autoRepair", false)
	addon.functions.InitDBValue("sellAllJunk", false)
	addon.functions.InitDBValue("ignoreTalkingHead", false)
	addon.functions.InitDBValue("hiddenLandingPages", {})
	addon.functions.InitDBValue("hideMinimapButton", false)
	addon.functions.InitDBValue("hideBagsBar", false)
	addon.functions.InitDBValue("hideMicroMenu", false)
	addon.functions.InitDBValue("instantCatalystEnabled", false)
	--@debug@
	addon.functions.InitDBValue("automaticallyOpenContainer", false)
	--@end-debug@

	-- Hook all static popups, because not the first one has to be the one for sell all junk if another popup is already shown
	for i = 1, 4 do
		local popup = _G["StaticPopup" .. i]
		if popup then
			hooksecurefunc(popup, "Show", function(self)
				if self then
					if addon.db["sellAllJunk"] and self.data and type(self.data) == "table" and self.data.text == SELL_ALL_JUNK_ITEMS_POPUP and self.button1 then
						self.button1:Click()
					elseif addon.db["deleteItemFillDialog"] and (self.which == "DELETE_GOOD_ITEM" or self.which == "DELETE_GOOD_QUEST_ITEM") and self.editBox then
						self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
					elseif addon.db["confirmPatronOrderDialog"] and self.data and type(self.data) == "table" and self.data.text == CRAFTING_ORDERS_OWN_REAGENTS_CONFIRMATION and self.button1 then
						local order = C_CraftingOrders.GetClaimedOrder()
						if order and order.npcCustomerCreatureID and order.npcCustomerCreatureID > 0 then self.button1:Click() end
					elseif addon.db["confirmTimerRemovalTrade"] and self.which == "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL" and self.button1 then
						self.button1:Click()
					end
				end
			end)
		end
	end

	hooksecurefunc(MerchantFrame, "Show", function(self, button)
		if addon.db["autoRepair"] then
			if CanMerchantRepair() then
				local repairAllCost = GetRepairAllCost()
				if repairAllCost and repairAllCost > 0 then
					RepairAllItems()
					PlaySound(SOUNDKIT.ITEM_REPAIR)
					print(L["repairCost"] .. addon.functions.formatMoney(repairAllCost))
				end
			end
		end
		if addon.db["sellAllJunk"] and MerchantSellAllJunkButton:IsEnabled() then MerchantSellAllJunkButton:Click() end
	end)

	hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function(self)
		if addon.db["ignoreTalkingHead"] then self:Hide() end
	end)
	_G.CompactRaidFrameManager:SetScript("OnShow", function(self) addon.functions.toggleRaidTools(addon.db["hideRaidTools"], self) end)
	ExpansionLandingPageMinimapButton:HookScript("OnShow", function(self)
		local id = addon.variables.landingPageReverse[self.title]
		if addon.db["enableSquareMinimap"] then
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -16, -16)
		end
		if addon.db["hiddenLandingPages"][id] then self:Hide() end
	end)
end

local function initUnitFrame()
	addon.functions.InitDBValue("hideHitIndicatorPlayer", false)
	addon.functions.InitDBValue("hideHitIndicatorPet", false)
	addon.functions.InitDBValue("hidePlayerFrame", false)
	addon.functions.InitDBValue("hideRaidFrameBuffs", false)
	if addon.db["hideHitIndicatorPlayer"] then PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide() end

	if PetHitIndicator then hooksecurefunc(PetHitIndicator, "Show", function(self)
		if addon.db["hideHitIndicatorPet"] then PetHitIndicator:Hide() end
	end) end

	function addon.functions.togglePlayerFrame(value)
		if addon.db["showPartyFrameInSoloContent"] and value then
			PlayerFrame:Hide()
		else
			PlayerFrame:Show()
		end
	end
	PlayerFrame:HookScript("OnShow", function(self)
		if addon.db["showPartyFrameInSoloContent"] and addon.db["hidePlayerFrame"] then self:Hide() end
	end)
	addon.functions.togglePlayerFrame(addon.db["hidePlayerFrame"])

	local function handleRaidFrameBuffs(frame)
		if type(frame) ~= "table" or type(frame.GetName) ~= "function" then return end

		local ok, frameName = pcall(frame.GetName, frame)
		if not ok or not frameName then return end

		for i = 1, 8 do
			local buffFrame = _G[frameName .. "Buff" .. i]
			if buffFrame then buffFrame:SetShown(not addon.db["hideRaidFrameBuffs"]) end
		end
	end

	function addon.functions.updateRaidFrameBuffs()
		for i = 1, 5 do
			local f = _G["CompactPartyFrameMember" .. i]
			if f then handleRaidFrameBuffs(f) end
		end
		for i = 1, 40 do
			local f = _G["CompactRaidFrame" .. i]
			if f then handleRaidFrameBuffs(f) end
		end
	end

	if addon.db["hideRaidFrameBuffs"] then
		if DefaultCompactUnitFrameSetup then hooksecurefunc("DefaultCompactUnitFrameSetup", handleRaidFrameBuffs) end
		if CompactUnitFrame_UpdateAuras then hooksecurefunc("CompactUnitFrame_UpdateAuras", handleRaidFrameBuffs) end
		addon.functions.updateRaidFrameBuffs()
	end

	for _, cbData in ipairs(addon.variables.unitFrameNames) do
		if cbData.var and cbData.name then
			if addon.db[cbData.var] then UpdateUnitFrameMouseover(cbData.name, cbData) end
		end
	end
end

local function initBagsFrame()
	addon.functions.InitDBValue("moneyTracker", {})
	addon.functions.InitDBValue("enableMoneyTracker", false)
	addon.functions.InitDBValue("showOnlyGoldOnMoney", false)
	if addon.db["moneyTracker"][UnitGUID("player")] == nil or type(addon.db["moneyTracker"][UnitGUID("player")]) ~= "table" then addon.db["moneyTracker"][UnitGUID("player")] = {} end
	local moneyFrame = ContainerFrameCombinedBags.MoneyFrame
	local otherMoney = {}

	local function ShowBagMoneyTooltip(self)
		if not addon.db["enableMoneyTracker"] then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()

		local list, total = {}, 0
		for _, info in pairs(addon.db["moneyTracker"]) do
			total = total + (info.money or 0)
			table.insert(list, info)
		end
		table.sort(list, function(a, b) return (a.money or 0) > (b.money or 0) end)

		for _, info in ipairs(list) do
			local col = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info.class] or { r = 1, g = 1, b = 1 }
			local displayName
			if info.realm == GetRealmName() or not info.realm or info.realm == "" then
				displayName = string.format("|cff%02x%02x%02x%s|r", col.r * 255, col.g * 255, col.b * 255, info.name)
			else
				displayName = string.format("|cff%02x%02x%02x%s-%s|r", col.r * 255, col.g * 255, col.b * 255, info.name, info.realm)
			end
			GameTooltip:AddDoubleLine(displayName, addon.functions.formatMoney(info.money, "tracker"))
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TOTAL, addon.functions.formatMoney(total, "tracker"))
		GameTooltip:Show()
	end

	local function HideBagMoneyTooltip()
		if not addon.db["enableMoneyTracker"] then return end
		GameTooltip:Hide()
	end

	moneyFrame:HookScript("OnEnter", ShowBagMoneyTooltip)
	moneyFrame:HookScript("OnLeave", HideBagMoneyTooltip)
	for _, coin in ipairs({ "GoldButton", "SilverButton", "CopperButton" }) do
		local btn = moneyFrame[coin]
		if btn then
			btn:HookScript("OnEnter", ShowBagMoneyTooltip)
			btn:HookScript("OnLeave", HideBagMoneyTooltip)
		end
	end

	moneyFrame = ContainerFrame1.MoneyFrame
	moneyFrame:HookScript("OnEnter", ShowBagMoneyTooltip)
	moneyFrame:HookScript("OnLeave", HideBagMoneyTooltip)
	for _, coin in ipairs({ "GoldButton", "SilverButton", "CopperButton" }) do
		local btn = moneyFrame[coin]
		if btn then
			btn:HookScript("OnEnter", ShowBagMoneyTooltip)
			btn:HookScript("OnLeave", HideBagMoneyTooltip)
		end
	end
end

local function initChatFrame()
	if ChatFrame1 then
		addon.functions.InitDBValue("chatFrameFadeEnabled", ChatFrame1:GetFading())
		addon.functions.InitDBValue("chatFrameFadeTimeVisible", ChatFrame1:GetTimeVisible())
		addon.functions.InitDBValue("chatFrameFadeDuration", ChatFrame1:GetFadeDuration())

		ChatFrame1:SetFading(addon.db["chatFrameFadeEnabled"])
		ChatFrame1:SetTimeVisible(addon.db["chatFrameFadeTimeVisible"])
		ChatFrame1:SetFadeDuration(addon.db["chatFrameFadeDuration"])
	else
		addon.functions.InitDBValue("chatFrameFadeEnabled", true)
		addon.functions.InitDBValue("chatFrameFadeTimeVisible", 120)
		addon.functions.InitDBValue("chatFrameFadeDuration", 3)
	end

	addon.functions.InitDBValue("enableChatIM", false)
	addon.functions.InitDBValue("enableChatIMFade", false)
	addon.functions.InitDBValue("chatIMUseCustomSound", false)
	addon.functions.InitDBValue("chatIMCustomSoundFile", "")
	addon.functions.InitDBValue("chatIMMaxHistory", 250)
	addon.functions.InitDBValue("chatIMFrameData", {})
	addon.functions.InitDBValue("chatIMHideInCombat", false)
	addon.functions.InitDBValue("chatIMUseAnimation", true)
	if addon.ChatIM and addon.ChatIM.SetEnabled then addon.ChatIM:SetEnabled(addon.db["enableChatIM"]) end
end

local function initMap()
	addon.functions.InitDBValue("enableWayCommand", false)
	if addon.db["enableWayCommand"] then addon.functions.registerWayCommand() end
end

local function initUI()
	addon.functions.InitDBValue("enableMinimapButtonBin", false)
	addon.functions.InitDBValue("buttonsink", {})
	addon.functions.InitDBValue("enableLootspecQuickswitch", false)
	addon.functions.InitDBValue("lootspec_quickswitch", {})
	addon.functions.InitDBValue("minimapSinkHoleData", {})
	addon.functions.InitDBValue("hideQuickJoinToast", false)
	addon.functions.InitDBValue("enableSquareMinimap", false)
	addon.functions.InitDBValue("persistAuctionHouseFilter", false)
	addon.functions.InitDBValue("hideDynamicFlightBar", false)

	table.insert(addon.variables.unitFrameNames, {
		name = "MicroMenu",
		var = "unitframeSettingMicroMenu",
		text = addon.L["MicroMenu"],
		children = { MicroMenu:GetChildren() },
		revealAllChilds = true,
		disableSetting = {
			"hideMicroMenu",
		},
	})
	table.insert(addon.variables.unitFrameNames, {
		name = "BagsBar",
		var = "unitframeSettingBagsBar",
		text = addon.L["BagsBar"],
		children = { BagsBar:GetChildren() },
		revealAllChilds = true,
		disableSetting = {
			"hideBagsBar",
		},
	})

	local function makeSquareMinimap()
		MinimapCompassTexture:Hide()
		Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
		function GetMinimapShape() return "SQUARE" end
	end
	if addon.db["enableSquareMinimap"] then makeSquareMinimap() end

	function addon.functions.toggleMinimapButton(value)
		if value == false then
			LDBIcon:Show(addonName)
		else
			LDBIcon:Hide(addonName)
		end
	end
	function addon.functions.toggleBagsBar(value)
		if value == false then
			BagsBar:Show()
		else
			BagsBar:Hide()
		end
	end
	addon.functions.toggleBagsBar(addon.db["hideBagsBar"])
	function addon.functions.toggleMicroMenu(value)
		if value == false then
			MicroMenu:Show()
		else
			MicroMenu:Hide()
		end
	end
	addon.functions.toggleMicroMenu(addon.db["hideMicroMenu"])

	function addon.functions.toggleQuickJoinToastButton(value)
		if value == false then
			QuickJoinToastButton:Show()
		else
			QuickJoinToastButton:Hide()
		end
	end
	addon.functions.toggleQuickJoinToastButton(addon.db["hideQuickJoinToast"])

	function addon.functions.toggleDynamicFlightBar(value)
		local bar = UIWidgetPowerBarContainerFrame
		if not bar then return end
		if value then
			if not bar.alphaDriverSet then
				RegisterAttributeDriver(bar, "state-visibility", "[flying]show;hide;")
				bar.alphaDriverSet = true
			end
		else
			addon.variables.requireReload = true
		end
	end
	if addon.db["hideDynamicFlightBar"] then addon.functions.toggleDynamicFlightBar(addon.db["hideDynamicFlightBar"]) end

	local eventFrame = CreateFrame("Frame")
	eventFrame:SetScript("OnUpdate", function(self)
		addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
		self:SetScript("OnUpdate", nil)
	end)

	local COLUMNS = 4
	local ICON_SIZE = 32
	local PADDING = 4
	addon.variables.bagButtons = {}
	addon.variables.bagButtonState = {}
	addon.variables.bagButtonPoint = {}
	addon.variables.buttonSink = nil

	local function hoverOutFrame()
		if addon.variables.buttonSink and LDBIcon.objects[addonName .. "_ButtonSinkMap"] then
			if not MouseIsOver(addon.variables.buttonSink) and not MouseIsOver(LDBIcon.objects[addonName .. "_ButtonSinkMap"]) then
				addon.variables.buttonSink:Hide()
			elseif addon.variables.buttonSink:IsShown() then
				C_Timer.After(1, function() hoverOutFrame() end)
			end
		end
	end
	local function hoverOutCheck(frame)
		if frame and frame:IsVisible() then
			if not MouseIsOver(frame) then
				frame:SetAlpha(0)
			else
				C_Timer.After(1, function() hoverOutCheck(frame) end)
			end
		end
	end

	local function positionBagFrame(bagFrame, anchorButton)
		bagFrame:ClearAllPoints()

		-- Zuerst berechnen wir die absoluten Bildschirmkoordinaten des Buttons.
		-- Das geht am einfachsten über 'GetLeft()', 'GetRight()', 'GetTop()', 'GetBottom()'.
		local bLeft = anchorButton:GetLeft() or 0
		local bRight = anchorButton:GetRight() or 0
		local bTop = anchorButton:GetTop() or 0
		local bBottom = anchorButton:GetBottom() or 0

		local screenWidth = GetScreenWidth()
		local screenHeight = GetScreenHeight()

		local bagWidth = bagFrame:GetWidth()
		local bagHeight = bagFrame:GetHeight()

		-- Standard-Anker: Wir wollen z.B. "BOTTOMRIGHT" der Bag an "TOPLEFT" des Buttons
		-- Also Bag rechts vom Button (und Bag unten am Button) – das können wir anpassen
		local pointOnBag = "BOTTOMRIGHT"
		local pointOnButton = "TOPLEFT"

		-- Prüfen, ob wir vertikal oben rausrennen
		-- Falls bTop + bagHeight zu hoch ist, docken wir uns an der "BOTTOMLEFT" des Buttons an
		-- und die Bag an "TOPRIGHT"
		if (bTop + bagHeight) > screenHeight then
			pointOnBag = "TOPRIGHT"
			pointOnButton = "BOTTOMLEFT"
		end

		-- Prüfen, ob wir horizontal links rausrennen (z. B. der Button ist links am Bildschirm
		-- und bagWidth würde drüber hinausragen)
		if (bLeft - bagWidth) < 0 then
			-- Dann wollen wir lieber rechts daneben andocken
			-- Also "BOTTOMLEFT" an "TOPRIGHT"
			if pointOnBag == "BOTTOMRIGHT" then
				pointOnBag = "BOTTOMLEFT"
				pointOnButton = "TOPRIGHT"
			else
				-- oder "TOPLEFT" an "BOTTOMRIGHT"
				pointOnBag = "TOPLEFT"
				pointOnButton = "BOTTOMRIGHT"
			end
		end

		-- Jetzt setzen wir den finalen Anker
		bagFrame:SetPoint(pointOnBag, anchorButton, pointOnButton, 0, 0)
	end

	local function removeButtonSink()
		if addon.variables.buttonSink then
			addon.variables.buttonSink:SetParent(nil)
			addon.variables.buttonSink:SetScript("OnLeave", nil)
			addon.variables.buttonSink:SetScript("OnDragStart", nil)
			addon.variables.buttonSink:SetScript("OnDragStop", nil)
			addon.variables.buttonSink:SetScript("OnEnter", nil)
			addon.variables.buttonSink:SetScript("OnLeave", nil)
			addon.variables.buttonSink:Hide()
			addon.variables.buttonSink = nil
		end
		addon.functions.LayoutButtons()
		if _G[addonName .. "_ButtonSinkMap"] then
			_G[addonName .. "_ButtonSinkMap"]:SetParent(nil)
			_G[addonName .. "_ButtonSinkMap"]:SetScript("OnEnter", nil)
			_G[addonName .. "_ButtonSinkMap"]:SetScript("OnLeave", nil)
			_G[addonName .. "_ButtonSinkMap"]:Hide()
			_G[addonName .. "_ButtonSinkMap"] = nil
		end
		if LDBIcon:IsRegistered(addonName .. "_ButtonSinkMap") then
			local button = LDBIcon.objects[addonName .. "_ButtonSinkMap"]
			if button then button:Hide() end
			LDBIcon.objects[addonName .. "_ButtonSinkMap"] = nil
		end
	end

	local function firstStartButtonSink(counter)
		if hookedATT then return end
		if C_AddOns.IsAddOnLoadable("AllTheThings") then
			if _G["AllTheThings-Minimap"] then
				addon.functions.gatherMinimapButtons()
				addon.functions.LayoutButtons()
				return
			end
			if _G["AllTheThings"] and _G["AllTheThings"].SetMinimapButtonSettings then
				hooksecurefunc(_G["AllTheThings"], "SetMinimapButtonSettings", function(self, visible)
					addon.functions.gatherMinimapButtons()
					addon.functions.LayoutButtons()
				end)
				hookedATT = true
				return
			end
			if counter < 30 then C_Timer.After(0.5, function() firstStartButtonSink(counter + 1) end) end
		end
	end

	function addon.functions.toggleButtonSink()
		if addon.db["enableMinimapButtonBin"] then
			removeButtonSink()

			firstStartButtonSink(0)
			local buttonBag = CreateFrame("Frame", addonName .. "_ButtonSink", UIParent, "BackdropTemplate")
			buttonBag:SetSize(150, 150)
			buttonBag:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
			})

			if addon.db["useMinimapButtonBinIcon"] then
				buttonBag:SetScript("OnLeave", function(self)
					if addon.db["useMinimapButtonBinIcon"] then C_Timer.After(1, function() hoverOutFrame() end) end
				end)
			else
				if not addon.db["lockMinimapButtonBin"] then
					buttonBag:SetMovable(true)
					buttonBag:EnableMouse(true)
					buttonBag:RegisterForDrag("LeftButton")
					buttonBag:SetScript("OnDragStart", buttonBag.StartMoving)
					buttonBag:SetScript("OnDragStop", function(self)
						self:StopMovingOrSizing()
						-- Position speichern
						local point, _, _, xOfs, yOfs = self:GetPoint()
						addon.db["minimapSinkHoleData"].point = point
						addon.db["minimapSinkHoleData"].x = xOfs
						addon.db["minimapSinkHoleData"].y = yOfs
					end)
				end
				buttonBag:SetPoint(
					addon.db["minimapSinkHoleData"].point or "CENTER",
					UIParent,
					addon.db["minimapSinkHoleData"].point or "CENTER",
					addon.db["minimapSinkHoleData"].x or 0,
					addon.db["minimapSinkHoleData"].y or 0
				)
				if addon.db["useMinimapButtonBinMouseover"] then
					buttonBag:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
					buttonBag:SetScript("OnLeave", function(self) hoverOutCheck(self) end)
					buttonBag:SetAlpha(0)
				end
			end
			buttonBag:SetBackdropColor(0, 0, 0, 0.4)
			buttonBag:SetBackdropBorderColor(1, 1, 1, 1)
			addon.variables.buttonSink = buttonBag
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()

			-- create ButtonSink Button
			if addon.db["useMinimapButtonBinIcon"] then
				local iconData = {
					type = "launcher",
					icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\SinkHole.tga" or "Interface\\ICONS\\INV_Misc_QuestionMark", -- irgendein Icon
					label = addonName .. "_ButtonSinkMap",
					OnEnter = function(self)
						positionBagFrame(addon.variables.buttonSink, LDBIcon.objects[addonName .. "_ButtonSinkMap"])
						addon.variables.buttonSink:Show()
					end,
					OnLeave = function(self)
						if addon.db["useMinimapButtonBinIcon"] then C_Timer.After(1, function() hoverOutFrame() end) end
					end,
				}
				-- Registriere das Icon bei LibDBIcon
				LDB:NewDataObject(addonName .. "_ButtonSinkMap", iconData)
				LDBIcon:Register(addonName .. "_ButtonSinkMap", iconData, addon.db["buttonsink"])
				buttonBag:Hide()
			else
				buttonBag:Show()
			end
		elseif addon.variables.buttonSink then
			removeButtonSink()
		end
	end

	function addon.functions.LayoutButtons()
		if addon.db["enableMinimapButtonBin"] then
			if addon.variables.buttonSink then
				local index = 0
				for name, button in pairs(addon.variables.bagButtons) do
					if addon.db["ignoreMinimapButtonBin_" .. name] then
						button:ClearAllPoints()
						button:SetParent(Minimap)
						if addon.variables.bagButtonPoint[name] then
							local pData = addon.variables.bagButtonPoint[name]
							if pData.point and pData.relativePoint and pData.relativeTo and pData.xOfs and pData.yOfs then
								button:SetPoint(pData.point, pData.relativeTo, pData.relativePoint, pData.xOfs, pData.yOfs)
							end
							if button:GetFrameStrata() == "LOW" then button:SetFrameStrata("MEDIUM") end
						end
					elseif addon.variables.bagButtonState[name] then
						index = index + 1
						button:ClearAllPoints()
						local col = (index - 1) % COLUMNS
						local row = math.floor((index - 1) / COLUMNS)

						button:SetParent(addon.variables.buttonSink)
						button:SetSize(ICON_SIZE, ICON_SIZE)
						button:SetPoint("TOPLEFT", addon.variables.buttonSink, "TOPLEFT", col * (ICON_SIZE + PADDING) + PADDING, -row * (ICON_SIZE + PADDING) - PADDING)
						button:Show()
					else
						button:Hide()
					end
				end

				local totalRows = math.ceil(index / COLUMNS)
				local width = (ICON_SIZE + PADDING) * COLUMNS + PADDING
				local height = (ICON_SIZE + PADDING) * totalRows + PADDING
				addon.variables.buttonSink:SetSize(width, height)
			end
		else
			for name, button in pairs(addon.variables.bagButtons) do
				button:ClearAllPoints()
				button:SetParent(Minimap)
				addon.variables.bagButtons[name] = nil
				addon.variables.bagButtonState[name] = nil
				if addon.variables.bagButtonPoint[name] then
					local pData = addon.variables.bagButtonPoint[name]
					if pData.point and pData.relativePoint and pData.relativeTo and pData.xOfs and pData.yOfs then
						button:SetPoint(pData.point, pData.relativeTo, pData.relativePoint, pData.xOfs, pData.yOfs)
					else
						LDBIcon:Show(name)
					end
					if button:GetFrameStrata() == "LOW" then button:SetFrameStrata("MEDIUM") end
					addon.variables.bagButtonPoint[name] = nil
				end
			end
		end
	end

	function addon.functions.gatherMinimapButtons()
		for _, child in ipairs({ Minimap:GetChildren() }) do
			if child:IsObjectType("Button") and child:GetName() then
				local btnName = child:GetName():gsub("^LibDBIcon10_", ""):gsub(".*_LibDBIcon_", "")
				if
					not (
						btnName == "MinimapZoomIn"
						or btnName == "MinimapZoomOut"
						or btnName == "MiniMapWorldMapButton"
						or btnName == "MiniMapTracking"
						or btnName == "GameTimeFrame"
						or btnName == "MinimapMailFrame"
						or btnName:match("^HandyNotesPin")
						or btnName == addonName .. "_ButtonSinkMap"
					)
				then
					if not addon.variables.bagButtonPoint[btnName] or not addon.variables.bagButtonPoint[btnName].point then
						local point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
						addon.variables.bagButtonPoint[btnName] = {
							point = point,
							relativeTo = relativeTo,
							relativePoint = relativePoint,
							xOfs = xOfs,
							yOfs = yOfs,
						}
					end
					if (child.db and child.db.hide) or not child:IsVisible() then
						addon.variables.bagButtonState[btnName] = false
					else
						addon.variables.bagButtonState[btnName] = true
						addon.variables.bagButtons[btnName] = child
					end
				end
			end
		end
	end
	hooksecurefunc(LDBIcon, "Show", function(self, name)
		if addon.db["enableMinimapButtonBin"] then
			if nil ~= addon.variables.bagButtonState[name] then addon.variables.bagButtonState[name] = true end
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()
		end
	end)

	hooksecurefunc(LDBIcon, "Hide", function(self, name)
		if addon.db["enableMinimapButtonBin"] then
			addon.variables.bagButtonState[name] = false
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()
		end
	end)

	local radioRows = {}
	local maxTextWidth = 0
	local rowHeight = 28 -- Höhe pro Zeile (Font + etwas Puffer)
	local totalRows = 0

	function addon.functions.updateLootspecIcon()
		if not LDBIcon or not LDBIcon:IsRegistered(addonName .. "_LootSpec") then return end

		local _, specIcon

		local curSpec = GetSpecialization()

		if GetLootSpecialization() == 0 and curSpec then
			_, _, _, specIcon = GetSpecializationInfoForClassID(addon.variables.unitClassID, curSpec)
		else
			_, _, _, specIcon = GetSpecializationInfoByID(GetLootSpecialization())
		end

		local button = LDBIcon.objects[addonName .. "_LootSpec"]
		if button and button.icon and specIcon then button.icon:SetTexture(specIcon) end
	end

	local function UpdateRadioSelection()
		local lootSpecID = GetLootSpecialization() or 0
		for _, row in ipairs(radioRows) do
			row.radio:SetChecked(row.specId == lootSpecID)
		end
	end

	local function CreateRadioRow(parent, specId, specName, index)
		totalRows = totalRows + 1

		local row = CreateFrame("Button", "MyRadioRow" .. index, parent, "BackdropTemplate")
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		row:GetHighlightTexture():SetAlpha(0.3)

		row.radio = CreateFrame("CheckButton", "$parentRadio", row, "UIRadioButtonTemplate")
		row.radio:SetPoint("LEFT", row, "LEFT", 4, 0)
		row.radio:SetChecked(false)

		row.radio.text:SetFontObject(GameFontNormalLarge)
		row.radio.text:SetText(specName)

		row:RegisterForClicks("AnyUp")
		row.radio:RegisterForClicks("AnyUp")

		local textWidth = row.radio.text:GetStringWidth()
		if textWidth > maxTextWidth then maxTextWidth = textWidth end

		row.specId = specId

		row:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				SetLootSpecialization(specId)
			else
				C_SpecializationInfo.SetSpecialization(index)
			end
		end)

		row.radio:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				SetLootSpecialization(specId)
			else
				C_SpecializationInfo.SetSpecialization(index)
			end
		end)

		table.insert(radioRows, row)
		return row
	end

	function addon.functions.removeLootspecframe()
		if LDBIcon:IsRegistered(addonName .. "_LootSpec") then
			local button = LDBIcon.objects[addonName .. "_LootSpec"]
			if button then button:Hide() end
			LDBIcon.objects[addonName .. "_LootSpec"] = nil
		end
		if addon.variables.lootSpec then
			addon.variables.lootSpec:SetParent(nil)
			addon.variables.lootSpec:SetScript("OnEvent", nil)
			addon.variables.lootSpec:Hide()
			addon.variables.lootSpec = nil
		end
	end

	local function hoverCheckHide(frame)
		if frame and frame:IsVisible() then
			if not MouseIsOver(frame) then
				frame:Hide()
			else
				C_Timer.After(1, function() hoverCheckHide(frame) end)
			end
		end
	end

	function addon.functions.createLootspecFrame()
		totalRows = 0
		radioRows = {}
		local lootSpec = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		lootSpec:SetPoint("CENTER")
		lootSpec:SetSize(200, 200) -- Erstmal ein Dummy-Wert, wir passen es später an
		lootSpec:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		lootSpec:SetBackdropColor(0, 0, 0, 0.4)
		lootSpec:SetBackdropBorderColor(1, 1, 1, 1)
		addon.variables.lootSpec = lootSpec
		lootSpec:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		lootSpec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		lootSpec:SetScript("OnEvent", function(self, event)
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then
				addon.functions.removeLootspecframe()
				addon.functions.createLootspecFrame()
			end
			addon.functions.updateLootspecIcon()
			UpdateRadioSelection()
		end)

		local container = CreateFrame("Frame", nil, lootSpec, "BackdropTemplate")
		container:SetPoint("TOPLEFT", 10, -10)
		if nil == GetSpecialization() then return end

		local _, curSpecName = GetSpecializationInfoForClassID(addon.variables.unitClassID, GetSpecialization())
		local totalSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(addon.variables.unitClassID)
		local row = CreateRadioRow(container, 0, string.format(LOOT_SPECIALIZATION_DEFAULT, curSpecName), 0)
		for i = 1, totalSpecs do
			local specID, specName, _, specIcon = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
			CreateRadioRow(container, specID, specName, i)
		end

		for i, row in ipairs(radioRows) do
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -(i - 1) * rowHeight)
			row:SetSize(maxTextWidth + 40, rowHeight)
		end

		local finalHeight = #radioRows * rowHeight + 20
		local finalWidth = math.max(maxTextWidth + 40, 150)

		container:SetSize(finalWidth, finalHeight)
		lootSpec:SetSize(finalWidth + 20, finalHeight + 20)

		local iconData = {
			type = "launcher",
			icon = "Interface\\ICONS\\INV_Misc_QuestionMark", -- irgendein Icon
			label = addonName .. "_LootSpec",
			OnEnter = function(self)
				if addon.variables.lootSpec then
					positionBagFrame(addon.variables.lootSpec, LDBIcon.objects[addonName .. "_LootSpec"])
					addon.variables.lootSpec:Show()
				end
			end,
			OnLeave = function(self)
				C_Timer.After(1, function() hoverCheckHide(addon.variables.lootSpec) end)
			end,
		}

		LDB:NewDataObject(addonName .. "_LootSpec", iconData)
		LDBIcon:Register(addonName .. "_LootSpec", iconData, addon.db["lootspec_quickswitch"])

		UpdateRadioSelection()
		lootSpec:Hide()
		addon.functions.updateLootspecIcon()
	end

	if addon.db["enableLootspecQuickswitch"] then addon.functions.createLootspecFrame() end
end

function addon.functions.createCatalystFrame()
	if addon.variables.catalystID then
		if addon.general.iconFrame then return end
		local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
		if cataclystInfo then
			local iconID = cataclystInfo.iconFileID

			addon.general.iconFrame = CreateFrame("Button", nil, PaperDollFrame, "BackdropTemplate")
			addon.general.iconFrame:SetSize(32, 32)
			addon.general.iconFrame:SetPoint("BOTTOMLEFT", PaperDollSidebarTab3, "BOTTOMRIGHT", 4, 0)

			addon.general.iconFrame.icon = addon.general.iconFrame:CreateTexture(nil, "OVERLAY")
			addon.general.iconFrame.icon:SetSize(32, 32)
			addon.general.iconFrame.icon:SetPoint("CENTER", addon.general.iconFrame, "CENTER")
			addon.general.iconFrame.icon:SetTexture(iconID)

			addon.general.iconFrame.count = addon.general.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
			addon.general.iconFrame.count:SetPoint("BOTTOMRIGHT", addon.general.iconFrame, "BOTTOMRIGHT", 1, 2)
			addon.general.iconFrame.count:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
			addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
			addon.general.iconFrame.count:SetTextColor(1, 0.82, 0)
			if addon.db["showCatalystChargesOnCharframe"] == false then addon.general.iconFrame:Hide() end
		end
	end
end

function addon.functions.createInstantCatalystButton()
	if not ItemInteractionFrame or EnhanceQoLInstantCatalyst then return end

	local parent = ItemInteractionFrame.ButtonFrame or ItemInteractionFrame
	local anchor = ItemInteractionFrame.TopTileStreaks

	local button = CreateFrame("Button", "EnhanceQoLInstantCatalyst", parent, "BackdropTemplate")
	button:SetSize(32, 32)
	button:SetEnabled(false)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(button)
	icon:SetTexture("Interface\\AddOns\\EnhanceQoL\\Icons\\InstantCatalyst.tga")
	button.icon = icon

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Instant Catalyst"])
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

	if anchor then
		button:SetPoint("RIGHT", anchor, "RIGHT", -2, 0)
	else
		button:SetPoint("BOTTOM", parent, "BOTTOM", 0, 4)
	end

	button:SetScript("OnClick", function() C_ItemInteraction.PerformItemInteraction() end)

	ItemInteractionFrame:HookScript("OnShow", function()
		button:SetEnabled(false)
		button.icon:SetDesaturated(true)
	end)
end

function addon.functions.toggleInstantCatalystButton(value)
	if not C_AddOns.IsAddOnLoaded("Blizzard_ItemInteractionUI") then return end
	if not ItemInteractionFrame then return end

	if value then
		if not EnhanceQoLInstantCatalyst then addon.functions.createInstantCatalystButton() end
		if EnhanceQoLInstantCatalyst then
			EnhanceQoLInstantCatalyst:Show()
			if ItemInteractionFrame:IsShown() then
				if not ItemInteractionFrame.ButtonFrame.ActionButton:IsEnabled() then
					EnhanceQoLInstantCatalyst:SetEnabled(false)
					EnhanceQoLInstantCatalyst.icon:SetDesaturated(true)
				else
					EnhanceQoLInstantCatalyst:SetEnabled(true)
					EnhanceQoLInstantCatalyst.icon:SetDesaturated(false)
				end
			end
		end
	elseif EnhanceQoLInstantCatalyst then
		EnhanceQoLInstantCatalyst:Hide()
	end
end

local function initCharacter()
	addon.functions.InitDBValue("showIlvlOnBankFrame", false)
	addon.functions.InitDBValue("showIlvlOnMerchantframe", false)
	addon.functions.InitDBValue("showIlvlOnCharframe", false)
	addon.functions.InitDBValue("showIlvlOnBagItems", false)
	addon.functions.InitDBValue("showBagFilterMenu", false)
	addon.functions.InitDBValue("bagFilterDockFrame", true)
	addon.functions.InitDBValue("showBindOnBagItems", false)
	addon.functions.InitDBValue("fadeBagQualityIcons", false)
	addon.functions.InitDBValue("showInfoOnInspectFrame", false)
	addon.functions.InitDBValue("showGemsOnCharframe", false)
	addon.functions.InitDBValue("showGemsTooltipOnCharframe", false)
	addon.functions.InitDBValue("showEnchantOnCharframe", false)
	addon.functions.InitDBValue("showCatalystChargesOnCharframe", false)
	addon.functions.InitDBValue("bagFilterFrameData", {})

	hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", addon.functions.updateBags)
	for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
		hooksecurefunc(frame, "UpdateItems", addon.functions.updateBags)
	end

       hooksecurefunc("MerchantFrame_UpdateMerchantInfo", updateMerchantButtonInfo)
       hooksecurefunc("MerchantFrame_UpdateBuybackInfo", updateBuybackButtonInfo)
       hooksecurefunc("EquipmentFlyout_DisplayButton", function(button) updateFlyoutButtonInfo(button) end)

	if _G.AccountBankPanel then
		hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", addon.functions.updateBags)
		hooksecurefunc(AccountBankPanel, "RefreshAllItemsForSelectedTab", addon.functions.updateBags)
		hooksecurefunc(AccountBankPanel, "UpdateSearchResults", addon.functions.updateBags)
	end

	-- Add Cataclyst charges in char frame
	addon.functions.createCatalystFrame()
	-- add durability icon on charframe

	addon.general.durabilityIconFrame = CreateFrame("Button", nil, PaperDollFrame, "BackdropTemplate")
	addon.general.durabilityIconFrame:SetSize(32, 32)
	addon.general.durabilityIconFrame:SetPoint("TOPLEFT", CharacterFramePortrait, "RIGHT", 4, 0)

	addon.general.durabilityIconFrame.icon = addon.general.durabilityIconFrame:CreateTexture(nil, "OVERLAY")
	addon.general.durabilityIconFrame.icon:SetSize(32, 32)
	addon.general.durabilityIconFrame.icon:SetPoint("CENTER", addon.general.durabilityIconFrame, "CENTER")
	addon.general.durabilityIconFrame.icon:SetTexture(addon.variables.durabilityIcon)

	addon.general.durabilityIconFrame.count = addon.general.durabilityIconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	addon.general.durabilityIconFrame.count:SetPoint("BOTTOMRIGHT", addon.general.durabilityIconFrame, "BOTTOMRIGHT", 1, 2)
	addon.general.durabilityIconFrame.count:SetFont(addon.variables.defaultFont, 12, "OUTLINE")

	if addon.db["showDurabilityOnCharframe"] == false then addon.general.durabilityIconFrame:Hide() end

	for key, value in pairs(addon.variables.itemSlots) do
		-- Hintergrund für das Item-Level
		value.ilvlBackground = value:CreateTexture(nil, "BACKGROUND")
		value.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
		value.ilvlBackground:SetPoint("TOPRIGHT", value, "TOPRIGHT", 1, 1)
		value.ilvlBackground:SetSize(30, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

		-- Roter Rahmen mit Farbverlauf
		if addon.variables.shouldEnchanted[key] or addon.variables.shouldEnchantedChecks[key] then
			value.borderGradient = value:CreateTexture(nil, "ARTWORK")
			value.borderGradient:SetPoint("TOPLEFT", value, "TOPLEFT", -2, 2)
			value.borderGradient:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 2, -2)
			value.borderGradient:SetColorTexture(1, 0, 0, 0.6) -- Grundfarbe Rot
			value.borderGradient:SetGradient("VERTICAL", CreateColor(1, 0, 0, 1), CreateColor(1, 0.3, 0.3, 0.5))
			value.borderGradient:Hide()
		end
		-- Text für das Item-Level
		value.ilvl = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		value.ilvl:SetPoint("TOPRIGHT", value.ilvlBackground, "TOPRIGHT", -1, -2) -- Position des Textes im Zentrum des Hintergrunds
		value.ilvl:SetFont(addon.variables.defaultFont, 14, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

		value.enchant = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		if addon.variables.itemSlotSide[key] == 0 then
			value.enchant:SetPoint("BOTTOMLEFT", value, "BOTTOMRIGHT", 2, 1)
		elseif addon.variables.itemSlotSide[key] == 2 then
			value.enchant:SetPoint("BOTTOMLEFT", value, "BOTTOMRIGHT", 2, 1)
		else
			value.enchant:SetPoint("BOTTOMRIGHT", value, "BOTTOMLEFT", -2, 1)
		end
		value.enchant:SetFont(addon.variables.defaultFont, 12, "OUTLINE")

		value.gems = {}
		for i = 1, 3 do
			value.gems[i] = CreateFrame("Frame", nil, PaperDollFrame)
			value.gems[i]:SetSize(16, 16) -- Setze die Größe des Icons

			if addon.variables.itemSlotSide[key] == 0 then
				value.gems[i]:SetPoint("TOPLEFT", value, "TOPRIGHT", 5 + (i - 1) * 16, -1) -- Verschiebe jedes Icon um 20px
			elseif addon.variables.itemSlotSide[key] == 1 then
				value.gems[i]:SetPoint("TOPRIGHT", value, "TOPLEFT", -5 - (i - 1) * 16, -1)
			else
				value.gems[i]:SetPoint("BOTTOM", value, "TOPLEFT", -1, 5 + (i - 1) * 16)
			end

			value.gems[i]:SetFrameStrata("HIGH")

			value.gems[i]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

			value.gems[i].icon = value.gems[i]:CreateTexture(nil, "OVERLAY")
			value.gems[i].icon:SetAllPoints(value.gems[i])
			value.gems[i].icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic") -- Setze die erhaltene Textur

			value.gems[i]:Hide()
		end
	end

	PaperDollFrame:HookScript("OnShow", function(self) setCharFrame() end)

	if OrderHallCommandBar then
		OrderHallCommandBar:HookScript("OnShow", function(self)
			if addon.db["hideOrderHallBar"] then
				self:Hide()
			else
				self:Show()
			end
		end)
		if addon.db["hideOrderHallBar"] then OrderHallCommandBar:Hide() end
	end
end

-- Frame-Position wiederherstellen
local function RestorePosition(frame)
	if addon.db.point and addon.db.x and addon.db.y then
		frame:ClearAllPoints()
		frame:SetPoint(addon.db.point, UIParent, addon.db.point, addon.db.x, addon.db.y)
	end
end

function addon.functions.checkReloadFrame()
	if addon.variables.requireReload == false then return end
	local reloadFrame = CreateFrame("Frame", "ReloadUIPopup", UIParent, "BasicFrameTemplateWithInset")
	reloadFrame:SetFrameStrata("TOOLTIP")
	reloadFrame:SetSize(500, 120) -- Breite und Höhe
	reloadFrame:SetPoint("TOP", UIParent, "TOP", 0, -200) -- Zentriert auf dem Bildschirm

	reloadFrame.title = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reloadFrame.title:SetPoint("TOP", reloadFrame, "TOP", 0, -6)
	reloadFrame.title:SetText(L["tReloadInterface"])

	reloadFrame.infoText = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	reloadFrame.infoText:SetPoint("CENTER", reloadFrame, "CENTER", 0, 10)
	reloadFrame.infoText:SetText(L["bReloadInterface"])

	local reloadButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
	reloadButton:SetSize(120, 30)
	reloadButton:SetPoint("BOTTOMLEFT", reloadFrame, "BOTTOMLEFT", 10, 10)
	reloadButton:SetText(RELOADUI)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)

	local cancelButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
	cancelButton:SetSize(120, 30)
	cancelButton:SetPoint("BOTTOMRIGHT", reloadFrame, "BOTTOMRIGHT", -10, 10)
	cancelButton:SetText(CANCEL)
	cancelButton:SetScript("OnClick", function()
		reloadFrame:Hide()
		addon.variables.requireReload = false -- disable the prompt on cancel
	end)

	reloadFrame:Show()
end

local function CreateUI()
	-- Create the main frame
	local frame = AceGUI:Create("Frame")
	addon.aceFrame = frame.frame
	frame:SetTitle("EnhanceQoL")
	frame:SetWidth(800)
	frame:SetHeight(600)
	frame:SetLayout("Fill")

	-- Frame wiederherstellen und überprfen, wenn das Addon geladen wird
	frame.frame:Hide()
	frame.frame:SetScript("OnShow", function(self) RestorePosition(self) end)
	frame.frame:SetScript("OnHide", function(self)
		local point, _, _, xOfs, yOfs = self:GetPoint()
		addon.db.point = point
		addon.db.x = xOfs
		addon.db.y = yOfs
		addon.functions.checkReloadFrame()
	end)
	addon.treeGroupData = {}

	-- Create the TreeGroup
	addon.treeGroup = AceGUI:Create("TreeGroup")
	addon.functions.addToTree(nil, {
		value = "general",
		text = L["General"],
		children = {
			{ value = "character", text = L["Character"] },
			{ value = "bags", text = HUD_EDIT_MODE_BAGS_LABEL },
			{ value = "cvar", text = "CVar" },
			{ value = "party", text = PARTY },
			{ value = "dungeon", text = L["Dungeon"] },
			{ value = "misc", text = L["Misc"] },
			{ value = "quest", text = L["Quest"] },
			{ value = "map", text = WORLD_MAP },
			{
				value = "ui",
				text = BUG_CATEGORY5,
				children = {
					{ value = "auctionhouse", text = BUTTON_LAG_AUCTIONHOUSE },
					{ value = "actionbar", text = ACTIONBARS_LABEL },
					{ value = "chatframe", text = HUD_EDIT_MODE_CHAT_FRAME_LABEL },
					{ value = "minimap", text = MINIMAP_LABEL },
					{ value = "unitframe", text = UNITFRAME_LABEL },
					{ value = "dynamicflight", text = DYNAMIC_FLIGHT },
				},
			},
		},
	})
	table.insert(addon.treeGroupData, {
		value = "profiles",
		text = L["Profiles"],
	})
	addon.treeGroup:SetLayout("Fill")
	addon.treeGroup:SetTree(addon.treeGroupData)
	addon.treeGroup:SetCallback("OnGroupSelected", function(container, _, group)
		container:ReleaseChildren() -- Entfernt vorherige Inhalte
		-- Prüfen, welche Gruppe ausgewählt wurde
		if group == "general\001misc" then
			addMiscFrame(container, true) -- Ruft die Funktion zum Hinzufügen der Misc-Optionen auf
		elseif group == "general\001quest" then
			addQuestFrame(container, true) -- Ruft die Funktion zum Hinzufügen der Quest-Optionen auf
		elseif group == "general\001cvar" then
			addCVarFrame(container, true) -- Ruft die Funktion zum Hinzufügen der CVar-Optionen auf
		elseif group == "general\001dungeon" then
			addDungeonFrame(container, true) -- Ruft die Funktion zum Hinzufügen der Dungeon-Optionen auf
		elseif group == "general\001character" then
			addCharacterFrame(container) -- Ruft die Funktion zum Hinzufügen der Character-Optionen auf
		elseif group == "general\001bags" then
			addBagFrame(container) -- Ruft die Funktion zum Hinzufügen der Character-Optionen auf
		elseif group == "general\001party" then
			addPartyFrame(container) -- Ruft die Funktion zum Hinzufügen der Party-Optionen auf
		elseif group == "general\001ui" then
			addUIFrame(container)
		elseif group == "general\001ui\001auctionhouse" then
			addAuctionHouseFrame(container)
		elseif group == "general\001ui\001actionbar" then
			addActionBarFrame(container)
		elseif group == "general\001ui\001unitframe" then
			addUnitFrame(container)
		elseif group == "general\001ui\001dynamicflight" then
			addDynamicFlightFrame(container)
		elseif group == "general\001ui\001chatframe" then
			addChatFrame(container)
		elseif group == "general\001ui\001minimap" then
			addMinimapFrame(container)
		elseif group == "general\001map" then
			addMapFrame(container)
		elseif group == "profiles" then
			local sub = AceGUI:Create("SimpleGroup")
			sub:SetFullWidth(true)
			sub:SetFullHeight(true)
			container:AddChild(sub)
			AceConfigDlg:Open("EQOL_Profiles", sub)
		elseif string.match(group, "^tooltip") then
			addon.Tooltip.functions.treeCallback(container, group)
		elseif string.match(group, "^vendor") then
			addon.Vendor.functions.treeCallback(container, group)
		elseif string.match(group, "^drink") then
			addon.Drinks.functions.treeCallback(container, group)
		elseif string.match(group, "^mythicplus") then
			addon.MythicPlus.functions.treeCallback(container, group)
		elseif string.match(group, "^aura") then
			addon.Aura.functions.treeCallback(container, group)
		elseif string.match(group, "^sound") then
			addon.Sounds.functions.treeCallback(container, group)
		elseif string.match(group, "^mouse") then
			addon.Mouse.functions.treeCallback(container, group)
		elseif string.match(group, "^move") then
			addon.LayoutTools.functions.treeCallback(container, group)
		end
	end)
	addon.treeGroup:SetStatusTable(addon.variables.statusTable)
	addon.variables.statusTable.groups["general\001ui"] = true
	frame:AddChild(addon.treeGroup)

	-- Select the first group by default
	addon.treeGroup:SelectByPath("general")

	-- Datenobjekt fr den Minimap-Button
	local EnhanceQoLLDB = LDB:NewDataObject("EnhanceQoL", {
		type = "launcher",
		text = addonName,
		icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\Icon.tga", -- Hier kannst du dein eigenes Icon verwenden
		OnClick = function(_, msg)
			if msg == "LeftButton" then
				if frame:IsShown() then
					frame:Hide()
				else
					frame:Show()
				end
			end
		end,
		OnTooltipShow = function(tt)
			tt:AddLine(addonName)
			tt:AddLine(L["Left-Click to show options"])
		end,
	})
	-- Toggle Minimap Button based on settings
	LDBIcon:Register(addonName, EnhanceQoLLDB, EnhanceQoLDB)

	-- Register to addon compartment
	AddonCompartmentFrame:RegisterAddon({
		text = "Enhance QoL",
		icon = "Interface\\AddOns\\EnhanceQoL\\Icons\\Icon.tga",
		notCheckable = true,
		func = function(button, menuInputData, menu)
			if frame:IsShown() then
				frame:Hide()
			else
				frame:Show()
			end
		end,
		funcOnEnter = function(button)
			MenuUtil.ShowTooltip(button, function(tooltip) tooltip:SetText(L["Left-Click to show options"]) end)
		end,
		funcOnLeave = function(button) MenuUtil.HideTooltip(button) end,
	})
end

local function setAllHooks()
	if RuneFrame then
		RuneFrame:HookScript("OnShow", function(self)
			if addon.db["deathknight_HideRuneFrame"] then
				RuneFrame:Hide()
			else
				RuneFrame:Show()
			end
		end)

		if addon.db["deathknight_HideRuneFrame"] then RuneFrame:Hide() end
	end

	if DruidComboPointBarFrame then
		DruidComboPointBarFrame:HookScript("OnShow", function(self)
			if addon.db["druid_HideComboPoint"] then
				DruidComboPointBarFrame:Hide()
			else
				DruidComboPointBarFrame:Show()
			end
		end)
		if addon.db["druid_HideComboPoint"] then DruidComboPointBarFrame:Hide() end
	end

	if EssencePlayerFrame then
		EssencePlayerFrame:HookScript("OnShow", function(self)
			if addon.db["evoker_HideEssence"] then EssencePlayerFrame:Hide() end
		end)
		if addon.db["evoker_HideEssence"] then EssencePlayerFrame:Hide() end -- Initialset
	end

	if MonkHarmonyBarFrame then
		MonkHarmonyBarFrame:HookScript("OnShow", function(self)
			if addon.db["monk_HideHarmonyBar"] then
				MonkHarmonyBarFrame:Hide()
			else
				MonkHarmonyBarFrame:Show()
			end
		end)
		if addon.db["monk_HideHarmonyBar"] then MonkHarmonyBarFrame:Hide() end
	end

	if RogueComboPointBarFrame then
		RogueComboPointBarFrame:HookScript("OnShow", function(self)
			if addon.db["rogue_HideComboPoint"] then
				RogueComboPointBarFrame:Hide()
			else
				RogueComboPointBarFrame:Show()
			end
		end)
		if addon.db["rogue_HideComboPoint"] then RogueComboPointBarFrame:Hide() end
	end

	if PaladinPowerBarFrame then
		PaladinPowerBarFrame:HookScript("OnShow", function(self)
			if addon.db["paladin_HideHolyPower"] then
				PaladinPowerBarFrame:Hide()
			else
				PaladinPowerBarFrame:Show()
			end
		end)
		if addon.db["paladin_HideHolyPower"] then PaladinPowerBarFrame:Hide() end
	end

	if TotemFrame then
		local classname = string.lower(select(2, UnitClass("player")))
		TotemFrame:HookScript("OnShow", function(self)
			if addon.db[classname .. "_HideTotemBar"] then
				TotemFrame:Hide()
			else
				TotemFrame:Show()
			end
		end)
		if addon.db[classname .. "_HideTotemBar"] then TotemFrame:Hide() end
	end

	if WarlockPowerFrame then
		WarlockPowerFrame:HookScript("OnShow", function(self)
			if addon.db["warlock_HideSoulShardBar"] then
				WarlockPowerFrame:Hide()
			else
				WarlockPowerFrame:Show()
			end
		end)
		if addon.db["warlock_HideSoulShardBar"] then WarlockPowerFrame:Hide() end
	end

	local function SortApplicants(applicants)
		if addon.db["lfgSortByRio"] then
			local function SortApplicantsCB(applicantID1, applicantID2)
				local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1)
				local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2)

				if applicantInfo1 == nil then return false end

				if applicantInfo2 == nil then return true end

				local _, _, localizedClass1, _, itemLevel1, _, tank1, healer1, damage1, assignedRole1, relationship1, dungeonScore1 = C_LFGList.GetApplicantMemberInfo(applicantInfo1.applicantID, 1)
				local _, _, localizedClass2, _, itemLevel2, _, tank2, healer2, damage2, assignedRole2, relationship2, dungeonScore2 = C_LFGList.GetApplicantMemberInfo(applicantInfo2.applicantID, 1)

				return dungeonScore1 > dungeonScore2
			end

			table.sort(applicants, SortApplicantsCB)
			LFGListApplicationViewer_UpdateResults(LFGListFrame.ApplicationViewer)
		end
	end

	hooksecurefunc("LFGListUtil_SortApplicants", SortApplicants)

	initCharacter()
	initMisc()
	initQuest()
	initDungeon()
	initParty()
	initActionBars()
	initUI()
	initUnitFrame()
	initChatFrame()
	initMap()
	initBagsFrame()
end

function loadMain()
	CreateUI()

	-- Schleife zur Erzeugung der Checkboxen
	addon.checkboxes = {}
	-- addon.db = EnhanceQoLDB
	addon.variables.acceptQuestID = {}

	setAllHooks()

	-- Slash-Command hinzufügen
	SLASH_ENHANCEQOL1 = "/eqol"
	SLASH_ENHANCEQOL2 = "/eqol resetframe"
	SLASH_ENHANCEQOL3 = "/eqol aag"
	SLASH_ENHANCEQOL4 = "/eqol rag"
	SLASH_ENHANCEQOL5 = "/eqol lag"
	SLASH_ENHANCEQOL6 = "/eqol lcid"
	SLASH_ENHANCEQOL6 = "/eqol rq"
	SlashCmdList["ENHANCEQOL"] = function(msg)
		if msg == "resetframe" then
			-- Frame zurücksetzen
			addon.aceFrame:ClearAllPoints()
			addon.aceFrame:SetPoint("CENTER", UIParent, "CENTER")
			addon.db.point = "CENTER"
			addon.db.x = 0
			addon.db.y = 0
			print(addonName .. " frame has been reset to the center.")
		elseif msg:match("^aag%s*(%d+)$") then
			local id = tonumber(msg:match("^aag%s*(%d+)$")) -- Extrahiere die ID
			if id then
				addon.db["autogossipID"][id] = true
				print(ADD, "ID: ", id)
			else
				print("|cffff0000Invalid input! Please provide a ID|r")
			end
		elseif msg:match("^rag%s*(%d+)$") then
			local id = tonumber(msg:match("^rag%s*(%d+)$")) -- Extrahiere die ID
			if id then
				if addon.db["autogossipID"][id] then
					addon.db["autogossipID"][id] = nil
					print(REMOVE, "ID: ", id)
				end
			else
				print("|cffff0000Invalid input! Please provide a ID|r")
			end
		elseif msg == "lag" then
			local options = C_GossipInfo.GetOptions()
			if #options > 0 then
				for _, v in pairs(options) do
					print(v.gossipOptionID, v.name)
				end
			end
		elseif msg == "lcid" then
			for i = 1, 600, 1 do
				local name, id = C_ChallengeMode.GetMapUIInfo(i)
				if name then print(name, id) end
			end
		elseif msg == "rq" then
			if addon.Query and addon.Query.frame then addon.Query.frame:Show() end
		else
			if addon.aceFrame:IsShown() then
				addon.aceFrame:Hide()
			else
				addon.aceFrame:Show()
			end
		end
	end

	-- Frame für die Optionen
	local configFrame = CreateFrame("Frame", addonName .. "ConfigFrame", InterfaceOptionsFramePanelContainer)
	configFrame.name = addonName

	-- Button fr die Optionen
	local configButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
	configButton:SetSize(140, 40)
	configButton:SetPoint("TOPLEFT", 10, -10)
	configButton:SetText("Config")
	configButton:SetScript("OnClick", function()
		if addon.aceFrame:IsShown() then
			addon.aceFrame:Hide()
		else
			addon.aceFrame:Show()
		end
	end)

	-- Frame zu den Interface-Optionen hinzufügen
	-- InterfaceOptions_AddCategory(configFrame)
	local category, layout = Settings.RegisterCanvasLayoutCategory(configFrame, configFrame.name)
	Settings.RegisterAddOnCategory(category)
	addon.settingsCategory = category
end

-- Erstelle ein Frame für Events
local frameLoad = CreateFrame("Frame")

local gossipClicked = {}

--@debug@
local wOpen = false -- Variable to ignore multiple checks for openItems
local function openItems(items)
	local function openNextItem()
		if #items == 0 then
			addon.functions.checkForContainer()
			return
		end

		if not MerchantFrame:IsShown() then
			local item = table.remove(items, 1)
			local iLoc = ItemLocation:CreateFromBagAndSlot(item.bag, item.slot)
			-- if iLoc then
			-- 	if C_Item.IsLocked(iLoc) then C_Item.UnlockItem(iLoc) end
			-- end
			C_Timer.After(0.1, function()
				C_Container.UseContainerItem(item.bag, item.slot)
				C_Timer.After(0.4, openNextItem) -- 100ms Pause zwischen den Verkäufen
			end)
		end
	end
	openNextItem()
end
function addon.functions.checkForContainer()
	local itemsToOpen = {}
	for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
			if containerInfo then
				local eItem = Item:CreateFromBagAndSlot(bag, slot)
				if eItem and not eItem:IsItemEmpty() then
					eItem:ContinueOnItemLoad(function()
						local tooltip = C_TooltipInfo.GetBagItem(bag, slot)
						if tooltip then
							for i, line in ipairs(tooltip.lines) do
								if line.leftText == ITEM_COSMETIC_LEARN then
									table.insert(itemsToOpen, { bag = bag, slot = slot })
								elseif line.leftText == ITEM_OPENABLE then
									table.insert(itemsToOpen, { bag = bag, slot = slot })
								end
							end
						end
					end)
				end
			end
		end
	end
	if #itemsToOpen > 0 then
		openItems(itemsToOpen)
	else
		wOpen = false
	end
end
--@end-debug@

local function loadSubAddon(name)
	local subAddonName = name

	local loadable, reason = C_AddOns.IsAddOnLoadable(name)
	if not loadable and reason == "DEMAND_LOADED" then
		local loaded, value = C_AddOns.LoadAddOn(name)
	end
end

local eventHandlers = {
	["ACTIVE_PLAYER_SPECIALIZATION_CHANGED"] = function(arg1)
		addon.variables.unitSpec = GetSpecialization()
		if addon.variables.unitSpec then
			addon.variables.unitSpecName = select(2, GetSpecializationInfo(addon.variables.unitSpec))
			addon.variables.unitRole = GetSpecializationRole(GetSpecialization())
		end

		if addon.db["showIlvlOnBagItems"] then
			addon.functions.updateBags(ContainerFrameCombinedBags)
			for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
				addon.functions.updateBags(frame)
			end
			if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end
		end
	end,
	["ADDON_LOADED"] = function(arg1)
		if arg1 == addonName then
			local legacy = {}
			if EnhanceQoLDB and not EnhanceQoLDB.profiles then
				for k, v in pairs(EnhanceQoLDB) do
					legacy[k] = v
				end
			end

			local dbObj = AceDB:New("EnhanceQoLDB", defaults, "Default")

			addon.dbObject = dbObj
			addon.db = dbObj.profile
			dbObj:RegisterCallback("OnProfileChanged", function() addon.variables.requireReload = true end)
			dbObj:RegisterCallback("OnProfileCopied", function() addon.variables.requireReload = true end)
			dbObj:RegisterCallback("OnProfileReset", function() addon.variables.requireReload = true end)

			if next(legacy) then
				for k, v in pairs(legacy) do
					if addon.db[k] == nil then addon.db[k] = v end
					EnhanceQoLDB[k] = nil
				end
			end
			local profilesPage = AceDBOptions:GetOptionsTable(addon.dbObject)
			AceConfig:RegisterOptionsTable("EQOL_Profiles", profilesPage)

			loadMain()
			EQOL.PersistSignUpNote()

			--@debug@
			loadSubAddon("EnhanceQoLAura")
			loadSubAddon("EnhanceQoLLayoutTools")
			loadSubAddon("EnhanceQoLQuery")
			--@end-debug@
			loadSubAddon("EnhanceQoLSound")
			loadSubAddon("EnhanceQoLMouse")
			loadSubAddon("EnhanceQoLMythicPlus")
			loadSubAddon("EnhanceQoLDrinkMacro")
			loadSubAddon("EnhanceQoLTooltip")
			loadSubAddon("EnhanceQoLVendor")

			checkBagIgnoreJunk()
		end
		if arg1 == "Blizzard_ItemInteractionUI" then addon.functions.toggleInstantCatalystButton(addon.db["instantCatalystEnabled"]) end
	end,
	--@debug@
	["BAG_UPDATE_DELAYED"] = function(arg1)
		if addon.db["automaticallyOpenContainer"] then
			if wOpen then return end
			wOpen = true
			addon.functions.checkForContainer()
		end
	end,
	--@end-debug@
	["BANKFRAME_OPENED"] = function()
		if not addon.db["showIlvlOnBankFrame"] then return end
		for slot = 1, NUM_BANKGENERIC_SLOTS do
			local itemButton = _G["BankFrameItem" .. slot]
			if itemButton then addon.functions.updateBank(itemButton, -1, slot) end
		end
	end,
	["CURRENCY_DISPLAY_UPDATE"] = function(arg1)
		if arg1 == addon.variables.catalystID and addon.variables.catalystID then
			local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
			addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
		end
	end,
	["ENCHANT_SPELL_COMPLETED"] = function(arg1, arg2)
		if PaperDollFrame:IsShown() and addon.db["showEnchantOnCharframe"] and arg1 == true and arg2 and arg2.equipmentSlotIndex then
			C_Timer.After(1, function() setIlvlText(addon.variables.itemSlots[arg2.equipmentSlotIndex], arg2.equipmentSlotIndex) end)
		end
	end,
	["GOSSIP_CLOSED"] = function()
		gossipClicked = {} -- clear all already clicked gossips
	end,
	["GOSSIP_SHOW"] = function()
		if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
			if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then return end

			local options = C_GossipInfo.GetOptions()

			local aQuests = C_GossipInfo.GetAvailableQuests()

			if C_GossipInfo.GetNumActiveQuests() > 0 then
				for i, quest in pairs(C_GossipInfo.GetActiveQuests()) do
					if quest.isComplete then C_GossipInfo.SelectActiveQuest(quest.questID) end
				end
			end

			if #aQuests > 0 then
				for i, quest in pairs(aQuests) do
					if addon.db["ignoreTrivialQuests"] and quest.isTrivial then
					-- ignore trivial
					elseif addon.db["ignoreDailyQuests"] and (quest.frequency > 0) then
						-- ignore daily/weekly
					elseif addon.db["ignoreWarbandCompleted"] and C_QuestLog.IsQuestFlaggedCompletedOnAccount(quest.questID) then
						-- ignore warband completed
					else
						C_GossipInfo.SelectAvailableQuest(quest.questID)
					end
				end
			else
				if options and #options > 0 then
					if #options > 1 then
						for _, v in pairs(options) do
							if v.gossipOptionID and addon.db["autogossipID"][v.gossipOptionID] then C_GossipInfo.SelectOption(v.gossipOptionID) end
							if v.flags == 1 then
								-- 1 könnte "Quest abgabe" sein
								C_GossipInfo.SelectOption(v.gossipOptionID)
								return
							end
						end
					elseif #options == 1 and options[1] and not gossipClicked[options[1].gossipOptionID] then
						gossipClicked[options[1].gossipOptionID] = true
						C_GossipInfo.SelectOption(options[1].gossipOptionID)
					end
				end
			end
		end
	end,
	["GUILDBANK_UPDATE_MONEY"] = function()
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	end,
	["LFG_ROLE_CHECK_SHOW"] = function()
		if addon.db["groupfinderSkipRoleSelect"] and UnitInParty("player") then skipRolecheck() end
	end,
	["LFG_LIST_APPLICANT_UPDATED"] = function()
		if PVEFrame:IsShown() and addon.db["lfgSortByRio"] then C_LFGList.RefreshApplicants() end
		if InCombatLockdown() then return end
		if addon.db["groupfinderAppText"] then toggleGroupApplication(true) end
	end,
	["LOOT_READY"] = function()
		if addon.db["autoQuickLoot"] and not IsShiftKeyDown() then
			for i = 1, GetNumLootItems() do
				C_Timer.After(0.1, function() LootSlot(i) end)
			end
		end
	end,
	["INSPECT_READY"] = function(arg1)
		if addon.db["showInfoOnInspectFrame"] then onInspect(arg1) end
	end,
	["ITEM_INTERACTION_ITEM_SELECTION_UPDATED"] = function(arg1)
		if not ItemInteractionFrame or not ItemInteractionFrame:IsShown() then return end
		if not EnhanceQoLInstantCatalyst then return end
		EnhanceQoLInstantCatalyst:SetEnabled(false)
		EnhanceQoLInstantCatalyst.icon:SetDesaturated(true)
		if arg1 ~= nil then
			local item
			if arg1.bagID and arg1.slotIndex then
				item = ItemLocation:CreateFromBagAndSlot(arg1.bagID, arg1.slotIndex)
			elseif arg1.equipmentSlotIndex then
				item = ItemLocation:CreateFromEquipmentSlot(arg1.equipmentSlotIndex)
			end
			if not item then return end
			local conversionCost = C_ItemInteraction.GetItemConversionCurrencyCost(item)
			if not conversionCost then return end
			if conversionCost.amount > 0 and conversionCost.currencyID ~= 0 then
				local cInfo = C_CurrencyInfo.GetCurrencyInfo(conversionCost.currencyID)
				if not cInfo then return end
				if cInfo.quantity == 0 then return end
			end
			EnhanceQoLInstantCatalyst:SetEnabled(true)
			EnhanceQoLInstantCatalyst.icon:SetDesaturated(false)
		end
	end,
	["INVENTORY_SEARCH_UPDATE"] = function()
		if addon.db["showBagFilterMenu"] then
			addon.functions.updateBags(ContainerFrameCombinedBags)
			for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
				addon.functions.updateBags(frame)
			end
			if _G.AccountBankPanel and _G.AccountBankPanel:IsShown() then addon.functions.updateBags(_G.AccountBankPanel) end
		end
	end,
	["PARTY_INVITE_REQUEST"] = function(unitName, arg2, arg3, arg4, arg5, arg6, unitID, arg8)
		if addon.db["autoAcceptGroupInvite"] then
			if addon.db["autoAcceptGroupInviteGuildOnly"] then
				local gMember = GetNumGuildMembers()
				if gMember then
					for i = 1, gMember do
						local name = GetGuildRosterInfo(i)
						if name == unitName then
							AcceptGroup()
							StaticPopup_Hide("PARTY_INVITE")
							return
						end
					end
				end
			end
			if addon.db["autoAcceptGroupInviteFriendOnly"] then
				if C_BattleNet.GetGameAccountInfoByGUID(unitID) then
					AcceptGroup()
					StaticPopup_Hide("PARTY_INVITE")
					return
				end
				for i = 1, C_FriendList.GetNumFriends() do
					local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
					if friendInfo.guid == unitID then
						AcceptGroup()
						StaticPopup_Hide("PARTY_INVITE")
						return
					end
				end
			end
			if not addon.db["autoAcceptGroupInviteGuildOnly"] and not addon.db["autoAcceptGroupInviteFriendOnly"] then
				AcceptGroup()
				StaticPopup_Hide("PARTY_INVITE")
			end
		end
	end,
	["PLAYERBANKSLOTS_CHANGED"] = function(arg1)
		if not addon.db["showIlvlOnBankFrame"] then return end
		local itemButton = _G["BankFrameItem" .. arg1]
		if itemButton then addon.functions.updateBank(itemButton, -1, arg1) end
	end,
	["PLAYER_CHOICE_UPDATE"] = function()
		if select(3, GetInstanceInfo()) == 208 and addon.db["autoChooseDelvePower"] then
			local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()
			if choiceInfo and choiceInfo.options and #choiceInfo.options == 1 then
				C_PlayerChoice.SendPlayerChoiceResponse(choiceInfo.options[1].buttons[1].id)
				if PlayerChoiceFrame:IsShown() then PlayerChoiceFrame:Hide() end
			end
		end
	end,
	["PLAYER_DEAD"] = function()
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	end,
	["PLAYER_EQUIPMENT_CHANGED"] = function(arg1)
		if addon.variables.itemSlots[arg1] and PaperDollFrame:IsShown() then setIlvlText(addon.variables.itemSlots[arg1], arg1) end
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	end,
	["PLAYER_INTERACTION_MANAGER_FRAME_SHOW"] = function(arg1)
		if arg1 == 53 and addon.db["openCharframeOnUpgrade"] then
			if CharacterFrame:IsShown() == false then ToggleCharacter("PaperDollFrame") end
		end
	end,
	["PLAYER_LOGIN"] = function()
		if addon.db["enableMinimapButtonBin"] then addon.functions.toggleButtonSink() end
		addon.variables.unitSpec = GetSpecialization()
		if addon.variables.unitSpec then
			addon.variables.unitSpecName = select(2, GetSpecializationInfo(addon.variables.unitSpec))
			addon.variables.unitRole = GetSpecializationRole(GetSpecialization())
		end

		addon.db["moneyTracker"][UnitGUID("player")] = {
			name = UnitName("player"),
			realm = GetRealmName(),
			money = GetMoney(),
			class = select(2, UnitClass("player")),
		}
		if addon.ChatIM then addon.ChatIM:BuildSoundTable() end
	end,
	["PLAYER_MONEY"] = function()
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
		if addon.db["moneyTracker"][UnitGUID("player")]["money"] then addon.db["moneyTracker"][UnitGUID("player")]["money"] = GetMoney() end
	end,
	["PLAYER_REGEN_ENABLED"] = function()
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	end,
	["PLAYER_UNGHOST"] = function()
		if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
	end,
	["QUEST_COMPLETE"] = function()
		if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
			local numQuestRewards = GetNumQuestChoices()
			if numQuestRewards > 1 then
			elseif numQuestRewards == 1 then
				GetQuestReward(1)
			else
				GetQuestReward()
			end
		end
	end,
	["QUEST_DATA_LOAD_RESULT"] = function(arg1)
		if arg1 and addon.variables.acceptQuestID[arg1] and addon.db["autoChooseQuest"] then
			if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then return end
			if addon.db["ignoreDailyQuests"] and addon.functions.IsQuestRepeatableType(arg1) then return end
			if addon.db["ignoreTrivialQuests"] and C_QuestLog.IsQuestTrivial(arg1) then return end
			if addon.db["ignoreWarbandCompleted"] and C_QuestLog.IsQuestFlaggedCompletedOnAccount(arg1) then return end

			AcceptQuest()
			if QuestFrame:IsShown() then QuestFrame:Hide() end -- Sometimes the frame is still stuck - hide it forcefully than
		end
	end,
	["QUEST_DETAIL"] = function()
		if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
			if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then return end

			local id = GetQuestID()
			addon.variables.acceptQuestID[id] = true
			C_QuestLog.RequestLoadQuestByID(id)
		end
	end,
	["QUEST_GREETING"] = function()
		if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
			if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then return end
			for i = 1, GetNumAvailableQuests() do
				if addon.db["ignoreTrivialQuests"] and IsAvailableQuestTrivial(i) then
				else
					SelectAvailableQuest(i)
				end
			end
			for i = 1, GetNumActiveQuests() do
				if select(2, GetActiveTitle(i)) then SelectActiveQuest(i) end
			end
		end
	end,
	["QUEST_PROGRESS"] = function()
		if addon.db["autoChooseQuest"] and not IsShiftKeyDown() and IsQuestCompletable() then CompleteQuest() end
	end,
	["SOCKET_INFO_UPDATE"] = function()
		if PaperDollFrame:IsShown() and addon.db["showGemsOnCharframe"] then C_Timer.After(0.5, function() setCharFrame() end) end
	end,
	["ZONE_CHANGED_NEW_AREA"] = function()
		if addon.variables.hookedOrderHall == false then
			local ohcb = OrderHallCommandBar
			if ohcb then
				ohcb:HookScript("OnShow", function(self)
					if addon.db["hideOrderHallBar"] then
						self:Hide()
					else
						self:Show()
					end
				end)
				addon.variables.hookedOrderHall = true
				if addon.db["hideOrderHallBar"] then OrderHallCommandBar:Hide() end
			end
		end
	end,

	["AUCTION_HOUSE_SHOW"] = function()
		if not addon.db["persistAuctionHouseFilter"] then return end
		if not AuctionHouseFrame.SearchBar.FilterButton.eqolHooked then
			hooksecurefunc(AuctionHouseFrame.SearchBar.FilterButton, "Reset", function(self)
				if not addon.db["persistAuctionHouseFilter"] or not addon.variables.safedAuctionFilters then return end
				if addon.variables.safedAuctionFilters then AuctionHouseFrame.SearchBar.FilterButton.filters = addon.variables.safedAuctionFilters end
				AuctionHouseFrame.SearchBar.FilterButton.minLevel = addon.variables.safedAuctionMinlevel
				AuctionHouseFrame.SearchBar.FilterButton.maxLevel = addon.variables.safedAuctionMaxlevel
				addon.variables.safedAuctionFilters = nil
				self.ClearFiltersButton:Show()
			end)
			AuctionHouseFrame.SearchBar.FilterButton.eqolHooked = true
		end
	end,
	["AUCTION_HOUSE_CLOSED"] = function()
		if not addon.db["persistAuctionHouseFilter"] then return end
		if AuctionHouseFrame.SearchBar.FilterButton.ClearFiltersButton:IsShown() then
			addon.variables.safedAuctionFilters = AuctionHouseFrame.SearchBar.FilterButton.filters
			addon.variables.safedAuctionMinlevel = AuctionHouseFrame.SearchBar.FilterButton.minLevel
			addon.variables.safedAuctionMaxlevel = AuctionHouseFrame.SearchBar.FilterButton.maxLevel
		else
			addon.variables.safedAuctionFilters = nil
		end
	end,
}

local function registerEvents(frame)
	for event in pairs(eventHandlers) do
		frame:RegisterEvent(event)
	end
end

local function eventHandler(self, event, ...)
	if eventHandlers[event] then
		if addon.Performance and addon.Performance.MeasurePerformance then
			addon.Performance.MeasurePerformance(addonName, event, eventHandlers[event], ...)
		else
			-- Normale Event-Verarbeitung
			eventHandlers[event](...)
		end
		-- if eventHandlers[event] then
		-- eventHandlers[event](...)
	end
end

registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)
