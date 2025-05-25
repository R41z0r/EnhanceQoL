local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

-- UI related functions extracted from EnhanceQoL.lua

local function addChatFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			var = "chatFrameFadeEnabled",
			text = L["chatFrameFadeEnabled"],
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["chatFrameFadeEnabled"] = value
				if ChatFrame1 then ChatFrame1:SetFading(value) end
				container:ReleaseChildren()
				addChatFrame(container)
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end

	if addon.db["chatFrameFadeEnabled"] then
		local groupCoreSetting = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCoreSetting)

		local sliderTimeVisible = addon.functions.createSliderAce(
			L["chatFrameFadeTimeVisibleText"] .. ": " .. addon.db["chatFrameFadeTimeVisible"] .. "s",
			addon.db["chatFrameFadeTimeVisible"],
			1,
			300,
			1,
			function(self, _, value2)
				addon.db["chatFrameFadeTimeVisible"] = value2
				if ChatFrame1 then ChatFrame1:SetTimeVisible(value2) end
				self:SetLabel(L["chatFrameFadeTimeVisibleText"] .. ": " .. value2 .. "s")
			end
		)
		groupCoreSetting:AddChild(sliderTimeVisible)

		groupCoreSetting:AddChild(addon.functions.createSpacerAce())

		local sliderFadeDuration = addon.functions.createSliderAce(
			L["chatFrameFadeDurationText"] .. ": " .. addon.db["chatFrameFadeDuration"] .. "s",
			addon.db["chatFrameFadeDuration"],
			1,
			60,
			1,
			function(self, _, value2)
				addon.db["chatFrameFadeDuration"] = value2
				if ChatFrame1 then ChatFrame1:SetFadeDuration(value2) end
				self:SetLabel(L["chatFrameFadeDurationText"] .. ": " .. value2 .. "s")
			end
		)
		groupCoreSetting:AddChild(sliderFadeDuration)
	end
end

local function addMinimapFrame(container)
	local data = {
		{
			parent = "",
			var = "enableLootspecQuickswitch",
			type = "CheckBox",
			desc = L["enableLootspecQuickswitchDesc"],
			callback = function(self, _, value)
				addon.db["enableLootspecQuickswitch"] = value
				if value then
					addon.functions.createLootspecFrame()
				else
					addon.functions.removeLootspecframe()
				end
			end,
		},
		{
			parent = "",
			var = "enableMinimapButtonBin",
			type = "CheckBox",
			desc = L["enableMinimapButtonBinDesc"],
			callback = function(self, _, value)
				addon.db["enableMinimapButtonBin"] = value
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		},
		{
			parent = "",
			var = "enableSquareMinimap",
			text = L["enableSquareMinimap"],
			desc = L["enableSquareMinimapDesc"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["enableSquareMinimap"] = value
				addon.variables.requireReload = true
				addon.functions.checkReloadFrame()
			end,
		},
	}

	if addon.db["enableMinimapButtonBin"] then
		table.insert(data, {
			parent = "",
			var = "useMinimapButtonBinIcon",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["useMinimapButtonBinIcon"] = value
				if value then addon.db["useMinimapButtonBinMouseover"] = false end
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		})
		table.insert(data, {
			parent = "",
			var = "useMinimapButtonBinMouseover",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["useMinimapButtonBinMouseover"] = value
				if value then addon.db["useMinimapButtonBinIcon"] = false end
				addon.functions.toggleButtonSink()
				container:ReleaseChildren()
				addMinimapFrame(container)
			end,
		})
		if not addon.db["useMinimapButtonBinIcon"] then
			table.insert(data, {
				parent = "",
				var = "lockMinimapButtonBin",
				type = "CheckBox",
				callback = function(self, _, value)
					addon.db["lockMinimapButtonBin"] = value
					addon.functions.toggleButtonSink()
				end,
			})
		end

		for i, _ in pairs(addon.variables.bagButtonState) do
			table.insert(data, {
				parent = MINIMAP_LABEL .. ": " .. L["ignoreMinimapSinkHole"],
				var = "ignoreMinimapButtonBin_" .. i,
				text = i,
				type = "CheckBox",
				value = addon.db["ignoreMinimapButtonBin_" .. i] or false,
				callback = function(self, _, value)
					addon.db["ignoreMinimapButtonBin_" .. i] = value
					addon.functions.LayoutButtons()
				end,
			})
		end
	end
	for id in pairs(addon.variables.landingPageType) do
		local actValue = false
		local page = addon.variables.landingPageType[id]
		if addon.db["hiddenLandingPages"][id] then actValue = true end

		table.insert(data, {
			parent = L["landingPageHide"],
			var = "landingPageType_" .. id,
			type = "CheckBox",
			value = actValue,
			id = id,
			text = page.checkbox,
			title = page.title,
			callback = function(self, _, value)
				addon.db["hiddenLandingPages"][id] = value
				addon.functions.toggleLandingPageButton(page.title, value)
			end,
		})
	end

	addon.functions.createWrapperData(data, container, L)
end

local function addUnitFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupHitIndicator = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupHitIndicator)
	groupHitIndicator:SetTitle(COMBAT_TEXT_LABEL)

	local data = {
		{
			var = "hideHitIndicatorPlayer",
			text = L["hideHitIndicatorPlayer"],
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["hideHitIndicatorPlayer"] = value
				if value then
					PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide()
				else
					PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Show()
				end
			end,
		},
		{
			text = L["hideHitIndicatorPet"],
			var = "hideHitIndicatorPet",
			type = "CheckBox",
			func = function(self, _, value)
				addon.db["hideHitIndicatorPet"] = value
				if value and PetHitIndicator then PetHitIndicator:Hide() end
			end,
		},
	}

	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupHitIndicator:AddChild(cbElement)
	end

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local labelHeadline = addon.functions.createLabelAce("|cffffd700" .. L["UnitFrameHideExplain"] .. "|r", nil, nil, 14)
	labelHeadline:SetFullWidth(true)
	groupCore:AddChild(labelHeadline)

	groupCore:AddChild(addon.functions.createSpacerAce())

	for _, cbData in ipairs(addon.variables.unitFrameNames) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value)
			if cbData.var and cbData.name then
				addon.db[cbData.var] = value
				UpdateUnitFrameMouseover(cbData.name, cbData)
			end
		end, desc)
		groupCore:AddChild(cbElement)
	end
