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
