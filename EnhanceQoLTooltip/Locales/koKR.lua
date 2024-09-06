if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "툴팁"
L[addonName] = "툴팁"
L["None"] = "없음"
L["Enemies"] = "적"
L["Friendly"] = "우호적"
L["Both"] = "모두"
L["TooltipOFF"] = "꺼짐"
L["TooltipON"] = "켜짐"

-- Tabs
L["Unit"] = "유닛"
L["Spell"] = "주문"
L["Item"] = "아이템"
L["Buff"] = "버프"
L["Debuff"] = "디버프"

-- Buff
L["TooltipBuffHideType"] = "버프 툴팁 숨기기"
L["TooltipBuffHideInCombat"] = "전투 중에만 숨기기"
L["TooltipBuffHideInDungeon"] = "던전에서만 숨기기"

-- Debuff
L["TooltipDebuffHideType"] = "디버프 툴팁 숨기기"
L["TooltipDebuffHideInCombat"] = "전투 중에만 숨기기"
L["TooltipDebuffHideInDungeon"] = "던전에서만 숨기기"

-- Unit
L["TooltipUnitHideType"] = "유닛 툴팁 숨기기"
L["TooltipUnitHideInCombat"] = "전투 중에만 숨기기"
L["TooltipUnitHideInDungeon"] = "던전에서만 숨기기"
L["Mythic+ Score"] = "쐐기돌 점수"
L["BestMythic+run"] = "최고 기록"
L["TooltipShowMythicScore"] = "툴팁에 쐐기돌 점수 표시"
L["TooltipShowClassColor"] = "툴팁에 직업 색상 표시"
L["TooltipShowNPCID"] = "NPC ID 표시"
L["NPCID"] = "ID"

-- Spell
L["TooltipSpellHideType"] = "주문 툴팁 숨기기"
L["TooltipSpellHideInCombat"] = "전투 중에만 숨기기"
L["TooltipSpellHideInDungeon"] = "던전에서만 숨기기"

L["TooltipShowSpellID"] = "툴팁에 주문 ID 표시"
L["SpellID"] = "주문 ID"
L["MacroID"] = "매크로 ID"

-- Item
L["TooltipItemHideType"] = "아이템 툴팁 숨기기"
L["TooltipItemHideInCombat"] = "전투 중에만 숨기기"
L["TooltipItemHideInDungeon"] = "던전에서만 숨기기"

L["ItemID"] = "아이템 ID"
L["TooltipShowItemID"] = "툴팁에 아이템 ID 표시"

L["TooltipShowItemCount"] = "툴팁에 아이템 개수 표시"
L["TooltipShowSeperateItemCount"] = "위치별로 분리된 아이템 개수 표시"
L["Reagentbank"] = "재료 은행"
L["Bank"] = "은행"
L["Bag"] = "가방"
L["Itemcount"] = "아이템 개수"
