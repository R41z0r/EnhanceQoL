local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LTooltip

local frameLoad = CreateFrame("Frame")

local function checkSpell(tooltip, id, name)
    if addon.db["TooltipShowSpellID"] then
        if id then
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(name, id)
        end
    end
    if addon.db["TooltipSpellHideType"] == 1 then
        return
    end -- only hide when ON
    if addon.db["TooltipSpellHideInDungeon"] and select(1, IsInInstance()) == false then
        return
    end -- only hide in dungeons
    if addon.db["TooltipSpellHideInCombat"] and UnitAffectingCombat("player") == false then
        return
    end -- only hide in combat
    tooltip:Hide()
end

local function checkAdditionalTooltip(tooltip)
    if addon.db["TooltipShowClassColor"] then
        local classDisplayName, class, classID = UnitClass("mouseover")
        if classDisplayName then
            local r, g, b = GetClassColor(class)
            for i = 1, tooltip:NumLines() do
                local line = _G[tooltip:GetName() .. "TextLeft" .. i]
                local text = line:GetText()
                if text and text:find(classDisplayName) then
                    line:SetTextColor(r, g, b)
                    break
                end
            end
        end
    end
    if addon.db["TooltipShowMythicScore"] then
        local name, _, timeLimit
        local rating = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("mouseover")
        if rating then
            local r, g, b = C_ChallengeMode.GetDungeonScoreRarityColor(rating.currentSeasonScore):GetRGB()
            local bestDungeon
            for _, key in pairs(rating.runs) do
                name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(key.challengeModeID)
                if nil == bestDungeon then
                    bestDungeon = key
                else
                    if bestDungeon.mapScore < key.mapScore then
                        bestDungeon = key
                    end
                end
            end
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(L["Mythic+ Score"], rating.currentSeasonScore, 1, 1, 0, r, g, b)
            if bestDungeon and bestDungeon.mapScore > 0 then
                name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(bestDungeon.challengeModeID)
                r, g, b = C_ChallengeMode.GetKeystoneLevelRarityColor(bestDungeon.bestRunLevel):GetRGB()
                local stars
                local hexColor = string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
                if bestDungeon.finishedSuccess then
                    local bestRunDuration = bestDungeon.bestRunDurationMS / 1000
                    local timeForPlus3 = timeLimit * 0.6
                    local timeForPlus2 = timeLimit * 0.8
                    local timeForPlus1 = timeLimit
                    if bestRunDuration <= timeForPlus3 then
                        stars = "+++"
                    elseif bestRunDuration <= timeForPlus2 then
                        stars = "++"
                    elseif bestRunDuration <= timeForPlus1 then
                        stars = "+"
                    end
                    stars = stars .. bestDungeon.bestRunLevel
                else
                    stars = bestDungeon.bestRunLevel
                end
                tooltip:AddDoubleLine(L["BestMythic+run"], hexColor .. stars .. "|r " .. name, 1, 1, 0, 1, 1, 1)
            end
        end
    end
end

local function checkUnit(tooltip)
    if addon.db["TooltipUnitHideInDungeon"] and select(1, IsInInstance()) == false then
        checkAdditionalTooltip(tooltip)
        return
    end -- only hide in dungeons
    if addon.db["TooltipUnitHideInCombat"] and UnitAffectingCombat("player") == false then
        checkAdditionalTooltip(tooltip)
        return
    end -- only hide in combat
    if addon.db["TooltipUnitHideType"] == 1 then
        checkAdditionalTooltip(tooltip)
        return
    end -- hide never
    if addon.db["TooltipUnitHideType"] == 4 then
        tooltip:Hide()
    end -- hide always because we selected BOTH
    if addon.db["TooltipUnitHideType"] == 2 and UnitCanAttack("player", "mouseover") then
        tooltip:Hide()
    end
    if addon.db["TooltipUnitHideType"] == 3 and UnitCanAttack("player", "mouseover") == false then
        tooltip:Hide()
    end
    checkAdditionalTooltip(tooltip)
end

