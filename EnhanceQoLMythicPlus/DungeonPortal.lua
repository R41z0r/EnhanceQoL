local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_MythicPlus")

local cModeIDs
local portalSpells = {}
local allSpells = {} --  for Cooldown checking
local mapInfo = {}
local mapIDInfo = {}
local selectedMapId
local faction = select(2, UnitFactionGroup("player"))
local checkCooldown

addon.functions.InitDBValue("teleportFavorites", {})

local GetItemCooldown = C_Item.GetItemCooldown
local GetItemCount = C_Item.GetItemCount

local function getCurrentSeasonPortal()
	local cModeIDs = C_ChallengeMode.GetMapTable()
	local cModeIDLookup = {}
	for _, id in ipairs(cModeIDs) do
		cModeIDLookup[id] = true
	end

	local filteredPortalSpells = {}
	local filteredMapInfo = {}
	local filteredMapID = {}

	for _, section in pairs(addon.MythicPlus.variables.portalCompendium) do
		for spellID, data in pairs(section.spells) do
			if data.cId then
				for cId in pairs(data.cId) do
					if cModeIDLookup[cId] then
						local mapName, _, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(cId)

						filteredPortalSpells[spellID] = {
							text = data.text,
							iconID = data.iconID,
						}
						if data.faction then
							filteredPortalSpells[spellID].faction = data.faction
							if data.faction == faction then
								filteredMapInfo[cId] = {
									text = data.text,
									spellId = spellID,
									mapName = mapName,
									texture = texture,
									background = backgroundTexture,
								}
							end
						else
							filteredMapInfo[cId] = {
								text = data.text,
								spellId = spellID,
								mapName = mapName,
								texture = texture,
								background = backgroundTexture,
							}
						end
						if data.mapID then
							if type(data.mapID) == "table" then
								for _, mID in pairs(data.mapID) do
									filteredMapID[mID] = cId
								end
							else
								filteredMapID[data.mapID] = cId
							end
						end
						break
					end
				end
			end
			allSpells[spellID] = { isToy = data.isToy or false, toyID = data.toyID, isItem = data.isItem or false, itemID = data.itemID }
		end
	end
	portalSpells = filteredPortalSpells
	mapInfo = filteredMapInfo
	mapIDInfo = filteredMapID
end

local isKnown = {}
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
local frameAnchorCompendium = CreateFrame("Frame", "DungeonTeleportFrameCompendium", parentFrame, "BackdropTemplate")
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
local spacing = 15
local spacingCompendium = 11
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
	local favoriteLookup = addon.db.teleportFavorites
	local favorites = {}
	local others = {}
	for spellID, data in pairs(spells) do
		local known = IsSpellKnown(spellID)
		local isFavorite = favoriteLookup[spellID]
		local passes = (not data.faction or data.faction == faction)
		if addon.db["portalHideMissing"] then passes = passes and known end

		if passes or (addon.db.teleportFavoritesIgnoreFilters and isFavorite and (not addon.db["portalHideMissing"] or known)) then
			local entry = {
				spellID = spellID,
				text = data.text,
				iconID = data.iconID,
				isKnown = known,
				isFavorite = isFavorite,
			}
			if isFavorite then
				table.insert(favorites, entry)
			else
				table.insert(others, entry)
			end
		end
	end

	table.sort(favorites, function(a, b) return a.text < b.text end)
	table.sort(others, function(a, b) return a.text < b.text end)

	local sortedSpells = {}
	for _, v in ipairs(favorites) do
		table.insert(sortedSpells, v)
	end
	for _, v in ipairs(others) do
		table.insert(sortedSpells, v)
	end

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

			-- Favoritenanzeige
			local star = button:CreateTexture(nil, "OVERLAY")
			star:SetSize(12, 12)
			star:SetPoint("TOPRIGHT", -2, -2)
			star:SetTexture("Interface\\COMMON\\ReputationStar")
			if not spellData.isFavorite then star:Hide() end
			button.favoriteStar = star

			-- berprüfen, ob der Zauber bekannt ist
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
			button:SetAttribute("type1", "spell")
			button:SetAttribute("spell1", spellID)
			button:SetAttribute("type2", nil)
			button:SetAttribute("spell2", nil)

			button:RegisterForClicks("AnyUp", "AnyDown")
			button:SetScript("OnMouseUp", function(self, btn)
				if btn == "RightButton" then
					local favs = addon.db.teleportFavorites
					if favs[self.spellID] then
						favs[self.spellID] = nil
					else
						favs[self.spellID] = true
					end
					checkCooldown()
				end
			end)
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

