if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

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
L["TooltipAnchorType"] = "提示位置"
L["CursorCenter"] = "光标居中"
L["CursorLeft"] = "光标左侧"
L["CursorRight"] = "光标右侧"
L["TooltipAnchorOffsetX"] = "水平偏移"
L["TooltipAnchorOffsetY"] = "垂直偏移"

-- Tabs
L["Unit"] = "单位"
L["Spell"] = "法术"
L["Item"] = "物品"
L["Buff"] = "增益"
L["Debuff"] = "减益"
L["Buff_Debuff"] = L["Buff"] .. "/" .. L["Debuff"]

-- Buff
L["TooltipBuffHideType"] = "隐藏" .. L["Buff_Debuff"] .. "提示"
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
L["BestMythic+run"] = "最佳成绩"
L["TooltipShowMythicScore"] = "在提示框中显示" .. DUNGEON_SCORE
L["TooltipShowClassColor"] = "在提示中显示职业颜色"
L["TooltipShowNPCID"] = "显示NPC ID"
L["NPCID"] = "ID"

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

L["TooltipShowItemCount"] = "在提示框中显示物品数量"
L["TooltipShowSeperateItemCount"] = "按位置分开显示物品数量"
L["Reagentbank"] = "材料银行"
L["Bank"] = "银行"
L["Bag"] = "背包"
L["Itemcount"] = "物品数量"

L["TooltipShowCurrencyAccountWide"] = "在鼠标提示中显示账号通用货币"