end

local function addAuctionHouseFrame(container)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local data = {
		{
			text = L["persistAuctionHouseFilter"],
			var = "persistAuctionHouseFilter",
			func = function(self, _, value) addon.db["persistAuctionHouseFilter"] = value end,
		},
	}
	table.sort(data, function(a, b) return a.text < b.text end)

	for _, cbData in ipairs(data) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], cbData.func, desc)
		groupCore:AddChild(cbElement)
	end
end

local function addActionBarFrame(container, d)
	local scroll = addon.functions.createContainer("ScrollFrame", "Flow")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	container:AddChild(scroll)

	local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
	scroll:AddChild(wrapper)

	local groupCore = addon.functions.createContainer("InlineGroup", "List")
	wrapper:AddChild(groupCore)

	local labelHeadline = addon.functions.createLabelAce(
		"|cffffd700"
			.. L["ActionbarHideExplain"]:format(_G["HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS"], _G["HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS"], _G["HUD_EDIT_MODE_MENU"])
			.. "|r",
		nil,
		nil,
		14
	)
	labelHeadline:SetFullWidth(true)
	groupCore:AddChild(labelHeadline)

	groupCore:AddChild(addon.functions.createSpacerAce())

	for _, cbData in ipairs(addon.variables.actionBarNames) do
		local desc
		if cbData.desc then desc = cbData.desc end
		local cbElement = addon.functions.createCheckboxAce(cbData.text, addon.db[cbData.var], function(self, _, value)
			if cbData.var and cbData.name then
				addon.db[cbData.var] = value
				UpdateActionBarMouseover(cbData.name, value, cbData.var)
			end
		end, desc)
		groupCore:AddChild(cbElement)
	end
