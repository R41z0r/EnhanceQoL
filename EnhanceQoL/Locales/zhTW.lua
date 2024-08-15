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