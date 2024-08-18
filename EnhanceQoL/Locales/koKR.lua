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