end
local function addUIFrame(container)
	local data = {
		{
			parent = "",
			var = "ignoreTalkingHead",
			type = "CheckBox",
			callback = function(self, _, value) addon.db["ignoreTalkingHead"] = value end,
		},
		{
			parent = "",
			var = "hideBagsBar",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideBagsBar"] = value
				addon.functions.toggleBagsBar(addon.db["hideBagsBar"])
				if value and addon.db["unitframeSettingBagsBar"] then
					addon.db["unitframeSettingBagsBar"] = false
					addon.variables.requireReload = true
				end
			end,
		},
		{
			parent = "",
			var = "hideQuickJoinToast",
			text = HIDE .. " " .. COMMUNITIES_NOTIFICATION_SETTINGS_DIALOG_QUICK_JOIN_LABEL,
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideQuickJoinToast"] = value
				addon.functions.toggleQuickJoinToastButton(addon.db["hideQuickJoinToast"])
			end,
		},
		{
			parent = "",
			var = "hideMicroMenu",
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideMicroMenu"] = value
				addon.functions.toggleMicroMenu(addon.db["hideMicroMenu"])
				if value and addon.db["unitframeSettingMicroMenu"] then
					addon.db["unitframeSettingMicroMenu"] = false
					addon.variables.requireReload = true
				end
			end,
		},
		{
			parent = "",
			var = "hideMinimapButton",
			text = L["Hide Minimap Button"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideMinimapButton"] = value
				addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
			end,
		},
		{
			parent = "",
			var = "hideRaidTools",
			text = L["Hide Raid Tools"],
			type = "CheckBox",
			callback = function(self, _, value)
				addon.db["hideRaidTools"] = value
				addon.functions.toggleRaidTools(addon.db["hideRaidTools"], _G.CompactRaidFrameManager)
			end,
		},
	}

	addon.functions.createWrapperData(data, container, L)
end
local function initUnitFrame()
	addon.functions.InitDBValue("hideHitIndicatorPlayer", false)
	addon.functions.InitDBValue("hideHitIndicatorPet", false)
	if addon.db["hideHitIndicatorPlayer"] then PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide() end

	if PetHitIndicator then hooksecurefunc(PetHitIndicator, "Show", function(self)
		if addon.db["hideHitIndicatorPet"] then PetHitIndicator:Hide() end
	end) end

	for _, cbData in ipairs(addon.variables.unitFrameNames) do
		if cbData.var and cbData.name then
			if addon.db[cbData.var] then UpdateUnitFrameMouseover(cbData.name, cbData) end
		end
	end
end

local function initBagsFrame()
	addon.functions.InitDBValue("moneyTracker", {})
	addon.functions.InitDBValue("enableMoneyTracker", false)
	addon.functions.InitDBValue("showOnlyGoldOnMoney", false)
	if addon.db["moneyTracker"][UnitGUID("player")] == nil or type(addon.db["moneyTracker"][UnitGUID("player")]) ~= "table" then addon.db["moneyTracker"][UnitGUID("player")] = {} end
	local moneyFrame = ContainerFrameCombinedBags.MoneyFrame
	local otherMoney = {}

	local function ShowBagMoneyTooltip(self)
		if not addon.db["enableMoneyTracker"] then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()

		local list, total = {}, 0
		for _, info in pairs(addon.db["moneyTracker"]) do
			total = total + (info.money or 0)
			table.insert(list, info)
		end
		table.sort(list, function(a, b) return (a.money or 0) > (b.money or 0) end)

		for _, info in ipairs(list) do
			local col = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info.class] or { r = 1, g = 1, b = 1 }
			local displayName
			if info.realm == GetRealmName() or not info.realm or info.realm == "" then
				displayName = string.format("|cff%02x%02x%02x%s|r", col.r * 255, col.g * 255, col.b * 255, info.name)
			else
				displayName = string.format("|cff%02x%02x%02x%s-%s|r", col.r * 255, col.g * 255, col.b * 255, info.name, info.realm)
			end
			GameTooltip:AddDoubleLine(displayName, addon.functions.formatMoney(info.money, "tracker"))
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TOTAL, addon.functions.formatMoney(total, "tracker"))
		GameTooltip:Show()
	end

	local function HideBagMoneyTooltip()
		if not addon.db["enableMoneyTracker"] then return end
		GameTooltip:Hide()
	end

	moneyFrame:HookScript("OnEnter", ShowBagMoneyTooltip)
	moneyFrame:HookScript("OnLeave", HideBagMoneyTooltip)
	for _, coin in ipairs({ "GoldButton", "SilverButton", "CopperButton" }) do
		local btn = moneyFrame[coin]
		if btn then
			btn:HookScript("OnEnter", ShowBagMoneyTooltip)
			btn:HookScript("OnLeave", HideBagMoneyTooltip)
		end
	end

	moneyFrame = ContainerFrame1.MoneyFrame
	moneyFrame:HookScript("OnEnter", ShowBagMoneyTooltip)
	moneyFrame:HookScript("OnLeave", HideBagMoneyTooltip)
	for _, coin in ipairs({ "GoldButton", "SilverButton", "CopperButton" }) do
		local btn = moneyFrame[coin]
		if btn then
			btn:HookScript("OnEnter", ShowBagMoneyTooltip)
			btn:HookScript("OnLeave", HideBagMoneyTooltip)
		end
	end
end

