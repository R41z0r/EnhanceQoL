local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LTooltip

local frameLoad = CreateFrame("Frame")

hooksecurefunc(GameTooltip, "Show", function(self)
    -- Überprüfe, ob wir uns in einem Dungeon befinden (falls konfiguriert)
    local tooltip = GameTooltip
    local name, link = tooltip:GetItem()
    if nil ~= link then -- it's an item - handle the item request
        if addon.db["TooltipItemHideType"] == 1 then
            return
        end -- only hide when ON
        if addon.db["TooltipItemHideInDungeon"] and select(1, IsInInstance()) == false then
            return
        end -- only hide in dungeons
        if addon.db["TooltipItemHideInCombat"] and UnitAffectingCombat("player") == false then
            return
        end -- only hide in combat
        self:Hide()
        return true
    end
    local spellName, spellId = tooltip:GetSpell()
    if nil ~= spellName then
        if addon.db["TooltipSpellHideType"] == 1 then
            return
        end -- only hide when ON
        if addon.db["TooltipSpellHideInDungeon"] and select(1, IsInInstance()) == false then
            return
        end -- only hide in dungeons
        if addon.db["TooltipSpellHideInCombat"] and UnitAffectingCombat("player") == false then
            return
        end -- only hide in combat
        self:Hide()
        return true
    end

    local unitName, unitId = tooltip:GetUnit()
    if nil ~= unitName then
        if addon.db["TooltipUnitHideInDungeon"] == 1 and select(1, IsInInstance()) == false then
            return
        end -- only hide in dungeons
        if addon.db["TooltipUnitHideInCombat"] and UnitAffectingCombat("player") == false then
            return
        end -- only hide in combat
        if addon.db["TooltipUnitHideType"] == 1 then
            return
        end -- hide never
        if addon.db["TooltipUnitHideType"] == 4 then
            self:Hide()
        end -- hide always because we selected BOTH
        if addon.db["TooltipUnitHideType"] == 2 and UnitCanAttack("player", "mouseover") then
            self:Hide()
        end
        if addon.db["TooltipUnitHideType"] == 3 and UnitCanAttack("player", "mouseover") == false then
            self:Hide()
        end
        return true
    end
end)

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Tooltip"])

local header = addon.functions.createHeader(frame, L[addonName], 0, -10)

local labelPullTimerType = addon.functions.createDropdown("TooltipUnitHideType", frame, {{
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
}}, 150, L["TooltipUnitHideType"], 10, addon.functions.getHeightOffset(header) - 10, addon.db["TooltipUnitHideType"])

local cbTooltipHideCombat = addon.functions.createCheckbox("TooltipUnitHideInCombat", frame,
    L["TooltipUnitHideInCombat"], 10, (addon.functions.getHeightOffset(labelPullTimerType) - 50))

local cbTooltipHideDungeon = addon.functions.createCheckbox("TooltipUnitHideInDungeon", frame,
    L["TooltipUnitHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipHideCombat) - 5))

-- Spells

local labelSpellHideType = addon.functions.createDropdown("TooltipSpellHideType", frame, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipSpellHideType"], 10, addon.functions.getHeightOffset(cbTooltipHideDungeon) - 20,
    addon.db["TooltipSpellHideType"])

local cbTooltipSpellHideCombat = addon.functions.createCheckbox("TooltipSpellHideInCombat", frame,
    L["TooltipSpellHideInCombat"], 10, (addon.functions.getHeightOffset(labelSpellHideType) - 50))

local cbTooltipSpellHideDungeon = addon.functions.createCheckbox("TooltipSpellHideInDungeon", frame,
    L["TooltipSpellHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipSpellHideCombat) - 5))

-- Items
local labelItemHideType = addon.functions.createDropdown("TooltipItemHideType", frame, {{
    text = L["TooltipOFF"],
    value = 1
}, {
    text = L["TooltipON"],
    value = 2
}}, 150, L["TooltipItemHideType"], 10, addon.functions.getHeightOffset(cbTooltipSpellHideDungeon) - 20,
    addon.db["TooltipItemHideType"])

local cbTooltipItemHideCombat = addon.functions.createCheckbox("TooltipItemHideInCombat", frame,
    L["TooltipItemHideInCombat"], 10, (addon.functions.getHeightOffset(labelItemHideType) - 50))

local cbTooltipItemHideDungeon = addon.functions.createCheckbox("TooltipItemHideInDungeon", frame,
    L["TooltipItemHideInDungeon"], 10, (addon.functions.getHeightOffset(cbTooltipItemHideCombat) - 5))
