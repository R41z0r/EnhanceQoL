local addonName, addon = ...
_G[addonName] = addon
addon.saveVariables = {} -- Cross-Module variables for DB Save

addon.variables = {}
addon.variables.numOfTabs = 0
addon.L = {} -- Language

addon.variables.itemSlots = {
    [1] = CharacterHeadSlot,
    [2] = CharacterNeckSlot,
    [3] = CharacterShoulderSlot,
    [15] = CharacterBackSlot,
    [5] = CharacterChestSlot,
    [9] = CharacterWristSlot,
    [10] = CharacterHandsSlot,
    [6] = CharacterWaistSlot,
    [7] = CharacterLegsSlot,
    [8] = CharacterFeetSlot,
    [11] = CharacterFinger0Slot,
    [12] = CharacterFinger1Slot,
    [13] = CharacterTrinket0Slot,
    [14] = CharacterTrinket1Slot,
    [16] = CharacterMainHandSlot,
    [17] = CharacterSecondaryHandSlot
}

addon.variables.itemSlotSide = { -- 0 = left, 1 = right, 2 = bottom (Weapons)
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [15] = 0,
    [5] = 0,
    [9] = 0,
    [10] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [11] = 1,
    [12] = 1,
    [13] = 1,
    [14] = 1,
    [16] = 2,
    [17] = 2
}

addon.variables.socketTextures = {
    ["EMPTY_SOCKET_RED"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Red",
    ["EMPTY_SOCKET_BLUE"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Blue",
    ["EMPTY_SOCKET_YELLOW"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Yellow",
    ["EMPTY_SOCKET_PRISMATIC"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic",
    ["EMPTY_SOCKET_META"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Meta",
    ["EMPTY_SOCKET_TINKER"] = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Tinker"
}
