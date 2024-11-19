if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "快速報名"
L["Persist LFG signup note"] = "保留LFG報名備註"
L["Select an option"] = "選擇一個選項"
L["Save"] = "保存"
L["Hide Minimap Button"] = "隱藏小地圖按鈕"
L["Left-Click to show options"] = "左鍵點擊顯示選項"

L["Hide Raid Tools"] = "在小隊中隱藏團隊工具"
L["repairCost"] = "修理物品花費 "
L["autoRepair"] = "自動修理所有物品"
L["sellAllJunk"] = "自動出售所有垃圾物品"
L["ignoreTalkingHead"] = "自動隱藏Talking Head框體"

L["showIlvlOnCharframe"] = "在角色裝備框架上顯示物品等級"
L["showGemsOnCharframe"] = "在角色裝備框架上顯示寶石插槽"
L["showEnchantOnCharframe"] = "在角色裝備框架上顯示附魔"
L["showCatalystChargesOnCharframe"] = "在角色裝備介面顯示催化劑次數"
L["showIlvlOnBagItems"] = "在所有背包的裝備上顯示物品等級"
L["showDurabilityOnCharframe"] = "在角色裝備框架上顯示耐久度"

L["deleteItemFillDialog"] = "將 \"" .. DELETE_ITEM_CONFIRM_STRING .. "\" 添加到\"刪除確認彈出窗口\""
L["autoChooseQuest"] = "自動接受並完成任務"

L["General"] = "通用"
L["Character"] = "角色"
L["Dungeon"] = "地下城"
L["Misc"] = "雜項"
L["Quest"] = "任務"

L["hideBagsBar"] = "隐藏背包栏"

-- Dungeon
L["autoChooseDelvePower"] = "僅有一個選項時自動選擇探險力量"
L["lfgSortByRio"] = "按史诗分数排序史诗地下城申请者"

-- Quest
L["ignoreTrivialQuests"] = "忽略瑣碎任務"
L["ignoreDailyQuests"] = "忽略每日/每週任務"

L["autoQuickLoot"] = "快速拾取物品"
L["openCharframeOnUpgrade"] = "在商人處升級物品時打開角色窗口"

L["headerClassInfo"] = "这些设置仅适用于 " .. select(1, UnitClass("player"))

-- 死亡骑士
L["deathknight_HideRuneFrame"] = "隐藏符文框架"

-- 唤魔师
L["evoker_HideEssence"] = "隐藏精华条"

-- 武僧
L["monk_HideHarmonyBar"] = "隐藏真气条"

-- 圣骑士
L["paladin_HideHolyPower"] = "隐藏圣能条"

-- 潜行者
L["rogue_HideComboPoint"] = "隐藏连击点数条"

-- 萨满
L["shaman_HideTotem"] = "隐藏图腾条"

-- 术士
L["warlock_HideSoulShardBar"] = "隐藏灵魂碎片条"
