if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

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
L["showCatalystChargesOnCharframe"] = "캐릭터 장비 창에 촉매 충전 표시"
L["showIlvlOnBagItems"] = "모든 가방의 장비에 아이템 레벨 표시"
L["showDurabilityOnCharframe"] = "캐릭터 장비 프레임에 내구도를 표시합니다"
L["hideOrderHallBar"] = "사령부 명령 바 숨기기"

L["deleteItemFillDialog"] = "\"삭제 확인 팝업\"에 \"" .. DELETE_ITEM_CONFIRM_STRING .. "\" 추가"
L["autoChooseQuest"] = "퀘스트 자동 수락 및 완료"

L["General"] = "일반"
L["Character"] = "캐릭터"
L["Dungeon"] = "던전"
L["Misc"] = "기타"
L["Quest"] = "퀘스트"

L["hideBagsBar"] = "가방 바 숨기기"

-- Dungeon
L["autoChooseDelvePower"] = "옵션이 1개만 있을 때 델브 파워 자동 선택"
L["lfgSortByRio"] = "신화 던전 지원자를 신화 점수로 정렬"

-- Quest
L["ignoreTrivialQuests"] = "사소한 퀘스트 무시"
L["ignoreDailyQuests"] = "일일/주간 퀘스트 무시"

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

-- 주술사
L["shaman_HideTotem"] = "토템 바 숨기기"

-- 흑마법사
L["warlock_HideSoulShardBar"] = "영혼의 조각 바 숨기기"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "인터페이스 다시 로드 필요"
L["bReloadInterface"] = "변경 사항을 적용하려면 인터페이스를 다시 로드해야 합니다"

L["CVarOptions"] = {["ShowClassColorInNameplate"] = {description = "이름표에 직업 색상 표시", -- 활성화 = 1
                                                     trueValue = "1", falseValue = "0"},
                    ["chatMouseScroll"] = {description = "채팅에서 마우스 스크롤 활성화", -- 활성화 = 1
trueValue = "1", falseValue = "0"},
                    ["WholeChatWindowClickable"] = {description = "채팅 창 전체를 클릭 가능하게 설정", -- 활성화 = 1
                                                    trueValue = "1", falseValue = "0"},
                    ["showTutorials"] = {description = "튜토리얼 비활성화", -- 비활성화 = 0
trueValue = "0", falseValue = "1"}, ["UberTooltips"] = {description = "향상된 툴팁 활성화", -- 활성화 = 1
trueValue = "1", falseValue = "0"}, ["ffxDeath"] = {description = "죽음 효과 비활성화", -- 비활성화 = 0
trueValue = "0", falseValue = "1"}}