local function isToyUsable(id)
	if id and PlayerHasToy(id) then
		for _, k in pairs(C_TooltipInfo.GetToyByItemID(id).lines) do
			if k.type and k.type == 23 then
				if k.leftColor.b == 1 and k.leftColor.g == 1 and k.leftColor.r == 1 then
					return true
				else
					return false
				end
			end
		end
		-- no restriction so return true
		return true
	end
	return false
end

local function checkProfession()
	-- Capture all profession slots into a table
	local professionIndices = { GetProfessions() }
	for _, profIndex in ipairs(professionIndices) do
		-- Only valid indices
		if profIndex and profIndex > 0 then
			local _, _, _, _, _, _, skillLine = GetProfessionInfo(profIndex)
			if skillLine == 202 then return true end
		end
	end
	return false
end

local function CreatePortalCompendium(frame, compendium)
	local hasEngineering = checkProfession()
	addon.MythicPlus.functions.setRandomHearthstone()
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

	local favorites = addon.db.teleportFavorites
	local newCompendium = {}
	local favSpells = {}
	for k, section in pairs(compendium) do
		local hidden = addon.db["teleportsCompendiumHide" .. section.headline]
		local newSpells = {}
		for spellID, data in pairs(section.spells) do
			if favorites[spellID] then
				if addon.db.teleportFavoritesIgnoreExpansionHide or not hidden then favSpells[spellID] = data end
			else
				newSpells[spellID] = data
			end
		end
		newCompendium[k] = { headline = section.headline, spells = newSpells }
	end
	if next(favSpells) then newCompendium[9999] = { headline = FAVORITES, spells = favSpells } end

	local sortedIndexes = {}
	for key, _ in pairs(newCompendium) do
		table.insert(sortedIndexes, key)
	end

	table.sort(sortedIndexes, function(a, b) return a > b end)

	for _, key in ipairs(sortedIndexes) do
		local section = newCompendium[key]

		local sortedSpells = {}
		if not addon.db["teleportsCompendiumHide" .. section.headline] then
			for spellID, data in pairs(section.spells) do
				local known = (IsSpellKnown(spellID) and not data.isToy)
					or (hasEngineering and data.toyID and not data.isHearthstone and isToyUsable(data.toyID))
					or (data.isItem and GetItemCount(data.itemID) > 0)
					or (data.isHearthstone and isToyUsable(data.toyID))
				local showSpell = (not data.faction or data.faction == faction)
					and (not data.map or (data.map == C_Map.GetBestMapForUnit("player")))
					and (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known))
					and (not addon.db["hideActualSeason"] or not portalSpells[spellID])
					and (addon.db["portalShowRaidTeleports"] or not data.isRaid)
					and (addon.db["portalShowToyHearthstones"] or not data.isHearthstone)
					and (addon.db["portalShowEngineering"] or not data.isEngineering)
					and ((addon.db["portalShowClassTeleport"] and (addon.variables.unitClass == data.isClassTP)) or not data.isClassTP)
					and ((addon.db["portalShowClassTeleport"] and addon.variables.unitRace == data.isRaceTP) or not data.isRaceTP)
					and ((addon.db["portalShowMagePortal"] and addon.variables.unitClass == "MAGE") or not data.isMagePortal)
					and (addon.db["portalShowDungeonTeleports"] or not data.cId)

				if not showSpell and addon.db.teleportFavoritesIgnoreFilters and favorites[spellID] then
					showSpell = (not addon.db["portalHideMissing"] or (addon.db["portalHideMissing"] and known))
				end

				if showSpell then
					table.insert(sortedSpells, {
						spellID = spellID,
						text = data.text,
						iconID = data.iconID,
						isKnown = known,
						isToy = data.isToy or false,
						toyID = data.toyID or false,
						isItem = data.isItem or false,
						itemID = data.itemID or false,
						icon = data.icon or false,
						isClassTP = data.isClassTP or false,
						isMagePortal = data.isMagePortal or false,
						isFavorite = favorites[spellID],
					})
				end
			end
			table.sort(sortedSpells, function(a, b)
				-- Erst vergleichen wir den Text
				if a.text < b.text then
					return true
				elseif a.text > b.text then
					return false
				else
					-- Wenn der Text identisch ist: isMageTP vor isMagePortal
					local aIsTP = a.isClassTP or false
					local bIsTP = b.isClassTP or false
					local aIsPortal = a.isMagePortal or false
					local bIsPortal = b.isMagePortal or false
					local aToyID = a.toyID or false
					local bToyID = b.toyID or false
					-- MageTP vor MagePortal
					if aIsTP and not bIsTP then
						return true
					elseif bIsTP and not aIsTP then
						return false
					elseif aIsPortal and not bIsPortal then
						-- Falls man Porter lieber später will, kann man hier return false machen
						return false
					elseif bIsPortal and not aIsPortal then
						return true
					elseif aToyID and bToyID then
						return aToyID < bToyID
					end

					-- Falls beide gleich sind (beide TP, beide Portal oder keins davon),
					-- dann ist die Reihenfolge egal:
					return false
				end
			end)
		end
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
			if not spellInfo then spellInfo = {} end

			if spellData.isToy then
				if spellData.icon then
					spellInfo.iconID = spellData.icon
				else
					local _, _, iconId = C_ToyBox.GetToyInfo(spellData.toyID)
					spellInfo.iconID = iconId
				end
			elseif spellData.isItem then
				if spellData.icon then spellInfo.iconID = spellData.icon end
			end
			if spellInfo then
				local row = math.floor(index / buttonsPerRow)
				local col = index % buttonsPerRow

				-- Button erstellen
				local button = CreateFrame("Button", "CompendiumButton" .. index, frame, "SecureActionButtonTemplate")
				button:SetSize(buttonSize, buttonSize)
				button:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + col * (buttonSize + spacingCompendium), currentYOffset - row * (buttonSize + hSpacingCompendium))
				button.spellID = spellID
				if spellData.isToy then
					button.isToy = spellData.isToy
					button.toyID = spellData.toyID
				elseif spellData.isItem then
					button.isItem = spellData.isItem
					button.itemID = spellData.itemID
				end

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

				-- Favoritenanzeige
				local star = button:CreateTexture(nil, "OVERLAY")
				star:SetSize(12, 12)
				star:SetPoint("TOPRIGHT", -2, -2)
				star:SetTexture("Interface\\COMMON\\ReputationStar")
				if not spellData.isFavorite then star:Hide() end
				button.favoriteStar = star

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
				if spellData.isToy then
					if spellData.isKnown then
						button:SetAttribute("type1", "macro")
						button:SetAttribute("macrotext1", "/use item:" .. spellData.toyID)
						button:SetAttribute("type2", nil)
						button:SetAttribute("macrotext2", nil)
					end
				elseif spellData.isItem then
					if spellData.isKnown then
						button:SetAttribute("type1", "macro")
						button:SetAttribute("macrotext1", "/use item:" .. spellData.itemID)
						button:SetAttribute("type2", nil)
						button:SetAttribute("macrotext2", nil)
					end
				else
					button:SetAttribute("type1", "spell")
					button:SetAttribute("spell1", spellID)
					button:SetAttribute("type2", nil)
					button:SetAttribute("spell2", nil)
				end
				button:RegisterForClicks("AnyUp", "AnyDown")
				button:SetScript("OnMouseUp", function(self, btn)
					if btn == "RightButton" then
						local favs = addon.db.teleportFavorites
						if favs[self.spellID] then
							favs[self.spellID] = nil
						else
							favs[self.spellID] = true
						end
						checkCooldown()
					end
				end)

				-- Text und Tooltip
				local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				label:SetPoint("TOP", button, "BOTTOM", 0, -2)
				label:SetText(spellData.text)

				-- Tooltip
				button:SetScript("OnEnter", function(self)
					if addon.db["portalShowTooltip"] then
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						if spellData.isToy then
							GameTooltip:SetToyByItemID(spellData.toyID)
						elseif spellData.isItem then
							GameTooltip:SetItemByID(spellData.itemID)
						else
							GameTooltip:SetSpellByID(spellID)
						end
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

function checkCooldown()
	if addon.db["teleportFrame"] then CreatePortalButtonsWithCooldown(frameAnchor, portalSpells) end

	if addon.db["teleportsEnableCompendium"] then CreatePortalCompendium(frameAnchorCompendium, addon.MythicPlus.variables.portalCompendium) end
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
			local cooldownData
			if button.isToy then
				if button.toyID then
					local startTime, duration, enable = GetItemCooldown(button.toyID)
					cooldownData = {
						startTime = startTime,
						duration = duration,
						modRate = 1,
						isEnabled = enable,
					}
				end
			elseif button.isItem then
				if button.itemID then
					local startTime, duration, enable = GetItemCooldown(button.itemID)
					cooldownData = {
						startTime = startTime,
						duration = duration,
						modRate = 1,
						isEnabled = enable,
					}
				end
			else
				if FindSpellOverrideByID(button.spellID) and FindSpellOverrideByID(button.spellID) ~= button.spellID then button.spellID = FindSpellOverrideByID(button.spellID) end
				cooldownData = C_Spell.GetSpellCooldown(button.spellID)
			end
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
		local cooldownData
		if allSpells[arg3].isToy then
			if allSpells[arg3].toyID then
				local startTime, duration, enable = GetItemCooldown(allSpells[arg3].toyID)
				cooldownData = {
					startTime = startTime,
					duration = duration,
					modRate = 1,
					isEnabled = enable,
				}
			end
		elseif allSpells[arg3].isItem then
			if allSpells[arg3].itemID then
				local startTime, duration, enable = GetItemCooldown(allSpells[arg3].itemID)
				cooldownData = {
					startTime = startTime,
					duration = duration,
					modRate = 1,
					isEnabled = enable,
				}
			end
		else
			cooldownData = C_Spell.GetSpellCooldown(arg3)
		end
		if cooldownData.duration > 0 then
			checkCooldown()
		else
			waitCooldown(arg3)
		end
	end)
