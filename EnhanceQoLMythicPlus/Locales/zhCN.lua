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
local L = addon.LMythicPlus

L["Automatically insert keystone"] = "自动插入钥石"
L["Mythic Plus"] = "大秘境+"
L[addonName] = "大秘境+"
L["Close all bags on keystone insert"] = "插入钥石时关闭所有背包"
L["ReadyCheck"] = "准备确认"
L["ReadyCheckWaiting"] = "检查准备状态..."
L["PullTimer"] = "开怪计时器"
L["Pull"] = "开怪"
L["Cancel"] = "取消"
L["Cancel Pull Timer on click"] = "点击时取消开怪计时器"
L["noChatOnPullTimer"] = "开怪计时器时不发送聊天信息"
L["sliderShortTime"] = "右键开怪计时器"
L["sliderLongTime"] = "开怪计时器"
L["Stating"] = "开始中..."
L["autoKeyStart"] = "开怪计时器后自动开始钥石"

L["None"] = "没有开怪计时器"
L["Blizzard Pull Timer"] = "暴雪开怪计时器"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 开怪计时器"
L["Both"] = "暴雪和 DBM / BigWigs"
L["Pull Timer Type"] = "开怪计时器类型"