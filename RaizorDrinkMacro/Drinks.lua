local parentAddonName = "Raizor"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local function newItem(id, name)
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

function addon.updateAllowedDrinks()
    local playerLevel = UnitLevel("Player")
    local mana = UnitPowerMax("player", 0)
    addon.Drinks = {}
    addon.Drinks.filteredDrinks = {} --Used for the filtered List later

    addon.Drinks.drinkList = {
        --Dragonflight
        { key = "ConjuredManaBun", id = 113509, desc = "Conjured Mana Bun", requiredLevel = 40, mana = 100000000 }, --fake the mana value to be always on top because it does 100%
        { key = "AzureLeywine", id = 194684, desc = "Azure Leywine", requiredLevel = 70, mana = 375000 },
        { key = "EmeraldGreenApple", id = 201469, desc = "Emerald Green Apple", requiredLevel = 70, mana = 240000 },
        { key = "DeliciousDragonSpittle", id = 197771, desc = "Delicious Dragon Spittle", requiredLevel = 70, mana = 428571 },
        { key = "StrongSniffinSoupForNiffen", id = 204790, desc = "Strong Sniffin Soup for Niffen", requiredLevel = 70, mana = 240000 },
        { key = "HoneySnack", id = 198356, desc = "HoneySnack", requiredLevel = 70, mana = 240000 },
        { key = "GorlocFinSoup", id = 197847, desc = "Gorloc Fin Soup", requiredLevel = 70, mana = 240000 },
        { key = "DragonspringWater", id = 194685, desc = "Dragonspring Water", requiredLevel = 70, mana = 375000 },
        { key = "Buttermilk", id = 194683, desc = "Buttermilk", requiredLevel = 70, mana = 375000 },
        { key = "BeetleJuice", id = 205794, desc = "Beetle Juice", requiredLevel = 70, mana = 375000 },
        { key = "FreshlySqueezedMosswater", id = 204729, desc = "Freshly Squeezed Mosswater", requiredLevel = 70, mana = 375000 },
    }

    table.sort(addon.Drinks.drinkList, function(a, b)
        return a.mana > b.mana
    end)

    for _, drink in ipairs(addon.Drinks.drinkList) do
        if (drink.requiredLevel >= 0 and drink.requiredLevel <= playerLevel) then
            table.insert(addon.Drinks.filteredDrinks, newItem(drink.id, drink.desc))
        end
    end
end

addon.updateAllowedDrinks()