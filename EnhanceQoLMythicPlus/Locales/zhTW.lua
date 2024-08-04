if (GAME_LOCALE or GetLocale()) ~= "zhTW" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Automatically insert keystone"] = "自動插入鑰石"
L["Mythic Plus"] = "大秘境+"
L[addonName] = "大秘境+"
L["Close all bags on keystone insert"] = "插入鑰石時關閉所有背包"
L["ReadyCheck"] = "準備確認"
L["ReadyCheckWaiting"] = "檢查準備狀態..."
L["PullTimer"] = "開怪計時器"
L["Pull"] = "開怪"
L["Cancel"] = "取消"
L["Cancel Pull Timer on click"] = "點擊時取消開怪計時器"
L["noChatOnPullTimer"] = "開怪計時器時不發送聊天訊息"
L["sliderShortTime"] = "右鍵開怪計時器"
L["sliderLongTime"] = "開怪計時器"
L["Stating"] = "開始中..."
L["autoKeyStart"] = "開怪計時器後自動開始鑰石"

L["None"] = "沒有開怪計時器"
L["Blizzard Pull Timer"] = "暴雪開怪計時器"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 開怪計時器"
L["Both"] = "暴雪和 DBM / BigWigs"
L["Pull Timer Type"] = "開怪計時器類型"