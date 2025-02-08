local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LMythicPlus

local cModeIDs
local portalSpells = {}

local portalCompendium = {
	[1] = {
		headline = EXPANSION_NAME10,
		spells = {
			[445269] = { text = "SV", cId = { [501] = true } },
			[445416] = { text = "COT", cId = { [502] = true } },
			[445414] = { text = "DAWN", cId = { [505] = true } },
			[445417] = { text = "ARAK", cId = { [503] = true } },
			[467546] = { text = "FLOOD", cId = { [525] = true } },
			[445440] = { text = "CBM", cId = { [506] = true } },
			[445444] = { text = "PSF", cId = { [499] = true } },
			[445441] = { text = "DC", cId = { [504] = true } },
			[445443] = { text = "ROOK", cId = { [500] = true } },
		},
	},
	[2] = {
		headline = EXPANSION_NAME9,
		spells = {
			[424197] = { text = "DOTI", cId = { [463] = true, [464] = true } },
			[393256] = { text = "RLP", cId = { [399] = true } },
			[393262] = { text = "NO", cId = { [400] = true } },
			[393267] = { text = "BH", cId = { [405] = true } },
			[393273] = { text = "AA", cId = { [402] = true } },
			[393276] = { text = "NELT", cId = { [404] = true } },
			[393279] = { text = "AV", cId = { [401] = true } },
			[393283] = { text = "HOI", cId = { [406] = true } },
			[393222] = { text = "ULD", cId = { [403] = true } },
			[432254] = { text = "VOTI", cId = {} },
			[432258] = { text = "AMIR", cId = {} },
			[432257] = { text = "ASC", cId = {} },
		},
	},
	[3] = {
		headline = EXPANSION_NAME8,
		spells = {
			[354462] = { text = "NW", cId = { [376] = true } },
			[354463] = { text = "PF", cId = { [379] = true } },
			[354464] = { text = "MISTS", cId = { [375] = true } },
			[354465] = { text = "HOA", cId = { [378] = true } },
			[354466] = { text = "SOA", cId = { [381] = true } },
			[354467] = { text = "TOP", cId = { [382] = true } },
			[354468] = { text = "DOS", cId = { [377] = true } },
			[354469] = { text = "SD", cId = { [380] = true } },
			[367416] = { text = "TAZA", cId = { [391] = true, [392] = true } },
			[373190] = { text = "CN", cId = {} }, -- Raids
			[373192] = { text = "SFO", cId = {} }, -- Raids
			[373191] = { text = "SOD", cId = {} }, -- Raids
		},
	},
	[4] = {
		headline = EXPANSION_NAME7,
		spells = {
			[410071] = { text = "FH", cId = { [245] = true } },
			[410074] = { text = "UR", cId = { [251] = true } },
			[373274] = { text = "MECH", cId = { [369] = true, [370] = true } },
			[424167] = { text = "WM", cId = { [248] = true } },
			[424187] = { text = "AD", cId = { [244] = true } },
			[445418] = { text = "SIEG", faction = FACTION_ALLIANCE, cId = { [353] = true } },
			[464256] = { text = "SIEG", faction = FACTION_HORDE, cId = { [353] = true } },
			[467553] = { text = "ML", faction = FACTION_ALLIANCE, cId = { [247] = true } },
			[467555] = { text = "ML", faction = FACTION_HORDE, cId = { [247] = true } },
		},
	},
	[5] = {
		headline = EXPANSION_NAME6,
		spells = {
			[424153] = { text = "BRH", cId = { [199] = true } },
			[393766] = { text = "COS", cId = { [210] = true } },
			[424163] = { text = "DHT", cId = { [198] = true } },
			[393764] = { text = "HOV", cId = { [200] = true } },
			[410078] = { text = "NL", cId = { [206] = true } },
			[373262] = { text = "KARA", cId = { [227] = true, [234] = true } },
		},
	},
	[6] = {
		headline = EXPANSION_NAME5,
		spells = {
			[159897] = { text = "AUCH", cId = { [164] = true } },
			[159895] = { text = "BSM", cId = { [163] = true } },
			[159901] = { text = "EB", cId = { [168] = true } },
			[159900] = { text = "GD", cId = { [166] = true } },
			[159896] = { text = "ID", cId = { [169] = true } },
			[159899] = { text = "SBG", cId = { [165] = true } },
			[159898] = { text = "SR", cId = { [161] = true } },
			[159902] = { text = "UBRS", cId = { [167] = true } },
		},
	},
	[7] = {
		headline = EXPANSION_NAME4,
		spells = {
			[131225] = { text = "GSS", cId = { [57] = true } },
			[131222] = { text = "MP", cId = { [60] = true } },
			[131232] = { text = "SCHO", cId = { [76] = true } },
			[131231] = { text = "SH", cId = { [77] = true } },
			[131229] = { text = "SM", cId = { [78] = true } },
			[131228] = { text = "SN", cId = { [59] = true } },
			[131206] = { text = "SPM", cId = { [58] = true } },
			[131205] = { text = "SB", cId = { [56] = true } },
			[131204] = { text = "TJS", cId = { [2] = true } },
		},
	},
	[8] = {
		headline = EXPANSION_NAME3,
		spells = { [445424] = { text = "GB", cId = { [507] = true } }, [424142] = { text = "TOTT", cId = { [456] = true } }, [410080] = { text = "VP", cId = { [438] = true } } },
	},
}

