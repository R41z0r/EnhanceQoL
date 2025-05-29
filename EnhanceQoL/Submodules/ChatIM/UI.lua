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

local MAX_HISTORY_LINES = 250
local ChatIM = addon.ChatIM

local MU = MenuUtil -- global ab 11.0+

local regionTable = { "US", "KR", "EU", "TW", "CN" }
local regionKey = regionTable[GetCurrentRegion()] or "EU" -- or EU for PTR because that is region 90+

local function PlayerMenuGenerator(_, root, targetName, isBN, bnetID)
	root:CreateTitle(targetName)

	local unit, riolink
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
			end
		end
	else
		unit = targetName
		if targetName:match("-") then
			local char, realm = targetName:match("^([^%-]+)%-(.+)$")
			if char and realm then riolink = "https://raider.io/characters/" .. string.lower(regionKey) .. "/" .. string.lower(realm:gsub("%s+", "-")) .. "/" .. char end
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

	if riolink then
		root:CreateDivider()
		root:CreateTitle("RaiderIO")
		root:CreateButton(L["RaiderIOUrl"], function(link) StaticPopup_Show("EQOL_URL_COPY", nil, nil, link) end, riolink)
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

ChatIM.storage = ChatIM.storage or CreateFrame("Frame")
ChatIM.activeGroup = nil
ChatIM.activeTab = nil
ChatIM.insertLinkHooked = ChatIM.insertLinkHooked or false
ChatIM.hooksSet = ChatIM.hooksSet or false
ChatIM.inactiveAlpha = 0.6

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
	frame:SetCallback("OnClose", function(widget) widget.frame:Hide() end)
	frame:SetStatusTable(addon.db.chatIMFrameData)
	frame.frame:SetAlpha(0.4)
	frame.frame:HookScript("OnEnter", function() ChatIM:UpdateAlpha() end)
	frame.frame:HookScript("OnLeave", function()
		C_Timer.After(5, function() ChatIM:UpdateAlpha() end)
	end)
	frame.frame:SetFrameStrata("DIALOG")
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
	tab.msg:SetPoint("BOTTOMLEFT", group.frame, "BOTTOMLEFT", 0, 24)

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

function ChatIM:CreateTab(sender, isBN, bnetID)
	self:CreateUI()
	if self.tabs[sender] then return end

	local displayName = Ambiguate(sender, "short")

	local smf = CreateFrame("ScrollingMessageFrame", nil, ChatIM.storage)
	-- we'll anchor later when the tab becomes active
	smf:SetAllPoints(ChatIM.storage)
	smf:SetFontObject(ChatFontNormal)
	smf:SetJustifyH("LEFT")
	smf:SetFading(false)
	smf:SetMaxLines(250)
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
	smf:SetScript("OnHyperlinkClick", function(self, linkData, text, button)
		local linkType, payload = linkData:match("^(%a+):(.+)$")
		if linkType == "url" then
			StaticPopup_Show("EQOL_URL_COPY", nil, nil, payload)
		else
			local name = Ambiguate(payload:match("^[^:]+"), "short")
			MU.CreateContextMenu(self, PlayerMenuGenerator, sender, isBN, bnetID)
		end
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
		displayName = displayName,
		unread = false,
	}
	self.tabs[sender].target = sender
	if ChatIM.history[sender] then
		-- purge excessive saved lines on load
		while #ChatIM.history[sender] > MAX_HISTORY_LINES do
			table.remove(ChatIM.history[sender], 1)
		end
		for _, line in ipairs(ChatIM.history[sender]) do
			smf:AddMessage(line)
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
	self:CreateTab(partner, isBN, bnetID)
	-- make sure the main window is visible
	if self.widget and self.widget.frame and not self.widget.frame:IsShown() then
		UIFrameFlashStop(self.widget.frame) -- stop any pending flash
		self.widget.frame:Show()
	end
	local tab = self.tabs[partner]
	-- New message formatting: recolour whole line and show "You" for outbound
	local timestamp = date("%H:%M")
	local shortName = outbound and AUCTION_HOUSE_SELLER_YOU or Ambiguate(partner, "short")
	local cHex = isBN and "82c5ff" or "ff80ff"
	local prefix = "|cff999999" .. timestamp .. "|r"
	text = self:FormatURLs(text)
	local nameLink
	if isBN then
		nameLink = string.format("|HBNplayer:%s|h[%s]|h", partner, shortName)
	else
		nameLink = string.format("|Hplayer:%s|h[%s]|h", partner, shortName)
	end
	if isBN then
		-- Farbe vor jedem Link schließen und danach wieder öffnen
		text = text:gsub("(|H[^|]+|h.-|h)", "|r%1|cff" .. cHex)
	end
	local line = prefix .. " |cff" .. cHex .. nameLink .. ": " .. text
	-- local line = prefix .. " |cff" .. cHex .. "[" .. shortName .. "]: " .. text
	tab.msg:AddMessage(line)
	ChatIM.history[partner] = ChatIM.history[partner] or {}
	table.insert(ChatIM.history[partner], line)
	while #ChatIM.history[partner] > MAX_HISTORY_LINES do
		table.remove(ChatIM.history[partner], 1)
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
		self.widget.frame:Hide()
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
		self.widget.frame:Hide()
	else
		UIFrameFlashStop(self.widget.frame)
		self.widget.frame:Show()
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
