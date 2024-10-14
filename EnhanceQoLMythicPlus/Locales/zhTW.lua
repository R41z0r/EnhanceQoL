if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "鑰石"
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

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "拖動我"
L["Potion Tracker"] = "藥水追蹤器"
L["Toggle Anchor"] = "切換錨點"
L["Save Anchor"] = "保存錨點"
L["potionTrackerHeadline"] =
    "這使您能夠將小隊成員的戰鬥藥水冷卻時間\n以可移動的條形顯示出來"
L["potionTracker"] = "啟用藥水冷卻時間追蹤器"
L["potionTrackerUpwardsBar"] = "向上增長"
L["potionTrackerClassColor"] = "使用職業顏色顯示條形"
L["potionTrackerDisableRaid"] = "在團隊中禁用藥水追蹤器"

L["Tinker"] = "工匠"
L["InvisPotion"] = "隱形"
L["potionTrackerShowTooltip"] = "在圖標上顯示提示"
L["HealingPotion"] = "治療"
L["potionTrackerHealingPotions"] = "追踪治疗药水CD"
L["potionTrackerOffhealing"] = "追踪次要治疗CD的使用"
-- LFG 工具

L["DungeonBrowser"] = "地下城浏览器"
L["groupfinderAppText"] = "隐藏团队查找器文本 \"你的团队目前正在形成\""
L["groupfinderSkipRolecheck"] = "跳过角色检查并使用当前角色"

-- Misc Frame
L["Misc"] = "雜項"
L["autoMarkTankInDungeon"] = "在地下城自動標記" .. TANK
L["autoMarkTankInDungeonMarker"] = "坦克標記"
L["Disabled"] = "已停用"
L["autoMarkTankExplanation"] = "如果坦克沒有標記，它將自動\n標記，並且只有當您是\n" ..
                                   COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " 或 " .. TANK .. " 時才會更改標記"
