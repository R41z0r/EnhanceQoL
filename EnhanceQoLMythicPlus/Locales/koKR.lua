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
local L = addon.LMythicPlus

L["Automatically insert keystone"] = "쐐기돌 자동 삽입"
L["Mythic Plus"] = "쐐기돌+"
L[addonName] = "쐐기돌+"
L["Close all bags on keystone insert"] = "쐐기돌 삽입 시 모든 가방 닫기"
L["ReadyCheck"] = "준비 확인"
L["ReadyCheckWaiting"] = "준비 상태 확인 중..."
L["PullTimer"] = "풀 타이머"
L["Pull"] = "풀"
L["Cancel"] = "취소"
L["Cancel Pull Timer on click"] = "클릭 시 풀 타이머 취소"
L["noChatOnPullTimer"] = "풀 타이머 시 채팅 메시지 없음"
L["sliderShortTime"] = "풀 타이머 우클릭"
L["sliderLongTime"] = "풀 타이머"
L["Stating"] = "시작 중..."
L["autoKeyStart"] = "풀 타이머 후 자동으로 쐐기돌 시작"

L["None"] = "풀 타이머 없음"
L["Blizzard Pull Timer"] = "블리자드 풀 타이머"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 풀 타이머"
L["Both"] = "블리자드 및 DBM / BigWigs"
L["Pull Timer Type"] = "풀 타이머 유형"