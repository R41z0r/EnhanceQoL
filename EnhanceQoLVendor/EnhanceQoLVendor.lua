local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = addon.LVendor

local frameLoad = CreateFrame("Frame")

local function updateLegend(value, value2)
    if not addon.frame:IsShown() then
        return
    end
    local text = {}
    if addon.db["vendor" .. value .. "IgnoreWarbound"] then
        table.insert(text, L["vendorIgnoreWarbound"])
    end
    if addon.db["vendor" .. value .. "IgnoreBoE"] then
        table.insert(text, L["vendorIgnoreBoE"])
    end
    if addon.db["vendor" .. value .. "IgnoreUpgradable"] then
        table.insert(text, L["vendorIgnoreUpgradable"])
    end

    addon.Vendor.variables["labelExplained" .. value .. "line"]:SetText(string.format(
        L["labelExplained" .. value .. "line"], (addon.Vendor.variables.avgItemLevelEquipped - value2),
        table.concat(text, '\n')))
end

-- Extend the option menu
local frame = addon.functions.createTabFrame(L["Vendor"])
frame.tabs = {}
frame:SetScript("OnSizeChanged", function(self, width, height)
    for i, tab in ipairs(frame.tabs) do
        tab:SetSize(width - 5, height - 35)
    end
end)
function frame:ShowTab(id)
    local _, avgItemLevelEquipped = GetAverageItemLevel()
    addon.Vendor.variables.avgItemLevelEquipped = avgItemLevelEquipped
    for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
        local value = addon.Vendor.variables.tabNames[key]
        updateLegend(value, addon.db["vendor" .. value .. "MinIlvlDif"])
    end
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
    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            containerInfo = C_Container.GetContainerItemInfo(bag, slot)
            if containerInfo then
                -- check if cosmetic
                local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(containerInfo.itemID)

                if classID == 4 and subclassID == 5 and not C_TransmogCollection.PlayerHasTransmog(containerInfo.itemID) then
                    -- Transmog not used don't sell
                elseif addon.db["vendorExcludeSellList"][containerInfo.itemID] then -- ignore everything and exclude in sell
                    -- do nothing
                elseif addon.db["vendorIncludeSellList"][containerInfo.itemID] then -- ignore everything and include in sell
                    local itemName, itemLink, _, itemLevel, _, _, _, _, _, _, sellPrice, classID, subclassID, bindType,
                        expansionID = C_Item.GetItemInfo(containerInfo.itemID)
                    if sellPrice > 0 then
                        table.insert(itemsToSell, {
                            bag = bag,
                            slot = slot
                        })
                    end
                elseif addon.Vendor.variables.itemQualityFilter[containerInfo.quality] then
                    local effectiveILvl = C_Item.GetDetailedItemLevelInfo(containerInfo.hyperlink) -- item level of the item with all upgrades calculated
                    local itemName, itemLink, _, itemLevel, _, _, _, _, _, _, sellPrice, classID, subclassID, bindType,
                        expansionID = C_Item.GetItemInfo(containerInfo.itemID)

                    if sellPrice > 0 and addon.Vendor.variables.itemTypeFilter[classID] and
                        (not addon.Vendor.variables.itemSubTypeFilter[classID] or
                            (addon.Vendor.variables.itemSubTypeFilter[classID] and
                                addon.Vendor.variables.itemSubTypeFilter[classID][subclassID])) and
                        addon.Vendor.variables.itemBindTypeQualityFilter[containerInfo.quality][bindType] then -- Check if classID is allowed for AutoSell

                        local canUpgrade = false
                        if addon.db["vendor" .. addon.Vendor.variables.tabNames[containerInfo.quality] ..
                            "IgnoreUpgradable"] then
                            local eItem = Item:CreateFromBagAndSlot(bag, slot)
                            local link = eItem:GetItemLink()
                            local tooltip = CreateFrame("GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate")
                            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                            tooltip:SetHyperlink(link)
                            for i = 1, tooltip:NumLines() do
                                local line = _G["ScanTooltipTextLeft" .. i]:GetText()
                                if line then
                                    local upgrade = strmatch(line, addon.Vendor.variables.upgradePattern)
                                    if upgrade then
                                        local r, g, b = _G["ScanTooltipTextLeft" .. i]:GetTextColor()
                                        if not (r > 0.5 and g > 0.5 and b > 0.5) then -- gray upgrade text = old item upgradable --> not = ignore gray
                                            canUpgrade = true
                                        end
                                        break
                                    end
                                end
                            end
                        end

                        if not canUpgrade then
                            if effectiveILvl <=
                                (avgItemLevelEquipped -
                                    addon.db["vendor" .. addon.Vendor.variables.tabNames[containerInfo.quality] ..
                                        "MinIlvlDif"]) then
                                table.insert(itemsToSell, {
                                    bag = bag,
                                    slot = slot
                                })
                            end
                        end
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
    vendorIlvl:SetScript("OnValueChanged", function(self, value2)
        value2 = math.floor(value2)
        _G[self:GetName() .. 'Text']:SetText(L["vendorMinIlvlDif"] .. ': ' .. value2)
        addon.db["vendor" .. value .. "MinIlvlDif"] = value2
        updateLegend(value, value2)
    end)

    local vendorIgnoreBoE = addon.functions.createCheckbox("vendor" .. value .. "IgnoreBoE", tabFrame,
        L["vendorIgnoreBoE"], 10, (addon.functions.getHeightOffset(vendorIlvl) - 25))
    vendorIgnoreBoE:SetScript("OnClick", function(self)
        addon.db["vendor" .. value .. "IgnoreBoE"] = self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][2] = not self:GetChecked()
        updateLegend(value, addon.db["vendor" .. value .. "MinIlvlDif"])
    end)

    local vendorIgnoreWarbound = addon.functions.createCheckbox("vendor" .. value .. "IgnoreWarbound", tabFrame,
        L["vendorIgnoreWarbound"], 10, (addon.functions.getHeightOffset(vendorIgnoreBoE) - 5))
    vendorIgnoreWarbound:SetScript("OnClick", function(self)
        addon.db["vendor" .. value .. "IgnoreWarbound"] = self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][8] = not self:GetChecked()
        addon.Vendor.variables.itemBindTypeQualityFilter[key][9] = not self:GetChecked()
        updateLegend(value, addon.db["vendor" .. value .. "MinIlvlDif"])
    end)

    local vendorIgnoreUpgradable
    if key ~= 1 then
        vendorIgnoreUpgradable = addon.functions.createCheckbox("vendor" .. value .. "IgnoreUpgradable", tabFrame,
            L["vendorIgnoreUpgradable"], 10, (addon.functions.getHeightOffset(vendorIgnoreWarbound) - 5))
        vendorIgnoreUpgradable:SetScript("OnClick", function(self)
            addon.db["vendor" .. value .. "IgnoreUpgradable"] = self:GetChecked()
            updateLegend(value, addon.db["vendor" .. value .. "MinIlvlDif"])
        end)
    end
    local text = {}
    if addon.db["vendor" .. value .. "IgnoreWarbound"] then
        table.insert(text, L["vendorIgnoreWarbound"])
    end
    if addon.db["vendor" .. value .. "IgnoreBoE"] then
        table.insert(text, L["vendorIgnoreBoE"])
    end
    if addon.db["vendor" .. value .. "IgnoreUpgradable"] then
        table.insert(text, L["vendorIgnoreUpgradable"])
    end

    local labelExplanation = addon.functions.createLabel(tabFrame,
        string.format(L["labelExplained" .. value .. "line"],
            (addon.Vendor.variables.avgItemLevelEquipped - addon.db["vendor" .. value .. "MinIlvlDif"]),
            table.concat(text, ' and ')), 0, 20, "BOTTOM", "BOTTOM")
    addon.Vendor.variables["labelExplained" .. value .. "line"] = labelExplanation

    table.insert(hideList[value], vendorIlvl)
    table.insert(hideList[value], vendorIgnoreBoE)
    table.insert(hideList[value], vendorIgnoreWarbound)
    table.insert(hideList[value], labelExplanation)
    if key ~= 1 then
        table.insert(hideList[value], vendorIgnoreUpgradable)
    end
    hideElements(hideList[value], addon.db["vendor" .. value .. "Enable"])
