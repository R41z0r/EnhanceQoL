local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local L = addon.LSounds

addon.variables.statusTable.groups["sound"] = true

addon.functions.addToTree(nil, {
	value = "sound",
	text = SOUND,
	children = {
		{ value = "general", text = ACCESSIBILITY_GENERAL_LABEL },
		{ value = "toy", text = TOY },
		{ value = "interface", text = INTERFACE_LABEL, children = { { value = "auctionhouse", text = BUTTON_LAG_AUCTIONHOUSE }, { value = "general", text = GENERAL } } },
		{ value = "emotes", text = CHAT_MSG_EMOTE },
		{ value = "dungeon", text = LFG_TYPE_DUNGEON, children = { { value = "affix", text = L["affix"] } } },
		{ value = "class", text = CLASS, children = { { value = "monk", text = "Monk" }, { value = "deathknight", text = "Death Knight" } } },
	},
}, true)

local AceGUI = addon.AceGUI

local function addDrinkFrame(container) end

local function toggleSounds(sounds, state)
	if type(sounds) == "table" then
		for _, v in pairs(sounds) do
			if state then
				MuteSoundFile(v)
			else
				UnmuteSoundFile(v)
			end
		end
	end
end

local function addClassFrame(container, group, sounds)
	if sounds then
		local sortedKeys = {}
		for key in pairs(sounds) do
			table.insert(sortedKeys, key)
		end
		table.sort(sortedKeys, function(a, b) return L[a] < L[b] end) -- Alphabetisch sortieren

		local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
		container:AddChild(wrapper)

		local groupCore = addon.functions.createContainer("InlineGroup", "List")
		wrapper:AddChild(groupCore)

		for _, key in ipairs(sortedKeys) do
			if L[key] then
				local cbElement = addon.functions.createCheckboxAce(L[key], addon.db["sounds_" .. group .. "_" .. key], function(self, _, value)
					addon.db["sounds_" .. group .. "_" .. key] = value
					toggleSounds(sounds[key], value)
				end)
				groupCore:AddChild(cbElement)
			end
		end
	end
end

function addon.Sounds.functions.treeCallback(container, group)
	container:ReleaseChildren() -- Entfernt vorherige Inhalte
	if group == "sound\001class\001monk" then
		addClassFrame(container, "class_monk", addon.Sounds.soundFiles["class"]["monk"])
	elseif group == "sound\001dungeon\001affix" then
		addClassFrame(container, "dungeon_affix", addon.Sounds.soundFiles["dungeon"]["affix"])
	elseif group == "sound\001toy" then
		addClassFrame(container, "toy")
	elseif group == "sound\001emotes" then
		addClassFrame(container, "emotes", addon.Sounds.soundFiles["emotes"])
	elseif group == "sound\001interface\001auctionhouse" then
		addClassFrame(container, "interface_auctionhouse", addon.Sounds.soundFiles["interface"]["auctionhouse"])
	elseif group == "sound\001interface\001general" then
		addClassFrame(container, "interface_general", addon.Sounds.soundFiles["interface"]["general"])
	end
end

-- init all active Settings

for topic in pairs(addon.Sounds.soundFiles) do
	if topic == "emotes" then
	else
		for class in pairs(addon.Sounds.soundFiles[topic]) do
			for key in pairs(addon.Sounds.soundFiles[topic][class]) do
				if addon.db["sounds_" .. topic .. "_" .. class .. "_" .. key] then toggleSounds(addon.db["sounds_" .. topic .. "_" .. class .. "_" .. key]) end
			end
		end
	end
end

hooksecurefunc("PlaySound", function(soundID, channel, forceNoDuplicates)
	print("Sound played:", soundID, "on channel:", channel)
	-- Hier kannst du deine Logik hinzufügen, z.B. Logging oder Tracking
end)

-- Hook für PlaySoundFile
hooksecurefunc("PlaySoundFile", function(soundFile, channel)
	print("Sound file played:", soundFile, "on channel:", channel)
	-- Hier kannst du auch deine Logik hinzufügen
end)
