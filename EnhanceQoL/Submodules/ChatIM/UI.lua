-- luacheck: globals EnhanceQoL_IMPinned ChatFrame_OnHyperlinkShow
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
ChatIM.history = ChatIM.history or {}

EnhanceQoL_IMPinned = EnhanceQoL_IMPinned or {}
ChatIM.pinned = EnhanceQoL_IMPinned
ChatIM.storage = ChatIM.storage or CreateFrame("Frame")
ChatIM.activeGroup = nil
ChatIM.activeTab = nil

function ChatIM:CreateUI()
	if self.widget then return end
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(L["Instant Chats"])
	frame:SetWidth(400)
	frame:SetHeight(300)
	frame:SetLayout("Fill")
	frame:SetCallback("OnClose", function(widget) widget.frame:Hide() end)
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
end

function ChatIM:RefreshTabCallbacks()
	if not self.tabGroup or not self.tabGroup.tabs then return end
	for _, btn in ipairs(self.tabGroup.tabs) do
		if not btn.hooked then
			local orig = btn:GetScript("OnClick")
			btn:SetScript("OnClick", function(frame, button)
				if button == "RightButton" then
					ChatIM:TogglePin(frame.value)
				else
					orig(frame)
				end
			end)
			btn.hooked = true
		end
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
end

function ChatIM:CreateTab(sender)
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
	smf:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
	smf:SetScript("OnHyperlinkEnter", function(self, linkData)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(linkData)
	end)
        smf:SetScript("OnHyperlinkLeave", GameTooltip_Hide)

        self.tabs[sender] = { msg = smf }
        self.tabs[sender].target = sender
        if ChatIM.history[sender] then
                for _, line in ipairs(ChatIM.history[sender]) do
                        smf:AddMessage(line)
                end
        end
        -- will be parented/anchored once the tab becomes active
	local eb = CreateFrame("EditBox", nil, ChatIM.storage, "InputBoxTemplate")
	eb:SetAutoFocus(false)
	eb:SetHeight(20)
	eb:SetFontObject(ChatFontNormal)
       eb:SetScript("OnEnterPressed", function(self)
               local txt = self:GetText()
               self:SetText("")
               local tgt = ChatIM.activeTab or sender
               if txt ~= "" and tgt then
                       SendChatMessage(txt, "WHISPER", nil, tgt)
                       ChatIM:AddMessage(tgt, txt, true) -- echo locally as outbound
               end
       end)

	self.tabs[sender].edit = eb

	table.insert(self.tabList, { text = displayName, value = sender })
	self.tabGroup:SetTabs(self.tabList)
	self.tabGroup:SelectTab(sender)
	self:RefreshTabCallbacks()
end

function ChatIM:AddMessage(partner, text, outbound)
        self:CreateTab(partner)
        -- make sure the main window is visible
        if self.widget and self.widget.frame and not self.widget.frame:IsShown() then
                UIFrameFlashStop(self.widget.frame) -- stop any pending flash
                self.widget.frame:Show()
        end
        local tab = self.tabs[partner]
        -- New message formatting: recolour whole line and show "You" for outbound
        local timestamp = date("%H:%M")
        local shortName = outbound and AUCTION_HOUSE_SELLER_YOU or Ambiguate(partner, "short")
        local cHex = "ff80ff"
        local prefix = "|cff999999" .. timestamp .. "|r"
        local line = prefix .. " |cffff80ff[" .. shortName .. "]: " .. text
        tab.msg:AddMessage(line)
        ChatIM.history[partner] = ChatIM.history[partner] or {}
        table.insert(ChatIM.history[partner], line)
        if #ChatIM.history[partner] > 250 then table.remove(ChatIM.history[partner], 1) end
       self.tabGroup:SelectTab(partner)
end

function ChatIM:RemoveTab(sender)
       local tab = self.tabs[sender]
       if not tab then return end
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
	end
end

function ChatIM:Flash()
	if self.widget and not self.widget.frame:IsShown() then UIFrameFlash(self.widget.frame, 0.2, 0.8, 1, false, 0, 1) end
end

function ChatIM:TogglePin(sender)
       if self.pinned[sender] then
               self.pinned[sender] = nil
       else
               self.pinned[sender] = true
       end
end
