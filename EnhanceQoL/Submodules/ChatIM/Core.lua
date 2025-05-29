local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local ChatIM = addon.ChatIM or {}
addon.ChatIM = ChatIM
ChatIM.enabled = false
ChatIM.soundPath = "Interface\\AddOns\\" .. parentAddonName .. "\\Sounds\\ChatIM\\"
ChatIM.availableSounds = {
	Bell = ChatIM.soundPath .. "Bell.ogg",
	Cheerfull = ChatIM.soundPath .. "Cheerfull.ogg",
	["For the Horde"] = "Interface\\AddOns\\" .. parentAddonName .. "\\Sounds\\bloodlust.ogg",
	Laughing = ChatIM.soundPath .. "Laughing.ogg",
	Metallic = ChatIM.soundPath .. "LightMetallic.ogg",
	Ping = ChatIM.soundPath .. "Ping.ogg",
	Ring = ChatIM.soundPath .. "Ring.ogg",
	Sonarr = ChatIM.soundPath .. "Sonarr.ogg",
}

local function shouldPlaySound(sender)
	if not ChatIM.widget or not ChatIM.widget.frame:IsShown() then return true end
	if ChatIM.activeTab ~= sender then return true end
	local tab = ChatIM.tabs[sender]
	if not tab or not tab.edit or not tab.edit:HasFocus() then return true end
	return false
end

local function playIncomingSound(sender)
	if not shouldPlaySound(sender) then return end
	if addon.db and addon.db["chatIMUseCustomSound"] then
		local key = addon.db["chatIMCustomSoundFile"]
		local file = key and ChatIM.availableSounds[key]
		if file then
			PlaySoundFile(file, "Master")
			return
		end
	end
	PlaySound(SOUNDKIT.TELL_MESSAGE)
end

local function whisperFilter() return true end

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
frame:SetScript("OnEvent", function(_, event, ...)
	if not ChatIM.enabled then return end
	if event == "CHAT_MSG_WHISPER" then
		local msg, sender = ...
		ChatIM:AddMessage(sender, msg)
		playIncomingSound(sender)
		ChatIM:Flash()
	elseif event == "CHAT_MSG_BN_WHISPER" then
		local msg, sender, _, _, _, _, _, _, _, _, _, _, bnetID = ...
		ChatIM:AddMessage(sender, msg, nil, true, bnetID)
		playIncomingSound(sender)
		ChatIM:Flash()
	elseif event == "CHAT_MSG_WHISPER_INFORM" then
		local msg, target = ...
		ChatIM:AddMessage(target, msg, true)
		focusTab(target)
	elseif event == "CHAT_MSG_BN_WHISPER_INFORM" then
		local msg, target, _, _, _, _, _, _, _, _, _, _, bnetID = ...
		ChatIM:AddMessage(target, msg, true, true, bnetID)
		focusTab(target)
	end
end)

local function updateRegistration()
	if ChatIM.enabled then
		frame:RegisterEvent("CHAT_MSG_WHISPER")
		frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
		frame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
		frame:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
		frame:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")

		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", whisperFilter)

		EnhanceQoL_IMHistory = EnhanceQoL_IMHistory or {}
		ChatIM.history = EnhanceQoL_IMHistory
	else
		frame:UnregisterAllEvents()
		if ChatIM.widget and ChatIM.widget.frame then ChatIM.widget.frame:Hide() end
	end
end

function ChatIM:SetEnabled(val)
	self.enabled = val and true or false
	if self.enabled then
		self:SetMaxHistoryLines(addon.db and addon.db["chatIMMaxHistory"])
		self:CreateUI()
	end
	updateRegistration()
end
SLASH_EQOLIM1 = "/eim"
SlashCmdList["EQOLIM"] = function()
	if ChatIM.enabled then ChatIM:Toggle() end
end

function ChatIM:ToggleIgnore(name)
	if C_FriendList.IsIgnored and C_FriendList.IsIgnored(name) or IsIgnored and IsIgnored(name) then
		if C_FriendList.DelIgnore then
			C_FriendList.DelIgnore(name)
		else
			DelIgnore(name)
		end
	else
		if C_FriendList.AddIgnore then
			C_FriendList.AddIgnore(name)
		else
			AddIgnore(name)
		end
	end
end
