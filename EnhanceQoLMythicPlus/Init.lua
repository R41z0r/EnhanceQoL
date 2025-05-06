local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

-- PullTimer
addon.functions.InitDBValue("enableKeystoneHelper", true)
addon.functions.InitDBValue("enableKeystoneHelperNewUI", true)
addon.functions.InitDBValue("autoInsertKeystone", false)
addon.functions.InitDBValue("closeBagsOnKeyInsert", false)
addon.functions.InitDBValue("noChatOnPullTimer", false)
addon.functions.InitDBValue("autoKeyStart", false)
addon.functions.InitDBValue("mythicPlusTruePercent", false)
addon.functions.InitDBValue("mythicPlusChestTimer", false)
addon.functions.InitDBValue("cancelPullTimerOnClick", true)
addon.functions.InitDBValue("pullTimerShortTime", 5)
addon.functions.InitDBValue("pullTimerLongTime", 10)
addon.functions.InitDBValue("PullTimerType", 4)

-- Cooldown Tracker
addon.functions.InitDBValue("CooldownTrackerPoint", "CENTER")
addon.functions.InitDBValue("CooldownTrackerX", 0)
addon.functions.InitDBValue("CooldownTrackerY", 0)
addon.functions.InitDBValue("CooldownTrackerBarHeight", 30)

-- Potion Tracker
addon.functions.InitDBValue("potionTracker", false)
addon.functions.InitDBValue("potionTrackerUpwardsBar", false)
addon.functions.InitDBValue("potionTrackerDisableRaid", true)
addon.functions.InitDBValue("potionTrackerShowTooltip", true)
addon.functions.InitDBValue("potionTrackerHealingPotions", false)
addon.functions.InitDBValue("potionTrackerOffhealing", false)

-- Dungeon Browser
addon.functions.InitDBValue("groupfinderAppText", false)
addon.functions.InitDBValue("groupfinderSkipRoleSelect", false)
addon.functions.InitDBValue("groupfinderSkipRoleSelectOption", 1)
addon.functions.InitDBValue("groupfinderShowDungeonScoreFrame", false)

-- Misc
addon.functions.InitDBValue("autoMarkTankInDungeon", false)
addon.functions.InitDBValue("autoMarkTankInDungeonMarker", 6)
addon.functions.InitDBValue("mythicPlusIgnoreMythic", true)
addon.functions.InitDBValue("mythicPlusIgnoreHeroic", true)
addon.functions.InitDBValue("mythicPlusIgnoreNormal", true)
addon.functions.InitDBValue("mythicPlusIgnoreTimewalking", true)

-- BR Tracker
addon.functions.InitDBValue("mythicPlusBRTrackerEnabled", false)
addon.functions.InitDBValue("mythicPlusBRTrackerLocked", false)
addon.functions.InitDBValue("mythicPlusBRButtonSize", 50)
addon.functions.InitDBValue("mythicPlusBRTrackerPoint", "CENTER")
addon.functions.InitDBValue("mythicPlusBRTrackerX", 0)
addon.functions.InitDBValue("mythicPlusBRTrackerY", 0)

-- Talent Reminder
addon.functions.InitDBValue("talentReminderEnabled", false)
addon.functions.InitDBValue("talentReminderSettings", {})

addon.MythicPlus = {}
addon.MythicPlus.functions = {}

addon.MythicPlus.Buttons = {}
addon.MythicPlus.nrOfButtons = 0
addon.MythicPlus.variables = {}

-- Teleports
addon.functions.InitDBValue("teleportFrame", false)
addon.functions.InitDBValue("portalHideMissing", false)
addon.functions.InitDBValue("portalShowTooltip", false)
addon.functions.InitDBValue("teleportsEnableCompendium", false)

-- Group Dungeon Filter
addon.functions.InitDBValue("mythicPlusEnableDungeonFilter", false)
addon.functions.InitDBValue("mythicPlusEnableDungeonFilterClearReset", false)

-- PullTimer
addon.MythicPlus.variables.handled = false
addon.MythicPlus.variables.breakIt = false

addon.MythicPlus.variables.resetCooldownEncounterDifficult = {
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[9] = true,
	[14] = true,
	[15] = true,
	[16] = true,
	[17] = true,
	[18] = true,
	[33] = true,
	[151] = true,
	[208] = true, -- delves
}

