local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local LSM = LibStub("LibSharedMedia-3.0")

local ChatIM = addon.ChatIM or {}
addon.ChatIM = ChatIM
ChatIM.enabled = false
ChatIM.whisperHooked = ChatIM.whisperHooked or false
ChatIM.soundPath = "Interface\\AddOns\\" .. parentAddonName .. "\\Sounds\\ChatIM\\"
LSM:Register("sound", "Bell", ChatIM.soundPath .. "Bell.ogg")
LSM:Register("sound", "Cheerfull", ChatIM.soundPath .. "Cheerfull.ogg")
LSM:Register("sound", "For the Horde", "Interface\\AddOns\\EnhanceQoL\\Sounds\\bloodlust.ogg")
LSM:Register("sound", "Laughing", ChatIM.soundPath .. "Laughing.ogg")
LSM:Register("sound", "LightMetallic", ChatIM.soundPath .. "LightMetallic.ogg")
LSM:Register("sound", "Ping", ChatIM.soundPath .. "Ping.ogg")
LSM:Register("sound", "Ring", ChatIM.soundPath .. "Ring.ogg")
LSM:Register("sound", "Sonarr", ChatIM.soundPath .. "Sonarr.ogg")

function ChatIM:BuildSoundTable()
	local result = {}

	-- LSM:HashTable("sound")  →  { ["Bell"]="path", ["blah"]="path", ... }
	for name, path in pairs(LSM:HashTable("sound")) do
		result[name] = path
	end
	ChatIM.availableSounds = result -- { "Bell","Cheerfull",... },   { name → path }
end

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
		ChatIM:ShowWindow()
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
	if event == "PLAYER_REGEN_DISABLED" then
		ChatIM.inCombat = true
		if addon.db and addon.db["chatIMHideInCombat"] then
			if ChatIM.widget and ChatIM.widget.frame:IsShown() then
				ChatIM.wasOpenBeforeCombat = true
				ChatIM:HideWindow()
			else
				ChatIM.wasOpenBeforeCombat = false
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		ChatIM.inCombat = false
		if addon.db and addon.db["chatIMHideInCombat"] then
			if (ChatIM.wasOpenBeforeCombat or ChatIM.pendingShow) and ChatIM.widget then ChatIM:ShowWindow() end
			for _, snd in ipairs(ChatIM.soundQueue or {}) do
				playIncomingSound(snd)
			end
			ChatIM.pendingShow = false
			ChatIM.soundQueue = {}
		end
	elseif event == "CHAT_MSG_WHISPER" then
		local msg, sender = ...
		if addon.Ignore and addon.Ignore.CheckIgnore and addon.Ignore:CheckIgnore(sender) then return end
		ChatIM:AddMessage(sender, msg)
		if addon.db and addon.db["chatIMHideInCombat"] and ChatIM.inCombat then
			table.insert(ChatIM.soundQueue, sender)
			ChatIM.pendingShow = true
		else
			playIncomingSound(sender)
			ChatIM:Flash()
		end
	elseif event == "CHAT_MSG_BN_WHISPER" then
		local msg, sender, _, _, _, _, _, _, _, _, _, _, bnetID = ...
		ChatIM:AddMessage(sender, msg, nil, true, bnetID)
		if addon.db and addon.db["chatIMHideInCombat"] and ChatIM.inCombat then
			table.insert(ChatIM.soundQueue, sender)
			ChatIM.pendingShow = true
		else
			playIncomingSound(sender)
			ChatIM:Flash()
		end
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
		if addon.db and addon.db["chatIMHideInCombat"] then
			frame:RegisterEvent("PLAYER_REGEN_DISABLED")
			frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
			frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whisperFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", whisperFilter)

		EnhanceQoL_IMHistory = EnhanceQoL_IMHistory or {}
		ChatIM.history = EnhanceQoL_IMHistory

		LSM:RegisterCallback("LibSharedMedia_Registered", function(mediaType)
			if mediaType == "sound" then ChatIM:BuildSoundTable() end
		end)
		ChatIM:BuildSoundTable()
	else
		frame:UnregisterAllEvents()
		if ChatIM.widget and ChatIM.widget.frame then ChatIM:HideWindow() end
	end
end

function ChatIM:SetEnabled(val)
	self.enabled = val and true or false
	if self.enabled then
		self:SetMaxHistoryLines(addon.db and addon.db["chatIMMaxHistory"])
		self:CreateUI()
		if not self.whisperHooked then
			hooksecurefunc("ChatFrame_SendTell", function(name)
				if not ChatIM.enabled then return end
				if name then
					if nil == name:match("-") then
						-- no minus means same realm so get my realm and add it
						name = name .. "-" .. (GetRealmName()):gsub("%s", "")
					end
					ChatIM:StartWhisper(name)
				end
			end)
			hooksecurefunc("ChatFrame_SendBNetTell", function(target)
				if not ChatIM.enabled then return end
				local bnetID = nil
				local plain = BNTokenFindName(target) or target
				bnetID = BNet_GetBNetIDAccount(plain)
				target = plain
				if bnetID then
					local accountTag
					local info = C_BattleNet.GetAccountInfoByID(bnetID)
					if info then accountTag = info.battleTag end
					if accountTag then ChatIM:StartWhisper(target, bnetID, accountTag) end
				end
			end)
			self.whisperHooked = true
		end
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
