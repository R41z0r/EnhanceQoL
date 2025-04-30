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
L["NoKeystone"] = "無資訊"
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
L["mythicPlusTruePercent"] = "显示敌军力量的小数值"
L["mythicPlusChestTimer"] = "显示箱子计时器"
L["interruptWithShift"] = "按住 Shift 鍵可中斷此功能"

L["None"] = "沒有開怪計時器"
L["Blizzard Pull Timer"] = "暴雪開怪計時器"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 開怪計時器"
L["Both"] = "暴雪和 DBM / BigWigs"
L["Pull Timer Type"] = "開怪計時器類型"

L["groupfinderShowDungeonScoreFrame"] = "在地下城搜尋旁顯示 " .. DUNGEON_SCORE .. " 框架"
-- Keystone
L["groupfinderShowPartyKeystone"] = "顯示隊伍成員的傳奇鑰石資訊"
L["groupfinderShowPartyKeystoneDesc"] = "允許你點擊鑰石資訊圖示以傳送至該地城"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "拖動我"
L["Potion Tracker"] = "藥水追蹤器"
L["Toggle Anchor"] = "切換錨點"
L["Save Anchor"] = "保存錨點"
L["potionTrackerHeadline"] = "這使您能夠將小隊成員的戰鬥藥水冷卻時間 以可移動的條形顯示出來"
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

-- AutoMark Frame
L["AutoMark"] = "自動標記"
L["autoMarkTankInDungeon"] = "在地下城自動標記" .. TANK
L["autoMarkTankInDungeonMarker"] = "坦克標記"
L["Disabled"] = "已停用"
L["autoMarkTankExplanation"] = "如果坦克沒有標記，它將自動 標記，並且只有當您是 " .. COMMUNITY_MEMBER_ROLE_NAME_LEADER .. " 或 " .. TANK .. " 時才會更改標記"
L["mythicPlusIgnoreMythic"] = "不要在" .. PLAYER_DIFFICULTY6 .. "地城中應用團隊標記"
L["mythicPlusIgnoreHeroic"] = "不要在" .. PLAYER_DIFFICULTY2 .. "地城中應用團隊標記"
L["mythicPlusIgnoreEvent"] = "不要在" .. BATTLE_PET_SOURCE_7 .. "地下城中应用团队标记"
L["mythicPlusIgnoreNormal"] = "不要在" .. PLAYER_DIFFICULTY1 .. "地城中應用團隊標記"
L["mythicPlusIgnoreTimewalking"] = "不要在" .. PLAYER_DIFFICULTY_TIMEWALKER .. "地下城中应用团队标记"

-- Teleports
L["Teleports"] = "傳送"
L["teleportEnabled"] = "啟用傳送框架"
L["DungeonCompendium"] = "地城傳送指南"
L["teleportsEnableCompendium"] = "啟用地城傳送指南"
L["teleportCompendiumHeadline"] = "隱藏特定資料片的傳送"

L["teleportsHeadline"] = "在PvE視窗中添加一個包含地城傳送的框架"
L["portalHideMissing"] = "隱藏缺失的傳送"
L["portalShowTooltip"] = "在傳送按鈕上顯示提示"
L["hideActualSeason"] = "隐藏当前赛季的传送点于 " .. L["DungeonCompendium"]
L["teleportCompendiumAdditionHeadline"] = "更多傳送門選項"
L["portalShowDungeonTeleports"] = "顯示地城傳送"
L["portalShowRaidTeleports"] = "顯示團隊副本傳送"
L["portalShowToyHearthstones"] = "顯示傳送物品及玩具（例如爐石）"
L["portalShowEngineering"] = "顯示工程學傳送（需要工程學）"
L["portalShowClassTeleport"] = "顯示職業專屬傳送（僅當該職業擁有）"
L["portalShowMagePortal"] = "顯示法師傳送門（僅限法師）"

-- BR Tracker
L["BRTracker"] = "戰鬥復活"
L["brTrackerHeadline"] = "在傳奇鑰石地城中添加戰鬥復活監視"
L["mythicPlusBRTrackerEnabled"] = "啟用戰鬥復活監視"
L["mythicPlusBRTrackerLocked"] = "鎖定監視器位置"
L["mythicPlusBRButtonSizeHeadline"] = "按鈕大小"

-- Talent Reminder
L["TalentReminder"] = "天賦提醒"
L["talentReminderEnabled"] = "啟用天賦提醒"
L["talentReminderEnabledDesc"] = "僅於 " .. _G["PLAYER_DIFFICULTY6"] .. " 難度進行檢查，以便為 " .. _G["PLAYER_DIFFICULTY_MYTHIC_PLUS"] .. " 做準備"
L["talentReminderLoadOnReadyCheck"] = "僅在" .. _G["READY_CHECK"] .. "時檢查天賦"
L["talentReminderSoundOnDifference"] = "若天賦與保存的配置不同則播放提示音"
L["WrongTalents"] = "錯誤的天賦"
L["ActualTalents"] = "當前天賦"
L["RequiredTalents"] = "所需天賦"
L["DeletedLoadout"] = "已刪除的天賦配置"
L["MissingTalentLoadout"] = "天賦提醒中使用的部分天賦配置已被刪除，無法再使用："

L["groupFilter"] = "隊伍篩選"
L["mythicPlusEnableDungeonFilter"] = "為暴雪預設的地城隊伍篩選新增條件"
L["mythicPlusEnableDungeonFilterClearReset"] = "重置暴雪篩選時清除擴充篩選"
L["filteredTextEntries"] = "已篩選\n%d條"
L["Partyfit"] = "隊伍符合"
L["BloodlustAvailable"] = "嗜血可用"
L["BattleResAvailable"] = "戰復可用"
L["NoSameSpec"] = "隊伍中沒有%s"

L["mythicPlusEnableObjectiveTracker"] = "自動管理目標追蹤"
L["mythicPlusEnableObjectiveTrackerDesc"] = "當進入 M+ 地城時，自動隱藏或收合所有目標追蹤區塊。"
L["mythicPlusObjectiveTrackerSetting"] = "行為"
L["collapse"] = "收合"

L["mythicPlusNoHealerMark"] = "當我扮演治療角色時移除自己的標記"