function addon.MythicPlus.functions.addRCButton()
	local rcButton = CreateFrame("Button", "EnhanceQoLMythicPlus_ReadyCheck", ChallengesKeystoneFrame)
	rcButton:ClearAllPoints()
	rcButton:SetPoint("TOPLEFT", ChallengesKeystoneFrame, "TOPLEFT", 15, -15)
	rcButton:SetSize(110, 110)
	rcButton:SetHitRectInsets(15, 15, 15, 15)
	rcButton:SetScript("OnClick", function(self, button)
		if not self.readyCheckRunning then
			self.readyCheckRunning = true
			DoReadyCheck()
		end
	end)
	rcButton:RegisterEvent("READY_CHECK")
	rcButton:RegisterEvent("READY_CHECK_CONFIRM")
	rcButton:RegisterEvent("READY_CHECK_FINISHED")
	rcButton:SetScript("OnEvent", function(self, event, ...)
		if event == "READY_CHECK" then
			self.icon:SetVertexColor(1, 0.8, 0)
			self.icon:SetDesaturated(false)
			self.spin:Play()
			-- pulse animation for "waiting" state
			if self.iconPulse and not self.iconPulse:IsPlaying() then
				self.iconPulse:Play() -- start pulsing while we wait
			end
			self.readyCheckRunning = true
		elseif event == "READY_CHECK_CONFIRM" then
			local unit, ready = ...
			if not ready then
				self.notReady = true
				self.icon:SetVertexColor(1, 0.2, 0.2)
			end
		elseif event == "READY_CHECK_FINISHED" then
			if self.iconPulse and self.iconPulse:IsPlaying() then
				self.iconPulse:Stop() -- stop pulsing, restore full alpha
				self.icon:SetAlpha(1)
			end
			if not self.notReady then self.icon:SetVertexColor(0, 1, 0.3) end
			self.readyCheckRunning = false
			C_Timer.After(2, function()
				if self.readyCheckRunning then return end
				self.icon:SetVertexColor(1, 1, 1)
				self.notReady = false
				if not MouseIsOver(rcButton) then
					self.spin:Stop()
					self.ring:SetRotation(0)
				end
			end)
		end
	end)
	rcButton:SetFrameStrata("DIALOG")

	local icon = rcButton:CreateTexture(nil, "ARTWORK", nil, 0)
	icon:SetPoint("CENTER", rcButton, "CENTER")
	icon:SetTexture("Interface/AddOns/EnhanceQoLMythicPlus/Art/coreRC.tga")
	icon:SetSize(70, 70)
	rcButton.icon = icon

	-- pulse animation for "waiting" state
	local pulse = icon:CreateAnimationGroup()
	local fadeOut = pulse:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0.3)
	fadeOut:SetDuration(0.8)
	fadeOut:SetOrder(1)

	local fadeIn = pulse:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0.3)
	fadeIn:SetToAlpha(1)
	fadeIn:SetDuration(0.8)
	fadeIn:SetOrder(2)

	pulse:SetLooping("REPEAT")
	rcButton.iconPulse = pulse

	local ring = rcButton:CreateTexture(nil, "OVERLAY", nil, 1)
	ring:SetTexture("Interface/AddOns/EnhanceQoLMythicPlus/Art/coreRing.tga")
	ring:SetSize(110, 110)
	ring:SetPoint("CENTER", rcButton, "CENTER")
	rcButton.ring = ring

	local spin = ring:CreateAnimationGroup()
	local rot = spin:CreateAnimation("Rotation")
	rot:SetDegrees(360)
	rot:SetDuration(24)
	spin:SetLooping("REPEAT")
	rcButton.spin = spin

	rcButton:SetScript("OnEnter", function(self, button)
		if not self.readyCheckRunning then spin:Play() end
	end)
	rcButton:SetScript("OnLeave", function(self, button)
		if not self.readyCheckRunning then
			spin:Stop()
			ring:SetRotation(0)
		end
	end)
	addon.MythicPlus.Buttons["EnhanceQoLMythicPlus_ReadyCheck"] = rcButton
	addon.MythicPlus.nrOfButtons = addon.MythicPlus.nrOfButtons + 1
end

