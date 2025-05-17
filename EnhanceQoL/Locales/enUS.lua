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

L["deleteItemFillDialog"] = 'Add "%s" to the "Delete confirmation Popup"'
L["confirmPatronOrderDialog"] = "Automatically confirm to use own materials on %s crafting orders"
L["autoChooseQuest"] = "Automatically accept and complete Quests"
L["confirmTimerRemovalTrade"] = "Automatically confirm to sell tradeable loot within the trade window time frame"

L["General"] = "General"
L["Character"] = "Character"
L["Dungeon"] = "Dungeon"
L["Misc"] = "Misc."
L["Quest"] = "Quest"

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

L["enableLootspecQuickswitch"] = "Enable quick switching for loot and active specializations on the Minimap"
L["enableLootspecQuickswitchDesc"] = "Left-click a specialization to set your loot spec, or right-click to change your active specialization."

L["enableSquareMinimap"] = "Use a square minimap instead of the normal round"
L["enableSquareMinimapDesc"] = "This option required a reload"

L["Profiles"] = "Profiles"
L["currentExpensionMythicPlusWarning"] = "For Mythic+ items from legacy dungeons, the results may be inaccurate."

L["persistAuctionHouseFilter"] = "Remember Auction House filters for this session"

L["Excluded NPCs"] = "Excluded NPCs"
