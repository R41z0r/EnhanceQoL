local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local ChatIM = addon.ChatIM or {}
addon.ChatIM = ChatIM

local function focusTab(target)
	ChatIM:CreateTab(target)
	if ChatIM.widget and ChatIM.widget.frame and not ChatIM.widget.frame:IsShown() then
		UIFrameFlashStop(ChatIM.widget.frame)
		ChatIM.widget.frame:Show()
	end
	local tab = ChatIM.tabs[target]
	if tab and tab.edit then
		ChatIM.tabGroup:SelectTab(target)
		tab.edit:SetFocus()
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
frame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
frame:SetScript("OnEvent", function(_, event, ...)
	if event == "CHAT_MSG_WHISPER" then
		local msg, sender = ...
		ChatIM:AddMessage(sender, msg)
		PlaySound(SOUNDKIT.TELL_MESSAGE)
		ChatIM:Flash()
	elseif event == "CHAT_MSG_BN_WHISPER" then
		local msg, sender, _, _, _, _, _, _, _, _, _, _, bnetID = ...
		ChatIM:AddMessage(sender, msg, nil, true, bnetID)
		PlaySound(SOUNDKIT.TELL_MESSAGE)
		ChatIM:Flash()
	elseif event == "CHAT_MSG_WHISPER_INFORM" then
		local msg, target = ...
		ChatIM:AddMessage(target, msg, true)
	elseif event == "CHAT_MSG_BN_WHISPER_INFORM" then
		local msg, target, _, _, _, _, _, _, _, _, _, _, bnetID = ...
		ChatIM:AddMessage(target, msg, true, true, bnetID)
	end
end)

local function whisperFilter() return true end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", whisperFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", whisperFilter)

SLASH_EQOLIM1 = "/im"
SlashCmdList["EQOLIM"] = function() ChatIM:Toggle() end