end

-- Include List
local tabFrame = addon.Vendor.functions.createTabFrame(L["Include"], frame)

local labelHeadline = addon.functions.createLabel(tabFrame, L["vendorAddItemToInclude"], 0, -10, "TOP", "TOP")

local tInclude = {}
local dropIncludeList, btnRemoveInclude

for id, name in pairs(addon.db["vendorIncludeSellList"]) do
    table.insert(tInclude, {
        value = id,
        text = name
    })
end

local txtInclude = addon.Vendor.functions.createEditBox(tabFrame, 20,
    addon.functions.getHeightOffset(labelHeadline) - 10, L["Item id or drag item"])

local btnAddInclude = addon.functions.createButton(tabFrame, txtInclude:GetWidth() + 20,
    addon.functions.getHeightOffset(labelHeadline) - 7, 50, 30, L["Add"], function()
        if txtInclude:GetText() ~= "" and txtInclude:GetText() ~= L["Item id or drag item"] then
            local eItem = Item:CreateFromItemID(tonumber(txtInclude:GetText()))
            if eItem and not eItem:IsItemEmpty() then
                eItem:ContinueOnItemLoad(function()
                    if not addon.db["vendorIncludeSellList"][eItem:GetItemID()] then
                        addon.db["vendorIncludeSellList"][eItem:GetItemID()] = eItem:GetItemName()
                        addon.Vendor.functions.addDropdownItem(dropIncludeList, tInclude, {
                            text = eItem:GetItemName(),
                            value = eItem:GetItemID()
                        })
                    end
                    txtInclude:SetText(L["Item id or drag item"])
                end)
            end
        end
    end)

