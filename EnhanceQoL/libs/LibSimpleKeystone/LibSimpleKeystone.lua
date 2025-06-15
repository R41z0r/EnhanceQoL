local MAJOR, MINOR = "LibSimpleKeystone-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or { KeystoneUpdate = {} }
lib.data = lib.data or {}
local PREFIX = "LRS"
local DATA_PREFIX = "K"
local REQUEST_PREFIX = "J"

C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

local function trigger(event, ...)
    local cbs = lib.callbacks[event]
    if not cbs then return end
    for i = 1, #cbs do
        local obj, func = cbs[i][1], cbs[i][2]
        if type(func) == "string" then
            if obj and obj[func] then obj[func](obj, ...) end
        elseif type(func) == "function" then
            func(obj, ...)
        end
    end
end

function lib.RegisterCallback(obj, event, method)
    lib.callbacks[event] = lib.callbacks[event] or {}
    table.insert(lib.callbacks[event], { obj, method })
end

function lib.UnregisterCallback(obj, event, method)
    local list = lib.callbacks[event]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i][1] == obj and list[i][2] == method then
            table.remove(list, i)
            break
        end
    end
end

function lib.GetAllKeystonesInfo()
    return lib.data
end

local function sendData(channel, target)
    local pName = UnitName("player")
    local info = lib.data[pName]
    if not info then return end
    local msg = string.format("%s,%d,%d,%d,0,0,0", DATA_PREFIX, info.level or 0, info.mapID or 0, info.challengeMapID or 0)
    C_ChatInfo.SendAddonMessage(PREFIX, msg, channel, target)
end

function lib.RequestKeystoneDataFromParty()
    if IsInGroup() and not IsInRaid() then
        C_ChatInfo.SendAddonMessage(PREFIX, REQUEST_PREFIX, "PARTY")
        sendData("PARTY")
        return true
    end
    return false
end

function lib.WipeKeystoneData()
    wipe(lib.data)
    lib.UpdateOwnKeystone()
    trigger("KeystoneUpdate", UnitName("player"), lib.data[UnitName("player")], lib.data)
end

function lib.UpdateOwnKeystone()
    local level = C_MythicPlus.GetOwnedKeystoneLevel() or 0
    local mapID = C_MythicPlus.GetOwnedKeystoneMapID() or 0
    local challengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID and C_MythicPlus.GetOwnedKeystoneChallengeMapID() or mapID
    lib.data[UnitName("player")] = {
        level = level,
        mapID = mapID,
        challengeMapID = challengeMapID,
    }
end

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, channel, sender = ...
        if prefix ~= PREFIX then return end
        if msg == REQUEST_PREFIX then
            sendData("PARTY")
        elseif msg:sub(1,2) == DATA_PREFIX .. "," then
            local level, mapID, challengeMapID = msg:match(DATA_PREFIX .. ",(%%d+),(%%d+),(%%d+)")
            level = tonumber(level) or 0
            mapID = tonumber(mapID) or 0
            challengeMapID = tonumber(challengeMapID) or 0
            lib.data[sender] = {
                level = level,
                mapID = mapID,
                challengeMapID = challengeMapID,
            }
            trigger("KeystoneUpdate", sender, lib.data[sender], lib.data)
        end
    else
        lib.UpdateOwnKeystone()
        trigger("KeystoneUpdate", UnitName("player"), lib.data[UnitName("player")], lib.data)
    end
end)

eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
