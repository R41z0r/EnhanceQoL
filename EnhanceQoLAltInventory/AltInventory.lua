local addonName, addon = ...
if not addon then addon = _G["EnhanceQoL"] end

-- Module table
local AltInventory = addon.AltInventory or {}
addon.AltInventory = AltInventory

local function update()
	if not addon.db.altInventory then addon.db.altInventory = {} end

	local guid = UnitGUID("player")
	if not guid then return end

	local data = {}

	local function scanBag(bag)
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.stackCount and info.stackCount > 0 then
				local link = C_Container.GetContainerItemLink(bag, slot)
				if link then data[link] = (data[link] or 0) + info.stackCount end
			end
		end
	end

	-- bags
	for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		scanBag(bag)
	end

	-- bank
	scanBag(BANK_CONTAINER)
	for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		scanBag(bag)
	end

	if IsReagentBankUnlocked() then scanBag(REAGENTBANK_CONTAINER) end

	addon.db.altInventory[guid] = data
end

local eventHandlers = {
	PLAYER_ENTERING_WORLD = update,
	BAG_UPDATE_DELAYED = update,
	BANKFRAME_CLOSED = update,
}

local frame = CreateFrame("Frame")
for e in pairs(eventHandlers) do
	frame:RegisterEvent(e)
end
frame:SetScript("OnEvent", function(_, event) eventHandlers[event]() end)