local function checkItem(tooltip, id, name)
    if addon.db["TooltipShowItemID"] then
        if id then
            tooltip:AddLine(" ")
            tooltip:AddDoubleLine(name, id)
        end
    end
    if addon.db["TooltipItemHideType"] == 1 then
        return
    end -- only hide when ON
    if addon.db["TooltipItemHideInDungeon"] and select(1, IsInInstance()) == false then
        return
    end -- only hide in dungeons
    if addon.db["TooltipItemHideInCombat"] and UnitAffectingCombat("player") == false then
        return
    end -- only hide in combat
    tooltip:Hide()
end

local function checkAura(tooltip)
    if addon.db["TooltipBuffHideType"] == 1 then
        return
    end -- only hide when ON
    if addon.db["TooltipBuffHideInDungeon"] and select(1, IsInInstance()) == false then
        return
    end -- only hide in dungeons
    if addon.db["TooltipBuffHideInCombat"] and UnitAffectingCombat("player") == false then
        return
    end -- only hide in combat
    tooltip:Hide()
end

local function checkDebuff(tooltip)
    if addon.db["TooltipDebuffHideType"] == 1 then
        return
    end -- only hide when ON
    if addon.db["TooltipDebuffHideInDungeon"] and select(1, IsInInstance()) == false then
        return
    end -- only hide in dungeons
    if addon.db["TooltipDebuffHideInCombat"] and UnitAffectingCombat("player") == false then
        return
    end -- only hide in combat
    tooltip:Hide()
end

-- hooksecurefunc(GameTooltip, "Show", function(self)
--     -- Überprüfe, ob wir uns in einem Dungeon befinden (falls konfiguriert)
--     local tooltip = GameTooltip
--     local name, link = tooltip:GetItem()
--     if nil ~= link then -- it's an item - handle the item request
--         checkItem(self)
--         return true
--     end
--     local spellName, spellId = tooltip:GetSpell()
--     if nil ~= spellName then
--         checkSpell(self)
--         return true
--     end

--     local unitName, unitId = tooltip:GetUnit()
--     if nil ~= unitName then
--         checkUnit(self)
--         return true
--     end
-- end)

-- Buffbar
-- if UnitBuff then
--     hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
--         local id = select(10, UnitBuff(...))
--         print("Buff", id)
--         self:Hide()
--     end)
-- end

if UnitAura then
    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        local id = select(10, UnitAura(...))
        checkAura(self)
    end)
end

if UnitDebuff then
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...)
        local id = select(10, UnitDebuff(...))
        checkDebuff(self)
    end)
end

if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
        if not data or not data.type then
            return
        end
        local id, name, _, timeLimit
        local kind = addon.Tooltip.variables.kindsByID[tonumber(data.type)]
        if kind == "spell" then
            id = data.id
            name = L["SpellID"]
            checkSpell(tooltip, id, name)
            return
        elseif kind == "macro" then
            id = data.id
            name = L["MacroID"]
            checkSpell(tooltip, id, name)
            return
        elseif kind == "unit" then
            checkUnit(tooltip)
            return
        elseif kind == "item" then
            id = data.id
            name = L["ItemID"]
            checkItem(tooltip, id, name)
            return
        end
        -- print(kind, tonumber(data.type))
    end)
end

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Tooltip"])
frame.tabs = {}
frame:SetScript("OnSizeChanged", function(self, width, height)
    for i, tab in ipairs(frame.tabs) do
        tab:SetSize(width - 5, height - 35)
    end
end)
function frame:ShowTab(id)
    for _, tabContent in pairs(self.tabs) do
        tabContent:Hide()
    end
    if self.tabs[id] then
        self.tabs[id]:Show()
    end
end

local tabFrameBuff = addon.Tooltip.functions.createTabFrame(L["Buff"], frame)
local tabFrameDebuff = addon.Tooltip.functions.createTabFrame(L["Debuff"], frame)
local tabFrameItem = addon.Tooltip.functions.createTabFrame(L["Item"], frame)
local tabFrameSpell = addon.Tooltip.functions.createTabFrame(L["Spell"], frame) -- contains macro and spell later
local tabFrameUnit = addon.Tooltip.functions.createTabFrame(L["Unit"], frame)

-- Buffs

