if (GAME_LOCALE or GetLocale()) ~= "koKR" then
    return
end

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
L["TooltipUnitHideType"] = "유닛에서 숨기기"
L["None"] = "없음"
L["Enemies"] = "적"
L["Friendly"] = "우호적"
L["Both"] = "둘 다"
L["TooltipOFF"] = "끔"
L["TooltipON"] = "켬"

L["TooltipUnitHideInCombat"] = "전투 중 유닛만 숨기기"
L["TooltipUnitHideInDungeon"] = "던전에서만 유닛 숨기기"

--Spell
L["TooltipSpellHideType"] = "주문에서 숨기기"

L["TooltipSpellHideInCombat"] = "전투 중 주문만 숨기기"
L["TooltipSpellHideInDungeon"] = "던전에서만 주문 숨기기"

--Item
L["TooltipItemHideType"] = "아이템에서 숨기기"

L["TooltipItemHideInCombat"] = "전투 중 아이템만 숨기기"
L["TooltipItemHideInDungeon"] = "던전에서만 아이템 숨기기"