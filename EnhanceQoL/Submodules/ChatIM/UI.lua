-- luacheck: globals CENSORED_MESSAGE_HIDDEN CENSORED_MESSAGE_REPORT
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local AceGUI = addon.AceGUI
local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")

local function colorWrap(hex, text) return "|cff" .. hex .. text .. "|r" end

addon.ChatIM = addon.ChatIM or {}

local ChatIM = addon.ChatIM
ChatIM.maxHistoryLines = ChatIM.maxHistoryLines or (addon.db and addon.db["chatIMMaxHistory"]) or 250

local MU = MenuUtil -- global ab 11.0+

local regionTable = { "US", "KR", "EU", "TW", "CN" }
local regionKey = regionTable[GetCurrentRegion()] or "EU" -- or EU for PTR because that is region 90+

local function PlayerMenuGenerator(_, root, targetName, isBN, bnetID)
	root:CreateTitle(targetName)

	local unit, riolink, wclLink
	if isBN and bnetID then
		local info = C_BattleNet.GetAccountInfoByID(bnetID)
		if info and info.gameAccountInfo then
			-- check for online and same game version
			if
				info.gameAccountInfo.isOnline
				and WOW_PROJECT_ID == info.gameAccountInfo.wowProjectID
				and BNET_CLIENT_WOW == info.gameAccountInfo.clientProgram
				and info.gameAccountInfo.regionID == GetCurrentRegion()
			then
				unit = info.gameAccountInfo.characterName .. "-" .. info.gameAccountInfo.realmName
				riolink = "https://raider.io/characters/"
					.. string.lower(regionKey)
					.. "/"
					.. string.lower(info.gameAccountInfo.realmDisplayName:gsub("%s", "-"))
					.. "/"
					.. info.gameAccountInfo.characterName
				wclLink = "https://www.warcraftlogs.com/character/"
					.. string.lower(regionKey)
					.. "/"
					.. string.lower(info.gameAccountInfo.realmDisplayName:gsub("%s", "-"))
					.. "/"
					.. info.gameAccountInfo.characterName
			end
		end
	else
		if nil == targetName:match("-") then
			-- no minus means same realm so get my realm and add it
			targetName = targetName .. "-" .. (GetRealmName()):gsub("%s", "")
		end
		unit = targetName
		if targetName:match("-") then
			local char, realm = targetName:match("^([^%-]+)%-(.+)$")
			if char and realm then
				riolink = "https://raider.io/characters/" .. string.lower(regionKey) .. "/" .. string.lower(realm:gsub("%s+", "-")) .. "/" .. char
				wclLink = "https://www.warcraftlogs.com/character/" .. string.lower(regionKey) .. "/" .. string.lower(realm:gsub("%s+", "-")) .. "/" .. char
			end
		end
	end
	if unit then
		root:CreateDivider()
		root:CreateTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		root:CreateButton(INVITE, function(unit) C_PartyInfo.InviteUnit(unit) end, unit)
		root:CreateDivider()
		root:CreateTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER)
		root:CreateButton(COPY_CHARACTER_NAME, function(unit) StaticPopup_Show("EQOL_URL_COPY", nil, nil, unit) end, unit)
	end

	if not isBN and unit then
		local label = C_FriendList.IsIgnored(targetName) and UNIGNORE_QUEST or IGNORE
		local function toggleIgnore(name) ChatIM:ToggleIgnore(name) end
		root:CreateButton(label, toggleIgnore, targetName)
	end

	if riolink and addon.db["enableChatIMRaiderIO"] then
		root:CreateDivider()
		root:CreateTitle("RaiderIO")
		root:CreateButton(L["RaiderIOUrl"], function(link) StaticPopup_Show("EQOL_URL_COPY", nil, nil, link) end, riolink)
	end
	if wclLink and addon.db["enableChatIMWCL"] then
		root:CreateDivider()
		root:CreateTitle("Warcraftlogs")
		root:CreateButton(L["WCLUrl"], function(link) StaticPopup_Show("EQOL_URL_COPY", nil, nil, link) end, wclLink)
	end
end

