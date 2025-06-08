local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
addon = _G[parentAddonName]
else
error(parentAddonName .. " is not loaded")
end

local IgnoreList = addon.IgnoreList or {}
addon.IgnoreList = IgnoreList
EnhanceQoL_IgnoreDB = EnhanceQoL_IgnoreDB or {}

local function normalize(name)
if not name then return end
name = name:gsub("%s", "")
if not name:find("-") then
local realm = GetNormalizedRealmName()
if realm then name = name .. "-" .. realm end
end
return name:lower()
end

local function addEntry(name, note)
EnhanceQoL_IgnoreDB[name] = {
name = name,
faction = UnitFactionGroup("player"),
time = time(),
note = note,
}
end

local function removeEntry(name)
EnhanceQoL_IgnoreDB[name] = nil
end

function IgnoreList:IsIgnored(name)
name = normalize(name)
return name and EnhanceQoL_IgnoreDB[name]
end

IgnoreList.origAdd = C_FriendList.AddIgnore or AddIgnore
IgnoreList.origDel = C_FriendList.DelIgnore or DelIgnore
IgnoreList.origToggle = C_FriendList.AddOrDelIgnore or AddOrDelIgnore
local maxSize = C_FriendList.GetMaxNumIgnored and C_FriendList.GetMaxNumIgnored() or 50

local function performAdd(name, note)
name = normalize(name)
if not name then return end
addEntry(name, note)
if C_FriendList.GetNumIgnores and C_FriendList.GetNumIgnores() < maxSize then
if IgnoreList.origAdd then IgnoreList.origAdd(name) end
end
end

IgnoreList.performAdd = performAdd
function IgnoreList:AddIgnore(name)
StaticPopup_Show("EQOL_ADD_IGNORE_NOTE", nil, nil, name)
end

function IgnoreList:DelIgnore(name)
name = normalize(name)
if not name then return end
removeEntry(name)
if IgnoreList.origDel then IgnoreList.origDel(name) end
end

function IgnoreList:AddOrDelIgnore(name)
if self:IsIgnored(name) then
self:DelIgnore(name)
else
self:AddIgnore(name)
end
end


local shown = {}
local frame = CreateFrame("Frame")
local function checkGroup()
local members = {}
local prefix = IsInRaid() and "raid" or "party"
for i = 1, GetNumGroupMembers() do
local unit = prefix .. i
local n = GetUnitName(unit, true)
n = normalize(n)
if n and IgnoreList:IsIgnored(n) and not shown[n] then
shown[n] = true
table.insert(members, n)
end
end
if #members > 0 then
StaticPopup_Show("EQOL_IGNORELIST_GROUP", table.concat(members, ", "))
end
end

frame:SetScript("OnEvent", function(_, event)
if event == "GROUP_JOINED" then
wipe(shown)
checkGroup()
elseif event == "GROUP_ROSTER_UPDATE" then
checkGroup()
end
end)
frame:RegisterEvent("GROUP_JOINED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")


local function whisperFilter(_, _, _, sender)
if IgnoreList:IsIgnored(sender) then return true end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whisperFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", whisperFilter)

if addon.ChatIM and addon.ChatIM.AddMessage then
local orig = addon.ChatIM.AddMessage
function addon.ChatIM:AddMessage(partner, text, outbound, isBN, bnetID)
if not outbound and IgnoreList:IsIgnored(partner) then return end
orig(self, partner, text, outbound, isBN, bnetID)
end
end

C_FriendList.AddIgnore = function(name) IgnoreList:AddIgnore(name) end
C_FriendList.DelIgnore = function(name) IgnoreList:DelIgnore(name) end
C_FriendList.AddOrDelIgnore = function(name) IgnoreList:AddOrDelIgnore(name) end

if AddIgnore then AddIgnore = C_FriendList.AddIgnore end
if DelIgnore then DelIgnore = C_FriendList.DelIgnore end
if AddOrDelIgnore then AddOrDelIgnore = C_FriendList.AddOrDelIgnore end
