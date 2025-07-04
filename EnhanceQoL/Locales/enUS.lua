local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale("EnhanceQoL", "enUS", true) -- “true” = default / fallback

L["Quick signup"] = "Quick signup"
L["interruptWithShift"] = "Hold shift to interrupt that feature"

L["Persist LFG signup note"] = "Persist LFG signup note"
L["Select an option"] = "Select an option"
L["Save"] = "Save"
L["Hide Minimap Button"] = "Hide Minimap Button"
L["Left-Click to show options"] = "Left-Click to show options"

L["Hide Raid Tools"] = "Hide Raid Tools in Party"
L["repairCost"] = "Repaired items for "
L["autoRepair"] = "Automatically repair all items"
L["sellAllJunk"] = "Automatically sell all junk items"
L["ignoreTalkingHead"] = "Automatically hide Talking Head Frame"
L["autoCancelCinematic"] = "Automatically skip cinematics if possible"
L["landingPageHide"] = "Enable this option to hide the Expansion Landing Page button on the minimap."
L["automaticallyOpenContainer"] = "Automatically open Container items in bag"

L["bagFilterDockFrameUnlock"] = "Click to undock the filter window from your bags"
L["bagFilterDockFrameLock"] = "Click to dock the filter window to your bags"
L["enableMoneyTracker"] = "Enable to track your money across all characters"
L["enableMoneyTrackerDesc"] = "When you mouse over your gold in your bags, you can see the gold of all characters"
L["showOnlyGoldOnMoney"] = "Show account gold only (hide silver and copper)"
L["moneyTrackerRemovePlayer"] = "All known characters"
L["showBagFilterMenu"] = "Enable item filter in bags"
L["showBagFilterMenuDesc"] = "Only usable when Combined Bags is enabled. Hold %s to move the frame"
L["fadeBagQualityIcons"] = "Fade profession quality icons during search and filtering"
L["bagFilterSpec"] = "Recommended for Specialization"
L["bagFilterEquip"] = "Equipment Only"
L["bagFilterBindType"] = "Bind Type"
L["bagFilterUpgradeLevel"] = "Upgrade Level"
L["bagFilterResetFilters"] = "Reset all filters"
L["upgradeLevelVeteran"] = "Veteran"
L["upgradeLevelChampion"] = "Champion"
L["upgradeLevelHero"] = "Hero"
L["upgradeLevelMythic"] = "Myth"
L["misc_sellable"] = "Can Vendor item"
L["misc_auctionhouse_sellable"] = "Can Sell in Auction House"

L["showIlvlOnBankFrame"] = "Display item level on the Bank Frame"
L["showIlvlOnMerchantframe"] = "Display item level on the Merchant Frame"
L["showIlvlOnCharframe"] = "Display item level on Character Equipment Frame"
L["showGemsOnCharframe"] = "Display gem slots on Character Equipment Frame"
L["showBindOnBagItems"] = "Display %s (BoE), %s (WuE), and %s (WB) as an addition to item level on items"
L["showGemsTooltipOnCharframe"] = "Display gem slots tooltip on Character Equipment Frame"
L["showEnchantOnCharframe"] = "Display enchants on Character Equipment Frame"
L["showCatalystChargesOnCharframe"] = "Display Catalyst charges on Character Equipment Frame"
L["showIlvlOnBagItems"] = "Display ilvl on equipment in all bags"
L["showDurabilityOnCharframe"] = "Display Durability on Character Equipment Frame"
L["hideOrderHallBar"] = "Hide Order Hall Command Bar"
L["showInfoOnInspectFrame"] = "Show additional information on the Inspect Frame"
L["MissingEnchant"] = "Enchant"
L["hideHitIndicatorPlayer"] = "Hide floating combat text (damage and healing) over your character"
L["hideHitIndicatorPet"] = "Hide floating combat text (damage and healing) over your pet"
L["UnitFrame"] = "UnitFrame"
L["SellJunkIgnoredBag"] = "You have ignored junk on %d bags.\nThis may prevent selling all junk items automatically."
L["enableGemHelper"] = "Enable Gem-Socket Helper"
L["enableGemHelperDesc"] = "Displays a helper panel when you open the socketing UI.\nLeft-click a gem to pick it up."