end

local textList = {}
local gFrameAnchorScore

local function createString(textLeft, textRight, colorLeft, colorRight, anchor, selected)
	local titleScore1 = gFrameAnchorScore:CreateFontString(nil, "OVERLAY")
	titleScore1:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
	titleScore1:SetFormattedText(textLeft)
	titleScore1:SetPoint("TOPLEFT", 7, (addon.functions.getHeightOffset(anchor) - 10))
	if colorLeft then titleScore1:SetTextColor(colorLeft.r, colorLeft.g, colorLeft.b, 1) end
	if selected then titleScore1:SetTextColor(0, 1, 0, 1) end
	table.insert(textList, titleScore1)

	local titleScoreValue = gFrameAnchorScore:CreateFontString(nil, "OVERLAY")
	titleScoreValue:SetFont(addon.variables.defaultFont, 14, "OUTLINE")
	titleScoreValue:SetFormattedText(textRight)
	titleScoreValue:SetPoint("TOPRIGHT", -7, (addon.functions.getHeightOffset(anchor) - 10))
	if colorRight then titleScoreValue:SetTextColor(colorRight.r, colorRight.g, colorRight.b, 1) end
	table.insert(textList, titleScoreValue)
	return titleScore1
end

local function CreateRioScore()
	if gFrameAnchorScore then
		gFrameAnchorScore:Hide()
		gFrameAnchorScore:SetScript("OnUpdate", nil)
		gFrameAnchorScore:SetScript("OnEvent", nil)
		gFrameAnchorScore:UnregisterAllEvents()
		gFrameAnchorScore:SetParent(nil)
		gFrameAnchorScore = nil
	end
	if addon.variables.maxLevel ~= UnitLevel("player") then return end

	if addon.db["groupfinderShowDungeonScoreFrame"] == true then
		local frameAnchorScore = CreateFrame("Frame", "EQOLDungeonScoreFrame", parentFrame, "BackdropTemplate")
		gFrameAnchorScore = frameAnchorScore
		frameAnchorScore:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Hintergrund
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- Rahmen
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		frameAnchorScore:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz
		frameAnchorScore:SetFrameStrata("TOOLTIP")

		-- Überschrift hinzufügen
		local titleScore = frameAnchorScore:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		titleScore:SetFormattedText(DUNGEON_SCORE)
		titleScore:SetPoint("TOP", 0, -10)

		frameAnchorScore:SetSize(max(titleScore:GetStringWidth() + 20, 200), 170) -- Breite x Höhe
		if addon.db["teleportFrame"] then
			frameAnchorScore:SetPoint("TOPLEFT", DungeonTeleportFrame, "BOTTOMLEFT", 0, 0)
		elseif nil ~= RaiderIO_ProfileTooltip then
			local offsetX = RaiderIO_ProfileTooltip:GetSize()
			frameAnchorScore:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", offsetX, 0)
		else
			frameAnchorScore:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 0, 0)
		end
		frameAnchor:SetSize(max(title:GetStringWidth() + 20, 205), 170) -- Breite x Höhe

		local ratingInfo = {}

		for i, v in pairs(textList) do
			v:Hide()
		end
		if #portalSpells == 0 then getCurrentSeasonPortal() end
		local name, _, timeLimit
		local rating = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
		if rating then
			for _, key in pairs(rating.runs) do
				ratingInfo[key.challengeModeID] = key
			end

			local r, g, b = C_ChallengeMode.GetDungeonScoreRarityColor(rating.currentSeasonScore):GetRGB()

			local l1 = createString(BATTLEGROUND_RATING, rating.currentSeasonScore, nil, { r = r, g = g, b = b }, titleScore)

			local nWidth = l1:GetStringWidth() + 60

			local dungeonList = {}

			-- Sammle und sortiere die Dungeons nach Score
			for _, key in pairs(C_ChallengeMode.GetMapScoreInfo()) do
				if mapInfo[key.mapChallengeModeID] then
					local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(key.mapChallengeModeID)
					local stars = ""

					local data = key
					data.bestRunDurationMS = 0

					if ratingInfo[key.mapChallengeModeID] then
						data.level = ratingInfo[key.mapChallengeModeID].bestRunLevel
						data.dungeonScore = ratingInfo[key.mapChallengeModeID].mapScore
						data.bestRunDurationMS = ratingInfo[key.mapChallengeModeID].bestRunDurationMS
					end
					-- local r, g, b = C_ChallengeMode.GetKeystoneLevelRarityColor(data.level):GetRGB()
					local r, g, b = 1, 1, 1

					if data.level > 0 then
						local bestRunDuration = data.bestRunDurationMS / 1000
						local timeForPlus3 = timeLimit * 0.6
						local timeForPlus2 = timeLimit * 0.8
						local timeForPlus1 = timeLimit

						if bestRunDuration <= timeForPlus3 then
							stars = "|cFFFFD700+++|r" -- Gold für 3 Sterne
						elseif bestRunDuration <= timeForPlus2 then
							stars = "|cFFFFD700++|r" -- Gold für 2 Sterne
						elseif bestRunDuration <= timeForPlus1 then
							stars = "|cFFFFD700+|r" -- Gold für 1 Stern
						else
							r = 0.5
							g = 0.5
							b = 0.5
						end
						stars = stars .. data.level
					else
						stars = data.level
						r = 0.5
						g = 0.5
						b = 0.5
					end

					local selected = false
					if key.mapChallengeModeID == selectedMapId then selected = true end
					-- Speichere die Daten für spätere Sortierung
					table.insert(dungeonList, {
						text = mapInfo[data.mapChallengeModeID].text,
						stars = stars,
						score = data.dungeonScore,
						r = r,
						g = g,
						b = b,
						select = selected,
					})
				end
			end

			table.sort(dungeonList, function(a, b) return a.score > b.score end)

			local lastElement = l1 -- Speichert das letzte UI-Element, um die richtige Position zu setzen

			for _, dungeon in ipairs(dungeonList) do
				lastElement = createString(dungeon.text, dungeon.stars, nil, { r = dungeon.r, g = dungeon.g, b = dungeon.b }, lastElement, dungeon.select)
			end

			local _, _, _, _, lp = lastElement:GetPoint()
			frameAnchorScore:SetSize(max(nWidth + 20, 205), max(lp * -1 + 30, 170)) -- Breite x Hhe
			frameAnchor:SetSize(max(title:GetStringWidth() + 20, nWidth + 20, 205), 170) -- Breite x Höhe
		end
	end