local function getCurrentSeasonPortal()
	local cModeIDs = C_ChallengeMode.GetMapTable()
	local cModeIDLookup = {}
	for _, id in ipairs(cModeIDs) do
		cModeIDLookup[id] = true
	end

	local filteredPortalSpells = {}

	for _, section in pairs(portalCompendium) do
		for spellID, data in pairs(section.spells) do
			if data.cId then
				for cId in pairs(data.cId) do
					if cModeIDLookup[cId] then
						filteredPortalSpells[spellID] = {
							text = data.text,
							iconID = data.iconID,
						}
						if data.faction then filteredPortalSpells[spellID].faction = data.faction end
						break
					end
				end
			end
		end
	end

	portalSpells = filteredPortalSpells
end
-- for _, exp in pairs(portalCompendium) do
-- 	for spellId, data in pairs(exp.spells) do
-- 		cIdMap[spellId] = { text = data.text }
-- 		if data.faction then cIdMap[spellId].faction = data.faction end
-- 		for cId, _ in pairs(data.cId) do
-- 	end
-- end

local isKnown = {}
local faction = UnitFactionGroup("player")
local parentFrame = PVEFrame
local doAfterCombat = false

local frameAnchor = CreateFrame("Frame", "DungeonTeleportFrame", parentFrame, "BackdropTemplate")
frameAnchor:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Hintergrund
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Rahmen
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frameAnchor:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz

-- Überschrift hinzufügen
local title = frameAnchor:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
local mSeasonTitle = MYTHIC_DUNGEON_SEASON
title:SetFormattedText(string.gsub(mSeasonTitle, "%s*%b()", ""))
frameAnchor:SetSize(title:GetStringWidth() + 20, 170) -- Breite x Höhe

-- Compendium
local frameAnchorCompendium = CreateFrame("Frame", "DungeonTeleportFrameCompendium", DungeonTeleportFrame, "BackdropTemplate")
frameAnchorCompendium:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Hintergrund
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Rahmen
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
frameAnchorCompendium:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz

-- Überschrift hinzufügen
local titleCompendium = frameAnchorCompendium:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleCompendium:SetPoint("TOP", 0, -10)
local mSeasonTitleCompendium = L["DungeonCompendium"]
titleCompendium:SetFormattedText(mSeasonTitleCompendium)
frameAnchorCompendium:SetSize(titleCompendium:GetStringWidth() + 20, 170) -- Breite x Höhe
frameAnchorCompendium:SetPoint("TOPLEFT", DungeonTeleportFrame, "TOPRIGHT", 0, 0)

local activeBars = {}
addon.MythicPlus.portalFrame = frameAnchor

local buttonSize = 30
local spacing = 20
local spacingCompendium = 10
local hSpacing = 30
local hSpacingCompendium = 10