L["deleteItemFillDialog"] = 'Add "%s" to the "Delete confirmation Popup"'
L["confirmPatronOrderDialog"] = "Automatically confirm to use own materials on %s crafting orders"
L["autoChooseQuest"] = "Automatically accept and complete Quests"
L["confirmTimerRemovalTrade"] = "Automatically confirm to sell tradeable loot within the trade window time frame"

L["General"] = "General"
L["Character"] = "Character"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Misc."
L["Quest"] = "Quest"
L["Loot"] = "Loot"

L["hideBagsBar"] = "Hide Bagsbar"
L["hideMicroMenu"] = "Hide Micro Menu"
L["MicroMenu"] = "Micro Menu"
L["BagsBar"] = "Bags Bar"
-- Dungeon
L["autoChooseDelvePower"] = "Automatically select delve power when only 1 option"
L["lfgSortByRio"] = "Sort Mythic Dungeon Applicants by Mythic Score"
L["DungeonBrowser"] = "Dungeonbrowser"
L["groupfinderAppText"] = 'Hide the group finder text "Your group is currently forming"'
L["groupfinderMoveResetButton"] = "Shift the 'Reset Filter' button in the Dungeon Browser to the left side"
L["groupfinderSkipRoleSelect"] = "Skip role selection"
L["groupfinderSkipRolecheckHeadline"] = "Automatic role assignment"
L["groupfinderSkipRolecheckUseSpec"] = "Use your current spec's role (e.g. Blood Death Knight = Tank)"
L["groupfinderSkipRolecheckUseLFD"] = "Use roles from Dungeon Finder"

-- Quest
L["ignoreTrivialQuests"] = "Don't automatically handle trivial %s"
L["ignoreDailyQuests"] = "Don't automatically handle daily/weekly %s"
L["ignoreWarbandCompleted"] = "Don't automatically handle %s %s"

L["autoQuickLoot"] = "Quick loot items"
L["openCharframeOnUpgrade"] = "Open the character frame when upgrading items at the vendor"
L["instantCatalystEnabled"] = "Instant Catalyst button"
L["Instant Catalyst"] = "Instant Catalyst"
L["enableLootToastFilter"] = "Enable custom loot toasts"
L["lootToastItemLevel"] = "Item level threshold"
L["lootToastCheckIlvl"] = "Check item level"
L["lootToastCheckRarity"] = "Check rarity"
L["lootToastRarity"] = "Rarities"
L["lootToastIncludeMounts"] = "Show for mounts"
L["lootToastIncludePets"] = "Show for pets"
L["lootToastIncludeLegendaries"] = "Show for legendaries"
L["lootToastExplanation"] =
	"Only loot toasts that match at least one filter will be shown. If rarity filtering is enabled the selected rarities also apply to mounts and pets. Item level is ignored for mounts and pets."

L["headerClassInfo"] = "These settings only apply to %s"

-- Deathknight
L["deathknight_HideRuneFrame"] = "Hide Runeframe"

-- Evoker
L["evoker_HideEssence"] = "Hide Essencebar"

-- Monk
L["monk_HideHarmonyBar"] = "Hide Harmonybar"
-- Paladin
L["paladin_HideHolyPower"] = "Hide Holypowerbar"

-- Rogue
L["rogue_HideComboPoint"] = "Hide Combopointbar"

-- Druid
L["druid_HideComboPoint"] = "Hide Combopointbar"

-- Shaman
L["shaman_HideTotem"] = "Hide Totembar"

-- Warlock
L["warlock_HideSoulShardBar"] = "Hide Soulshard Bar"

L["questAddNPCToExclude"] = "Add targetted NPC/opened Gossipwindow to exclude"

