if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "提示"
L["None"] = "無"
L["Enemies"] = "敵人"
L["Friendly"] = "友方"
L["Both"] = "雙方"
L["TooltipOFF"] = "關閉"
L["TooltipON"] = "開啟"
L["TooltipAnchorType"] = "提示位置"
L["CursorCenter"] = "游標置中"
L["CursorLeft"] = "游標左側"
L["CursorRight"] = "游標右側"
L["TooltipAnchorOffsetX"] = "水平偏移"
L["TooltipAnchorOffsetY"] = "垂直偏移"

-- Tabs
L["Unit"] = "單位"
L["Spell"] = "法術"
L["Item"] = "物品"
L["Buff"] = "增益"
L["Debuff"] = "減益"
L["Buff_Debuff"] = "增益/減益"

-- Buff
L["TooltipBuffHideType"] = "隱藏 增益/減益 提示"
L["TooltipBuffHideInCombat"] = "僅在戰鬥中隱藏"
L["TooltipBuffHideInDungeon"] = "僅在副本中隱藏"

-- Debuff
L["TooltipDebuffHideType"] = "隱藏減益提示"
L["TooltipDebuffHideInCombat"] = "僅在戰鬥中隱藏"
L["TooltipDebuffHideInDungeon"] = "僅在副本中隱藏"

-- Unit
L["TooltipUnitHideType"] = "隱藏單位提示"
L["TooltipUnitHideInCombat"] = "僅在戰鬥中隱藏"
L["TooltipUnitHideInDungeon"] = "僅在副本中隱藏"
L["BestMythic+run"] = "最佳成績"
L["TooltipShowMythicScore"] = "在提示框中顯示 %s"
L["TooltipShowClassColor"] = "在提示中顯示職業顏色"
L["TooltipShowNPCID"] = "顯示NPC ID"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "隱藏法術提示"

L["TooltipSpellHideInCombat"] = "僅在戰鬥中隱藏"
L["TooltipSpellHideInDungeon"] = "僅在副本中隱藏"

L["TooltipShowSpellID"] = "在工具提示中顯示法術ID"
L["SpellID"] = "法術ID"
L["MacroID"] = "宏ID"

-- Item
L["TooltipItemHideType"] = "隱藏物品提示"
L["TooltipItemHideInCombat"] = "僅在戰鬥中隱藏"
L["TooltipItemHideInDungeon"] = "僅在副本中隱藏"

L["ItemID"] = "物品ID"
L["TooltipShowItemID"] = "在工具提示中顯示物品ID"

L["TooltipShowItemCount"] = "在提示框中显示物品数量"
L["TooltipShowSeperateItemCount"] = "按位置分开显示物品数量"
L["Reagentbank"] = "材料银行"
L["Bank"] = "银行"
L["Bag"] = "背包"
L["Itemcount"] = "物品数量"

L["TooltipShowQuestID"] = "顯示任務ID"

L["TooltipShowCurrencyAccountWide"] = "在滑鼠提示中顯示帳號通用貨幣"
