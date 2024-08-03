local parentAddonName = "Raizor"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

addon.Drinks = {}
addon.Drinks.filteredDrinks = {} --Used for the filtered List later
addon.LDrinkMacro = {} --Locales for drink macro

function addon.functions.newItem(id, name)
    local self = {}

    self.id = id
    self.name = name

    local function setName()
        local itemInfoName = GetItemInfo(self.id)
        if itemInfoName ~= nil then
            self.name = itemInfoName
        end
    end

    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getCount()
        return GetItemCount(self.id, false, false)
    end

    return self
end
