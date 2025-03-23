if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "快速报名"
L["interruptWithShift"] = "按住 Shift 键可中断此功能"

L["Persist LFG signup note"] = "保留LFG报名备注"
L["Select an option"] = "选择一个选项"
L["Save"] = "保存"
L["Hide Minimap Button"] = "隐藏小地图按钮"
L["Left-Click to show options"] = "左键点击显示选项"

L["Hide Raid Tools"] = "在小队中隐藏团队工具"
L["repairCost"] = "修理物品花费 "
L["autoRepair"] = "自动修理所有物品"
L["sellAllJunk"] = "自动出售所有垃圾物品"
L["ignoreTalkingHead"] = "自动隐藏Talking Head框体"
L["landingPageHide"] = "启用此选项以隐藏小地图上的扩展按钮。"
L["automaticallyOpenContainer"] = "自动打开背包中的容器物品"

L["showIlvlOnBankFrame"] = "在银行界面显示物品等级"
L["showIlvlOnMerchantframe"] = "在商人窗口显示物品等级"
L["showIlvlOnCharframe"] = "在角色装备框架上显示物品等级"
L["showGemsOnCharframe"] = "在角色装备框架上显示宝石插槽"
L["showBindOnBagItems"] = "在物品上显示" .. _G.ITEM_BIND_ON_EQUIP .. " (BoE)、" .. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP .. " (WuE)和" .. _G.ITEM_BNETACCOUNTBOUND .. " (WB)来附加到物品等级"
L["showGemsTooltipOnCharframe"] = "在角色装备框架上显示宝石槽提示"
L["showEnchantOnCharframe"] = "在角色装备框架上显示附魔"
L["showCatalystChargesOnCharframe"] = "在角色装备界面显示催化剂次数"
L["showIlvlOnBagItems"] = "在所有背包的装备上显示物品等级"
L["showDurabilityOnCharframe"] = "在角色装备框架上显示耐久度"
L["hideOrderHallBar"] = "隱藏職業大廳指揮欄"
L["showInfoOnInspectFrame"] = "在检查框架中显示额外信息"
L["MissingEnchant"] = "附魔"
L["hideHitIndicatorPlayer"] = "隐藏角色头上的浮动战斗文字（伤害和治疗）"
L["hideHitIndicatorPet"] = "隐藏宠物头上的浮动战斗文字（伤害和治疗）"
L["UnitFrame"] = "单位框架"
L["SellJunkIgnoredBag"] = "您在 %d 个背包中禁用了垃圾物品的销售。\n这可能会阻止所有垃圾物品的自动销售。"

L["deleteItemFillDialog"] = '将 "' .. DELETE_ITEM_CONFIRM_STRING .. '" 添加到“删除确认弹窗”'
L["confirmPatronOrderDialog"] = "自动确认使用自己的材料进行 " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC .. " 制作订单"
L["autoChooseQuest"] = "自动接受并完成任务"
L["confirmTimerRemovalTrade"] = "自动确认在交易时间内出售可交易的战利品"

L["General"] = "通用"
L["Character"] = "角色"
L["Dungeon"] = "地下城"
L["Misc"] = "杂项"
L["Quest"] = "任务"

L["hideBagsBar"] = "隐藏背包栏"
L["hideMicroMenu"] = "隐藏微型菜单"
-- Dungeon
L["autoChooseDelvePower"] = "仅有一个选项时自动选择探险力量"
L["lfgSortByRio"] = "按史诗分数排序史诗地下城申请者"
L["DungeonBrowser"] = "地城瀏覽器"
L["groupfinderAppText"] = '隱藏組隊搜尋器的文字 "您的隊伍目前正在組成中"'
L["groupfinderMoveResetButton"] = "将地下城查找器的重置过滤按钮移动到左侧。"
L["groupfinderShowDungeonScoreFrame"] = "在地下城搜索旁显示 " .. DUNGEON_SCORE .. " 框架"
L["groupfinderSkipRoleSelect"] = "跳过角色选择"
L["groupfinderSkipRolecheckHeadline"] = "自动分配角色"
L["groupfinderSkipRolecheckUseSpec"] = "使用当前专精的角色（如血死亡骑士 = 坦克）"
L["groupfinderSkipRolecheckUseLFD"] = "使用地下城查找器中的角色"
L["groupfinderShowPartyKeystone"] = "显示队伍成员的史诗钥石信息"

-- Quest
L["ignoreTrivialQuests"] = "不要自动处理低级的" .. QUESTS_LABEL
L["ignoreDailyQuests"] = "不要自动处理日常/周常" .. QUESTS_LABEL
L["ignoreWarbandCompleted"] = "不要自动处理" .. ACCOUNT_COMPLETED_QUEST_LABEL .. " " .. QUESTS_LABEL

L["autoQuickLoot"] = "快速拾取物品"
L["openCharframeOnUpgrade"] = "在商人处升级物品时打开角色窗口"

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

L["questAddNPCToExclude"] = "将目标 NPC/打开的对话窗口添加到排除列表"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "需要重新加载界面"
L["bReloadInterface"] = "您需要重新加载界面以应用更改"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "启用使用技能时自动下马" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "启用飞行时使用技能时自动下马" },
	["chatMouseScroll"] = { description = "启用聊天鼠标滚动", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "禁用死亡效果", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "启用移动时地图淡出" },
	["scriptErrors"] = { description = "在界面上显示 LUA 错误", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "在姓名板上显示职业颜色", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "显示目标的施法条" },
	["showTutorials"] = { description = "禁用教程", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "启用增强提示", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "显示玩家的公会名称" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "显示玩家的头衔" },
	["WholeChatWindowClickable"] = { description = "使整个聊天窗口可点击", trueValue = "1", falseValue = "0" },
}

L["autoAcceptGroupInvite"] = "自动接受组队邀请"
L["autoAcceptGroupInviteGuildOnly"] = "公会成员"
L["autoAcceptGroupInviteFriendOnly"] = "好友"
L["autoAcceptGroupInviteOptions"] = "接受来自...的邀请"
