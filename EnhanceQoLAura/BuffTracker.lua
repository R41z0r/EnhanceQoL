local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
        addon = _G[parentAddonName]
else
        error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Aura")

local activeBuffFrames = {}

local anchor = CreateFrame("Frame", "EQOLBuffTrackerAnchor", UIParent, "BackdropTemplate")
anchor:SetSize(36, 36)
anchor:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
anchor:SetBackdropColor(0, 0, 0, 0.6)
anchor:SetMovable(true)
anchor:EnableMouse(true)
anchor:RegisterForDrag("LeftButton")
anchor.text = anchor:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
anchor.text:SetPoint("CENTER", anchor, "CENTER")
anchor.text:SetText(L["DragToPosition"])

anchor:SetScript("OnDragStart", anchor.StartMoving)
anchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, xOfs, yOfs = self:GetPoint()
        addon.db["buffTrackerPoint"] = point
        addon.db["buffTrackerX"] = xOfs
        addon.db["buffTrackerY"] = yOfs
end)

local function restorePosition()
        if addon.db["buffTrackerPoint"] then
                anchor:ClearAllPoints()
                anchor:SetPoint(addon.db["buffTrackerPoint"], UIParent, addon.db["buffTrackerPoint"], addon.db["buffTrackerX"], addon.db["buffTrackerY"])
        end
end

anchor:SetScript("OnShow", restorePosition)
restorePosition()

local function createBuffFrame(icon)
        local frame = CreateFrame("Frame", nil, anchor)
        frame:SetSize(36, 36)

        local tex = frame:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints(frame)
        tex:SetTexture(icon)
        frame.icon = tex

        local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cd:SetAllPoints(frame)
        cd:SetDrawEdge(false)
        frame.cd = cd

        return frame
end

local function updatePositions()
        local point = addon.db["buffTrackerDirection"] or "RIGHT"
        local prev = anchor
        for _, frame in pairs(activeBuffFrames) do
                if frame:IsShown() then
                        frame:ClearAllPoints()
                        if point == "LEFT" then
                                frame:SetPoint("RIGHT", prev, "LEFT", -2, 0)
                        elseif point == "UP" then
                                frame:SetPoint("BOTTOM", prev, "TOP", 0, 2)
                        elseif point == "DOWN" then
                                frame:SetPoint("TOP", prev, "BOTTOM", 0, -2)
                        else
                                frame:SetPoint("LEFT", prev, "RIGHT", 2, 0)
                        end
                        prev = frame
                end
        end
end

local function updateBuff(id)
        local name, icon, _, _, duration, expires = AuraUtil.FindAuraBySpellId(id, "player", "HELPFUL")
        local frame = activeBuffFrames[id]
        if name then
                if not frame then
                        frame = createBuffFrame(icon)
                        activeBuffFrames[id] = frame
                end
                frame.icon:SetTexture(icon)
                if duration and duration > 0 then frame.cd:SetCooldown(expires - duration, duration) else frame.cd:Clear() end
                frame:Show()
        else
                if frame then frame:Hide() end
        end
end

local function scanBuffs()
        for id in pairs(addon.db["buffTrackerList"]) do updateBuff(tonumber(id)) end
        updatePositions()
end

anchor:SetScript("OnEvent", function(_, event, unit)
        if unit ~= "player" then return end
        scanBuffs()
end)

anchor:RegisterUnitEvent("UNIT_AURA", "player")
anchor:RegisterEvent("PLAYER_ENTERING_WORLD")

if addon.db["buffTrackerEnabled"] then anchor:Show() else anchor:Hide() end

addon.Aura.buffAnchor = anchor
addon.Aura.scanBuffs = scanBuffs

local function addBuff(id)
        local spellName = GetSpellInfo(id)
        if not spellName then return end
        if not addon.db["buffTrackerList"][id] then
                addon.db["buffTrackerList"][id] = spellName
        end
        scanBuffs()
end

local function removeBuff(id)
        addon.db["buffTrackerList"][id] = nil
        if activeBuffFrames[id] then
                activeBuffFrames[id]:Hide()
                activeBuffFrames[id] = nil
        end
        scanBuffs()
end

function addon.Aura.functions.addBuffTrackerOptions(container)
        local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
        container:AddChild(wrapper)

        local core = addon.functions.createContainer("InlineGroup", "List")
        wrapper:AddChild(core)

        local cb = addon.functions.createCheckboxAce(L["EnableBuffTracker"], addon.db["buffTrackerEnabled"], function(self, _, val)
                addon.db["buffTrackerEnabled"] = val
                if val then anchor:Show() else anchor:Hide() end
        end)
        core:AddChild(cb)

        local dirDrop = addon.functions.createDropdownAce(L["GrowthDirection"], { LEFT = "LEFT", RIGHT = "RIGHT", UP = "UP", DOWN = "DOWN" }, nil, function(self, _, val)
                addon.db["buffTrackerDirection"] = val
                updatePositions()
        end)
        dirDrop:SetValue(addon.db["buffTrackerDirection"])
        core:AddChild(dirDrop)

        local edit
        edit = addon.functions.createEditboxAce(L["SpellID"], nil, function(self, _, text)
                local id = tonumber(text)
                if id then addBuff(id) end
                self:SetText("")
        end)
        core:AddChild(edit)

        local list, order = addon.functions.prepareListForDropdown(addon.db["buffTrackerList"])
        local drop = addon.functions.createDropdownAce(L["TrackedBuffs"], list, order)
        core:AddChild(drop)

        local removeBtn = addon.functions.createButtonAce(REMOVE, 100, function()
                local val = drop:GetValue()
                if val then removeBuff(val) end
                local l, o = addon.functions.prepareListForDropdown(addon.db["buffTrackerList"])
                drop:SetList(l, o)
                drop:SetValue(nil)
        end)
        core:AddChild(removeBtn)
end

