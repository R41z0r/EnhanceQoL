local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LDrinkMacro

local brButton
local defaultButtonSize = 60
local defaultFontSize = 16

local function removeBRFrame()
	if brButton then
		brButton:Hide()
		brButton:SetParent(nil)
		brButton:SetScript("OnClick", nil)
		brButton:SetScript("OnEnter", nil)
		brButton:SetScript("OnLeave", nil)
		brButton:SetScript("OnUpdate", nil)
		brButton:SetScript("OnEvent", nil)
		brButton:SetScript("OnDragStart", nil)
		brButton:SetScript("OnDragStop", nil)
		brButton:UnregisterAllEvents()
		brButton:ClearAllPoints()
		brButton = nil
	end
end

local function createBRFrame()
	removeBRFrame()
	-- if not addon.db["mythicPlusBRTrackerEnabled"] then return end
	brButton = CreateFrame("Button", nil, UIParent)
	brButton:SetSize(defaultButtonSize, defaultButtonSize)
	brButton:SetPoint("TOP", UIParent, "TOP", 0, -100)
	brButton:SetFrameStrata("DIALOG")
	brButton:SetScript("OnClick", function()
		LFDQueueFrame_SetType("follower")

		LFDQueueFrame_Update()
		for _, dungeonID in ipairs(_G["LFDDungeonList"]) do
			if dungeonID >= 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID) then
				LFGDungeonList_SetDungeonEnabled(dungeonID, true)

				LFDQueueFrameList_Update()
				LFDQueueFrame_UpdateRoleButtons()
				LFDQueueFrameFindGroupButton:Click()
				return
			end
		end
	end)

	brButton.info = brButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	brButton.info:SetPoint("TOP", brButton, "BOTTOM", 0, -3)
	brButton.info:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
	brButton.info:SetText("Get Mage food from follower Dungeon\n\nClick to automatically queue")

	local bg = brButton:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(brButton)
	bg:SetColorTexture(0, 0, 0, 0.8)

	local icon = brButton:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(brButton)
	icon:SetTexture(134029)
	brButton.icon = icon

	local jumpGroup = brButton:CreateAnimationGroup()
	local up = jumpGroup:CreateAnimation("Translation")
	up:SetOffset(0, 50)
	up:SetDuration(1)
	up:SetSmoothing("OUT")

	local down = jumpGroup:CreateAnimation("Translation")
	down:SetOffset(0, -50)
	down:SetDuration(1)
	down:SetSmoothing("IN")

	jumpGroup:SetLooping("BOUNCE")
	jumpGroup:SetScript("OnFinished", function() print("Jump done!") end)
	jumpGroup:Play()
end

local healerRole

local frameLoad = CreateFrame("Frame")
-- Registriere das Event
frameLoad:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frameLoad:RegisterEvent("PLAYER_LOGIN")
frameLoad:RegisterEvent("BAG_UPDATE_DELAYED")
frameLoad:RegisterEvent("PLAYER_UPDATE_RESTING")

frameLoad:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		healerRole = GetSpecializationRole(GetSpecialization()) == "HEALER" or false
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		healerRole = GetSpecializationRole(GetSpecialization()) == "HEALER" or false
	end
	-- check for mage food
	if not healerRole or not IsResting() then
		removeBRFrame()
		return
	end
	local found = false
	if addon.Drinks.mageFood then
		for i in pairs(addon.Drinks.mageFood) do
			local count = C_Item.GetItemCount(i, false, false)
			if count and count > 20 then
				found = true
				break
			end
		end
		if found == false then createBRFrame() end
	end
end)