end

local keyStoneFrame
local measureFontString
local function calculateMaxWidth(dataTable)
	local maxWidth = 0
	for key, data in pairs(dataTable) do
		if UnitInParty(key) or key == UnitName("player") then
			if not measureFontString then return end
			local widthMap = 0
			if data.challengeMapID and data.challengeMapID > 0 then
				local mapData = mapInfo[data.challengeMapID]
				if not mapData then mapData = { mapName = L["NoKeystone"] } end
				measureFontString:SetText(mapData.mapName or "")
				widthMap = measureFontString:GetStringWidth() + 25 + buttonSize
			else
				measureFontString:SetText(L["NoKeystone"] or "")
				widthMap = measureFontString:GetStringWidth() + 25 + buttonSize
			end
			local uName = UnitName(key)

			measureFontString:SetText(uName or "")
			local widthCharName = measureFontString:GetStringWidth() + 25 + buttonSize
			local width = max(widthCharName, widthMap)
			if width > maxWidth then maxWidth = width end
		end
	end
	return maxWidth
end

local function updateKeystoneInfo()
	if InCombatLockdown() then
		doAfterCombat = true
		return
	end
	if parentFrame:IsShown() then
		local minHightOffset = 0
		if PVEFrameTab4:IsVisible() then minHightOffset = 0 - PVEFrameTab4:GetHeight() end
		if not keyStoneFrame then
			keyStoneFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
			keyStoneFrame:SetSize(200, 300) -- Passe die Größe nach Bedarf an
			keyStoneFrame:Show()
		else
			for _, child in ipairs({ keyStoneFrame:GetChildren() }) do
				child:Hide()
				child:SetParent(nil)
			end
		end
		if IsInRaid() then return end
		keyStoneFrame:SetPoint("TOPRIGHT", parentFrame, "BOTTOMRIGHT", 0, minHightOffset)
		if #portalSpells == 0 then getCurrentSeasonPortal() end
		local keystoneData = openRaidLib.GetAllKeystonesInfo()

		if keystoneData then
			local unitsAdded = {}
			local isOnline = true

			local maxWidthKeystone = calculateMaxWidth(keystoneData)

			local index = 0
			for key, data in pairs(keystoneData) do
				local uName, uRealm = UnitName(key)
				data.charName = uName
				data.classColor = RAID_CLASS_COLORS[select(2, UnitClass(key))] or { r = 1, g = 1, b = 1 }

				if UnitInParty(key) or key == addon.variables.unitName then
					local mapData
					if data.challengeMapID and data.challengeMapID > 0 then
						mapData = mapInfo[data.challengeMapID]
						if not mapData then mapData = {
							mapName = L["NoKeystone"],
						} end
					else
						mapData = {
							mapName = L["NoKeystone"],
						}
					end
					local frame = CreateFrame("Frame", nil, keyStoneFrame, "BackdropTemplate")
					frame:SetSize(maxWidthKeystone, 50) -- Passe die Größe nach Bedarf an
					frame:SetPoint("TOPRIGHT", keyStoneFrame, "TOPRIGHT", 0, -50 * index)
					frame:SetBackdrop({
						bgFile = "Interface\\Buttons\\WHITE8x8", -- Hintergrund
						edgeFile = nil, -- Rahmen
						edgeSize = 16,
						insets = { left = 4, right = 4, top = 1, bottom = 0 },
					})
					frame:SetBackdropColor(0, 0, 0, 0.8) -- Dunkler Hintergrund mit 80% Transparenz
					frame:Show()

					-- Button erstellen
					local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
					button:SetSize(buttonSize, buttonSize)
					button:SetPoint("LEFT", frame, "LEFT", 10, 0)
					if mapData.spellId then button.spellID = mapData.spellId end
					-- Dungeonname (zum Beispiel rechtsbündig)
					local dungeonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					dungeonText:SetPoint("TOPLEFT", button, "TOPRIGHT", 5, 0)
					dungeonText:SetText(mapData.mapName or "Unknown Dungeon")

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
					icon:SetTexture(mapData.texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
					button.icon = icon

					-- Überprüfen, ob der Zauber bekannt ist
					if mapData.spellId and IsSpellKnown(mapData.spellId) then
						local cooldownData = C_Spell.GetSpellCooldown(mapData.spellId)
						if cooldownData and cooldownData.isEnabled then
							button:EnableMouse(true) -- Aktiviert Klicks

							-- Cooldown-Spirale
							button:SetAttribute("type", "spell")
							button:SetAttribute("spell", mapData.spellId)
							button:RegisterForClicks("AnyUp", "AnyDown")
						else
							button:EnableMouse(false)
						end
					else
						button:EnableMouse(false) -- Deaktiviert Klicks auf den Button
					end

					if data.level and data.level > 0 then
						-- Key-Level als Text
						local levelText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
						levelText:SetPoint("CENTER", button, "CENTER", 0, 0)
						levelText:SetText((data.level or "0"))
						levelText:SetTextColor(1, 1, 1)
					end
					-- Spielername in Klassenfarbe
					local playerNameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					playerNameText:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, 0)

					local classColor = data.classColor
					playerNameText:SetText(data.charName)
					playerNameText:SetTextColor(classColor.r, classColor.g, classColor.b)
					index = index + 1
				end
			end
		end
	end
