if (GAME_LOCALE or GetLocale()) ~= "koKR" then
    return
end

local addonName, addon = ...

local L = addon.L

L["Quick signup"] = "빠른 가입"
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

L["showIlvlOnCharframe"] = "캐릭터 장비 창에 아이템 레벨 표시"
L["showGemsOnCharframe"] = "캐릭터 장비 창에 보석 슬롯 표시"
L["showEnchantOnCharframe"] = "캐릭터 장비 창에 마법 부여 표시"

L["deleteItemFillDialog"] = "\"삭제 확인 팝업\"에 \"" .. COMMUNITIES_DELETE_CONFIRM_STRING .. "\" 추가"
L["autoChooseQuest"] = "퀘스트 자동 수락 및 완료"

L["General"] = "일반"
L["Character"] = "캐릭터"
L["Dungeon"] = "던전"
L["Misc"] = "기타"
L["Quest"] = "퀘스트"

-- Dungeon
L["autoChooseDelvePower"] = "옵션이 1개만 있을 때 델브 파워 자동 선택"

-- Quest
L["ignoreTrivialQuests"] = "사소한 퀘스트 무시"
L["ignoreDailyQuests"] = "일일/주간 퀘스트 무시"