function addon.MythicPlus.functions.addPullButton()
	local rcButton = CreateFrame("Button", "EnhanceQoLMythicPlus_PullTimer", ChallengesKeystoneFrame)
	rcButton:ClearAllPoints()
	rcButton:SetPoint("TOPRIGHT", ChallengesKeystoneFrame, "TOPRIGHT", -15, -15)
	rcButton:SetSize(110, 110)
	rcButton:SetHitRectInsets(15, 15, 15, 15)
	-- streamlined pull‑timer logic
	local function startPull(self, duration)
		self.remaining = duration
		self.icon:Hide()
		self.timerCountdown:SetText(duration)
		self.timerCountdown:Show()
		if self.remaining > 6 then
			self.timerCountdown:SetVertexColor(0, 1, 0)
		elseif self.remaining > 3 then
			self.timerCountdown:SetVertexColor(1, 1, 0)
		else
			self.timerCountdown:SetVertexColor(1, 0, 0)
		end
		-- blizzard / DBM alignment
		local _, _, _, _, _, _, _, instanceId = GetInstanceInfo()
		if addon.db["PullTimerType"] == 2 or addon.db["PullTimerType"] == 4 then C_PartyInfo.DoCountdown(duration) end
		if addon.db["PullTimerType"] == 3 or addon.db["PullTimerType"] == 4 then
			C_ChatInfo.SendAddonMessage("D4", ("PT\t%d\t%d"):format(duration, instanceId), IsInGroup(2) and "INSTANCE_CHAT" or "RAID")
		end
		if not addon.db["noChatOnPullTimer"] then SendChatMessage(("PULL in %ds"):format(duration), "PARTY") end

		-- ticker updates local countdown (also handles chat, optional)
		self.ticker = C_Timer.NewTicker(1, function(t)
			self.remaining = self.remaining - 1
			if self.remaining > 6 then
				self.timerCountdown:SetVertexColor(0, 1, 0)
			elseif self.remaining > 3 then
				self.timerCountdown:SetVertexColor(1, 1, 0)
			else
				self.timerCountdown:SetVertexColor(1, 0, 0)
			end
			if self.remaining <= 0 then
				t:Cancel()
				self.timerCountdown:SetText("0")
				self.icon:Show()
				self.timerCountdown:Hide()
				self.running = false
				if not MouseIsOver(rcButton) then
					self.spin:Stop()
					self.ring:SetRotation(0)
				end

				if not addon.db["noChatOnPullTimer"] then SendChatMessage(">>PULL NOW<<", "PARTY") end
				if addon.db["autoKeyStart"] and C_ChallengeMode.GetSlottedKeystoneInfo() then
					C_ChallengeMode.StartChallengeMode()
					ChallengesKeystoneFrame:Hide()
				end
			else
				self.timerCountdown:SetText(self.remaining)
				if not addon.db["noChatOnPullTimer"] then SendChatMessage(("PULL in %d"):format(self.remaining), "PARTY") end
			end
		end)
		self.running = true
	end

	local function cancelPull(self)
		if self.ticker then self.ticker:Cancel() end
		self.icon:Show()
		self.timerCountdown:Hide()
		self.running = false
		if not MouseIsOver(rcButton) then
			self.spin:Stop()
			self.ring:SetRotation(0)
		end
		C_PartyInfo.DoCountdown(0) -- abort Blizzard countdown
		if not addon.db["noChatOnPullTimer"] then SendChatMessage("PULL Canceled", "PARTY") end
	end

	rcButton:RegisterForClicks("RightButtonDown", "LeftButtonDown")
	rcButton:SetScript("OnClick", function(self, button)
		if self.running then
			if addon.db["cancelPullTimerOnClick"] then cancelPull(self) end
			return
		end

		local duration = (button == "RightButton") and addon.db["pullTimerShortTime"] or addon.db["pullTimerLongTime"]
		startPull(self, duration)
	end)
	rcButton:SetFrameStrata("DIALOG")

	local icon = rcButton:CreateTexture(nil, "ARTWORK", nil, 0)
	icon:SetPoint("CENTER", rcButton, "CENTER")
	icon:SetTexture("Interface/AddOns/EnhanceQoLMythicPlus/Art/corePull.tga")
	icon:SetSize(72, 72)
	rcButton.icon = icon

	local timerCountdown = rcButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	timerCountdown:SetPoint("CENTER", rcButton, "CENTER", 0, 0)
	timerCountdown:SetFont(addon.variables.defaultFont, 20, "OUTLINE")
	timerCountdown:SetVertexColor(1, 1, 0)
	timerCountdown:Hide()
	rcButton.timerCountdown = timerCountdown

	-- pulse animation for "waiting" state
	local pulse = icon:CreateAnimationGroup()
	local fadeOut = pulse:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0.3)
	fadeOut:SetDuration(0.8)
	fadeOut:SetOrder(1)

	local fadeIn = pulse:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0.3)
	fadeIn:SetToAlpha(1)
	fadeIn:SetDuration(0.8)
	fadeIn:SetOrder(2)

	pulse:SetLooping("REPEAT")
	rcButton.iconPulse = pulse

	local ring = rcButton:CreateTexture(nil, "OVERLAY", nil, 1)
	ring:SetTexture("Interface/AddOns/EnhanceQoLMythicPlus/Art/coreRing.tga")
	ring:SetSize(110, 110)
	ring:SetPoint("CENTER", rcButton, "CENTER")
	rcButton.ring = ring

	local spin = ring:CreateAnimationGroup()
	local rot = spin:CreateAnimation("Rotation")
	rot:SetDegrees(360)
	rot:SetDuration(24)
	spin:SetLooping("REPEAT")
	rcButton.spin = spin

	rcButton:SetScript("OnEnter", function(self, button)
		if not self.running then spin:Play() end
	end)
	rcButton:SetScript("OnLeave", function(self, button)
		if not self.running then
			spin:Stop()
			ring:SetRotation(0)
		end
	end)
	addon.MythicPlus.Buttons["EnhanceQoLMythicPlus_PullTimer"] = rcButton
	addon.MythicPlus.nrOfButtons = addon.MythicPlus.nrOfButtons + 1
