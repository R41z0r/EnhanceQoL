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
L["NoKeystone"] = "无信息"
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
L["mythicPlusTruePercent"] = "显示敌军力量的小数值"
L["mythicPlusChestTimer"] = "显示箱子计时器"
L["interruptWithShift"] = "按住 Shift 键可中断此功能"

L["None"] = "没有开怪计时器"
L["Blizzard Pull Timer"] = "暴雪开怪计时器"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 开怪计时器"
L["Both"] = "暴雪和 DBM / BigWigs"
L["Pull Timer Type"] = "开怪计时器类型"

L["groupfinderShowDungeonScoreFrame"] = "在地下城搜索旁显示 " .. DUNGEON_SCORE .. " 框架"
-- Keystone
L["groupfinderShowPartyKeystone"] = "显示队伍成员的史诗钥石信息"
L["groupfinderShowPartyKeystoneDesc"] = "允许你点击钥石信息图标来传送到该地下城"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "拖动我"
L["Potion Tracker"] = "药水跟踪器"
L["Toggle Anchor"] = "切换锚点"
L["Save Anchor"] = "保存锚点"
L["potionTrackerHeadline"] = "这使您能够将小队成员的战斗药水冷却时间 以可移动的条形显示出来"
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

-- AutoMark Frame
L["AutoMark"] = "自动标记"
L["autoMarkTankInDungeon"] = "在地下城自動標記" .. TANK
L["autoMarkTankInDungeonMarker"] = "坦克標記"
L["Disabled"] = "已停用"
L["autoMarkTankExplanation"] = "如果坦克没有标记，它将自动 标记，只有当你是 " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " 或 " .. TANK .. " 时才会更改标记"
L["mythicPlusIgnoreMythic"] = "不要在" .. PLAYER_DIFFICULTY6 .. "地下城中应用团队标记"
L["mythicPlusIgnoreHeroic"] = "不要在" .. PLAYER_DIFFICULTY2 .. "地下城中应用团队标记"
L["mythicPlusIgnoreEvent"] = "不要在" .. BATTLE_PET_SOURCE_7 .. "地下城中应用团队标记"
L["mythicPlusIgnoreNormal"] = "不要在" .. PLAYER_DIFFICULTY1 .. "地下城中应用团队标记"
L["mythicPlusIgnoreTimewalking"] = "不要在" .. PLAYER_DIFFICULTY_TIMEWALKER .. "地下城中应用团队标记"

-- Teleports
L["Teleports"] = "传送"
L["teleportEnabled"] = "启用传送框架"
L["DungeonCompendium"] = "地下城传送手册"
L["teleportsEnableCompendium"] = "启用地下城传送手册"
L["teleportCompendiumHeadline"] = "隐藏特定资料片的传送"

L["teleportsHeadline"] = "在PvE窗口中添加一个包含地下城传送的框架"
L["portalHideMissing"] = "隐藏缺失的传送"
L["portalShowTooltip"] = "在传送按钮上显示提示"
L["hideActualSeason"] = "隐藏当前赛季的传送点于 " .. L["DungeonCompendium"]
L["teleportCompendiumAdditionHeadline"] = "更多传送门选项"
L["portalShowDungeonTeleports"] = "显示地下城传送"
L["portalShowRaidTeleports"] = "显示团队副本传送"
L["portalShowToyHearthstones"] = "显示传送物品及玩具（例如炉石）"
L["portalShowEngineering"] = "显示工程学传送（需要工程学）"
L["portalShowClassTeleport"] = "显示职业专属传送（仅当该职业拥有）"
L["portalShowMagePortal"] = "显示法师传送门（仅限法师）"

-- BR Tracker
L["BRTracker"] = "战斗复活"
L["brTrackerHeadline"] = "在史诗钥石地下城中添加战斗复活监视"
L["mythicPlusBRTrackerEnabled"] = "启用战斗复活监视"
L["mythicPlusBRTrackerLocked"] = "锁定监视器位置"
L["mythicPlusBRButtonSizeHeadline"] = "按钮大小"

-- Talent Reminder
L["TalentReminder"] = "天赋提醒"
L["talentReminderEnabled"] = "启用天赋提醒"
L["talentReminderEnabledDesc"] = "仅在 " .. _G["PLAYER_DIFFICULTY6"] .. " 难度检查，以便为 " .. _G["PLAYER_DIFFICULTY_MYTHIC_PLUS"] .. " 做准备"
L["talentReminderLoadOnReadyCheck"] = "仅在" .. _G["READY_CHECK"] .. "时检查天赋"
L["talentReminderSoundOnDifference"] = "若天赋与保存的配置不同则播放提示音"
L["WrongTalents"] = "错误的天赋"
L["ActualTalents"] = "当前天赋"
L["RequiredTalents"] = "所需天赋"
L["DeletedLoadout"] = "已删除的天赋配置"
L["MissingTalentLoadout"] = "天赋提醒中使用的一些天赋配置已被删除，无法再使用："

L["groupFilter"] = "队伍筛选"
L["mythicPlusEnableDungeonFilter"] = "为暴雪默认地下城队伍筛选添加新条件"
L["mythicPlusEnableDungeonFilterClearReset"] = "重置暴雪筛选时清除扩展筛选"
L["filteredTextEntries"] = "已筛选\n%d条"
L["Partyfit"] = "队伍符合"
L["BloodlustAvailable"] = "嗜血可用"
L["BattleResAvailable"] = "战复可用"
L["NoSameSpec"] = "队伍中没有%s"

L["mythicPlusEnableObjectiveTracker"] = "自动管理目标追踪"
L["mythicPlusEnableObjectiveTrackerDesc"] = "当开启大秘境时，自动隐藏或折叠所有目标追踪栏。"
L["mythicPlusObjectiveTrackerSetting"] = "行为"
L["collapse"] = "折叠"

L["mythicPlusNoHealerMark"] = "当我担任治疗时移除自己的标记"