local function CreatePortalButtonsWithCooldown(frame, spells)
	-- Entferne alle bestehenden Buttons
	for _, button in pairs(frame.buttons or {}) do
		button:Hide()
		button:ClearAllPoints()
	end
	frame.buttons = {}

	-- Sortiere und filtere die bekannten Spells
	local sortedSpells = {}
	for spellID, data in pairs(spells) do
		local known = IsSpellKnown(spellID)
		if (not data.faction or data.faction == faction) and (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known)) then
			table.insert(sortedSpells, { spellID = spellID, text = data.text, iconID = data.iconID, isKnown = known })
		end
	end

	-- Sortiere alphabetisch nach Text
	table.sort(sortedSpells, function(a, b) return a.text < b.text end)

	-- Berechne dynamische Anzahl der Buttons
	local totalButtons = #sortedSpells
	local buttonsPerRow = math.ceil(totalButtons / 2)
	local totalButtonWidth = (buttonSize * buttonsPerRow) + (spacing * (buttonsPerRow - 1))
	local frameWidth = math.max(totalButtonWidth + 40, title:GetStringWidth() + 20)
	local initialSpacing = math.max(0, (frameWidth - totalButtonWidth) / 2)

	-- Dynamische Höhe
	local rows = math.ceil(totalButtons / buttonsPerRow)
	local frameHeight = math.max(title:GetStringHeight() + 20, 40 + rows * (buttonSize + hSpacing))
	frame:SetSize(frameWidth, frameHeight)

	-- Erstelle neue Buttons
	local index = 1
	for _, spellData in ipairs(sortedSpells) do
		local spellID = spellData.spellID
		local spellInfo = C_Spell.GetSpellInfo(spellID)

		if spellInfo then
			-- Button erstellen
			local button = CreateFrame("Button", "PortalButton" .. index, frame, "SecureActionButtonTemplate")
			button:SetSize(buttonSize, buttonSize)
			button.spellID = spellID

			-- Hintergrund
			local bg = button:CreateTexture(nil, "BACKGROUND")
			bg:SetAllPoints(button)
			bg:SetColorTexture(0, 0, 0, 0.8)

			-- Rahmen
			local border = button:CreateTexture(nil, "BORDER")
			border:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
			border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
			border:SetColorTexture(1, 1, 1, 1)

			-- Highlight/Glow-Effekt bei Mouseover
			local highlight = button:CreateTexture(nil, "HIGHLIGHT")
			highlight:SetAllPoints(button)
			highlight:SetColorTexture(1, 1, 0, 0.4) -- Gelber Glow mit 30% Transparenz
			button:SetHighlightTexture(highlight)

			-- Positionierung
			local row = math.ceil(index / buttonsPerRow) - 1
			local col = (index - 1) % buttonsPerRow
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", initialSpacing + col * (buttonSize + spacing), -40 - row * (buttonSize + hSpacing))

			-- Icon
			local icon = button:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints(button)
			icon:SetTexture(spellInfo.iconID or "Interface\\ICONS\\INV_Misc_QuestionMark")
			button.icon = icon

			-- Überprüfen, ob der Zauber bekannt ist
			if not spellData.isKnown then
				icon:SetDesaturated(true) -- Macht das Icon grau/schwarzweiß
				icon:SetAlpha(0.5) -- Optional: Reduziert die Sichtbarkeit
				button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
			else
				isKnown[spellID] = true
				icon:SetDesaturated(false)
				icon:SetAlpha(1) -- Normale Sichtbarkeit
				button:EnableMouse(true) -- Aktiviert Klicks
			end

			-- Cooldown-Spirale
			button.cooldownFrame = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
			button.cooldownFrame:SetAllPoints(button)

			-- Sichere Aktion (CastSpell)
			button:SetAttribute("type", "spell")
			button:SetAttribute("spell", spellID)
			button:RegisterForClicks("AnyUp", "AnyDown")

			-- Text und Tooltip
			local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("TOP", button, "BOTTOM", 0, -2)
			label:SetText(spellData.text)

			button:SetScript("OnEnter", function(self)
				if addon.db["portalShowTooltip"] then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetSpellByID(spellID)
					GameTooltip:Show()
				end
			end)
			button:SetScript("OnLeave", function() GameTooltip:Hide() end)

			-- Button speichern
			table.insert(frame.buttons, button)
			index = index + 1
		end
	end
end