-- CVar
L["CVar"] = "CVar"
L["tReloadInterface"] = "Interface Reload Required"
L["bReloadInterface"] = "You need to reload your interface to apply changes"

L["autoDismount"] = "Enable autodismount when using abilities"
L["autoDismountFlying"] = "Enable autodismount when using abilities while flying"
L["chatMouseScroll"] = "Enable mouse scroll in chat"
L["ffxDeath"] = "Disable death effects"
L["mapFade"] = "Enable Map Fade while moving"
L["scriptErrors"] = "Show LUA-Error on UI"
L["ShowClassColorInNameplate"] = "Show class colors on nameplates"
L["ShowTargetCastbar"] = "Show the Castbar of your Target"
L["showTutorials"] = "Disable tutorials"
L["UberTooltips"] = "Enable enhanced tooltips"
L["UnitNamePlayerGuild"] = "Show the Guild on Players"
L["UnitNamePlayerPVPTitle"] = "Show the Title on Players"
L["WholeChatWindowClickable"] = "Make the entire chat window clickable"

L["autoAcceptGroupInvite"] = "Automatically accept group invites"
L["autoAcceptGroupInviteGuildOnly"] = "Guild members"
L["autoAcceptGroupInviteFriendOnly"] = "Friends"
L["autoAcceptGroupInviteOptions"] = "Accept invites from..."

L["showLeaderIconRaidFrame"] = "Show leader icon on raid-style party frames"
L["showPartyFrameInSoloContent"] = "Show Party Frames in Solo Content"
L["hidePlayerFrame"] = "Hide Player Frame"
L["hideRaidFrameBuffs"] = "Hide buffs on raid-style frames"

L["ActionbarHideExplain"] = 'Set the action bar to hidden and show on mouseover. This works only when your Action Bar is set to "%s" and "%s" in %s'

L["enableMinimapButtonBin"] = "Enable Minimap Button Sink"
L["enableMinimapButtonBinDesc"] = "Collect all minimap buttons in a single button"
L["ignoreMinimapSinkHole"] = "Ignore the following minimap button from the sinkhole..."
L["useMinimapButtonBinIcon"] = "Use a Minimap button for the sink"
L["useMinimapButtonBinMouseover"] = "Show a movable frame for the button sink with mouseover"
L["lockMinimapButtonBin"] = "Lock the button sink frame"

L["UnitFrameHideExplain"] = "Hide the element and only show it on mouseover"
L["chatFrameFadeEnabled"] = "Enable chat fading"
L["chatFrameFadeTimeVisibleText"] = "Text remains visible for"
L["chatFrameFadeDurationText"] = "Fade animation duration"
L["enableChatIM"] = "Enable Instant Messenger"
L["enableChatIMDesc"] = "Open whispers in a compact IM-style window.\n/eim to open the frame"
L["enableChatIMFade"] = "Fade Instant Messenger when unfocused"
L["enableChatIMFadeDesc"] = "Reduce the window’s opacity when it loses focus"
L["Instant Chats"] = "Instant Chats"
L["RightClickCloseTab"] = "Right-click a tab to close it.\nPrevious messages are saved in a per-player history.\nRight-click a name for actions like Invite, Raider.IO link etc."
L["ChatIMHistoryLimit"] = "Maximum stored messages per player"
L["ChatIMHistoryPlayer"] = "History for"
L["ChatIMHistoryDelete"] = "Delete history"
L["ChatIMHistoryDeleteConfirm"] = "Delete all history with %s?"
L["ChatIMHistoryClearAll"] = "Clear all history"
L["ChatIMHistoryClearConfirm"] = "Delete all stored IM history?"
L["enableChatIMRaiderIO"] = "Enable Raider.IO link in Context Menu"
L["enableChatIMWCL"] = "Enable Warcraftlogs link in Context Menu"
L["RaiderIOUrl"] = "Copy Raider.IO URL"
L["WCLUrl"] = "Copy Warcraftlogs URL"
L["enableChatIMCustomSound"] = "Use custom whisper sound"
L["ChatIMCustomSound"] = "Whisper sound"
L["chatIMHideInCombat"] = "Hide Instant Messenger in combat"
L["chatIMHideInCombatDesc"] = "Suppress the IM window and sounds while you are in combat"
L["chatIMUseAnimation"] = "Animate window"
L["chatIMUseAnimationDesc"] = "Slide the window in and out when showing or hiding"
L["communityWarningLink"] = "This link must be opened in Blizzard’s default chat. It has been added to your chat frame."

