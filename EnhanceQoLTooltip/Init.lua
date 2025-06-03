local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.functions.InitDBValue("TooltipAnchorType", 1)
addon.functions.InitDBValue("TooltipAnchorOffsetX", 0)
addon.functions.InitDBValue("TooltipAnchorOffsetY", 0)

addon.functions.InitDBValue("TooltipUnitHideType", 1)
addon.functions.InitDBValue("TooltipUnitHideInCombat", true)
addon.functions.InitDBValue("TooltipUnitHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowMythicScore", false)
addon.functions.InitDBValue("TooltipShowClassColor", false)
addon.functions.InitDBValue("TooltipShowNPCID", false)

-- Spell
addon.functions.InitDBValue("TooltipSpellHideType", 1)
addon.functions.InitDBValue("TooltipSpellHideInCombat", false)
addon.functions.InitDBValue("TooltipSpellHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowSpellID", false)

-- Item
addon.functions.InitDBValue("TooltipItemHideType", 1)
addon.functions.InitDBValue("TooltipItemHideInCombat", false)
addon.functions.InitDBValue("TooltipItemHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowItemID", false)
addon.functions.InitDBValue("showAltItemCountTooltip", false)

-- Buff
addon.functions.InitDBValue("TooltipBuffHideType", 1)
addon.functions.InitDBValue("TooltipBuffHideInCombat", false)
addon.functions.InitDBValue("TooltipBuffHideInDungeon", false)

-- Debuff
addon.functions.InitDBValue("TooltipDebuffHideType", 1)
addon.functions.InitDBValue("TooltipDebuffHideInCombat", false)
addon.functions.InitDBValue("TooltipDebuffHideInDungeon", false)

addon.Tooltip = {}
addon.LTooltip = {} -- Locales for MythicPlus
addon.Tooltip.functions = {}

addon.Tooltip.variables = {}

addon.Tooltip.variables.maxLevel = GetMaxLevelForPlayerExpansion()

addon.Tooltip.variables.kindsByID = {
	[0] = "item", -- Item
	[1] = "spell", -- Spell
	[2] = "unit", -- Unit
	[3] = "unit", -- Corpse
	[4] = "object", -- Object
	[5] = "currency", -- Currency
	[6] = "unit", -- BattlePet
	[7] = "aura", -- UnitAura
	[8] = "spell", -- AzeriteEssence
	[9] = "unit", -- CompanionPet
	[10] = "mount", -- Mount
	[11] = "spell", -- PetAction
	[12] = "achievement", -- Achievement
	[13] = "spell", -- EnhancedConduit
	[14] = "set", -- EquipmentSet
	[15] = "", -- InstanceLock
	[16] = "", -- PvPBrawl
	[17] = "spell", -- RecipeRankInfo
	[18] = "spell", -- Totem
	[19] = "item", -- Toy
	[20] = "", -- CorruptionCleanser
	[21] = "", -- MinimapMouseover
	[22] = "", -- Flyout
	[23] = "quest", -- Quest
	[24] = "quest", -- QuestPartyProgress
	[25] = "macro", -- Macro
	[26] = "", -- Debug
}

addon.Tooltip.variables.challengeMapID = {
	[501] = "SV",
	[502] = "COT",
	[505] = "DAWN",
	[503] = "ARAK",
	[525] = "FLOOD",
	[506] = "MEAD",
	[499] = "PRIO",
	[504] = "DFC",
	[500] = "ROOK",
	[463] = "DOTI",
	[464] = "DOTI",
	[399] = "RLP",
	[400] = "NO",
	[405] = "BH",
	[402] = "AA",
	[404] = "NELT",
	[401] = "AV",
	[406] = "HOI",
	[403] = "ULD",
	[376] = "NW",
	[379] = "PF",
	[375] = "MISTS",
	[378] = "HOA",
	[381] = "SOA",
	[382] = "TOP",
	[377] = "DOS",
	[380] = "SD",
	[391] = "TAZA",
	[392] = "TAZA",
	[245] = "FH",
	[251] = "UR",
	[369] = "WORK",
	[370] = "WORK",
	[248] = "WM",
	[244] = "AD",
	[353] = "SIEG",
	[247] = "ML",
	[199] = "BRH",
	[210] = "COS",
	[198] = "DHT",
	[200] = "HOV",
	[206] = "NL",
	[227] = "KARA",
	[234] = "KARA",
	[164] = "AUCH",
	[163] = "BSM",
	[168] = "EB",
	[166] = "GD",
	[169] = "ID",
	[165] = "SBG",
	[161] = "SR",
	[167] = "UBRS",
	[57] = "GSS",
	[60] = "MP",
	[76] = "SCHO",
	[77] = "SH",
	[78] = "SM",
	[59] = "SN",
	[58] = "SPM",
	[56] = "SB",
	[2] = "TJS",
	[507] = "GB",
	[456] = "TOTT",
	[438] = "VP",
}
