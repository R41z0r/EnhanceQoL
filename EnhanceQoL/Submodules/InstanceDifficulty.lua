-- luacheck: globals MinimapCluster
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local InstanceDifficulty = addon.InstanceDifficulty or {}
addon.InstanceDifficulty = InstanceDifficulty
InstanceDifficulty.enabled = InstanceDifficulty.enabled or false

InstanceDifficulty.frame = InstanceDifficulty.frame or CreateFrame("Frame")

local indicator = MinimapCluster.InstanceDifficulty
indicator:SetAlpha(1)
if indicator.Default then
	indicator.Default:Hide()
	indicator.Default:SetScript("OnShow", indicator.Default.Hide)
end
if indicator.ChallengeMode then
	indicator.ChallengeMode:Hide()
	indicator.ChallengeMode:SetScript("OnShow", indicator.ChallengeMode.Hide)
end

InstanceDifficulty.text = InstanceDifficulty.text or indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
InstanceDifficulty.text:SetPoint("CENTER", indicator, "CENTER", 0, 0)
InstanceDifficulty.text:Hide()

InstanceDifficulty.icon = InstanceDifficulty.icon or indicator:CreateTexture(nil, "OVERLAY")
InstanceDifficulty.icon:ClearAllPoints()
InstanceDifficulty.icon:SetPoint("CENTER", indicator, "CENTER", 0, 4)
InstanceDifficulty.icon:SetSize(50,50)
InstanceDifficulty.icon:Hide()

InstanceDifficulty.icons = {
	NM = "Interface\\AddOns\\EnhanceQoL\\Icons\\Difficulty_NM.tga",
	HC = "Interface\\AddOns\\EnhanceQoL\\Icons\\Difficulty_HC.tga",
	M = "Interface\\AddOns\\EnhanceQoL\\Icons\\Difficulty_M.tga",
	MPLUS = "Interface\\AddOns\\EnhanceQoL\\Icons\\Difficulty_MPlus.tga",
	LFR = "Interface\\AddOns\\EnhanceQoL\\Icons\\Difficulty_LFR.tga",
}

local function getShortLabel(difficultyID, difficultyName)
	if difficultyID == 1 or difficultyID == 3 or difficultyID == 4 or difficultyID == 14 or difficultyID == 33 or difficultyID == 150 then
		return "NM"
	elseif difficultyID == 2 or difficultyID == 5 or difficultyID == 6 or difficultyID == 15 or difficultyID == 205 or difficultyID == 230 then
		return "HC"
	elseif difficultyID == 16 or difficultyID == 23 then
		return "M"
	elseif difficultyID == 8 then
		local _, level = C_ChallengeMode.GetActiveKeystoneInfo()
		if level and type(level) ~= "table" and level > 0 then return "M+" .. level end
		return "M+"
	elseif difficultyID == 7 or difficultyID == 17 or difficultyID == 151 then
		return "LFR"
	end
	return difficultyName
end

function InstanceDifficulty:Update()
	if not self.enabled or not addon.db then return end
	if not IsInInstance() then
		self.text:Hide()
		self.icon:Hide()
		return
	end

	local _, _, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
	local short = getShortLabel(difficultyID, difficultyName)

	if addon.db.instanceDifficultyUseIcon then
		local key = short
		if key:find("^M%+") then key = "MPLUS" end
		local icon = self.icons[key]
		if icon then
			self.icon:SetTexture(icon)
			self.icon:Show()
			self.text:Hide()
			return
		end
	end

	local text
	if maxPlayers and maxPlayers > 0 then
		text = string.format("%d (%s)", maxPlayers, short)
	else
		text = short
	end
	self.text:SetText(text)
	self.text:Show()
	self.icon:Hide()
end

function InstanceDifficulty:SetEnabled(value)
	self.enabled = value
	if value then
		self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self.frame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
		if indicator.Default then
			indicator.Default:Hide()
			indicator.Default:SetScript("OnShow", indicator.Default.Hide)
		end
		self:Update()
	else
		self.frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self.frame:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED")
		self.text:Hide()
		self.icon:Hide()
		if indicator.Default then
			indicator.Default:SetScript("OnShow", nil)
			indicator.Default:Show()
		end
	end
end

InstanceDifficulty.frame:SetScript("OnEvent", function() InstanceDifficulty:Update() end)