StaticPopupDialogs["EQOL_URL_COPY"] = {
	text = CALENDAR_COPY_EVENT,
	button1 = CLOSE,
	hasEditBox = true,
	editBoxWidth = 320,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(self, data)
		self.editBox:SetText(data or "")
		self.editBox:SetFocus()
		self.editBox:HighlightText()
	end,
}

StaticPopupDialogs["EQOL_LINK_WARNING"] = {
	text = L["communityWarningLink"],
	button1 = CLOSE,
	hasEditBox = false,
	editBoxWidth = 320,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

ChatIM.storage = ChatIM.storage or CreateFrame("Frame")
ChatIM.activeGroup = nil
ChatIM.activeTab = nil
ChatIM.insertLinkHooked = ChatIM.insertLinkHooked or false
ChatIM.hooksSet = ChatIM.hooksSet or false
ChatIM.inactiveAlpha = 0.6
ChatIM.pendingShow = false
ChatIM.wasOpenBeforeCombat = false
ChatIM.soundQueue = {}
ChatIM.inCombat = false

function ChatIM:UpdateAlpha()
	if not addon.db["enableChatIMFade"] then return end
	if not self.frame then return end
	local tab = self.activeTab and self.tabs[self.activeTab]
	local focus = MouseIsOver(self.frame) or (tab and tab.edit and tab.edit:HasFocus())
	if focus then
		self.frame:SetAlpha(1)
	else
		self.frame:SetAlpha(self.inactiveAlpha)
	end
end

function ChatIM:SetMaxHistoryLines(val)
	self.maxHistoryLines = val or self.maxHistoryLines or 250
	if self.history then
		for partner, lines in pairs(self.history) do
			while #lines > self.maxHistoryLines do
				table.remove(lines, 1)
			end
		end
	end
end

function ChatIM:FormatURLs(text)
	local function repl(url) return "|Hurl:" .. url .. "|h[|cffffffff" .. url .. "|r]|h" end
	text = text:gsub("https?://%S+", repl)
	text = text:gsub("www%.%S+", repl)
	return text
end

function ChatIM:HookInsertLink()
	if self.insertLinkHooked then return end
	hooksecurefunc("ChatEdit_InsertLink", function(link)
		local tab = ChatIM.activeTab and ChatIM.tabs[ChatIM.activeTab]
		if link and tab and tab.edit and tab.edit:HasFocus() then
			tab.edit:Insert(link)
			return true
		end
	end)
	self.insertLinkHooked = true
end

function ChatIM:CreateUI()
	if self.widget then return end
	self:HookInsertLink()
	local frame = AceGUI:Create("Window")
	frame:SetTitle(L["Instant Chats"])
	frame:SetWidth(400)
	frame:SetHeight(300)
	frame:SetLayout("Fill")
	frame:SetCallback("OnClose", function() ChatIM:HideWindow() end)
	frame:SetStatusTable(addon.db.chatIMFrameData)
	frame.frame:SetAlpha(0.4)
	frame.frame:HookScript("OnEnter", function() ChatIM:UpdateAlpha() end)
	frame.frame:HookScript("OnLeave", function()
		C_Timer.After(5, function() ChatIM:UpdateAlpha() end)
	end)
	frame.frame:SetFrameStrata("MEDIUM")
	frame.frame:Hide()

	local tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetCallback("OnGroupSelected", function(widget, _, value) ChatIM:SelectTab(widget, value) end)
	frame:AddChild(tabGroup)

	self.widget = frame
	self.frame = frame.frame
	self.tabGroup = tabGroup
	self.tabs = {}
	self.tabList = {}

	if not self.hooksSet then
		self.frame:HookScript("OnMouseDown", ChatIM.ClearEditFocus)
		WorldFrame:HookScript("OnMouseDown", ChatIM.ClearEditFocus)
		self.hooksSet = true
	end

	self:UpdateAlpha()
end

function ChatIM:RefreshTabCallbacks()
	if not self.tabGroup or not self.tabGroup.tabs then return end
	for _, btn in ipairs(self.tabGroup.tabs) do
		if not btn.hooked then
			btn:SetScript("OnMouseDown", function(frame, button)
				if button == "RightButton" then ChatIM:RemoveTab(frame.value) end
			end)
			btn.hooked = true
		end
		-- update text for unread indicator
		local data = ChatIM.tabs[btn.value]
		if data and data.label then btn:SetText(data.label) end
	end
end

function ChatIM:SelectTab(widget, value)
	if self.activeTab == value then return end

	if self.activeGroup then
		AceGUI:Release(self.activeGroup)
		self.activeGroup = nil
	end

	if self.activeTab then
		local old = self.tabs[self.activeTab]
		if old and old.msg then
			old.msg:SetParent(self.storage)
			old.msg:Hide()
			if old.edit then
				old.edit:SetParent(ChatIM.storage)
				old.edit:Hide()
			end
			old.group = nil
		end
	end

	self.activeTab = value

	local tab = self.tabs[value]
	if not tab then return end
	tab.unread = false
	self:StopTabFlash(value)

	local group = AceGUI:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetFullHeight(true)
	tab.msg:SetParent(group.frame)
	tab.msg:Show()
	-- ensure the message frame fills the new parent
	tab.msg:ClearAllPoints()
	tab.msg:SetPoint("TOPLEFT", group.frame, "TOPLEFT", 0, -2)
	tab.msg:SetPoint("TOPRIGHT", group.frame, "TOPRIGHT", 0, -2)
	tab.msg:SetPoint("BOTTOMLEFT", group.frame, "BOTTOMLEFT", 0, 28)

	if tab.edit then
		tab.edit:SetParent(group.frame)
		tab.edit:ClearAllPoints()
		tab.edit:SetPoint("LEFT", group.frame, "LEFT", 0, 2)
		tab.edit:SetPoint("RIGHT", group.frame, "RIGHT", 0, 2)
		tab.edit:SetPoint("BOTTOM", group.frame, "BOTTOM", 0, 2)
		tab.edit:Show()
	end

	widget:AddChild(group)
	tab.group = group
	self.activeGroup = group
	self:UpdateTabLabel(value)
end

function ChatIM:CreateTab(sender, isBN, bnetID, battleTag)
	self:CreateUI()
	if self.tabs[sender] then return end

	local displayName = Ambiguate(sender, "short")

	if isBN and not battleTag and bnetID then
		local info = C_BattleNet.GetAccountInfoByID(bnetID)
		if info then battleTag = info.battleTag end
	end

	local smf = CreateFrame("ScrollingMessageFrame", nil, ChatIM.storage)
	-- we'll anchor later when the tab becomes active
	smf:SetAllPoints(ChatIM.storage)
	smf:SetFontObject(ChatFontNormal)
	smf:SetJustifyH("LEFT")
	smf:SetFading(false)
	smf:SetMaxLines(ChatIM.maxHistoryLines)
	smf:SetHyperlinksEnabled(true)
	-- enable wheel scrolling
	smf:EnableMouseWheel(true)
	smf:SetScript("OnMouseWheel", function(frame, delta)
		if delta > 0 then
			if IsShiftKeyDown() then
				frame:ScrollToTop()
			else
				frame:ScrollUp()
			end
		elseif delta < 0 then
			if IsShiftKeyDown() then
				frame:ScrollToBottom()
			else
				frame:ScrollDown()
			end
		end
	end)
	smf:SetScript("OnHyperlinkClick", function(frame, linkData, text, button)
		local linkType, payload = linkData:match("^(%a+):(.+)$")

		if linkType == "url" then
			StaticPopup_Show("EQOL_URL_COPY", nil, nil, payload)
			return
		end

		if linkType == "player" or linkType == "BNplayer" then
			if button == "RightButton" then
				local name = Ambiguate(payload:match("^[^:]+"), "none")
				local bn = linkType == "BNplayer"
				MU.CreateContextMenu(frame, PlayerMenuGenerator, name, bn, bnetID)
			end
			return
		end
		if linkType == "clubTicket" then
			-- Special case - because of Taint need to funnel it through blizzard frame
			StaticPopup_Show("EQOL_LINK_WARNING", nil, nil, payload)
			DEFAULT_CHAT_FRAME:AddMessage(text)
			return
		end

		if linkType == "censoredmessage" then
			local _, censorID = string.split(":", linkData)
			if censorID then
				_G.C_ChatInfo.UncensorChatLine(censorID)
				local text = C_ChatInfo.GetChatLineText(censorID)
				if text then
					text = ChatIM:FormatURLs(text)
					local hidden = CENSORED_MESSAGE_HIDDEN:format(sender, censorID)
					local report = CENSORED_MESSAGE_REPORT:format(censorID)
					local tabData = ChatIM.tabs[sender]
					local key = tabData and tabData.isBN and tabData.battleTag or sender
					local history = key and ChatIM.history[key]
					local replaced
					if history then
						for i, line in ipairs(history) do
							if line:find(hidden, 1, true) then
								local escHidden = hidden:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
								local escReport = report:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
								history[i] = line:gsub(escHidden, text, 1):gsub(escReport, "", 1)
								replaced = true
								break
							end
						end
					end
					if replaced and history then
						frame:Clear()
						for _, line in ipairs(history) do
							if tabData and tabData.isBN then
								frame:AddMessage(string.format(line, sender))
							else
								frame:AddMessage(line)
							end
						end
					end
				end
			end
			return
		end

		-- Alles andere an Blizzard weiterreichen
		ChatFrame_OnHyperlinkShow(frame, linkData, text, button)
	end)
	smf:SetScript("OnHyperlinkEnter", function(self, linkData)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(linkData)
	end)
	smf:SetScript("OnHyperlinkLeave", GameTooltip_Hide)

	self.tabs[sender] = {
		msg = smf,
		isBN = isBN,
		bnetID = bnetID,
		battleTag = battleTag,
		displayName = displayName,
		unread = false,
	}
	self.tabs[sender].target = sender

	local historyKey = isBN and battleTag or sender
	if historyKey and ChatIM.history[historyKey] then
		-- purge excessive saved lines on load
		while #ChatIM.history[historyKey] > ChatIM.maxHistoryLines do
			table.remove(ChatIM.history[historyKey], 1)
		end
		smf:SetMaxLines(ChatIM.maxHistoryLines)

		for _, line in ipairs(ChatIM.history[historyKey]) do
			if isBN then
				smf:AddMessage(string.format(line, sender, sender))
			else
				smf:AddMessage(line)
			end
		end
	end
	-- will be parented/anchored once the tab becomes active
	local eb = CreateFrame("EditBox", nil, ChatIM.storage, "InputBoxTemplate")
	eb:SetAutoFocus(false)
	eb:SetHeight(20)
	eb:SetFontObject(ChatFontNormal)
	eb:SetScript("OnEditFocusGained", function() ChatIM:UpdateAlpha() end)
	eb:SetScript("OnEditFocusLost", function()
		C_Timer.After(5, function() ChatIM:UpdateAlpha() end)
	end)
	eb:SetScript("OnEnterPressed", function(self)
		local txt = self:GetText()
		self:SetText("")
		local tgt = ChatIM.activeTab or sender
		if txt ~= "" and tgt then
			local tab = ChatIM.tabs[tgt]
			if tab and tab.isBN and tab.bnetID then
				BNSendWhisper(tab.bnetID, txt)
			else
				SendChatMessage(txt, "WHISPER", nil, tgt)
			end
		end
	end)
	eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

	self.tabs[sender].edit = eb

	table.insert(self.tabList, { text = displayName, value = sender })
	self.tabGroup:SetTabs(self.tabList)
	if not self.activeTab then self.tabGroup:SelectTab(sender) end
	self:RefreshTabCallbacks()
	self:UpdateTabLabel(sender)
end

function ChatIM:AddMessage(partner, text, outbound, isBN, bnetID)
	local accountTag
	if isBN and bnetID then
		local info = C_BattleNet.GetAccountInfoByID(bnetID)
		if info then accountTag = info.battleTag end
	end
	self:CreateTab(partner, isBN, bnetID, accountTag)
	-- make sure the main window is visible
	if self.widget and self.widget.frame and not self.widget.frame:IsShown() then
		if addon.db and addon.db["chatIMHideInCombat"] and ChatIM.inCombat then
			ChatIM.pendingShow = true
		else
			UIFrameFlashStop(self.widget.frame) -- stop any pending flash
			ChatIM:ShowWindow()
		end
	end
	local tab = self.tabs[partner]
	-- New message formatting: recolour whole line and show "You" for outbound
	local timestamp = date("%H:%M")
	local shortName = outbound and AUCTION_HOUSE_SELLER_YOU or Ambiguate(partner, "short")
	local prefix = "|cff999999" .. timestamp .. "|r"
	text = self:FormatURLs(text)
	local nameLink, colorInfo
	if isBN then
		nameLink = string.format("|HBNplayer:%s|h[%s]|h", partner, shortName)
		colorInfo = outbound and ChatTypeInfo.BN_WHISPER_INFORM or ChatTypeInfo.BN_WHISPER
	else
		nameLink = string.format("|Hplayer:%s|h[%s]|h", partner, shortName)
		colorInfo = outbound and ChatTypeInfo.WHISPER_INFORM or ChatTypeInfo.WHISPER
	end
	local cHex = ("%02x%02x%02x"):format(colorInfo.r * 255, colorInfo.g * 255, colorInfo.b * 255)

	-- plain line (no |cff…) so embedded hyperlinks keep native colours
	local line = string.format("%s |cff%s%s|r: |cff%s%s|r", prefix, cHex, nameLink, cHex, text)
	tab.msg:AddMessage(line)
	local historyKey = isBN and tab.battleTag or partner
	local storeLine
	if isBN then
		local nameLinkFmt
		if outbound then
			nameLinkFmt = "|HBNplayer:%s|h[" .. AUCTION_HOUSE_SELLER_YOU .. "]|h"
		else
			nameLinkFmt = "|HBNplayer:%s|h[%s]|h"
		end
		storeLine = string.format("%s |cff%s%s|r: |cff%s%s|r", prefix, cHex, nameLinkFmt, cHex, text)
	else
		storeLine = line
	end
	if historyKey then
		ChatIM.history[historyKey] = ChatIM.history[historyKey] or {}
		table.insert(ChatIM.history[historyKey], storeLine)
		while #ChatIM.history[historyKey] > ChatIM.maxHistoryLines do
			table.remove(ChatIM.history[historyKey], 1)
		end
	end
	tab.msg:SetMaxLines(ChatIM.maxHistoryLines)

	if outbound then
		if isBN then
			ChatEdit_SetLastToldTarget(partner, "BN_WHISPER")
		else
			ChatEdit_SetLastToldTarget(partner, "WHISPER")
		end
	else
		if isBN then
			ChatEdit_SetLastTellTarget(partner, "BN_WHISPER")
		else
			ChatEdit_SetLastTellTarget(partner, "WHISPER")
		end
	end

	if self.activeTab ~= partner then
		tab.unread = true
		self:UpdateTabLabel(partner)
		self:StartTabFlash(partner)
	end
end

function ChatIM:RemoveTab(sender)
	local tab = self.tabs[sender]
	if not tab then return end
	self:StopTabFlash(sender)
	if self.activeTab == sender then
		-- activeGroup *is* tab.group – release it once
		if self.activeGroup then AceGUI:Release(self.activeGroup) end
		self.activeGroup = nil
		self.activeTab = nil
	end

	tab.group = nil -- avoid accidental double‑release later

	if tab.msg then
		tab.msg:SetParent(nil)
		tab.msg:Hide()
	end
	for i, t in ipairs(self.tabList) do
		if t.value == sender then
			table.remove(self.tabList, i)
			break
		end
	end
	self.tabs[sender] = nil
	self.tabGroup:SetTabs(self.tabList)
	self:RefreshTabCallbacks()
	if #self.tabList == 0 then
		self:HideWindow()
		UIFrameFlashStop(self.widget.frame)
	else
		local last = self.tabList[#self.tabList]
		if last then self.tabGroup:SelectTab(last.value) end
	end
end

function ChatIM:Toggle()
	self:CreateUI()
	if self.widget.frame:IsShown() then
		UIFrameFlashStop(self.widget.frame)
		self:HideWindow()
	else
		UIFrameFlashStop(self.widget.frame)
		self:ShowWindow()
		-- reselect previously active tab so messages are visible
		if self.activeTab then
			self.tabGroup:SelectTab(self.activeTab)
		elseif self.tabList[1] then
			self.tabGroup:SelectTab(self.tabList[1].value)
		end
		self:UpdateAlpha()
	end
end

function ChatIM:Flash()
	if self.widget and not self.widget.frame:IsShown() then UIFrameFlash(self.widget.frame, 0.2, 0.8, 1, false, 0, 1) end
end

function ChatIM:StartTabFlash(sender)
	if not self.tabGroup or not self.tabGroup.tabs then return end
	for _, btn in ipairs(self.tabGroup.tabs) do
		if btn.value == sender then
			if not UIFrameIsFlashing(btn) then UIFrameFlash(btn, 0.8, 0.8, -1, true, 0.6, 0) end
			break
		end
	end
end

function ChatIM:StopTabFlash(sender)
	if not self.tabGroup or not self.tabGroup.tabs then return end
	for _, btn in ipairs(self.tabGroup.tabs) do
		if btn.value == sender then
			UIFrameFlashStop(btn)
			break
		end
	end
end

function ChatIM:UpdateTabLabel(sender)
	if not self.tabGroup or not self.tabList then return end
	local tab = self.tabs[sender]
	if not tab then return end
	local baseName = tab.displayName or Ambiguate(sender, "short")
	local label = tab.unread and ("* " .. baseName) or baseName
	tab.label = label
	for _, t in ipairs(self.tabList) do
		if t.value == sender then
			t.text = label
			break
		end
	end
	local current = self.activeTab
	self.tabGroup:SetTabs(self.tabList)
	if current then self.tabGroup:SelectTab(current) end
	self:RefreshTabCallbacks()
end

function ChatIM:ClearEditFocus()
	local tab = ChatIM.activeTab and ChatIM.tabs[ChatIM.activeTab]
	if tab and tab.edit then tab.edit:ClearFocus() end
end

local ANIM_OFFSET = 80

function ChatIM:EnsureAnimations()
	if not self.widget or not self.widget.frame or self.widget.frame.slideIn then return end
	local frame = self.widget.frame
	frame.slideIn = frame:CreateAnimationGroup()
	local sin = frame.slideIn:CreateAnimation("Translation")
	sin:SetDuration(0.25)
	sin:SetSmoothing("OUT")
	frame.slideInTrans = sin

	frame.slideOut = frame:CreateAnimationGroup()
	local sout = frame.slideOut:CreateAnimation("Translation")
	sout:SetDuration(0.25)
	sout:SetSmoothing("IN")
	frame.slideOutTrans = sout
	frame.slideOut:SetScript("OnFinished", function()
		frame:Hide()
		if ChatIM.animFinal then
			frame:ClearAllPoints()
			for i, p in ipairs(ChatIM.animFinal) do
				frame:SetPoint(unpack(p))
			end
		end
	end)
end

function ChatIM:ShowWindow()
	self:CreateUI()
	if not self.widget or not self.widget.frame or self.widget.frame:IsShown() then return end
	UIFrameFlashStop(self.widget.frame)
	if addon.db and addon.db["chatIMUseAnimation"] then
		self:EnsureAnimations()
		local frame = self.widget.frame
		self.animFinal = {}
		for i = 1, frame:GetNumPoints() do
			self.animFinal[i] = { frame:GetPoint(i) }
		end
		frame:ClearAllPoints()
		for i, p in ipairs(self.animFinal) do
			if i == 1 then
				frame:SetPoint(p[1], p[2], p[3], (p[4] or 0) + ANIM_OFFSET, p[5])
			else
				frame:SetPoint(unpack(p))
			end
		end
		frame:Show()
		frame.slideInTrans:SetOffset(-ANIM_OFFSET, 0)
		frame.slideIn:SetScript("OnFinished", function()
			frame:ClearAllPoints()
			for _, p in ipairs(ChatIM.animFinal) do
				frame:SetPoint(unpack(p))
			end
		end)
		frame.slideIn:Play()
	else
		self.widget.frame:Show()
	end
end

function ChatIM:HideWindow()
	if not self.widget or not self.widget.frame or not self.widget.frame:IsShown() then return end
	UIFrameFlashStop(self.widget.frame)
	if addon.db and addon.db["chatIMUseAnimation"] then
		self:EnsureAnimations()
		local frame = self.widget.frame
		self.animFinal = {}
		for i = 1, frame:GetNumPoints() do
			self.animFinal[i] = { frame:GetPoint(i) }
		end
		frame.slideOutTrans:SetOffset(ANIM_OFFSET, 0)
		frame.slideOut:Play()
	else
		self.widget.frame:Hide()
	end
end
