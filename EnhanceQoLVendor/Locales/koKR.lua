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
local L = addon.LVendor

-- Koreanisch
L["Vendor"] = "상인"
L["MerchantWindowClosed"] = "상인 창이 닫혔습니다. 판매 중지"

-- 일반
L["vendorMinIlvlDif"] = "내 평균보다 낮은 최소 아이템 레벨을 자동 판매 대상으로 지정"
L["vendorIgnoreBoE"] = "착용 시 귀속되는 아이템 무시"
L["vendorIgnoreWarbound"] = "전쟁에 귀속된 아이템 무시"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] =
        "이 옵션을 사용하면 상인에게 있는 동안 필터 기준에 따라\n" ..
            ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
            "|r 품질의 아이템을 자동으로 판매할 수 있습니다."
    L["vendor" .. value .. "Enable"] =
        "품질 " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] ..
            "|r 아이템 자동 판매 활성화"
    L["labelExplained" .. value .. "line"] = "이것은 자동으로 " .. ITEM_QUALITY_COLORS[key].hex ..
                                                 _G["ITEM_QUALITY" .. key .. "_DESC"] ..
                                                 "|r\n아이템 레벨이 %s 이하인 아이템을 판매합니다\n%s"
end
