if (GAME_LOCALE or GetLocale()) ~= "koKR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "마우스 커서 주위에 반지 모양 표시 활성화"
L["mouseTrailEnabled"] = "마우스 커서 이동 시 표시되는 자취 활성화"
L["Trailinfo"] = "하드웨어 성능에 따라 프레임 저하 등이 발생할 수 있습니다"
L["Ring Color"] = "반지 색상"
L["Trail Color"] = "자취 색상"
L["mouseTrailDensity"] = "마우스 자취 밀도"