end

function addon.MythicPlus.onKeystoneUpdate(unitName, keystoneInfo, keystoneData)
	if parentFrame:IsShown() then updateKeystoneInfo() end
end

local isRegistered = false
function addon.MythicPlus.functions.togglePartyKeystone()
	if InCombatLockdown() then
		doAfterCombat = true
	else
		if addon.db["groupfinderShowPartyKeystone"] and not IsInRaid() then
			if not isRegistered then
				isRegistered = true
				measureFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				measureFontString:Hide()
				openRaidLib.RegisterCallback(addon.MythicPlus, "KeystoneUpdate", "onKeystoneUpdate")
				openRaidLib.RequestKeystoneDataFromParty()
			end
		else
			isRegistered = false
			measureFontString = nil
			if keyStoneFrame then
				keyStoneFrame:Hide()
				keyStoneFrame:SetParent(nil)
				keyStoneFrame = nil
			end
			openRaidLib.UnregisterCallback(addon.MythicPlus, "KeystoneUpdate", "onKeystoneUpdate")
			openRaidLib.WipeKeystoneData()
		end
	end
end
if addon.db["groupfinderShowPartyKeystone"] then addon.MythicPlus.functions.togglePartyKeystone() end

function addon.MythicPlus.triggerRequest()
	if not IsInRaid() then openRaidLib.RequestKeystoneDataFromParty() end
