local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LVendor

local frameLoad = CreateFrame("Frame")

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Vendor"])
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

local function sellItems(items)
    local function sellNextItem()
        if not MerchantFrame:IsShown() then
            print(L["MerchantWindowClosed"])
            return
        end
        if #items == 0 then
            -- print("Finished selling items.")
            return
        end

        local item = table.remove(items, 1)
        C_Container.UseContainerItem(item.bag, item.slot)
        C_Timer.After(0.1, sellNextItem) -- 100ms Pause zwischen den Verkäufen
    end

    sellNextItem()
end

local function checkItem()
    local _, avgItemLevelEquipped = GetAverageItemLevel()
    local itemsToSell = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            containerInfo = C_Container.GetContainerItemInfo(bag, slot)
            if containerInfo and addon.Vendor.variables.itemQualityFilter[containerInfo.quality] then
                local effectiveILvl = GetDetailedItemLevelInfo(containerInfo.hyperlink) -- item level of the item with all upgrades calculated
                local itemName, itemLink, _, itemLevel, _, _, _, _, _, _, sellPrice, classID, subclassID, bindType,
                    expansionID = C_Item.GetItemInfo(containerInfo.itemID)
                if sellPrice > 0 and addon.Vendor.variables.itemTypeFilter[classID] and
                    addon.Vendor.variables.itemBindTypeQualityFilter[containerInfo.quality][bindType] then -- Check if classID is allowed for AutoSell
                    if effectiveILvl <=
                        (avgItemLevelEquipped -
                            addon.db["vendor" .. addon.Vendor.variables.tabNames[containerInfo.quality] .. "MinIlvlDif"]) then
                        table.insert(itemsToSell, {
                            bag = bag,
                            slot = slot
                        })
                    end
                end
            end
        end
    end
    if #itemsToSell > 0 then
        C_Timer.After(0.1, function()
            sellItems(itemsToSell)
        end)
    end
end

local function hideElements(elements, value)
    for _, element in pairs(elements) do
        if value then
            element:Show()
        else
            element:Hide()
        end
    end
end

local hideList = {}

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    hideList[value] = {}

    local tabFrame = addon.Vendor.functions.createTabFrame(ITEM_QUALITY_COLORS[key].hex ..
                                                               _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r", frame)

    local labelHeadline = addon.functions.createLabel(tabFrame, L["labelItemQuality" .. value .. "line"], 0, -10, "TOP",
        "TOP")

    local vendorEnable = addon.functions.createCheckbox("vendor" .. value .. "Enable", tabFrame,
        L["vendor" .. value .. "Enable"], 10, (addon.functions.getHeightOffset(labelHeadline) - 15))

    vendorEnable:SetScript("OnClick", function(self)
        addon.db["vendor" .. value .. "Enable"] = self:GetChecked()
        hideElements(hideList[value], self:GetChecked())
        addon.Vendor.variables.itemQualityFilter[key] = self:GetChecked()
    end)

    local vendorIlvl = addon.functions.createSlider("vendor" .. value .. "MinIlvlDif", tabFrame, L["vendorMinIlvlDif"],
        15, (addon.functions.getHeightOffset(vendorEnable) - 30), addon.db["vendor" .. value .. "MinIlvlDif"], 1, 600,
        "")

    local vendorIgnoreBoE = addon.functions.createCheckbox("vendor" .. value .. "IgnoreBoE", tabFrame,
        L["vendorIgnoreBoE"], 10, (addon.functions.getHeightOffset(vendorIlvl) - 25))
    vendorIgnoreBoE:SetScript("OnClick", function(self)
        addon.db["vendor" .. value .. "IgnoreBoE"] = self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][2] = not self:GetChecked()
    end)

    local vendorIgnoreWarbound = addon.functions.createCheckbox("vendor" .. value .. "IgnoreWarbound", tabFrame,
        L["vendorIgnoreWarbound"], 10, (addon.functions.getHeightOffset(vendorIgnoreBoE) - 5))
    vendorIgnoreWarbound:SetScript("OnClick", function(self)
        addon.db["vendor" .. value .. "IgnoreWarbound"] = self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][8] = not self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][9] = not self:GetChecked()
    end)

    table.insert(hideList[value], vendorIlvl)
    table.insert(hideList[value], vendorIgnoreBoE)
    table.insert(hideList[value], vendorIgnoreWarbound)

    hideElements(hideList[value], addon.db["vendor" .. value .. "Enable"])
end

------Event Handler
local function eventHandler(self, event, arg1)

    if event == "MERCHANT_SHOW" then
        if IsShiftKeyDown() then
            return
        end

        checkItem()
    end
end

frameLoad:RegisterEvent("MERCHANT_SHOW")

frameLoad:SetScript("OnEvent", eventHandler)

-- hideElements(hideListUncommon, addon.db["vendorUncommonEnable"])
-- Bigger frame for all Options
addon.frame:SetSize(500, 550)
