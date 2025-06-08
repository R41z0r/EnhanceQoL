local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
addon = _G[parentAddonName]
else
error(parentAddonName .. " is not loaded")
end

local IgnoreList = addon.IgnoreList or {}

StaticPopupDialogs["EQOL_ADD_IGNORE_NOTE"] = {
text = IGNORE .. " %s",
button1 = ACCEPT,
button2 = CANCEL,
hasEditBox = true,
timeout = 0,
whileDead = true,
hideOnEscape = true,
preferredIndex = 3,
OnShow = function(self, data)
self.editBox:SetText("")
self.editBox:SetFocus()
self.data = data
end,
OnAccept = function(self)
if IgnoreList and IgnoreList.performAdd then
IgnoreList.performAdd(self.data, self.editBox:GetText())
end
end,
}

StaticPopupDialogs["EQOL_IGNORELIST_GROUP"] = {
text = "Ignored players in group:\n%s",
button1 = OKAY,
timeout = 0,
whileDead = true,
hideOnEscape = true,
preferredIndex = 3,
}
