local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

local frameLoad = CreateFrame("Frame")

local function checkKeyStone()
    local GetContainerNumSlots = C_Container.GetContainerNumSlots
    local GetContainerItemID = C_Container.GetContainerItemID
    local UseContainerItem = C_Container.UseContainerItem
    local GetContainerItemInfo = C_Container.GetContainerItemInfo

    local kId = C_MythicPlus.GetOwnedKeystoneMapID()
    local mapId = select(8, GetInstanceInfo())
    if nil ~= kId and mapId == kId then
        for container = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(container) do
                local id = GetContainerItemID(container, slot)
                if id == 180653 then
                    print("Used keystone")
                    UseContainerItem(container, slot)
                    break
                    -- if aura_env.config.pCloseBags then CloseAllBags() end
                    -- return UnitIsGroupLeader("Player")
                end
            end
        end
    end
end

-- Registriere das Event
frameLoad:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- loadMain()
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        checkKeyStone()
    end
end

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Mythic Plus"])

header = addon.functions.createHeader(frame, L[addonName], 0, -10)
local _, _, _, _, headerY = header:GetPoint()

cbAutoInsertKeystone = addon.functions.createCheckbox("autoInsertKeystone", frame,
    L["Automatically insert keystone"], 10, (headerY - header:GetHeight() - 10))
cbAutoInsertKeystone:SetChecked(addon.db["autoInsertKeystone"])

_, _, _, _, headerY = cbAutoInsertKeystone:GetPoint()