end

function addon.MythicPlus.functions.toggleFrame()
	if InCombatLockdown() then
		doAfterCombat = true
	else
		doAfterCombat = false
		frameAnchor:SetAlpha(1)
		frameAnchorCompendium:SetAlpha(1)
		if nil ~= RaiderIO_ProfileTooltip then
			C_Timer.After(0.1, function()
				if InCombatLockdown() then
					doAfterCombat = true
				else
					CreateRioScore()
				end
			end)
		else
			CreateRioScore()
		end
		if addon.db["teleportFrame"] or addon.db["teleportsEnableCompendium"] then
			if #portalSpells == 0 then getCurrentSeasonPortal() end
			checkCooldown()

			frameAnchorCompendium:ClearAllPoints()
			-- Based on RaiderIO Client place the Frame
			if nil ~= RaiderIO_ProfileTooltip then
				C_Timer.After(0.1, function()
					if InCombatLockdown() then
						doAfterCombat = true
					else
						CreateRioScore()
						frameAnchorCompendium:ClearAllPoints()
						local offsetX = RaiderIO_ProfileTooltip:GetSize()
						frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", offsetX, 0)
						if not addon.db["teleportFrame"] then
							if gFrameAnchorScore then
								local offsetX2 = gFrameAnchorScore:GetSize()
								frameAnchorCompendium:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", (offsetX + offsetX2), 0)
							else
								frameAnchorCompendium:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", offsetX, 0)
							end
						else
							frameAnchorCompendium:SetPoint("TOPLEFT", frameAnchor, "TOPRIGHT", 0, 0)
						end
					end
				end)
			else
				frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 0, 0)
				if not addon.db["teleportFrame"] then
					if gFrameAnchorScore then
						local offsetX2 = gFrameAnchorScore:GetSize()
						frameAnchorCompendium:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", offsetX2, 0)
					else
						frameAnchorCompendium:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 0, 0)
					end
				else
					frameAnchorCompendium:SetPoint("TOPLEFT", frameAnchor, "TOPRIGHT", 0, 0)
				end
			end

			-- Set Visibility
			if addon.db["teleportFrame"] == true then
				if not frameAnchor:IsShown() then frameAnchor:Show() end
			else
				frameAnchor:Hide()
			end
			if addon.db["teleportsEnableCompendium"] then
				if not frameAnchorCompendium:IsShown() then frameAnchorCompendium:Show() end
			else
				frameAnchorCompendium:Hide()
			end
		else
			frameAnchor:Hide()
			frameAnchorCompendium:Hide()
		end
		if addon.db["groupfinderShowPartyKeystone"] then
			addon.MythicPlus.triggerRequest()
			updateKeystoneInfo() -- precall to check if we have all information already
		end
	end
