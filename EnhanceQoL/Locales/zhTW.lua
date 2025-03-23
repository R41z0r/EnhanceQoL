if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "快速報名"
L["interruptWithShift"] = "按住 Shift 鍵可中斷此功能"

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
L["landingPageHide"] = "啟用此選項以隱藏小地圖上的擴展按鈕。"
L["automaticallyOpenContainer"] = "自動打開背包中的容器物品"

L["showIlvlOnBankFrame"] = "在銀行介面顯示物品等級"
L["showIlvlOnMerchantframe"] = "在商人視窗顯示物品等級"
L["showIlvlOnCharframe"] = "在角色裝備框架上顯示物品等級"
L["showGemsOnCharframe"] = "在角色裝備框架上顯示寶石插槽"
L["showBindOnBagItems"] = "在物品上顯示"
	.. _G.ITEM_BIND_ON_EQUIP
	.. " (BoE)、"
	.. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
	.. " (WuE)以及"
	.. _G.ITEM_BNETACCOUNTBOUND
	.. " (WB)，作為物品等級的附加資訊"
L["showGemsTooltipOnCharframe"] = "在角色裝備框架上顯示寶石插槽提示"
L["showEnchantOnCharframe"] = "在角色裝備框架上顯示附魔"
L["showCatalystChargesOnCharframe"] = "在角色裝備介面顯示催化劑次數"
L["showIlvlOnBagItems"] = "在所有背包的裝備上顯示物品等級"
L["showDurabilityOnCharframe"] = "在角色裝備框架上顯示耐久度"
L["hideOrderHallBar"] = "隐藏职业大厅指挥栏"
L["showInfoOnInspectFrame"] = "在檢查框架中顯示額外資訊"
L["MissingEnchant"] = "附魔"
L["hideHitIndicatorPlayer"] = "隱藏角色頭上的浮動戰鬥文字（傷害和治療）"
L["hideHitIndicatorPet"] = "隱藏寵物頭上的浮動戰鬥文字（傷害和治療）"
L["UnitFrame"] = "單位框架"
L["SellJunkIgnoredBag"] = "您已在 %d 個背包中停用了垃圾物品的銷售。\n這可能會阻止所有垃圾物品的自動銷售。"

L["deleteItemFillDialog"] = '將 "' .. DELETE_ITEM_CONFIRM_STRING .. '" 添加到"刪除確認彈出窗口"'
L["confirmPatronOrderDialog"] = "自动确认使用自己的材料进行 " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC .. " 制作订单"
L["autoChooseQuest"] = "自動接受並完成任務"
L["confirmTimerRemovalTrade"] = "自動確認在交易時間內出售可交易的戰利品"

L["General"] = "通用"
L["Character"] = "角色"
L["Dungeon"] = "地下城"
L["Misc"] = "雜項"
L["Quest"] = "任務"

L["hideBagsBar"] = "隐藏背包栏"
L["hideMicroMenu"] = "隱藏微型選單"
-- Dungeon
L["autoChooseDelvePower"] = "僅有一個選項時自動選擇探險力量"
L["lfgSortByRio"] = "按史诗分数排序史诗地下城申请者"
L["DungeonBrowser"] = "地下城浏览器"
L["groupfinderAppText"] = '隐藏团队查找器文本 "你的团队目前正在形成"'
L["groupfinderMoveResetButton"] = "將地城搜尋器的重置過濾按鈕移至左側。"
L["groupfinderSkipRoleSelect"] = "跳過角色選擇"
L["groupfinderSkipRolecheckHeadline"] = "自動角色分配"
L["groupfinderSkipRolecheckUseSpec"] = "使用當前專精的角色（如血死亡騎士 = 坦克）"
L["groupfinderSkipRolecheckUseLFD"] = "使用地城搜尋器中的角色"

-- Quest
L["ignoreTrivialQuests"] = "不要自動處理等級較低的" .. QUESTS_LABEL
L["ignoreDailyQuests"] = "不要自動處理每日/每週" .. QUESTS_LABEL
L["ignoreWarbandCompleted"] = "不要自動處理" .. ACCOUNT_COMPLETED_QUEST_LABEL .. " " .. QUESTS_LABEL

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

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- 萨满
L["shaman_HideTotem"] = "隐藏图腾条"

-- 术士
L["warlock_HideSoulShardBar"] = "隐藏灵魂碎片条"

L["questAddNPCToExclude"] = "將目標 NPC/打開的對話視窗添加到排除清單"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "需要重新加載界面"
L["bReloadInterface"] = "您需要重新加載界面以應用更改"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "啟用使用技能時自動下馬" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "啟用飛行時使用技能時自動下馬" },
	["chatMouseScroll"] = { description = "啟用聊天視窗的鼠標滾動", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "禁用死亡效果", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "啟用移動時地圖淡出" },
	["scriptErrors"] = { description = "在界面上顯示 LUA 錯誤", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "在姓名板上顯示職業顏色", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "顯示目標的施法條" },
	["showTutorials"] = { description = "禁用教程", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "啟用增強提示", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "顯示玩家的公會名稱" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "顯示玩家的頭銜" },
	["WholeChatWindowClickable"] = { description = "使整個聊天視窗可點擊", trueValue = "1", falseValue = "0" },
}

L["autoAcceptGroupInvite"] = "自動接受組隊邀請"
L["autoAcceptGroupInviteGuildOnly"] = "公會成員"
L["autoAcceptGroupInviteFriendOnly"] = "好友"
L["autoAcceptGroupInviteOptions"] = "接受來自...的邀請"

L["showLeaderIconRaidFrame"] = "在團隊風格的隊伍框架上顯示隊長圖示"
