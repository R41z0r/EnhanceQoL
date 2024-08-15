if (GAME_LOCALE or GetLocale()) ~= "zhCN" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "提示"
L[addonName] = "提示"
L["None"] = "无"
L["Enemies"] = "敌人"
L["Friendly"] = "友方"
L["Both"] = "双方"
L["TooltipOFF"] = "关闭"
L["TooltipON"] = "开启"

-- Tabs
L["Unit"] = "单位"
L["Spell"] = "法术"
L["Item"] = "物品"
L["Buff"] = "增益"
L["Debuff"] = "减益"

-- Buff
L["TooltipBuffHideType"] = "隐藏增益提示"
L["TooltipBuffHideInCombat"] = "仅在战斗中隐藏"
L["TooltipBuffHideInDungeon"] = "仅在副本中隐藏"

-- Debuff
L["TooltipDebuffHideType"] = "隐藏减益提示"
L["TooltipDebuffHideInCombat"] = "仅在战斗中隐藏"
L["TooltipDebuffHideInDungeon"] = "仅在副本中隐藏"

-- Unit
L["TooltipUnitHideType"] = "隐藏单位提示"
L["TooltipUnitHideInCombat"] = "仅在战斗中隐藏"
L["TooltipUnitHideInDungeon"] = "仅在副本中隐藏"

-- Spell
L["TooltipSpellHideType"] = "隐藏法术提示"

L["TooltipSpellHideInCombat"] = "仅在战斗中隐藏"
L["TooltipSpellHideInDungeon"] = "仅在副本中隐藏"

L["TooltipShowSpellID"] = "在工具提示中显示法术ID"
L["SpellID"] = "法术ID"
L["MacroID"] = "宏ID"

-- Item
L["TooltipItemHideType"] = "隐藏物品提示"

L["TooltipItemHideInCombat"] = "仅在战斗中隐藏"
L["TooltipItemHideInDungeon"] = "仅在副本中隐藏"

L["ItemID"] = "物品ID"
L["TooltipShowItemID"] = "在工具提示中显示物品ID"