end

function addon.MythicPlus.functions.addButton(frame, name, text, call)
	local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
	button:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, (addon.MythicPlus.nrOfButtons * -40))
	button:SetSize(140, 40)
	button:SetText(text)
	button:SetNormalFontObject("GameFontNormalLarge")
	button:SetHighlightFontObject("GameFontHighlightLarge")
	button:RegisterForClicks("RightButtonDown", "LeftButtonDown")
	button:SetScript("OnClick", call)
	if UnitIsGroupLeader("Player") == false then button:Hide() end
	addon.MythicPlus.Buttons[name] = button
	addon.MythicPlus.nrOfButtons = addon.MythicPlus.nrOfButtons + 1
end

function addon.MythicPlus.functions.removeExistingButton()
	for _, button in pairs(addon.MythicPlus.Buttons) do
		if button then
			button:Hide() -- Versteckt den Button
			button:SetParent(nil) -- Entfernt den Parent-Frame

			-- Entferne alle registrierten Event-Handler und Scripte
			button:SetScript("OnClick", nil)
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button:SetScript("OnUpdate", nil)
			button:SetScript("OnEvent", nil)

			-- Entferne alle Texturen und andere Frames
			button:UnregisterAllEvents()
			button:ClearAllPoints()
		end
	end
	addon.MythicPlus.Buttons = {}
	addon.MythicPlus.nrOfButtons = 0
end