dropIncludeList = addon.Vendor.functions.createDropdown("IncludeVendorList", tabFrame, tInclude, 150,
    L["IncludeVendorList"], 10, addon.functions.getHeightOffset(txtInclude) - 30)

btnRemoveInclude = addon.functions.createButton(tabFrame, dropIncludeList:GetWidth(),
    addon.functions.getHeightOffset(txtInclude) - 47, 50, 30, L["Remove"], function()
        local selectedID = UIDropDownMenu_GetSelectedID(dropIncludeList)
        if selectedID then
            local selectedItem = tInclude[selectedID]
            if selectedItem then
                addon.db["vendorIncludeSellList"][selectedItem.value] = nil
                table.remove(tInclude, selectedID)
                local function Initialize(self, level)
                    local info = UIDropDownMenu_CreateInfo()
                    for i, item in ipairs(tInclude) do
                        info.text = item.text
                        info.value = item.value
                        info.checked = nil
                        info.func = function(self)
                            UIDropDownMenu_SetSelectedID(dropIncludeList, i)
                        end
                        UIDropDownMenu_AddButton(info, level)
                    end
                end

                UIDropDownMenu_Initialize(dropIncludeList, Initialize)
                UIDropDownMenu_SetText(dropIncludeList, "")
            end
        end
    end)
btnRemoveInclude:SetWidth(btnRemoveInclude:GetFontString():GetStringWidth() + 20)

-- Exclude
local tabFrameExclude = addon.Vendor.functions.createTabFrame(L["Exclude"], frame)

local labelHeadlineExclude = addon.functions.createLabel(tabFrameExclude, L["vendorAddItemToExclude"], 0, -10, "TOP",
    "TOP")

local tExclude = {}
local dropExcludeList, btnRemoveExclude

for id, name in pairs(addon.db["vendorExcludeSellList"]) do
    table.insert(tExclude, {
        value = id,
        text = name
    })