end

-- Buttons erstellen

frameAnchor:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frameAnchor:RegisterEvent("ENCOUNTER_END")
frameAnchor:RegisterEvent("ADDON_LOADED")
frameAnchor:RegisterEvent("SPELL_DATA_LOAD_RESULT")
frameAnchor:RegisterEvent("PLAYER_REGEN_ENABLED")
frameAnchor:RegisterEvent("GROUP_ROSTER_UPDATE")
frameAnchor:RegisterEvent("GROUP_JOINED")
local function eventHandler(self, event, arg1, arg2, arg3, arg4)
	if addon.db["teleportFrame"] then
		if InCombatLockdown() then
			doAfterCombat = true
		else
			if event == "ADDON_LOADED" and arg1 == addonName then
				CreatePortalButtonsWithCooldown(frameAnchor, portalSpells)
				CreatePortalCompendium(frameAnchorCompendium, addon.MythicPlus.variables.portalCompendium)
				CreateRioScore()
				frameAnchor:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 230, 0)
				frameAnchor:Show()
				if addon.db["teleportsEnableCompendium"] then
					frameAnchorCompendium:Show()
				else
					frameAnchorCompendium:Hide()
				end
			elseif event == "GROUP_JOINED" then
				if PVEFrame:IsShown() then
					addon.MythicPlus.triggerRequest() -- because I won't get the information from the people already in party otherwise
				end
			elseif event == "GROUP_ROSTER_UPDATE" then
				if (IsInRaid() and isRegistered) or (not IsInRaid() and not isRegistered) then addon.MythicPlus.functions.togglePartyKeystone() end
			elseif parentFrame:IsShown() then -- Only do stuff, when PVEFrame Open
				if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
					if allSpells[arg3] then waitCooldown(arg3) end
				elseif event == "ENCOUNTER_END" and arg3 == 8 then
					C_Timer.After(0.1, function() checkCooldown() end)
				elseif event == "SPELL_DATA_LOAD_RESULT" and portalSpells[arg1] then
					print("Loaded", portalSpells[arg1].text)
				elseif event == "PLAYER_REGEN_ENABLED" then
					if doAfterCombat then
						if (IsInRaid() and isRegistered) or (not IsInRaid() and not isRegistered) then addon.MythicPlus.functions.togglePartyKeystone() end
						addon.MythicPlus.functions.toggleFrame()
					end
				end
			end
		end
	end
