local addonName, addon = ...
_G[addonName] = addon
addon.saveVariables = {} -- Cross-Module variables for DB Save
addon.gossip = {}
addon.gossip.variables = {}
addon.variables = {}
addon.general = {}
addon.general.variables = {}
addon.L = {} -- Language
addon.elements = {}
--@debug@
addon.itemBagFilters = {}
addon.itemBagFiltersQuality = {}
addon.itemBagFilterTypes = {
	WARRIOR = { "Plate" },
	PALADIN = { "Plate" },
	HUNTER = { "Mail" },
	ROGUE = { "Leather" },
	PRIEST = { "Cloth" },
	DEATHKNIGHT = { "Plate" },
	SHAMAN = { "Mail" },
	MAGE = { "Cloth" },
	WARLOCK = { "Cloth" },
	MONK = { "Leather" },
	DRUID = {
		[1] = { --Balance
			[2] = { -- Weapon
				[10] = true, -- Staff
				[15] = true, -- Daggers
				[4] = true, -- Mace 1h
				[5] = true, -- Mace 2h
			},
			[4] = { -- Armor
				[0] = true, -- Generic
				[2] = true, -- Leather
				[6] = true, -- Shield
			},
		},
		[2] = { --Feral
			[2] = { -- Weapon
				[10] = true, -- Staff
				[6] = true, -- Polearm
			},
			[4] = { -- Armor
				[0] = true, -- Generic
				[2] = true, -- Leather
			},
		},
		[3] = { --Guardian
			[2] = { -- Weapon
				[10] = true, -- Staff
				[6] = true, -- Polearm
			},
			[4] = { -- Armor
				[0] = true, -- Generic
				[2] = true, -- Leather
			},
		},
		[4] = { --Restoration
			[2] = { -- Weapon
				[10] = true, -- Staff
				[15] = true, -- Daggers
				[4] = true, -- Mace 1h
				[5] = true, -- Mace 2h
			},
			[4] = { -- Armor
				[0] = true, -- Generic
				[2] = true, -- Leather
				[6] = true, -- Shield
			},
		},
	},
	DEMONHUNTER = { "Leather" },
	EVOKER = { "Mail" },
}
--@end-debug@

addon.variables.unitClass = select(2, UnitClass("player"))
addon.variables.unitClassID = select(3, UnitClass("player"))
addon.variables.unitPlayerGUID = UnitGUID("player")
addon.variables.unitSpec = GetSpecialization()
addon.variables.unitRace = select(2, UnitRace("player"))
addon.variables.unitName = select(1, UnitName("player"))

addon.variables.requireReload = false
addon.variables.catalystID = 3116 -- Change to get the actual cataclyst charges in char frame
addon.variables.durabilityIcon = 136241 -- Anvil Symbol
addon.variables.durabilityCount = 0
addon.variables.hookedOrderHall = false
addon.variables.maxLevel = GetMaxLevelForPlayerExpansion()
addon.variables.statusTable = { groups = {} }

addon.variables.enchantString = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")

addon.variables.itemSlots = {
	[1] = CharacterHeadSlot,
	[2] = CharacterNeckSlot,
	[3] = CharacterShoulderSlot,
	[15] = CharacterBackSlot,
	[5] = CharacterChestSlot,
	[9] = CharacterWristSlot,
	[10] = CharacterHandsSlot,
	[6] = CharacterWaistSlot,
	[7] = CharacterLegsSlot,
	[8] = CharacterFeetSlot,
	[11] = CharacterFinger0Slot,
	[12] = CharacterFinger1Slot,
	[13] = CharacterTrinket0Slot,
	[14] = CharacterTrinket1Slot,
	[16] = CharacterMainHandSlot,
	[17] = CharacterSecondaryHandSlot,
}
addon.variables.shouldEnchanted = { [15] = true, [5] = true, [9] = true, [7] = true, [8] = true, [11] = true, [12] = true, [16] = true, [17] = true }

addon.variables.landingPageType = {
	[10] = { title = GARRISON_LANDING_PAGE_TITLE, checkbox = GARRISON_LOCATION_TOOLTIP },
	[20] = { title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, checkbox = EXPANSION_NAME8 },
	[30] = { title = DRAGONFLIGHT_LANDING_PAGE_TITLE, checkbox = EXPANSION_NAME9 },
	[40] = { title = WAR_WITHIN_LANDING_PAGE_TITLE, checkbox = EXPANSION_NAME10 },
}
addon.variables.landingPageReverse = {} -- Used for onShow Method of LandingPage
for id, data in pairs(addon.variables.landingPageType) do
	addon.variables.landingPageReverse[data.title] = id
end

addon.variables.allowedEnchantTypesForOffhand = { ["INVTYPE_WEAPON"] = true, ["INVTYPE_WEAPONOFFHAND"] = true }

addon.variables.itemSlotSide = { -- 0 = Text to right side, 1 = Text to left side
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[15] = 0,
	[5] = 0,
	[9] = 0,
	[10] = 1,
	[6] = 1,
	[7] = 1,
	[8] = 1,
	[11] = 1,
	[12] = 1,
	[13] = 1,
	[14] = 1,
	[16] = 1,
	[17] = 2,
}