end

local txtExclude = addon.Vendor.functions.createEditBox(tabFrameExclude, 20,
    addon.functions.getHeightOffset(labelHeadlineExclude) - 10, L["Item id or drag item"])

local btnAddExclude = addon.functions.createButton(tabFrameExclude, txtExclude:GetWidth() + 20,
    addon.functions.getHeightOffset(labelHeadlineExclude) - 7, 50, 30, L["Add"], function()
        if txtExclude:GetText() ~= "" and txtExclude:GetText() ~= L["Item id or drag item"] then
            local eItem = Item:CreateFromItemID(tonumber(txtExclude:GetText()))
            if eItem and not eItem:IsItemEmpty() then
                eItem:ContinueOnItemLoad(function()
                    if not addon.db["vendorExcludeSellList"][eItem:GetItemID()] then
                        addon.db["vendorExcludeSellList"][eItem:GetItemID()] = eItem:GetItemName()
                        addon.Vendor.functions.addDropdownItem(dropExcludeList, tExclude, {
                            text = eItem:GetItemName(),
                            value = eItem:GetItemID()
                        })
                    end
                    txtExclude:SetText(L["Item id or drag item"])
                end)
            end
        end
    end)

dropExcludeList = addon.Vendor.functions.createDropdown("ExcludeVendorList", tabFrameExclude, tExclude, 150,
    L["ExcludeVendorList"], 10, addon.functions.getHeightOffset(txtExclude) - 30)

btnRemoveExclude = addon.functions.createButton(tabFrameExclude, dropExcludeList:GetWidth(),
    addon.functions.getHeightOffset(txtExclude) - 47, 50, 30, L["Remove"], function()
        local selectedID = UIDropDownMenu_GetSelectedID(dropExcludeList)
        if selectedID then
            local selectedItem = tExclude[selectedID]
            if selectedItem then
                addon.db["vendorExcludeSellList"][selectedItem.value] = nil
                table.remove(tExclude, selectedID)
                local function Initialize(self, level)
                    local info = UIDropDownMenu_CreateInfo()
                    for i, item in ipairs(tExclude) do
                        info.text = item.text
                        info.value = item.value
                        info.checked = nil
                        info.func = function(self)
                            UIDropDownMenu_SetSelectedID(dropExcludeList, i)
                        end
                        UIDropDownMenu_AddButton(info, level)
                    end
                end

                UIDropDownMenu_Initialize(dropExcludeList, Initialize)
                UIDropDownMenu_SetText(dropExcludeList, "")
            end
        end
    end)
btnRemoveExclude:SetWidth(btnRemoveExclude:GetFontString():GetStringWidth() + 20)

------Event Handler
local function eventHandler(self, event, arg1, arg2)

    if event == "MERCHANT_SHOW" then
        if IsShiftKeyDown() then
            return
        end
        checkItem()
    elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
        local _, avgItemLevelEquipped = GetAverageItemLevel()
        addon.Vendor.variables.avgItemLevelEquipped = avgItemLevelEquipped
        for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
            local value = addon.Vendor.variables.tabNames[key]
            updateLegend(value, addon.db["vendor" .. value .. "MinIlvlDif"])
        end
    elseif event == "ITEM_DATA_LOAD_RESULT" and arg2 == false and tabFrame:IsShown() and txtInclude:GetText() ~= "" and
        txtInclude:GetText() ~= L["Item id or drag item"] then
        StaticPopupDialogs["VendorWrongItemID"] = {
            text = L["Item id does not exist"],
            button1 = "OK",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
        }
        StaticPopup_Show("VendorWrongItemID")
        txtInclude:SetText(L["Item id or drag item"])

    end
end

frameLoad:RegisterEvent("MERCHANT_SHOW")
frameLoad:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
frameLoad:RegisterEvent("ITEM_DATA_LOAD_RESULT")

frameLoad:SetScript("OnEvent", eventHandler)