local function CreatePortalCompendium(frame, compendium)
	-- Entferne alle bestehenden Elemente
	for _, button in pairs(frame.buttons or {}) do
		button:Hide()
		button:ClearAllPoints()
	end
	for _, headline in pairs(frame.headline or {}) do
		headline:Hide()
		headline:ClearAllPoints()
	end
	frame.buttons = {}
	frame.headline = {}

	-- Initiale Position
	local currentYOffset = 0 - titleCompendium:GetStringHeight() - 20 -- Startabstand vom oberen Rand
	local maxWidth = titleCompendium:GetStringWidth() + 20

	-- Durchlaufe die Reihenfolge in `compendium`
	for _, section in ipairs(compendium) do
		local sortedSpells = {}
		for spellID, data in pairs(section.spells) do
			local known = IsSpellKnown(spellID)
			if
				(not data.faction or data.faction == faction)
				and (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known))
				and (not addon.db["hideActualSeason"] or not portalSpells[spellID])
			then
				table.insert(sortedSpells, { spellID = spellID, text = data.text, iconID = data.iconID, isKnown = known })
			end
		end
		table.sort(sortedSpells, function(a, b) return a.text < b.text end)

		if #sortedSpells > 0 then
			-- Überschrift (Headline)
			local headline = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			headline:SetPoint("TOP", frame, "TOP", 0, currentYOffset)
			headline:SetText(section.headline)
			currentYOffset = currentYOffset - headline:GetStringHeight() - 10 -- Abstand für Buttons
			table.insert(frame.headline, headline)
		end

		-- Buttons generieren
		local buttonsPerRow = math.max(1, math.ceil(#sortedSpells))
		local totalButtonWidth = (buttonSize * buttonsPerRow) + (spacingCompendium * (buttonsPerRow - 1))
		maxWidth = math.max(maxWidth, totalButtonWidth + 20)

		local index = 0
		for _, spellData in ipairs(sortedSpells) do
			local spellID = spellData.spellID
			local spellInfo = C_Spell.GetSpellInfo(spellID)

			if spellInfo then
				local row = math.floor(index / buttonsPerRow)
				local col = index % buttonsPerRow

				-- Button erstellen
				local button = CreateFrame("Button", "CompendiumButton" .. index, frame, "SecureActionButtonTemplate")
				button:SetSize(buttonSize, buttonSize)
				button:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col * (buttonSize + spacingCompendium), currentYOffset - row * (buttonSize + hSpacingCompendium))
				button.spellID = spellID

				-- Hintergrund
				local bg = button:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints(button)
				bg:SetColorTexture(0, 0, 0, 0.8)

				-- Rahmen
				local border = button:CreateTexture(nil, "BORDER")
				border:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
				border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
				border:SetColorTexture(1, 1, 1, 1)

				-- Highlight/Glow-Effekt
				local highlight = button:CreateTexture(nil, "HIGHLIGHT")
				highlight:SetAllPoints(button)
				highlight:SetColorTexture(1, 1, 0, 0.4)
				button:SetHighlightTexture(highlight)

				-- Icon
				local icon = button:CreateTexture(nil, "ARTWORK")
				icon:SetAllPoints(button)
				icon:SetTexture(spellInfo.iconID or "Interface\\ICONS\\INV_Misc_QuestionMark")
				button.icon = icon

				-- Überprüfen, ob der Zauber bekannt ist
				if not spellData.isKnown then
					icon:SetDesaturated(true) -- Macht das Icon grau/schwarzweiß
					icon:SetAlpha(0.5) -- Optional: Reduziert die Sichtbarkeit
					button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
				else
					isKnown[spellID] = true
					icon:SetDesaturated(false)
					icon:SetAlpha(1) -- Normale Sichtbarkeit
					button:EnableMouse(true) -- Aktiviert Klicks
				end

				-- Cooldown-Spirale
				button.cooldownFrame = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
				button.cooldownFrame:SetAllPoints(button)

				-- Sichere Aktion (CastSpell)
				button:SetAttribute("type", "spell")
				button:SetAttribute("spell", spellID)
				button:RegisterForClicks("AnyUp", "AnyDown")

				-- Text und Tooltip
				local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				label:SetPoint("TOP", button, "BOTTOM", 0, -2)
				label:SetText(spellData.text)

				-- Tooltip
				button:SetScript("OnEnter", function(self)
					if addon.db["portalShowTooltip"] then
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetSpellByID(spellID)
						GameTooltip:Show()
					end
				end)
				button:SetScript("OnLeave", function() GameTooltip:Hide() end)

				table.insert(frame.buttons, button)
				index = index + 1
			end
		end
		-- Höhe für die nächste Sektion berechnen
		local rows = math.ceil(#sortedSpells / buttonsPerRow)
		currentYOffset = currentYOffset - rows * (buttonSize + hSpacingCompendium + 10)
	end

	-- Frame-Größe dynamisch anpassen
	frame:SetSize(maxWidth, max(math.abs(currentYOffset) + 20, titleCompendium:GetStringHeight() + 20))
end

local function checkCooldown()
	CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
	CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
	for _, button in pairs(frameAnchor.buttons or {}) do
		if isKnown[button.spellID] then
			local cooldownData = C_Spell.GetSpellCooldown(button.spellID)
			if cooldownData and cooldownData.isEnabled then
				button.cooldownFrame:SetCooldown(cooldownData.startTime, cooldownData.duration, cooldownData.modRate)
			else
				button.cooldownFrame:SetCooldown(0, 0)
			end
		end
	end

	for _, button in pairs(frameAnchorCompendium.buttons or {}) do
		if isKnown[button.spellID] then
			local cooldownData = C_Spell.GetSpellCooldown(button.spellID)
			if cooldownData and cooldownData.isEnabled then
				button.cooldownFrame:SetCooldown(cooldownData.startTime, cooldownData.duration, cooldownData.modRate)
			else
				button.cooldownFrame:SetCooldown(0, 0)
			end
		end
	end
end

local function waitCooldown(arg3)
	C_Timer.After(0.1, function()
		local cooldownData = C_Spell.GetSpellCooldown(arg3)
		if cooldownData.duration > 0 then
			checkCooldown()
		else
			waitCooldown(arg3)
		end
	end)
end

function addon.MythicPlus.functions.toggleFrame()
	if InCombatLockdown() then
		doAfterCombat = true
	else
		if addon.db["teleportFrame"] == true then
			doAfterCombat = false
			if not frameAnchor:IsShown() then frameAnchor:Show() end
			if #portalSpells == 0 then getCurrentSeasonPortal() end
			CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
			if addon.db["teleportsEnableCompendium"] then
				if not frameAnchorCompendium:IsShown() then frameAnchorCompendium:Show() end
				CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
			else
				frameAnchorCompendium:Hide()
			end
			-- Based on RaiderIO Client place the Frame
			if nil ~= RaiderIO_ProfileTooltip then
				C_Timer.After(0.1, function()
					if InCombatLockdown() then
						doAfterCombat = true
					else
						local offsetX = RaiderIO_ProfileTooltip:GetSize()
						frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", offsetX, 0)
					end
				end)
			else
				frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 0, 0)
			end
			checkCooldown()
		else
			frameAnchor:Hide()
		end
	end
end

-- Buttons erstellen

frameAnchor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frameAnchor:RegisterEvent("ENCOUNTER_END")
frameAnchor:RegisterEvent("ADDON_LOADED")
frameAnchor:RegisterEvent("SPELL_DATA_LOAD_RESULT")
frameAnchor:RegisterEvent("PLAYER_REGEN_ENABLED")

local function eventHandler(self, event, arg1, arg2, arg3, arg4)
	if addon.db["teleportFrame"] then
		if InCombatLockdown() then
			doAfterCombat = true
		else
			if event == "ADDON_LOADED" and arg1 == addonName then
				CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
				CreatePortalCompendium(frameAnchorCompendium, portalCompendium)
				frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 230, 0)
				frameAnchor:Show()
				if addon.db["teleportsEnableCompendium"] then
					frameAnchorCompendium:Show()
				else
					frameAnchorCompendium:Hide()
				end
			elseif parentFrame:IsShown() then -- Only do stuff, when PVEFrame Open
				if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
					if portalSpells[arg3] then waitCooldown(arg3) end
				elseif event == "ENCOUNTER_END" and arg3 == 8 then
					C_Timer.After(0.1, function() checkCooldown() end)
				elseif event == "SPELL_DATA_LOAD_RESULT" and portalSpells[arg1] then
					print("Loaded", portalSpells[arg1].text)
				elseif event == "PLAYER_REGEN_ENABLED" then
					if doAfterCombat then addon.MythicPlus.functions.toggleFrame() end
				end
			end
		end
	end
end

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)

parentFrame:HookScript("OnShow", function(self) addon.MythicPlus.functions.toggleFrame() end)
