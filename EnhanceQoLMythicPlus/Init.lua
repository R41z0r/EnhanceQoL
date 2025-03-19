local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

-- PullTimer
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
addon.functions.InitDBValue("groupfinderSkipRolecheck", false)
addon.functions.InitDBValue("groupfinderShowDungeonScoreFrame", false)

-- Misc
addon.functions.InitDBValue("autoMarkTankInDungeon", false)
addon.functions.InitDBValue("autoMarkTankInDungeonMarker", 6)
addon.functions.InitDBValue("mythicPlusIgnoreMythic", true)
addon.functions.InitDBValue("mythicPlusIgnoreHeroic", true)
addon.functions.InitDBValue("mythicPlusIgnoreNormal", true)
addon.functions.InitDBValue("mythicPlusIgnoreTimewalking", true)

addon.MythicPlus = {}
addon.LMythicPlus = {} -- Locales for MythicPlus
addon.MythicPlus.functions = {}

addon.MythicPlus.Buttons = {}
addon.MythicPlus.nrOfButtons = 0
addon.MythicPlus.variables = {}

-- Teleports
addon.functions.InitDBValue("teleportFrame", false)
addon.functions.InitDBValue("portalHideMissing", false)
addon.functions.InitDBValue("portalShowTooltip", false)
addon.functions.InitDBValue("teleportsEnableCompendium", false)

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
			[222695] = { text = "HS", isToy = true, toyID = 140192, isHearthstone = true },
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

local hearthstoneID = {
	6948, -- Default Hearthstone
	54452, -- Ethereal Portal
	64488, -- The Innkeeper's Daughter
	93672, -- Dark Portal
	--142542, -- Tome of Town Portal -- Cooldown is to long to be usable
	162973, -- Greatfather Winter's Hearthstone
	163045, -- Headless Horseman's Hearthstone
	165669, -- Lunar Edler's Hearthstone
	165670, -- Peddlefeet's Lovely Hearthstone
	165802, -- Noble Gardener's Hearthstone
	166746, -- Fire Eater's Hearthstone
	166747, -- Brewfest Reveler's Hearthstone
	168907, -- Holographic Digitalization Hearthstone
	172179, -- Eternal Traveler's Hearthstone
	188952, -- Dominated Hearthstone
	190196, -- Enlightened Hearthstone
	190237, -- Broker Translocation Matrix
	193588, -- Timewalker's Hearthstone
	200630, -- Ohn'ir Windsage's Hearthstone
	206195, -- Path of the Naaru
	208704, -- Deepdweller's Earth Hearthstone
	209035, -- Hearthstone of the Flame
	212337, -- Stone of the Hearth
	228940, -- Notorious Thread's Hearthstone
	236687, -- Explosive Hearthstone

	-- Covenent Hearthstones
	184353, -- Kyrian Hearthstone
	183716, -- Venthyr Sinstone
	180290, -- Night Fae Hearthstone
	182773, -- Necrolord Hearthstone
}

local availableHearthstones = {}

for i, v in pairs(hearthstoneID) do
	if v == 6948 then
		if C_Item.GetItemCount(v) > 0 then table.insert(availableHearthstones, v) end
	elseif v == 184353 and select(4, GetAchievementInfo(15242)) == true then
		table.insert(availableHearthstones, v)
	elseif v == 183716 and select(4, GetAchievementInfo(15245)) == true then
		table.insert(availableHearthstones, v)
	elseif v == 180290 and select(4, GetAchievementInfo(15244)) == true then
		table.insert(availableHearthstones, v)
	elseif v == 182773 and select(4, GetAchievementInfo(15243)) == true then
		table.insert(availableHearthstones, v)
	elseif PlayerHasToy(v) then
		table.insert(availableHearthstones, v)
	end
end

local foundHearthstone = false

function addon.MythicPlus.functions.setRandomHearthstone()
	if foundHearthstone then return end
	if #availableHearthstones == 0 then return nil end

	local randomIndex = math.random(1, #availableHearthstones)

	local hs = availableHearthstones[randomIndex]
	if hs == 6948 then
		if C_Item.GetItemCount(hs) > 0 then
			foundHearthstone = true
			addon.MythicPlus.variables.portalCompendium[11].spells = {
				[1] = { text = "HS", isItem = true, itemID = hs, isHearthstone = true },
			}
		else
			addon.MythicPlus.functions.setRandomHearthstone()
		end
	elseif PlayerHasToy(hs) then
		foundHearthstone = true
		addon.MythicPlus.variables.portalCompendium[11].spells = {
			[1] = { text = "HS", isToy = true, toyID = hs, isHearthstone = true },
		}
	else
		addon.MythicPlus.functions.setRandomHearthstone()
	end
end