addon.variables.allowedSockets = {
	["EMPTY_SOCKET_BLUE"] = true,
	["EMPTY_SOCKET_COGWHEEL"] = true,
	["EMPTY_SOCKET_CYPHER"] = true,
	["EMPTY_SOCKET_DOMINATION"] = true,
	["EMPTY_SOCKET_HYDRAULIC"] = true,
	["EMPTY_SOCKET_META"] = true,
	["EMPTY_SOCKET_NO_COLOR"] = true,
	["EMPTY_SOCKET_PRIMORDIAL"] = true,
	["EMPTY_SOCKET_PRISMATIC"] = true,
	["EMPTY_SOCKET_PUNCHCARDBLUE"] = true,
	["EMPTY_SOCKET_PUNCHCARDRED"] = true,
	["EMPTY_SOCKET_PUNCHCARDYELLOW"] = true,
	["EMPTY_SOCKET_RED"] = true,
	["EMPTY_SOCKET_TINKER"] = true,
	["EMPTY_SOCKET_YELLOW"] = true,
	["EMPTY_SOCKET_SINGINGSEA"] = true,
	["EMPTY_SOCKET_SINGINGTHUNDER"] = true,
	["EMPTY_SOCKET_SINGINGWIND"] = true,
}

addon.variables.allowBagIlvlClassID = { [2] = true, [4] = true }
addon.variables.denyBagIlvlClassSubClassID = { [4] = { [5] = true } }
addon.variables.allowedEquipSlotsBagIlvl = {
	["INVTYPE_NON_EQUIP_IGNORE"] = true,
	["INVTYPE_HEAD"] = true,
	["INVTYPE_NECK"] = true,
	["INVTYPE_SHOULDER"] = true,
	["INVTYPE_BODY"] = true,
	["INVTYPE_CHEST"] = true,
	["INVTYPE_WAIST"] = true,
	["INVTYPE_LEGS"] = true,
	["INVTYPE_FEET"] = true,
	["INVTYPE_WRIST"] = true,
	["INVTYPE_HAND"] = true,
	["INVTYPE_FINGER"] = true,
	["INVTYPE_TRINKET"] = true,
	["INVTYPE_WEAPON"] = true,
	["INVTYPE_SHIELD"] = true,
	["INVTYPE_RANGED"] = true,
	["INVTYPE_CLOAK"] = true,
	["INVTYPE_2HWEAPON"] = true, -- ["INVTYPE_BAG"] = true,
	-- ["INVTYPE_TABARD"] = true,
	-- ["INVTYPE_ROBE"] = true,
	["INVTYPE_WEAPONMAINHAND"] = true,
	["INVTYPE_WEAPONOFFHAND"] = true,
	["INVTYPE_HOLDABLE"] = true,
	-- ["INVTYPE_AMMO"] = true,
	-- ["INVTYPE_THROWN"] = true,
	-- ["INVTYPE_RANGEDRIGHT"] = true,
	-- ["INVTYPE_QUIVER"] = true,
	-- ["INVTYPE_RELIC"] = true,
	["INVTYPE_PROFESSION_TOOL"] = true,
	["INVTYPE_PROFESSION_GEAR"] = true,
}

-- Actionbars
addon.variables.actionBarNames = {
	{ name = "MainMenuBar", var = "mouseoverActionBar1", text = BINDING_HEADER_ACTIONBAR },
	{ name = "MultiBarBottomLeft", var = "mouseoverActionBar2", text = BINDING_HEADER_ACTIONBAR2 },
	{ name = "MultiBarBottomRight", var = "mouseoverActionBar3", text = BINDING_HEADER_ACTIONBAR3 },
	{ name = "MultiBarRight", var = "mouseoverActionBar4", text = BINDING_HEADER_ACTIONBAR4 },
	{ name = "MultiBarLeft", var = "mouseoverActionBar5", text = BINDING_HEADER_ACTIONBAR5 },
	{ name = "MultiBar5", var = "mouseoverActionBar6", text = BINDING_HEADER_ACTIONBAR6 },
	{ name = "MultiBar6", var = "mouseoverActionBar7", text = BINDING_HEADER_ACTIONBAR7 },
	{ name = "MultiBar7", var = "mouseoverActionBar8", text = BINDING_HEADER_ACTIONBAR8 },
	{ name = "PetActionBar", var = "mouseoverActionBarPet", text = TUTORIAL_TITLE61_HUNTER },
	{ name = "StanceBar", var = "mouseoverActionBarStanceBar", text = HUD_EDIT_MODE_STANCE_BAR_LABEL },
}

addon.variables.unitFrameNames = {
	{ name = "PlayerFrame", var = "unitframeSettingPlayerFrame", text = HUD_EDIT_MODE_PLAYER_FRAME_LABEL },
	{ name = "BossTargetFrameContainer", var = "unitframeSettingBossTargetFrame", text = HUD_EDIT_MODE_BOSS_FRAMES_LABEL },
	{ name = "TargetFrame", var = "unitframeSettingTargetFrame", text = HUD_EDIT_MODE_TARGET_FRAME_LABEL },
}

table.sort(addon.variables.actionBarNames, function(a, b) return a.text < b.text end)