local labelBuffHideType = addon.functions.createDropdown("TooltipBuffHideType", tabFrameBuff, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipBuffHideType"], 10, -10, addon.db["TooltipBuffHideType"])

local cbTooltipBuffHideCombat = addon.functions.createCheckbox("TooltipBuffHideInCombat", tabFrameBuff,
    L["TooltipBuffHideInCombat"], 10, (addon.functions.getHeightOffset(labelBuffHideType) - 50))

local cbTooltipBuffHideDungeon = addon.functions.createCheckbox("TooltipBuffHideInDungeon", tabFrameBuff,
    L["TooltipBuffHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipBuffHideCombat) - 5))

-- Debuffs

local labelDebuffHideType = addon.functions.createDropdown("TooltipDebuffHideType", tabFrameDebuff, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipDebuffHideType"], 10, -10, addon.db["TooltipDebuffHideType"])

local cbTooltipDebuffHideCombat = addon.functions.createCheckbox("TooltipDebuffHideInCombat", tabFrameDebuff,
    L["TooltipDebuffHideInCombat"], 10, (addon.functions.getHeightOffset(labelDebuffHideType) - 50))

local cbTooltipDebuffHideDungeon = addon.functions.createCheckbox("TooltipDebuffHideInDungeon", tabFrameDebuff,
    L["TooltipDebuffHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipDebuffHideCombat) - 5))

-- Unit
local labelPullTimerType = addon.functions.createDropdown("TooltipUnitHideType", tabFrameUnit, {{
    text = L["None"],
    value = 1
}, {
    text = L["Enemies"],
    value = 2
}, {
    text = L["Friendly"],
    value = 3
}, {
    text = L["Both"],
    value = 4
}}, 150, L["TooltipUnitHideType"], 10, -10, addon.db["TooltipUnitHideType"])

local cbTooltipHideCombat = addon.functions.createCheckbox("TooltipUnitHideInCombat", tabFrameUnit,
    L["TooltipUnitHideInCombat"], 10, (addon.functions.getHeightOffset(labelPullTimerType) - 50))

local cbTooltipHideDungeon = addon.functions.createCheckbox("TooltipUnitHideInDungeon", tabFrameUnit,
    L["TooltipUnitHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipHideCombat) - 5))

local cbTooltipShowMythicScore = addon.functions.createCheckbox("TooltipShowMythicScore", tabFrameUnit,
    L["TooltipShowMythicScore"], 10, (addon.functions.getHeightOffset(cbTooltipHideDungeon) - 5))

local cbTooltipShowClassColor = addon.functions.createCheckbox("TooltipShowClassColor", tabFrameUnit,
    L["TooltipShowClassColor"], 10, (addon.functions.getHeightOffset(cbTooltipShowMythicScore) - 5))

-- Spells

local labelSpellHideType = addon.functions.createDropdown("TooltipSpellHideType", tabFrameSpell, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipSpellHideType"], 10, -10, addon.db["TooltipSpellHideType"])

local cbTooltipSpellHideCombat = addon.functions.createCheckbox("TooltipSpellHideInCombat", tabFrameSpell,
    L["TooltipSpellHideInCombat"], 10, (addon.functions.getHeightOffset(labelSpellHideType) - 50))

local cbTooltipSpellHideDungeon = addon.functions.createCheckbox("TooltipSpellHideInDungeon", tabFrameSpell,
    L["TooltipSpellHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipSpellHideCombat) - 5))

local cbTooltipSpellShowID = addon.functions.createCheckbox("TooltipShowSpellID", tabFrameSpell,
    L["TooltipShowSpellID"], 10, (addon.functions.getHeightOffset(cbTooltipSpellHideDungeon) - 5))

-- Items
local labelItemHideType = addon.functions.createDropdown("TooltipItemHideType", tabFrameItem, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipItemHideType"], 10, -10, addon.db["TooltipItemHideType"])

local cbTooltipItemHideCombat = addon.functions.createCheckbox("TooltipItemHideInCombat", tabFrameItem,
    L["TooltipItemHideInCombat"], 10, (addon.functions.getHeightOffset(labelItemHideType) - 50))

local cbTooltipItemHideDungeon = addon.functions.createCheckbox("TooltipItemHideInDungeon", tabFrameItem,
    L["TooltipItemHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipItemHideCombat) - 5))

local cbTooltipItemShowID = addon.functions.createCheckbox("TooltipShowItemID", tabFrameItem, L["TooltipShowItemID"],
    10, (addon.functions.getHeightOffset(cbTooltipItemHideDungeon) - 5))

-- Bigger frame for all Options
addon.frame:SetSize(500, 550)
