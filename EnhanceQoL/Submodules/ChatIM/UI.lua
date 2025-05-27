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

addon.ChatIM = addon.ChatIM or {}
local ChatIM = addon.ChatIM

EnhanceQoL_IMPinned = EnhanceQoL_IMPinned or {}
ChatIM.pinned = EnhanceQoL_IMPinned

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
	tabGroup:SetCallback("OnGroupSelected", function(widget, _, value)
		widget:ReleaseChildren()
		local tab = ChatIM.tabs[value]
		if tab then widget:AddChild(tab.group) end
	end)
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

function ChatIM:CreateTab(sender)
	self:CreateUI()
	if self.tabs[sender] then return end

	local group = AceGUI:Create("SimpleGroup")
	group:SetFullWidth(true)
	group:SetFullHeight(true)

	local smf = CreateFrame("ScrollingMessageFrame", nil, group.frame)
	smf:SetAllPoints(true)
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

	group.msg = smf

	self.tabs[sender] = { group = group }
	table.insert(self.tabList, { text = sender, value = sender })
	self.tabGroup:SetTabs(self.tabList)
	self.tabGroup:SelectTab(sender)
	self:RefreshTabCallbacks()
end

function ChatIM:AddMessage(sender, text)
	self:CreateTab(sender)
	local tab = self.tabs[sender]
	tab.msg:AddMessage(text)
	self.tabGroup:SelectTab(sender)
	self:ScheduleAutoClose(sender)
end

function ChatIM:ScheduleAutoClose(sender)
	local tab = self.tabs[sender]
	if not tab then return end
	if tab.timer then tab.timer:Cancel() end
	tab.timer = C_Timer.NewTimer(30, function()
		if not ChatIM.pinned[sender] then ChatIM:RemoveTab(sender) end
	end)
end

function ChatIM:RemoveTab(sender)
	local tab = self.tabs[sender]
	if not tab then return end
	if tab.timer then tab.timer:Cancel() end
	AceGUI:Release(tab.group)
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
