local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

if nil == addon.db["TooltipUnitHideType"] then
    addon.db["TooltipUnitHideType"] = 1
end
if nil == addon.db["TooltipUnitHideInCombat"] then
    addon.db["TooltipUnitHideInCombat"] = true
end
if nil == addon.db["TooltipUnitHideInDungeon"] then
    addon.db["TooltipUnitHideInDungeon"] = false
end

if nil == addon.db["TooltipShowMythicScore"] then
    addon.db["TooltipShowMythicScore"] = false
end

if nil == addon.db["TooltipShowClassColor"] then
    addon.db["TooltipShowClassColor"] = false
end

-- Spell
if nil == addon.db["TooltipSpellHideType"] then
    addon.db["TooltipSpellHideType"] = 1
end
if nil == addon.db["TooltipSpellHideInCombat"] then
    addon.db["TooltipSpellHideInCombat"] = false
end
if nil == addon.db["TooltipSpellHideInDungeon"] then
    addon.db["TooltipSpellHideInDungeon"] = false
end
if nil == addon.db["TooltipShowSpellID"] then
    addon.db["TooltipShowSpellID"] = true
end

if nil == addon.db["TooltipItemHideType"] then
    addon.db["TooltipItemHideType"] = 1
end
if nil == addon.db["TooltipItemHideInCombat"] then
    addon.db["TooltipItemHideInCombat"] = false
end
if nil == addon.db["TooltipItemHideInDungeon"] then
    addon.db["TooltipItemHideInDungeon"] = false
end
if nil == addon.db["TooltipShowItemID"] then
    addon.db["TooltipShowItemID"] = true
end

-- Buff
if nil == addon.db["TooltipBuffHideType"] then
    addon.db["TooltipBuffHideType"] = 1
end
if nil == addon.db["TooltipBuffHideInCombat"] then
    addon.db["TooltipBuffHideInCombat"] = false
end
if nil == addon.db["TooltipBuffHideInDungeon"] then
    addon.db["TooltipBuffHideInDungeon"] = false
end
-- Debuff
if nil == addon.db["TooltipDebuffHideType"] then
    addon.db["TooltipDebuffHideType"] = 1
end
if nil == addon.db["TooltipDebuffHideInCombat"] then
    addon.db["TooltipDebuffHideInCombat"] = false
end
if nil == addon.db["TooltipDebuffHideInDungeon"] then
    addon.db["TooltipDebuffHideInDungeon"] = false
end

addon.Tooltip = {}
addon.LTooltip = {} -- Locales for MythicPlus
addon.Tooltip.functions = {}

addon.Tooltip.Buttons = {}
addon.Tooltip.nrOfButtons = 0
addon.Tooltip.variables = {}
addon.Tooltip.variables.numOfTabs = 0

addon.Tooltip.variables.kindsByID = {
    [0] = "item", -- Item
    [1] = "spell", -- Spell
    [2] = "unit", -- Unit
    [3] = "unit", -- Corpse
    [4] = "object", -- Object
    [5] = "currency", -- Currency
    [6] = "unit", -- BattlePet
    [7] = "spell", -- UnitAura
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
    [26] = "" -- Debug
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
