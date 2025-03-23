if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMythicPlus

L["Keystone"] = "쐐기돌"
L["NoKeystone"] = "정보 없음"
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
L["mythicPlusTruePercent"] = "적군 세력의 소수점 값을 표시"
L["mythicPlusChestTimer"] = "상자 타이머 표시"
L["interruptWithShift"] = "해당 기능을 중단하려면 Shift를 누르고 계세요"

L["None"] = "풀 타이머 없음"
L["Blizzard Pull Timer"] = "블리자드 풀 타이머"
L["DBM / BigWigs Pull Timer"] = "DBM / BigWigs 풀 타이머"
L["Both"] = "블리자드 및 DBM / BigWigs"
L["Pull Timer Type"] = "풀 타이머 유형"

L["groupfinderShowDungeonScoreFrame"] = "던전 찾기 옆에 " .. DUNGEON_SCORE .. " 프레임 표시"
-- Keystone
L["groupfinderShowPartyKeystone"] = "파티원의 쐐기돌 정보를 표시합니다"
L["groupfinderShowPartyKeystoneDesc"] = "해당 던전으로 순간이동하기 위해 키 정보 아이콘을 클릭할 수 있습니다"

-- Potion Tracker
L["Drag me to position Cooldownbars"] = "쿨다운바 위치 조정"
L["Potion Tracker"] = "물약 추적기"
L["Toggle Anchor"] = "앵커 토글"
L["Save Anchor"] = "앵커 저장"
L["potionTrackerHeadline"] = "이 기능은 파티원의 전투 물약의 쿨다운을 추적하는 이동 가능한 바를 제공합니다."
L["potionTracker"] = "물약 쿨다운 추적기 활성화"
L["potionTrackerUpwardsBar"] = "위로 성장"
L["potionTrackerClassColor"] = "바에 직업 색상 사용"
L["potionTrackerDisableRaid"] = "공격대에서 물약 추적기 비활성화"

L["Tinker"] = "기계공"
L["InvisPotion"] = "투명 물약"
L["potionTrackerShowTooltip"] = "아이콘에 툴팁 표시"
L["HealingPotion"] = "치유"
L["potionTrackerHealingPotions"] = "치유 물약 CD 추적"
L["potionTrackerOffhealing"] = "보조 치유 CD 사용 추적"

-- AutoMark Frame
L["AutoMark"] = "탱커 징표"
L["autoMarkTankInDungeon"] = "던전에서 " .. TANK .. " 자동 표시"
L["autoMarkTankInDungeonMarker"] = "탱커 징표"
L["Disabled"] = "비활성화됨"
L["autoMarkTankExplanation"] = "탱커에게 표식이 없을 때 자동으로 표식을 지정하고 변경은 당신이 "
	.. COMMUNITY_MEMBER_ROLE_NAME_LEADER
	.. " 또는 "
	.. TANK
	.. "일 때만 가능합니다."
L["mythicPlusIgnoreMythic"] = PLAYER_DIFFICULTY6 .. " 던전에서 공격대 징표를 적용하지 않음"
L["mythicPlusIgnoreHeroic"] = PLAYER_DIFFICULTY2 .. " 던전에서 공격대 징표를 적용하지 않음"
L["mythicPlusIgnoreEvent"] = BATTLE_PET_SOURCE_7 .. " 던전에서 공격대 징표를 적용하지 않음"
L["mythicPlusIgnoreNormal"] = PLAYER_DIFFICULTY1 .. " 던전에서 공격대 징표를 적용하지 않음"
L["mythicPlusIgnoreTimewalking"] = PLAYER_DIFFICULTY_TIMEWALKER .. " 던전에서 공격대 징표를 적용하지 않음"

-- Teleports
L["Teleports"] = "순간이동"
L["teleportEnabled"] = "순간이동 창 활성화"
L["DungeonCompendium"] = "던전 순간이동 모음집"
L["teleportsEnableCompendium"] = "던전 순간이동 모음집 활성화"
L["teleportCompendiumHeadline"] = "특정 확장팩의 순간이동 숨기기"

L["teleportsHeadline"] = "던전 순간이동을 포함한 프레임을 PVE 창에 추가합니다"
L["portalHideMissing"] = "누락된 순간이동 숨기기"
L["portalShowTooltip"] = "순간이동 버튼에 툴팁 표시"
L["hideActualSeason"] = "현재 시즌의 순간이동 숨기기: " .. L["DungeonCompendium"]
L["teleportCompendiumAdditionHeadline"] = "추가 포털 옵션"
L["portalShowDungeonTeleports"] = "던전 순간이동 표시"
L["portalShowRaidTeleports"] = "공격대 순간이동 표시"
L["portalShowToyHearthstones"] = "순간이동 아이템 및 장난감 표시 (예: 귀환석)"
L["portalShowEngineering"] = "기계공학 순간이동 표시 (기계공학 필요)"
L["portalShowClassTeleport"] = "직업별 순간이동 표시 (해당 직업만 사용 가능)"
L["portalShowMagePortal"] = "마법사 차원문 표시 (마법사 전용)"

-- BR Tracker
L["BRTracker"] = "전투 부활"
L["brTrackerHeadline"] = "Mythic+ 던전에서 전투 부활 추적기를 추가합니다."
L["mythicPlusBRTrackerEnabled"] = "전투 부활 추적기 사용"
L["mythicPlusBRTrackerLocked"] = "추적기 위치 잠금"
L["mythicPlusBRButtonSizeHeadline"] = "버튼 크기"
