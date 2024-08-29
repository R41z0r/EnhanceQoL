if (GAME_LOCALE or GetLocale()) ~= "zhTW" then
    return
end

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

L["deleteItemFillDialog"] = "將 \"" .. COMMUNITIES_DELETE_CONFIRM_STRING .. "\" 添加到\"刪除確認彈出窗口\""
L["autoChooseQuest"] = "自動接受並完成任務"

L["General"] = "通用"
L["Character"] = "角色"
L["Dungeon"] = "地下城"
L["Misc"] = "雜項"
L["Quest"] = "任務"

-- Dungeon
L["autoChooseDelvePower"] = "僅有一個選項時自動選擇探險力量"

-- Quest
L["ignoreTrivialQuests"] = "忽略瑣碎任務"
