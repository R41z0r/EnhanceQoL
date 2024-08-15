local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "Tooltip"
L[addonName] = "Tooltip"
L["None"] = "None"
L["Enemies"] = "Enemies"
L["Friendly"] = "Friendly"
L["Both"] = "Both"
L["TooltipOFF"] = "OFF"
L["TooltipON"] = "ON"

-- Tabs
L["Unit"] = "Unit"
L["Spell"] = "Spell"
L["Item"] = "Item"
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"

-- Buff
L["TooltipBuffHideType"] = "Hide tooltip on buffs"
L["TooltipBuffHideInCombat"] = "Only hide it in combat"
L["TooltipBuffHideInDungeon"] = "Only hide it in dungeons"

-- Debuff
L["TooltipDebuffHideType"] = "Hide tooltip on debuffs"
L["TooltipDebuffHideInCombat"] = "Only hide it in combat"
L["TooltipDebuffHideInDungeon"] = "Only hide it in dungeons"

-- Unit
L["TooltipUnitHideType"] = "Hide tooltip on Unit"
L["TooltipUnitHideInCombat"] = "Only hide it in combat"
L["TooltipUnitHideInDungeon"] = "Only hide it in dungeons"
L["Mythic+ Score"] = "Mythic+ Score"
L["BestMythic+run"] = "Best run"
L["TooltipShowMythicScore"] = "Show Mythic+ Score on Tooltip"

-- Spell
L["TooltipSpellHideType"] = "Hide tooltip on Spells"

L["TooltipSpellHideInCombat"] = "Only hide it in combat"
L["TooltipSpellHideInDungeon"] = "Only hide it in dungeons"

L["TooltipShowSpellID"] = "Show SpellID on Tooltip"
L["SpellID"] = "SpellID"
L["MacroID"] = "MacroID"

-- Item
L["TooltipItemHideType"] = "Hide tooltip on Items"

L["TooltipItemHideInCombat"] = "Only hide it in combat"
L["TooltipItemHideInDungeon"] = "Only hide it in dungeons"

L["ItemID"] = "ItemID"
L["TooltipShowItemID"] = "Show ItemID on Tooltip"
