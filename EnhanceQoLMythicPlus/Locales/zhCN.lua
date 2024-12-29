if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "钥石"
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

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "拖动我"
L["Potion Tracker"] = "药水跟踪器"
L["Toggle Anchor"] = "切换锚点"
L["Save Anchor"] = "保存锚点"
L["potionTrackerHeadline"] = "这使您能够将小队成员的战斗药水冷却时间\n以可移动的条形显示出来"
L["potionTracker"] = "启用药水冷却时间跟踪器"
L["potionTrackerUpwardsBar"] = "向上增长"
L["potionTrackerClassColor"] = "使用职业颜色显示条形"
L["potionTrackerDisableRaid"] = "在团队中禁用药水跟踪器"

L["Tinker"] = "工匠"
L["InvisPotion"] = "隐形"
L["potionTrackerShowTooltip"] = "在图标上显示提示"
L["HealingPotion"] = "治疗"
L["potionTrackerHealingPotions"] = "追踪治疗药水CD"
L["potionTrackerOffhealing"] = "追踪次要治疗CD的使用"
-- LFG 工具

L["DungeonBrowser"] = "地城瀏覽器"
L["groupfinderAppText"] = '隱藏組隊搜尋器的文字 "您的隊伍目前正在組成中"'
L["groupfinderSkipRolecheck"] = "跳過角色檢查並使用當前角色"

-- Misc Frame
L["Misc"] = "雜項"
L["autoMarkTankInDungeon"] = "在地下城自動標記" .. TANK
L["autoMarkTankInDungeonMarker"] = "坦克標記"
L["Disabled"] = "已停用"
L["autoMarkTankExplanation"] = "如果坦克没有标记，它将自动 标记，只有当你是 " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " 或 " .. TANK .. " 时才会更改标记"

-- Teleports
L["Teleports"] = "传送"
L["teleportEnabled"] = "启用传送框架"
L["DungeonCompendium"] = "地下城传送手册"
L["teleportsEnableCompendium"] = "启用地下城传送手册"

L["teleportsHeadline"] = "在PvE窗口中添加一个包含地下城传送的框架"
L["portalHideMissing"] = "隐藏缺失的传送"
L["portalShowTooltip"] = "在传送按钮上显示提示"
L["hideActualSeason"] = "隐藏当前赛季的传送点于 " .. L["DungeonCompendium"]
