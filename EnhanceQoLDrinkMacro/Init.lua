local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

addon.Drinks = {}
addon.Drinks.filteredDrinks = {} -- Used for the filtered List later
addon.LDrinkMacro = {} -- Locales for drink macro

function addon.functions.newItem(id, name, isSpell)
    local self = {}

    self.id = id
    self.name = name
    self.isSpell = isSpell

    local function setName()
        local itemInfoName = C_Item.GetItemInfo(self.id)
        if itemInfoName ~= nil then self.name = itemInfoName end
    end

    function self.getId() 
        if self.isSpell then return C_Spell.GetSpellName(self.id) end
        return "item:" .. self.id
     end

    function self.getName() return self.name end

    function self.getCount()
        if self.isSpell then return 1 end
        return C_Item.GetItemCount(self.id, false, false)
    end

    return self
end
