local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.functions.InitDBValue("TooltipUnitHideType", 1)
addon.functions.InitDBValue("TooltipUnitHideInCombat", true)
addon.functions.InitDBValue("TooltipUnitHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowMythicScore", false)
addon.functions.InitDBValue("TooltipShowClassColor", false)
addon.functions.InitDBValue("TooltipShowNPCID", true)

-- Spell
addon.functions.InitDBValue("TooltipSpellHideType", 1)
addon.functions.InitDBValue("TooltipSpellHideInCombat", false)
addon.functions.InitDBValue("TooltipSpellHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowSpellID", true)

-- Item
addon.functions.InitDBValue("TooltipItemHideType", 1)
addon.functions.InitDBValue("TooltipItemHideInCombat", false)
addon.functions.InitDBValue("TooltipItemHideInDungeon", false)
addon.functions.InitDBValue("TooltipShowItemID", true)

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

addon.Tooltip.Buttons = {}
addon.Tooltip.nrOfButtons = 0
addon.Tooltip.variables = {}
addon.Tooltip.variables.numOfTabs = 0

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

function addon.Tooltip.functions.createTabFrame(text, frame)
	addon.Tooltip.variables.numOfTabs = addon.Tooltip.variables.numOfTabs + 1
	local tab1 = addon.functions.createTabButton(frame, addon.Tooltip.variables.numOfTabs, text)
	tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	PanelTemplates_SetNumTabs(frame, addon.Tooltip.variables.numOfTabs)
	PanelTemplates_SetTab(frame, 1)

	frame.tabs[addon.Tooltip.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
	frame.tabs[addon.Tooltip.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
	frame.tabs[addon.Tooltip.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -2 - (tab1:GetHeight()))

	if addon.Tooltip.variables.numOfTabs == 1 then
		frame.tabs[addon.Tooltip.variables.numOfTabs]:Show()
	else
		frame.tabs[addon.Tooltip.variables.numOfTabs]:Hide()
	end
	return frame.tabs[addon.Tooltip.variables.numOfTabs]
end
