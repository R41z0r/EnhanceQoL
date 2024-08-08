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

if nil == addon.db["TooltipSpellHideType"] then
    addon.db["TooltipSpellHideType"] = 1
end
if nil == addon.db["TooltipSpellHideInCombat"] then
    addon.db["TooltipSpellHideInCombat"] = false
end
if nil == addon.db["TooltipSpellHideInDungeon"] then
    addon.db["TooltipSpellHideInDungeon"] = false
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


addon.Tooltip = {}
addon.LTooltip = {} -- Locales for MythicPlus
addon.Tooltip.functions = {}

addon.Tooltip.Buttons = {}
addon.Tooltip.nrOfButtons = 0
addon.Tooltip.variables = {}