addon.MythicPlus.variables.portalCompendium = {
	[120] = {
		headline = EXPANSION_NAME10,
		spells = {
			[445269] = { text = "SV", cId = { [501] = true } },
			[445416] = { text = "COT", cId = { [502] = true } },
			[445414] = { text = "DAWN", cId = { [505] = true } },
			[445417] = { text = "ARAK", cId = { [503] = true } },
			[1216786] = { text = "FLOOD", cId = { [525] = true }, mapID = 2773 },
			[445440] = { text = "BREW", cId = { [506] = true }, mapID = 2661 },
			[445444] = { text = "PSF", cId = { [499] = true }, mapID = 2649 },
			[445441] = { text = "DFC", cId = { [504] = true }, mapID = 2651 },
			[445443] = { text = "ROOK", cId = { [500] = true }, mapID = 2648 },
			[448126] = { text = "ENGI", isToy = true, toyID = 221966, isEngineering = true },
			[446540] = { text = "DORN", isClassTP = "MAGE" },
			[446534] = { text = "DORN", isMagePortal = true },
			[1226482] = { text = "LOU", isRaid = true },
			[1223041] = { text = "HS", isItem = true, itemID = 234389, isRaid = true, icon = 3718248, map = 2406 },
		},
	},
	[110] = {
		headline = EXPANSION_NAME9,
		spells = {
			[424197] = { text = "DOTI", cId = { [463] = true, [464] = true } },
			[393256] = { text = "RLP", cId = { [399] = true } },
			[393262] = { text = "NO", cId = { [400] = true } },
			[393267] = { text = "BH", cId = { [405] = true } },
			[393273] = { text = "AA", cId = { [402] = true } },
			[393276] = { text = "NELT", cId = { [404] = true } },
			[393279] = { text = "AV", cId = { [401] = true } },
			[393283] = { text = "HOI", cId = { [406] = true } },
			[393222] = { text = "ULD", cId = { [403] = true } },
			[432254] = { text = "VOTI", isRaid = true },
			[432258] = { text = "AMIR", isRaid = true },
			[432257] = { text = "ASC", isRaid = true },
			[386379] = { text = "ENGI", isToy = true, toyID = 198156, isEngineering = true },
			-- Valdrakken (Dragonflight)
			[395277] = { text = "Vald", isClassTP = "MAGE" },
			[395289] = { text = "Vald", isMagePortal = true },
		},
	},
	[100] = {
		headline = EXPANSION_NAME8,
		spells = {
			[354462] = { text = "NW", cId = { [376] = true } },
			[354463] = { text = "PF", cId = { [379] = true } },
			[354464] = { text = "MISTS", cId = { [375] = true } },
			[354465] = { text = "HOA", cId = { [378] = true } },
			[354466] = { text = "SOA", cId = { [381] = true } },
			[354467] = { text = "TOP", cId = { [382] = true }, mapID = 2293 },
			[354468] = { text = "DOS", cId = { [377] = true } },
			[354469] = { text = "SD", cId = { [380] = true } },
			[367416] = { text = "TAZA", cId = { [391] = true, [392] = true } },
			[373190] = { text = "CN", isRaid = true }, -- Raids
			[373192] = { text = "SFO", isRaid = true }, -- Raids
			[373191] = { text = "SOD", isRaid = true }, -- Raids
			[324031] = { text = "ENGI", isToy = true, toyID = 172924, isEngineering = true },
			-- Oribos (Shadowlands)
			[344587] = { text = "Orib", isClassTP = "MAGE" },
			[344597] = { text = "Orib", isMagePortal = true },
		},
	},
	[90] = {
		headline = EXPANSION_NAME7,
		spells = {
			[410071] = { text = "FH", cId = { [245] = true } },
			[410074] = { text = "UR", cId = { [251] = true } },
			[373274] = { text = "WORK", cId = { [369] = true, [370] = true }, mapID = 2097 },
			[424167] = { text = "WM", cId = { [248] = true } },
			[424187] = { text = "AD", cId = { [244] = true } },
			[445418] = { text = "SIEG", faction = FACTION_ALLIANCE, cId = { [353] = true } },
			[464256] = { text = "SIEG", faction = FACTION_HORDE, cId = { [353] = true } },
			[467553] = { text = "ML", faction = FACTION_ALLIANCE, cId = { [247] = true }, mapID = 1594 },
			[467555] = { text = "ML", faction = FACTION_HORDE, cId = { [247] = true }, mapID = 1594 },
			[299083] = { text = "ENGI", isToy = true, toyID = 168807, isEngineering = true },
			[299084] = { text = "ENGI", isToy = true, toyID = 168808, isEngineering = true },
			-- Boralus (BfA)
			[281403] = { text = "Borl", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[281400] = { text = "Borl", isMagePortal = true, faction = FACTION_ALLIANCE },
			-- Dazar'alor (BfA)
			[281404] = { text = "Daza", isClassTP = "MAGE", faction = FACTION_HORDE },
			[281402] = { text = "Daza", isMagePortal = true, faction = FACTION_HORDE },
			[396591] = { text = "HS", isItem = true, itemID = 202046, isHearthstone = true, icon = 2203919 },
		},
	},
	[80] = {
		headline = EXPANSION_NAME6,
		spells = {
			[424153] = { text = "BRH", cId = { [199] = true } },
			[393766] = { text = "COS", cId = { [210] = true } },
			[424163] = { text = "DHT", cId = { [198] = true } },
			[393764] = { text = "HOV", cId = { [200] = true } },
			[410078] = { text = "NL", cId = { [206] = true } },
			[373262] = { text = "KARA", cId = { [227] = true, [234] = true } },
			[250796] = { text = "ENGI", isToy = true, toyID = 151652, isEngineering = true },
			[222695] = { text = "HS", isToy = true, toyID = 140192, isHearthstone = true, icon = 1444943 },
			-- Dalaran (Broken Isles, Legion)
			[224869] = { text = "DalB", isClassTP = "MAGE" },
			[224871] = { text = "DalB", isMagePortal = true },
		},
	},
	[70] = {
		headline = EXPANSION_NAME5,
		spells = {
			[159897] = { text = "AUCH", cId = { [164] = true } },
			[159895] = { text = "BSM", cId = { [163] = true } },
			[159901] = { text = "EB", cId = { [168] = true } },
			[159900] = { text = "GD", cId = { [166] = true } },
			[159896] = { text = "ID", cId = { [169] = true } },
			[159899] = { text = "SBG", cId = { [165] = true } },
			[159898] = { text = "SR", cId = { [161] = true } },
			[159902] = { text = "UBRS", cId = { [167] = true } },
			[163830] = { text = "ENGI", isToy = true, toyID = 112059, isEngineering = true },
			[171253] = { text = "HS", isToy = true, toyID = 110560, isHearthstone = true },
			[132621] = { text = "VALE", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[132620] = { text = "VALE", isMagePortal = true, faction = FACTION_ALLIANCE },
			[132627] = { text = "VALE", isClassTP = "MAGE", faction = FACTION_HORDE },
			[132625] = { text = "VALE", isMagePortal = true, faction = FACTION_HORDE },
			[49359] = { text = "THER", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[49360] = { text = "THER", isMagePortal = true, faction = FACTION_ALLIANCE },
			[49358] = { text = "STON", isClassTP = "MAGE", faction = FACTION_HORDE },
			[49361] = { text = "STON", isMagePortal = true, faction = FACTION_HORDE },

			[176248] = { text = "STORM", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[176246] = { text = "STORM", isMagePortal = true, faction = FACTION_ALLIANCE },
			[176242] = { text = "WARS", isClassTP = "MAGE", faction = FACTION_HORDE },
			[176244] = { text = "WARS", isMagePortal = true, faction = FACTION_HORDE },
		},
	},
	[60] = {
		headline = EXPANSION_NAME4,
		spells = {
			[131225] = { text = "GSS", cId = { [57] = true } },
			[131222] = { text = "MP", cId = { [60] = true } },
			[131232] = { text = "SCHO", cId = { [76] = true } },
			[131231] = { text = "SH", cId = { [77] = true } },
			[131229] = { text = "SM", cId = { [78] = true } },
			[131228] = { text = "SN", cId = { [59] = true } },
			[131206] = { text = "SPM", cId = { [58] = true } },
			[131205] = { text = "SB", cId = { [56] = true } },
			[131204] = { text = "TJS", cId = { [2] = true } },
			[87215] = { text = "ENGI", isToy = true, toyID = 87215, isEngineering = true }, -- spellID ist noch falsch
			[120145] = { text = "DALA", isClassTP = "MAGE" },
			[120146] = { text = "DALA", isMagePortal = true },
		},
	},
	[50] = {
		headline = EXPANSION_NAME3,
		spells = {
			[445424] = { text = "GB", cId = { [507] = true } },
			[424142] = { text = "TOTT", cId = { [456] = true } },
			[410080] = { text = "VP", cId = { [438] = true } },
			-- Tol Barad (Cata)
			[88344] = { text = "TolB", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[88345] = { text = "TolB", isMagePortal = true, faction = FACTION_ALLIANCE },
			[88346] = { text = "TolB", isClassTP = "MAGE", faction = FACTION_HORDE },
			[88347] = { text = "TolB", isMagePortal = true, faction = FACTION_HORDE },
		},
	},
	[40] = {
		headline = EXPANSION_NAME2,
		spells = {
			[67833] = { text = "ENGI", isToy = true, toyID = 48933, isEngineering = true },
			[73324] = { text = "HS", isItem = true, itemID = 52251, isHearthstone = true, icon = 133308 },
			-- Dalaran (Northrend, WotLK)
			[53140] = { text = "DalN", isClassTP = "MAGE" },
			[53142] = { text = "DalN", isMagePortal = true },
		},
	},
	[30] = {
		headline = EXPANSION_NAME1,
		spells = {
			-- Shattrath (TBC)
			[245173] = { text = "BT", isToy = true, toyID = 151016, isHearthstone = true },
			[33690] = { text = "Shat", isClassTP = "MAGE" },
			[33691] = { text = "Shat", isMagePortal = true },
			[32271] = { text = "Exod", isClassTP = "MAGE", faction = FACTION_ALLIANCE }, -- Teleport: Exodar
			[32266] = { text = "Exod", isMagePortal = true, faction = FACTION_ALLIANCE }, -- Portal: Exodar
			[32272] = { text = "SMC", isClassTP = "MAGE", faction = FACTION_HORDE }, -- Teleport: Silvermoon
			[32267] = { text = "SMC", isMagePortal = true, faction = FACTION_HORDE }, -- Portal: Silvermoon
		},
	},
	[20] = {
		headline = EXPANSION_NAME0,
		spells = {
			-- Allianz
			[3561] = { text = "SW", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[10059] = { text = "SW", isMagePortal = true, faction = FACTION_ALLIANCE },
			[3562] = { text = "IF", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[11416] = { text = "IF", isMagePortal = true, faction = FACTION_ALLIANCE },
			[3565] = { text = "Darn", isClassTP = "MAGE", faction = FACTION_ALLIANCE },
			[11419] = { text = "Darn", isMagePortal = true, faction = FACTION_ALLIANCE },

			-- Horde
			[3567] = { text = "Orgr", isClassTP = "MAGE", faction = FACTION_HORDE },
			[11417] = { text = "Orgr", isMagePortal = true, faction = FACTION_HORDE },
			[3563] = { text = "UC", isClassTP = "MAGE", faction = FACTION_HORDE },
			[11418] = { text = "UC", isMagePortal = true, faction = FACTION_HORDE },
			[3566] = { text = "ThBl", isClassTP = "MAGE", faction = FACTION_HORDE },
			[11420] = { text = "ThBl", isMagePortal = true, faction = FACTION_HORDE },
		},
	},
	[10] = {
		headline = CLASS,
		spells = {
			[193759] = { text = "CLASS", isClassTP = "MAGE" },
			[193753] = { text = "CLASS", isClassTP = "DRUID" },
			[50977] = { text = "CLASS", isClassTP = "DEATHKNIGHT" },
			[556] = { text = "CLASS", isClassTP = "SHAMAN" },
			[126892] = { text = "CLASS", isClassTP = "MONK" },
			[265225] = { text = "RACE", isRaceTP = "DarkIronDwarf" },
		},
	},
	[11] = {
		headline = HOME,
		spells = {},
	},
}

-- Pre-Stage all icon to have less calls to LUA API
local hearthstoneID = {
	{ isItem = true, icon = 134414, id = 6948, spellID = 8690 }, -- Default Hearthstone
	{ isToy = true, icon = 236222, id = 54452, spellID = 75136 }, -- Ethereal Portal
	{ isToy = true, icon = 458254, id = 64488, spellID = 94716 }, -- The Innkeeper's Daughter
	{ isToy = true, icon = 255348, id = 93672, spellID = 136508 }, -- Dark Portal
	-- { isToy = true, icon = 1529351, id = 142542, spellID = 231504 }, -- Tome of Town Portal -- Cooldown is to long to be usable
	{ isToy = true, icon = 2124576, id = 162973, spellID = 278244 }, -- Greatfather Winter's Hearthstone
	{ isToy = true, icon = 2124575, id = 163045, spellID = 278559 }, -- Headless Horseman's Hearthstone
	{ isToy = true, icon = 2491049, id = 165669, spellID = 285362 }, -- Lunar Elder's Hearthstone
	{ isToy = true, icon = 2491048, id = 165670, spellID = 285424 }, -- Peddlefeet's Lovely Hearthstone
	{ isToy = true, icon = 2491065, id = 165802, spellID = 286031 }, -- Noble Gardener's Hearthstone
	{ isToy = true, icon = 2491064, id = 166746, spellID = 286331 }, -- Fire Eater's Hearthstone
	{ isToy = true, icon = 2491063, id = 166747, spellID = 286353 }, -- Brewfest Reveler's Hearthstone
	{ isToy = true, icon = 2491049, id = 168907, spellID = 298068 }, -- Holographic Digitalization Hearthstone
	{ isToy = true, icon = 3084684, id = 172179, spellID = 308742 }, -- Eternal Traveler's Hearthstone
	{ isToy = true, icon = 3528303, id = 188952, spellID = 363799 }, -- Dominated Hearthstone
	{ isToy = true, icon = 3950360, id = 190196, spellID = 366945 }, -- Enlightened Hearthstone
	{ isToy = true, icon = 3954409, id = 190237, spellID = 367013 }, -- Broker Translocation Matrix
	{ isToy = true, icon = 4571434, id = 193588, spellID = 375357 }, -- Timewalker's Hearthstone
	{ isToy = true, icon = 4080564, id = 200630, spellID = 391042 }, -- Ohn'ir Windsage's Hearthstone
	{ isToy = true, icon = 1708140, id = 206195, spellID = 412555 }, -- Path of the Naaru
	{ isToy = true, icon = 5333528, id = 208704, spellID = 420418 }, -- Deepdweller's Earth Hearthstone
	{ isToy = true, icon = 2491064, id = 209035, spellID = 422284 }, -- Hearthstone of the Flame
	{ isToy = true, icon = 5524923, id = 212337, spellID = 401802 }, -- Stone of the Hearth
	{ isToy = true, icon = 5891370, id = 228940, spellID = 463481 }, -- Notorious Thread's Hearthstone
	{ isToy = true, icon = 6383489, id = 236687, spellID = 1220729 }, -- Explosive Hearthstone

	-- Covenent Hearthstones
	{ isToy = true, icon = 3257748, id = 184353, spellID = 345393, achievementID = 15242 }, -- Kyrian Hearthstone
	{ isToy = true, icon = 3514225, id = 183716, spellID = 342122, achievementID = 15245 }, -- Venthyr Sinstone
	{ isToy = true, icon = 3489827, id = 180290, spellID = 326064, achievementID = 15244 }, -- Night Fae Hearthstone
	{ isToy = true, icon = 3716927, id = 182773, spellID = 340200, achievementID = 15243 }, -- Necrolord Hearthstone
}

local availableHearthstones = {}

local function setAvailableHearthstone()
	availableHearthstones = {}
	for _, v in pairs(hearthstoneID) do
		local addIt = false
		if v.isItem then
			if C_Item.GetItemCount(v.id) > 0 then addIt = true end
		elseif PlayerHasToy(v.id) then
			if v.achievementID then
				if select(4, GetAchievementInfo(v.achievementID)) then addIt = true end
			else
				addIt = true
			end
		end
		if addIt then table.insert(availableHearthstones, v) end
	end
end

function addon.MythicPlus.functions.setRandomHearthstone()
	if #availableHearthstones == 0 then
		setAvailableHearthstone() -- recheck hearthstones
		if #availableHearthstones == 0 then return nil end
	end

	local randomIndex = math.random(1, #availableHearthstones)

	local hs = availableHearthstones[randomIndex]
	local hsSpellID = hs.spellID or 1
	addon.MythicPlus.variables.portalCompendium[11].spells = {
		[hsSpellID] = { text = "HS", isItem = false or hs.isItem, itemID = hs.id, isToy = false or hs.isToy, toyID = hs.id, isHearthstone = true, icon = hs.icon },
	}
end

addon.MythicPlus.variables.collapseFrames = {
	{ frame = AchievementObjectiveTracker },
	{ frame = AdventureObjectiveTracker },
	{ frame = BonusObjectiveTracker },
	{ frame = CampaignQuestObjectiveTracker },
	{ frame = QuestObjectiveTracker },
	{ frame = ProfessionsRecipeTracker },
	{ frame = WorldQuestObjectiveTracker },
}
