if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "빠른 가입"
L["interruptWithShift"] = "해당 기능을 중단하려면 Shift를 누르고 계세요"

L["Persist LFG signup note"] = "LFG 가입 메모 유지"
L["Select an option"] = "옵션 선택"
L["Save"] = "저장"
L["Hide Minimap Button"] = "미니맵 버튼 숨기기"
L["Left-Click to show options"] = "옵션을 표시하려면 왼쪽 클릭"

L["Hide Raid Tools"] = "파티에서 공격대 도구 숨기기"
L["repairCost"] = "아이템 수리 비용 "
L["autoRepair"] = "모든 아이템 자동 수리"
L["sellAllJunk"] = "모든 잡동사니 자동 판매"
L["ignoreTalkingHead"] = "자동으로 대화 머리 프레임 숨기기"
L["landingPageHide"] = "미니맵에서 확장 페이지 버튼을 숨기려면 이 옵션을 활성화하세요."
L["automaticallyOpenContainer"] = "자동으로 가방의 컨테이너 아이템 열기"

L["showIlvlOnBankFrame"] = "은행 창에 아이템 레벨 표시"
L["showIlvlOnMerchantframe"] = "상인 창에 아이템 레벨 표시"
L["showIlvlOnCharframe"] = "캐릭터 장비 창에 아이템 레벨 표시"
L["showGemsOnCharframe"] = "캐릭터 장비 창에 보석 슬롯 표시"
L["showBindOnBagItems"] = _G.ITEM_BIND_ON_EQUIP .. "(BoE), " .. _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP .. " (WuE), " .. _G.ITEM_BNETACCOUNTBOUND .. " (WB)를 아이템 레벨과 함께 표시합니다"
L["showGemsTooltipOnCharframe"] = "캐릭터 장비 창에서 보석 슬롯 툴팁 표시"
L["showEnchantOnCharframe"] = "캐릭터 장비 창에 마법 부여 표시"
L["showCatalystChargesOnCharframe"] = "캐릭터 장비 창에 촉매 충전 표시"
L["showIlvlOnBagItems"] = "모든 가방의 장비에 아이템 레벨 표시"
L["showDurabilityOnCharframe"] = "캐릭터 장비 프레임에 내구도를 표시합니다"
L["hideOrderHallBar"] = "사령부 명령 바 숨기기"
L["showInfoOnInspectFrame"] = "검사 창에 추가 정보를 표시합니다"
L["MissingEnchant"] = "마법부여"
L["hideHitIndicatorPlayer"] = "캐릭터 위에 뜨는 전투 텍스트(피해 및 치유) 숨기기"
L["hideHitIndicatorPet"] = "소환수 위에 뜨는 전투 텍스트(피해 및 치유) 숨기기"
L["UnitFrame"] = "유닛 프레임"
L["SellJunkIgnoredBag"] = "가방 %d개에서 쓰레기 판매를 비활성화했습니다.\n이로 인해 모든 쓰레기 아이템이 자동으로 판매되지 않을 수 있습니다."

L["deleteItemFillDialog"] = '"삭제 확인 팝업"에 "' .. DELETE_ITEM_CONFIRM_STRING .. '" 추가'
L["confirmPatronOrderDialog"] = "자체 재료 사용을 " .. PROFESSIONS_CRAFTER_ORDER_TAB_NPC .. " 제작 주문에 자동으로 확인합니다."
L["autoChooseQuest"] = "퀘스트 자동 수락 및 완료"
L["confirmTimerRemovalTrade"] = "교환 기간 내 교환 가능한 전리품 판매를 자동으로 확인"

L["General"] = "일반"
L["Character"] = "캐릭터"
L["Dungeon"] = "던전"
L["Misc"] = "기타"
L["Quest"] = "퀘스트"

L["hideBagsBar"] = "가방 바 숨기기"
L["hideMicroMenu"] = "마이크로 메뉴 숨기기"
-- Dungeon
L["autoChooseDelvePower"] = "옵션이 1개만 있을 때 델브 파워 자동 선택"
L["lfgSortByRio"] = "신화 던전 지원자를 신화 점수로 정렬"
L["DungeonBrowser"] = "던전 브라우저"
L["groupfinderAppText"] = '그룹 찾기 텍스트 "당신의 그룹이 현재 형성 중입니다" 숨기기'
L["groupfinderMoveResetButton"] = "던전 찾기의 필터 초기화 버튼을 왼쪽으로 이동합니다."
L["groupfinderSkipRoleSelect"] = "역할 선택 건너뛰기"
L["groupfinderSkipRolecheckHeadline"] = "자동 역할 설정"
L["groupfinderSkipRolecheckUseSpec"] = "현재 전문화의 역할 사용 (예: 죽음의 기사 (혈기) = 탱커)"
L["groupfinderSkipRolecheckUseLFD"] = "던전 찾기에 설정된 역할 사용"

