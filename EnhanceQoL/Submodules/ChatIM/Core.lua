local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local ChatIM = addon.ChatIM or {}
addon.ChatIM = ChatIM

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
frame:SetScript("OnEvent", function(_, event, ...)
	if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
		local msg, sender = ...
		ChatIM:AddMessage(sender, msg)
		PlaySound(SOUNDKIT.TELL_MESSAGE)
		ChatIM:Flash()
	end
end)

SLASH_EQOLIM1 = "/im"
SlashCmdList["EQOLIM"] = function() ChatIM:Toggle() end