end

GameTooltip:HookScript("OnShow", function(self)
	if PVEFrame:IsVisible() then
		selectedMapId = nil
		local owner = self:GetOwner()
		if
			owner
			and owner.GetParent
			and LFGListFrame
			and LFGListFrame.SearchPanel
			and LFGListFrame.SearchPanel.ScrollBox
			and LFGListFrame.SearchPanel.ScrollBox.ScrollTarget
			and owner:GetParent() == LFGListFrame.SearchPanel.ScrollBox.ScrollTarget
		then
			local resultID = owner.resultID
			if resultID then
				local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
				if searchResultInfo then
					local mapData = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
					if mapData then
						if mapIDInfo[mapData.mapID] then selectedMapId = mapIDInfo[mapData.mapID] end
					end
				end
			end
			CreateRioScore()
			local offsetX = 0
			if nil ~= RaiderIO_ProfileTooltip then offsetX = RaiderIO_ProfileTooltip:GetSize() end
			if gFrameAnchorScore then gFrameAnchorScore:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", offsetX, 0) end

			if addon.db["teleportFrame"] then frameAnchor:SetAlpha(0) end
			if addon.db["teleportsEnableCompendium"] then frameAnchorCompendium:SetAlpha(0) end
		end
	end
end)
GameTooltip:HookScript("OnHide", function(self)
	if PVEFrame:IsVisible() then
		selectedMapId = nil
		local owner = self:GetOwner()
		CreateRioScore()
		if addon.db["teleportFrame"] then frameAnchor:SetAlpha(1) end
		if addon.db["teleportsEnableCompendium"] then frameAnchorCompendium:SetAlpha(1) end
	end
end)

-- Setze den Event-Handler
frameAnchor:SetScript("OnEvent", eventHandler)

parentFrame:HookScript("OnShow", function(self) addon.MythicPlus.functions.toggleFrame() end)