-- Quest
L["ignoreTrivialQuests"] = "사소한 " .. QUESTS_LABEL .. "을(를) 자동으로 처리하지 않음"
L["ignoreDailyQuests"] = "일일/주간 " .. QUESTS_LABEL .. "을(를) 자동으로 처리하지 않음"
L["ignoreWarbandCompleted"] = "계정 완료된 " .. QUESTS_LABEL .. "을(를) 자동으로 처리하지 않음"

L["autoQuickLoot"] = "빠른 전리품 획득"
L["openCharframeOnUpgrade"] = "상인에게서 아이템을 강화할 때 캐릭터 창 열기"

L["headerClassInfo"] = "이 설정은 " .. select(1, UnitClass("player")) .. "에게만 적용됩니다."

-- 죽음의 기사
L["deathknight_HideRuneFrame"] = "룬 프레임 숨기기"

-- 기원사
L["evoker_HideEssence"] = "정수 바 숨기기"

-- 수도사
L["monk_HideHarmonyBar"] = "조화 바 숨기기"

-- 성기사
L["paladin_HideHolyPower"] = "신성한 힘 바 숨기기"

-- 도적
L["rogue_HideComboPoint"] = "연계 점수 바 숨기기"

-- Druid
L["druid_HideComboPoint"] = L["rogue_HideComboPoint"]

-- 주술사
L["shaman_HideTotem"] = "토템 바 숨기기"

-- 흑마법사
L["warlock_HideSoulShardBar"] = "영혼의 조각 바 숨기기"

L["questAddNPCToExclude"] = "대상 NPC/열린 대화 창을 제외 목록에 추가"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "인터페이스 다시 로드 필요"
L["bReloadInterface"] = "변경 사항을 적용하려면 인터페이스를 다시 로드해야 합니다"

L["CVarOptions"] = {
	["autoDismount"] = { trueValue = "1", falseValue = "0", description = "스킬 사용 시 자동 탈것 내리기 활성화" },
	["autoDismountFlying"] = { trueValue = "1", falseValue = "0", description = "비행 중 스킬 사용 시 자동 탈것 내리기 활성화" },
	["chatMouseScroll"] = { description = "채팅에서 마우스 스크롤 활성화", trueValue = "1", falseValue = "0" },
	["ffxDeath"] = { description = "죽음 효과 비활성화", trueValue = "0", falseValue = "1" },
	["mapFade"] = { trueValue = "1", falseValue = "0", description = "이동 중 지도 흐려짐 활성화" },
	["scriptErrors"] = { description = "UI에서 LUA 오류 표시", trueValue = "1", falseValue = "0" },
	["ShowClassColorInNameplate"] = { description = "이름표에 직업 색상 표시", trueValue = "1", falseValue = "0" },
	["ShowTargetCastbar"] = { trueValue = "1", falseValue = "0", description = "대상의 시전 바 표시" },
	["showTutorials"] = { description = "튜토리얼 비활성화", trueValue = "0", falseValue = "1" },
	["UberTooltips"] = { description = "향상된 툴팁 활성화", trueValue = "1", falseValue = "0" },
	["UnitNamePlayerGuild"] = { trueValue = "1", falseValue = "0", description = "플레이어의 길드 표시" },
	["UnitNamePlayerPVPTitle"] = { trueValue = "1", falseValue = "0", description = "플레이어의 칭호 표시" },
	["WholeChatWindowClickable"] = { description = "전체 채팅 창 클릭 가능하게 설정", trueValue = "1", falseValue = "0" },
}

L["autoAcceptGroupInvite"] = "파티 초대를 자동으로 수락"
L["autoAcceptGroupInviteGuildOnly"] = "길드원"
L["autoAcceptGroupInviteFriendOnly"] = "친구"
L["autoAcceptGroupInviteOptions"] = "다음 대상의 초대를 수락..."
