if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "快速报名"
L["Persist LFG signup note"] = "保留LFG报名备注"
L["Select an option"] = "选择一个选项"
L["Save"] = "保存"
L["Hide Minimap Button"] = "隐藏小地图按钮"
L["Left-Click to show options"] = "左键点击显示选项"

L["Hide Raid Tools"] = "在小队中隐藏团队工具"
L["repairCost"] = "修理物品花费 "
L["autoRepair"] = "自动修理所有物品"
L["sellAllJunk"] = "自动出售所有垃圾物品"
L["ignoreTalkingHead"] = "自动隐藏Talking Head框体"

L["showIlvlOnCharframe"] = "在角色装备框架上显示物品等级"
L["showGemsOnCharframe"] = "在角色装备框架上显示宝石插槽"
L["showEnchantOnCharframe"] = "在角色装备框架上显示附魔"

L["deleteItemFillDialog"] = "将 \"" .. COMMUNITIES_DELETE_CONFIRM_STRING .. "\" 添加到“删除确认弹窗”"
L["autoChooseQuest"] = "自动接受并完成任务"

L["General"] = "通用"
L["Character"] = "角色"
L["Dungeon"] = "地下城"
L["Misc"] = "杂项"
L["Quest"] = "任务"

L["hideBagsBar"] = "隐藏背包栏"

-- Dungeon
L["autoChooseDelvePower"] = "仅有一个选项时自动选择探险力量"
L["lfgSortByRio"] = "按史诗分数排序史诗地下城申请者"

-- Quest
L["ignoreTrivialQuests"] = "忽略琐碎任务"
L["ignoreDailyQuests"] = "忽略每日/每周任务"

L["autoQuickLoot"] = "快速拾取物品"

L["headerClassInfo"] = "这些设置仅适用于 " .. select(1, UnitClass("player"))

-- 唤魔师
L["evoker_HideEssence"] = "隐藏精华条"

-- 圣骑士
L["paladin_HideHolyPower"] = "隐藏圣能条"

-- 潜行者
L["rogue_HideComboPoint"] = "隐藏连击点数条"

-- 萨满
L["shaman_HideTotem"] = "隐藏图腾条"