L["enableLootspecQuickswitch"] = "Enable quick switching for loot and active specializations on the Minimap"
L["enableLootspecQuickswitchDesc"] = "Left-click a specialization to set your loot spec, or right-click to change your active specialization."

L["enableSquareMinimap"] = "Use a square minimap instead of the normal round"
L["enableSquareMinimapDesc"] = "This option required a reload"

L["Profiles"] = "Profiles"
L["currentExpensionMythicPlusWarning"] = "For Mythic+ items from legacy dungeons, the results may be inaccurate."

-- Map
L["enableWayCommand"] = "Enable /way command"
L["enableWayCommandDesc"] = "Checks whether another add-on already claims /way before registering it."
L["wayUsage"] = "Usage: /way [mapID] 37.8 61.2"
L["waySet"] = "Waypoint set on map %s at %.1f %.1f"
L["wayError"] = "Map ID %s not found"
L["wayErrorPlacePing"] = "You can't place a waypoint here"
L["wayMapUnknown"] = "Map unknown – try again outdoors."

L["persistAuctionHouseFilter"] = "Remember Auction House filters for this session"

L["Excluded NPCs"] = "Excluded NPCs"
L["hideDynamicFlightBar"] = "Hide %s Vigor bar while on the ground"
L["InvalidExpiration"] = "Invalid expiration value"

-- Ignore module
L["IgnorePlayer"] = "Player"
L["IgnoreServer"] = "Realm"
L["IgnoreListed"] = "Added"
L["IgnoreExpires"] = "Expires"
L["IgnoreNote"] = "Note"
L["IgnoreEntries"] = "Entries: %d"
L["IgnoreWindowTitle"] = "Enhanced Ignore"
L["IgnoreExpiresDays"] = "Expires (days)"
L["IgnoreAddSave"] = "Add / Save"
L["IgnoreGroupPopupTitle"] = "Ignored group members"
L["IgnoreGroupPopupText"] = "The following ignored players are in your group:\n%s"
L["Social"] = "Social"
L["EnableAdvancedIgnore"] = "Enable advanced ignore list"
L["IgnoreAttachFriends"] = "Open with Friends list"
L["IgnoreAttachFriendsDesc"] = "Automatically show or hide the enhanced ignore list when the Friends list opens or closes."
L["IgnoreAnchorFriends"] = "Anchor to Friends list"
L["IgnoreAnchorFriendsDesc"] = "Attach the enhanced ignore list to the Friends window."
L["IgnoreDesc"] =
	'Blocks duel, pet-battle, trade, invite and whisper requests from ignored players. Automatically adds same-realm names to Blizzard’s ignore list when space is available.\nIn the Dungeon Finder ignored players are shown as "!!! <Name> !!!".\n\nOpen the list with /eil.'
L["ImportGILDialog"] = "GlobalIgnoreList data found. Import its entries and disable that addon? Both addons cannot be active at the same time."
L["ImportGILCancelDialog"] = "Disable either the advanced ignore option or GlobalIgnoreList and reload your interface."
L["ImportGILAccept"] = "Import & Reload"
L["GILActivePopup"] = "Advanced ignore disabled because GlobalIgnoreList is active. Disable that addon and re-enable the option."
L["IgnoredApplicant"] = "Player is on your ignore list"
L["IgnoreAdded"] = "%s has been added to your ignore list"
L["IgnoreRemoved"] = "%s has been removed from your ignore list"
L["IgnoreExpiredRemoved"] = "%s was removed from your ignore list (expired)"