local function initChatFrame()
	if ChatFrame1 then
		addon.functions.InitDBValue("chatFrameFadeEnabled", ChatFrame1:GetFading())
		addon.functions.InitDBValue("chatFrameFadeTimeVisible", ChatFrame1:GetTimeVisible())
		addon.functions.InitDBValue("chatFrameFadeDuration", ChatFrame1:GetFadeDuration())

		ChatFrame1:SetFading(addon.db["chatFrameFadeEnabled"])
		ChatFrame1:SetTimeVisible(addon.db["chatFrameFadeTimeVisible"])
		ChatFrame1:SetFadeDuration(addon.db["chatFrameFadeDuration"])
	else
		addon.functions.InitDBValue("chatFrameFadeEnabled", true)
		addon.functions.InitDBValue("chatFrameFadeTimeVisible", 120)
		addon.functions.InitDBValue("chatFrameFadeDuration", 3)
	end
end

local function initUI()
	addon.functions.InitDBValue("enableMinimapButtonBin", false)
	addon.functions.InitDBValue("buttonsink", {})
	addon.functions.InitDBValue("enableLootspecQuickswitch", false)
	addon.functions.InitDBValue("lootspec_quickswitch", {})
	addon.functions.InitDBValue("minimapSinkHoleData", {})
	addon.functions.InitDBValue("hideQuickJoinToast", false)
	addon.functions.InitDBValue("enableSquareMinimap", false)
	addon.functions.InitDBValue("persistAuctionHouseFilter", false)

	table.insert(addon.variables.unitFrameNames, {
		name = "MicroMenu",
		var = "unitframeSettingMicroMenu",
		text = addon.L["MicroMenu"],
		children = { MicroMenu:GetChildren() },
		revealAllChilds = true,
		disableSetting = {
			"hideMicroMenu",
		},
	})
	table.insert(addon.variables.unitFrameNames, {
		name = "BagsBar",
		var = "unitframeSettingBagsBar",
		text = addon.L["BagsBar"],
		children = { BagsBar:GetChildren() },
		revealAllChilds = true,
		disableSetting = {
			"hideBagsBar",
		},
	})

	local function makeSquareMinimap()
		MinimapCompassTexture:Hide()
		Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
		function GetMinimapShape() return "SQUARE" end
	end
	if addon.db["enableSquareMinimap"] then makeSquareMinimap() end

	function addon.functions.toggleMinimapButton(value)
		if value == false then
			LDBIcon:Show(addonName)
		else
			LDBIcon:Hide(addonName)
		end
	end
	function addon.functions.toggleBagsBar(value)
		if value == false then
			BagsBar:Show()
		else
			BagsBar:Hide()
		end
	end
	addon.functions.toggleBagsBar(addon.db["hideBagsBar"])
	function addon.functions.toggleMicroMenu(value)
		if value == false then
			MicroMenu:Show()
		else
			MicroMenu:Hide()
		end
	end
	addon.functions.toggleMicroMenu(addon.db["hideMicroMenu"])

	function addon.functions.toggleQuickJoinToastButton(value)
		if value == false then
			QuickJoinToastButton:Show()
		else
			QuickJoinToastButton:Hide()
		end
	end
	addon.functions.toggleQuickJoinToastButton(addon.db["hideQuickJoinToast"])

	local eventFrame = CreateFrame("Frame")
	eventFrame:SetScript("OnUpdate", function(self)
		addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
		self:SetScript("OnUpdate", nil)
	end)

	local COLUMNS = 4
	local ICON_SIZE = 32
	local PADDING = 4
	addon.variables.bagButtons = {}
	addon.variables.bagButtonState = {}
	addon.variables.bagButtonPoint = {}
	addon.variables.buttonSink = nil

	local function hoverOutFrame()
		if addon.variables.buttonSink and LDBIcon.objects[addonName .. "_ButtonSinkMap"] then
			if not MouseIsOver(addon.variables.buttonSink) and not MouseIsOver(LDBIcon.objects[addonName .. "_ButtonSinkMap"]) then
				addon.variables.buttonSink:Hide()
			elseif addon.variables.buttonSink:IsShown() then
				C_Timer.After(1, function() hoverOutFrame() end)
			end
		end
	end
	local function hoverOutCheck(frame)
		if frame and frame:IsVisible() then
			if not MouseIsOver(frame) then
				frame:SetAlpha(0)
			else
				C_Timer.After(1, function() hoverOutCheck(frame) end)
			end
		end
	end

	local function positionBagFrame(bagFrame, anchorButton)
		bagFrame:ClearAllPoints()

		-- Zuerst berechnen wir die absoluten Bildschirmkoordinaten des Buttons.
		-- Das geht am einfachsten über 'GetLeft()', 'GetRight()', 'GetTop()', 'GetBottom()'.
		local bLeft = anchorButton:GetLeft() or 0
		local bRight = anchorButton:GetRight() or 0
		local bTop = anchorButton:GetTop() or 0
		local bBottom = anchorButton:GetBottom() or 0

		local screenWidth = GetScreenWidth()
		local screenHeight = GetScreenHeight()

		local bagWidth = bagFrame:GetWidth()
		local bagHeight = bagFrame:GetHeight()

		-- Standard-Anker: Wir wollen z.B. "BOTTOMRIGHT" der Bag an "TOPLEFT" des Buttons
		-- Also Bag rechts vom Button (und Bag unten am Button) – das können wir anpassen
		local pointOnBag = "BOTTOMRIGHT"
		local pointOnButton = "TOPLEFT"

		-- Prüfen, ob wir vertikal oben rausrennen
		-- Falls bTop + bagHeight zu hoch ist, docken wir uns an der "BOTTOMLEFT" des Buttons an
		-- und die Bag an "TOPRIGHT"
		if (bTop + bagHeight) > screenHeight then
			pointOnBag = "TOPRIGHT"
			pointOnButton = "BOTTOMLEFT"
		end

		-- Prüfen, ob wir horizontal links rausrennen (z. B. der Button ist links am Bildschirm
		-- und bagWidth würde drüber hinausragen)
		if (bLeft - bagWidth) < 0 then
			-- Dann wollen wir lieber rechts daneben andocken
			-- Also "BOTTOMLEFT" an "TOPRIGHT"
			if pointOnBag == "BOTTOMRIGHT" then
				pointOnBag = "BOTTOMLEFT"
				pointOnButton = "TOPRIGHT"
			else
				-- oder "TOPLEFT" an "BOTTOMRIGHT"
				pointOnBag = "TOPLEFT"
				pointOnButton = "BOTTOMRIGHT"
			end
		end

		-- Jetzt setzen wir den finalen Anker
		bagFrame:SetPoint(pointOnBag, anchorButton, pointOnButton, 0, 0)
	end

	local function removeButtonSink()
		if addon.variables.buttonSink then
			addon.variables.buttonSink:SetParent(nil)
			addon.variables.buttonSink:SetScript("OnLeave", nil)
			addon.variables.buttonSink:SetScript("OnDragStart", nil)
			addon.variables.buttonSink:SetScript("OnDragStop", nil)
			addon.variables.buttonSink:SetScript("OnEnter", nil)
			addon.variables.buttonSink:SetScript("OnLeave", nil)
			addon.variables.buttonSink:Hide()
			addon.variables.buttonSink = nil
		end
		addon.functions.LayoutButtons()
		if _G[addonName .. "_ButtonSinkMap"] then
			_G[addonName .. "_ButtonSinkMap"]:SetParent(nil)
			_G[addonName .. "_ButtonSinkMap"]:SetScript("OnEnter", nil)
			_G[addonName .. "_ButtonSinkMap"]:SetScript("OnLeave", nil)
			_G[addonName .. "_ButtonSinkMap"]:Hide()
			_G[addonName .. "_ButtonSinkMap"] = nil
		end
		if LDBIcon:IsRegistered(addonName .. "_ButtonSinkMap") then
			local button = LDBIcon.objects[addonName .. "_ButtonSinkMap"]
			if button then button:Hide() end
			LDBIcon.objects[addonName .. "_ButtonSinkMap"] = nil
		end
	end

	local function firstStartButtonSink(counter)
		if hookedATT then return end
		if C_AddOns.IsAddOnLoadable("AllTheThings") then
			if _G["AllTheThings-Minimap"] then
				addon.functions.gatherMinimapButtons()
				addon.functions.LayoutButtons()
				return
			end
			if _G["AllTheThings"] and _G["AllTheThings"].SetMinimapButtonSettings then
				hooksecurefunc(_G["AllTheThings"], "SetMinimapButtonSettings", function(self, visible)
					addon.functions.gatherMinimapButtons()
					addon.functions.LayoutButtons()
				end)
				hookedATT = true
				return
			end
			if counter < 30 then C_Timer.After(0.5, function() firstStartButtonSink(counter + 1) end) end
		end
	end

	function addon.functions.toggleButtonSink()
		if addon.db["enableMinimapButtonBin"] then
			removeButtonSink()

			firstStartButtonSink(0)
			local buttonBag = CreateFrame("Frame", addonName .. "_ButtonSink", UIParent, "BackdropTemplate")
			buttonBag:SetSize(150, 150)
			buttonBag:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				edgeSize = 1,
			})

			if addon.db["useMinimapButtonBinIcon"] then
				buttonBag:SetScript("OnLeave", function(self)
					if addon.db["useMinimapButtonBinIcon"] then C_Timer.After(1, function() hoverOutFrame() end) end
				end)
			else
				if not addon.db["lockMinimapButtonBin"] then
					buttonBag:SetMovable(true)
					buttonBag:EnableMouse(true)
					buttonBag:RegisterForDrag("LeftButton")
					buttonBag:SetScript("OnDragStart", buttonBag.StartMoving)
					buttonBag:SetScript("OnDragStop", function(self)
						self:StopMovingOrSizing()
						-- Position speichern
						local point, _, _, xOfs, yOfs = self:GetPoint()
						addon.db["minimapSinkHoleData"].point = point
						addon.db["minimapSinkHoleData"].x = xOfs
						addon.db["minimapSinkHoleData"].y = yOfs
					end)
				end
				buttonBag:SetPoint(
					addon.db["minimapSinkHoleData"].point or "CENTER",
					UIParent,
					addon.db["minimapSinkHoleData"].point or "CENTER",
					addon.db["minimapSinkHoleData"].x or 0,
					addon.db["minimapSinkHoleData"].y or 0
				)
				if addon.db["useMinimapButtonBinMouseover"] then
					buttonBag:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
					buttonBag:SetScript("OnLeave", function(self) hoverOutCheck(self) end)
					buttonBag:SetAlpha(0)
				end
			end
			buttonBag:SetBackdropColor(0, 0, 0, 0.4)
			buttonBag:SetBackdropBorderColor(1, 1, 1, 1)
			addon.variables.buttonSink = buttonBag
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()

			-- create ButtonSink Button
			if addon.db["useMinimapButtonBinIcon"] then
				local iconData = {
					type = "launcher",
					icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\SinkHole.tga" or "Interface\\ICONS\\INV_Misc_QuestionMark", -- irgendein Icon
					label = addonName .. "_ButtonSinkMap",
					OnEnter = function(self)
						positionBagFrame(addon.variables.buttonSink, LDBIcon.objects[addonName .. "_ButtonSinkMap"])
						addon.variables.buttonSink:Show()
					end,
					OnLeave = function(self)
						if addon.db["useMinimapButtonBinIcon"] then C_Timer.After(1, function() hoverOutFrame() end) end
					end,
				}
				-- Registriere das Icon bei LibDBIcon
				LDB:NewDataObject(addonName .. "_ButtonSinkMap", iconData)
				LDBIcon:Register(addonName .. "_ButtonSinkMap", iconData, addon.db["buttonsink"])
				buttonBag:Hide()
			else
				buttonBag:Show()
			end
		elseif addon.variables.buttonSink then
			removeButtonSink()
		end
	end

	function addon.functions.LayoutButtons()
		if addon.db["enableMinimapButtonBin"] then
			if addon.variables.buttonSink then
				local index = 0
				for name, button in pairs(addon.variables.bagButtons) do
					if addon.db["ignoreMinimapButtonBin_" .. name] then
						button:ClearAllPoints()
						button:SetParent(Minimap)
						if addon.variables.bagButtonPoint[name] then
							local pData = addon.variables.bagButtonPoint[name]
							if pData.point and pData.relativePoint and pData.relativeTo and pData.xOfs and pData.yOfs then
								button:SetPoint(pData.point, pData.relativeTo, pData.relativePoint, pData.xOfs, pData.yOfs)
							end
							if button:GetFrameStrata() == "LOW" then button:SetFrameStrata("MEDIUM") end
						end
					elseif addon.variables.bagButtonState[name] then
						index = index + 1
						button:ClearAllPoints()
						local col = (index - 1) % COLUMNS
						local row = math.floor((index - 1) / COLUMNS)

						button:SetParent(addon.variables.buttonSink)
						button:SetSize(ICON_SIZE, ICON_SIZE)
						button:SetPoint("TOPLEFT", addon.variables.buttonSink, "TOPLEFT", col * (ICON_SIZE + PADDING) + PADDING, -row * (ICON_SIZE + PADDING) - PADDING)
						button:Show()
					else
						button:Hide()
					end
				end

				local totalRows = math.ceil(index / COLUMNS)
				local width = (ICON_SIZE + PADDING) * COLUMNS + PADDING
				local height = (ICON_SIZE + PADDING) * totalRows + PADDING
				addon.variables.buttonSink:SetSize(width, height)
			end
		else
			for name, button in pairs(addon.variables.bagButtons) do
				button:ClearAllPoints()
				button:SetParent(Minimap)
				addon.variables.bagButtons[name] = nil
				addon.variables.bagButtonState[name] = nil
				if addon.variables.bagButtonPoint[name] then
					local pData = addon.variables.bagButtonPoint[name]
					if pData.point and pData.relativePoint and pData.relativeTo and pData.xOfs and pData.yOfs then
						button:SetPoint(pData.point, pData.relativeTo, pData.relativePoint, pData.xOfs, pData.yOfs)
					else
						LDBIcon:Show(name)
					end
					if button:GetFrameStrata() == "LOW" then button:SetFrameStrata("MEDIUM") end
					addon.variables.bagButtonPoint[name] = nil
				end
			end
		end
	end

	function addon.functions.gatherMinimapButtons()
		for _, child in ipairs({ Minimap:GetChildren() }) do
			if child:IsObjectType("Button") and child:GetName() then
				local btnName = child:GetName():gsub("^LibDBIcon10_", ""):gsub(".*_LibDBIcon_", "")
				if
					not (
						btnName == "MinimapZoomIn"
						or btnName == "MinimapZoomOut"
						or btnName == "MiniMapWorldMapButton"
						or btnName == "MiniMapTracking"
						or btnName == "GameTimeFrame"
						or btnName == "MinimapMailFrame"
						or btnName:match("^HandyNotesPin")
						or btnName == addonName .. "_ButtonSinkMap"
					)
				then
					if not addon.variables.bagButtonPoint[btnName] or not addon.variables.bagButtonPoint[btnName].point then
						local point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
						addon.variables.bagButtonPoint[btnName] = {
							point = point,
							relativeTo = relativeTo,
							relativePoint = relativePoint,
							xOfs = xOfs,
							yOfs = yOfs,
						}
					end
					if (child.db and child.db.hide) or not child:IsVisible() then
						addon.variables.bagButtonState[btnName] = false
					else
						addon.variables.bagButtonState[btnName] = true
						addon.variables.bagButtons[btnName] = child
					end
				end
			end
		end
	end
	hooksecurefunc(LDBIcon, "Show", function(self, name)
		if addon.db["enableMinimapButtonBin"] then
			if nil ~= addon.variables.bagButtonState[name] then addon.variables.bagButtonState[name] = true end
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()
		end
	end)

	hooksecurefunc(LDBIcon, "Hide", function(self, name)
		if addon.db["enableMinimapButtonBin"] then
			addon.variables.bagButtonState[name] = false
			addon.functions.gatherMinimapButtons()
			addon.functions.LayoutButtons()
		end
	end)

	local radioRows = {}
	local maxTextWidth = 0
	local rowHeight = 28 -- Höhe pro Zeile (Font + etwas Puffer)
	local totalRows = 0

	function addon.functions.updateLootspecIcon()
		if not LDBIcon or not LDBIcon:IsRegistered(addonName .. "_LootSpec") then return end

		local _, specIcon

		local curSpec = GetSpecialization()

		if GetLootSpecialization() == 0 and curSpec then
			_, _, _, specIcon = GetSpecializationInfoForClassID(addon.variables.unitClassID, curSpec)
		else
			_, _, _, specIcon = GetSpecializationInfoByID(GetLootSpecialization())
		end

		local button = LDBIcon.objects[addonName .. "_LootSpec"]
		if button and button.icon and specIcon then button.icon:SetTexture(specIcon) end
	end

	local function UpdateRadioSelection()
		local lootSpecID = GetLootSpecialization() or 0
		for _, row in ipairs(radioRows) do
			row.radio:SetChecked(row.specId == lootSpecID)
		end
	end

	local function CreateRadioRow(parent, specId, specName, index)
		totalRows = totalRows + 1

		local row = CreateFrame("Button", "MyRadioRow" .. index, parent, "BackdropTemplate")
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		row:GetHighlightTexture():SetAlpha(0.3)

		row.radio = CreateFrame("CheckButton", "$parentRadio", row, "UIRadioButtonTemplate")
		row.radio:SetPoint("LEFT", row, "LEFT", 4, 0)
		row.radio:SetChecked(false)

		row.radio.text:SetFontObject(GameFontNormalLarge)
		row.radio.text:SetText(specName)

		row:RegisterForClicks("AnyUp")
		row.radio:RegisterForClicks("AnyUp")

		local textWidth = row.radio.text:GetStringWidth()
		if textWidth > maxTextWidth then maxTextWidth = textWidth end

		row.specId = specId

		row:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				SetLootSpecialization(specId)
			else
				C_SpecializationInfo.SetSpecialization(index)
			end
		end)

		row.radio:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				SetLootSpecialization(specId)
			else
				C_SpecializationInfo.SetSpecialization(index)
			end
		end)

		table.insert(radioRows, row)
		return row
	end

	function addon.functions.removeLootspecframe()
		if LDBIcon:IsRegistered(addonName .. "_LootSpec") then
			local button = LDBIcon.objects[addonName .. "_LootSpec"]
			if button then button:Hide() end
			LDBIcon.objects[addonName .. "_LootSpec"] = nil
		end
		if addon.variables.lootSpec then
			addon.variables.lootSpec:SetParent(nil)
			addon.variables.lootSpec:SetScript("OnEvent", nil)
			addon.variables.lootSpec:Hide()
			addon.variables.lootSpec = nil
		end
	end

	local function hoverCheckHide(frame)
		if frame and frame:IsVisible() then
			if not MouseIsOver(frame) then
				frame:Hide()
			else
				C_Timer.After(1, function() hoverCheckHide(frame) end)
			end
		end
	end

	function addon.functions.createLootspecFrame()
		totalRows = 0
		radioRows = {}
		local lootSpec = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
		lootSpec:SetPoint("CENTER")
		lootSpec:SetSize(200, 200) -- Erstmal ein Dummy-Wert, wir passen es später an
		lootSpec:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		lootSpec:SetBackdropColor(0, 0, 0, 0.4)
		lootSpec:SetBackdropBorderColor(1, 1, 1, 1)
		addon.variables.lootSpec = lootSpec
		lootSpec:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		lootSpec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		lootSpec:SetScript("OnEvent", function(self, event)
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then
				addon.functions.removeLootspecframe()
				addon.functions.createLootspecFrame()
			end
			addon.functions.updateLootspecIcon()
			UpdateRadioSelection()
		end)

		local container = CreateFrame("Frame", nil, lootSpec, "BackdropTemplate")
		container:SetPoint("TOPLEFT", 10, -10)
		if nil == GetSpecialization() then return end

		local _, curSpecName = GetSpecializationInfoForClassID(addon.variables.unitClassID, GetSpecialization())
		local totalSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(addon.variables.unitClassID)
		local row = CreateRadioRow(container, 0, string.format(LOOT_SPECIALIZATION_DEFAULT, curSpecName), 0)
		for i = 1, totalSpecs do
			local specID, specName, _, specIcon = GetSpecializationInfoForClassID(addon.variables.unitClassID, i)
			CreateRadioRow(container, specID, specName, i)
		end

		for i, row in ipairs(radioRows) do
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -(i - 1) * rowHeight)
			row:SetSize(maxTextWidth + 40, rowHeight)
		end

		local finalHeight = #radioRows * rowHeight + 20
		local finalWidth = math.max(maxTextWidth + 40, 150)

		container:SetSize(finalWidth, finalHeight)
		lootSpec:SetSize(finalWidth + 20, finalHeight + 20)

		local iconData = {
			type = "launcher",
			icon = "Interface\\ICONS\\INV_Misc_QuestionMark", -- irgendein Icon
			label = addonName .. "_LootSpec",
			OnEnter = function(self)
				if addon.variables.lootSpec then
					positionBagFrame(addon.variables.lootSpec, LDBIcon.objects[addonName .. "_LootSpec"])
					addon.variables.lootSpec:Show()
				end
			end,
			OnLeave = function(self)
				C_Timer.After(1, function() hoverCheckHide(addon.variables.lootSpec) end)
			end,
		}

		LDB:NewDataObject(addonName .. "_LootSpec", iconData)
		LDBIcon:Register(addonName .. "_LootSpec", iconData, addon.db["lootspec_quickswitch"])

		UpdateRadioSelection()
		lootSpec:Hide()
		addon.functions.updateLootspecIcon()
	end

	if addon.db["enableLootspecQuickswitch"] then addon.functions.createLootspecFrame() end
end

addon.UI = {
	addChatFrame = addChatFrame,
	addMinimapFrame = addMinimapFrame,
	addUnitFrame = addUnitFrame,
	addAuctionHouseFrame = addAuctionHouseFrame,
	addActionBarFrame = addActionBarFrame,
	addUIFrame = addUIFrame,
	initUnitFrame = initUnitFrame,
	initBagsFrame = initBagsFrame,
	initChatFrame = initChatFrame,
	initUI = initUI,
}

return addon.UI
