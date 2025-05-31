# Enhance QoL – Options Reference

Enhance QoL is a modular collection of small tweaks and user interface improvements for World of Warcraft. Every feature can be toggled individually, so you can enable only the tools you like.

This document lists the checkboxes found in `EnhanceQoL.lua` and briefly explains what each option does. They are grouped roughly by feature block to match the configuration window.

## Chat

### Chat Fading
- **Enable chat fading** (`chatFrameFadeEnabled`): allow chat messages to fade out after a short delay.
  When enabled you can adjust how long text stays visible and how quickly it fades.

### Instant Messenger
- **Enable Instant Messenger** (`enableChatIM`): open whispers in a compact IM-style window (`/eim` toggles the frame).
- **Fade Instant Messenger when unfocused** (`enableChatIMFade`): reduce the window's opacity when it is not active.
- **Enable Raider.IO link in Context Menu** (`enableChatIMRaiderIO`): add a context menu entry to copy the sender's Raider.IO profile URL.
- **Enable Warcraftlogs link in Context Menu** (`enableChatIMWCL`): add a WarcraftLogs URL to the context menu.
- **Use custom whisper sound** (`chatIMUseCustomSound`): choose a custom sound for new messages.
- **Hide Instant Messenger in combat** (`chatIMHideInCombat`): suppress the IM window and sound while you are in combat.
- **Animate window** (`chatIMUseAnimation`): slide the IM window in and out when showing or hiding.

## Bags & Inventory
- **Display item level on the Merchant Frame** (`showIlvlOnMerchantframe`).
- **Display ilvl on equipment in all bags** (`showIlvlOnBagItems`).
- **Enable item filter in bags** (`showBagFilterMenu` – drag with <kbd>Shift</kbd> to move).
- **Enable money tracker** (`enableMoneyTracker`): track gold across all characters.
- **Display item level on the Bank Frame** (`showIlvlOnBankFrame`).
- **Display bind type on bag items** (`showBindOnBagItems`).
- **Fade profession quality icons during search** (`fadeBagQualityIcons`).
- If the money tracker is enabled: **Show account gold only** (`showOnlyGoldOnMoney`).

## Character & Inspect
- **Display item level on Character Equipment Frame** (`showIlvlOnCharframe`).
- **Display gem slots tooltip on Character Frame** (`showGemsTooltipOnCharframe`).
- **Display gem slots on Character Frame** (`showGemsOnCharframe`).
- **Display enchants on Character Frame** (`showEnchantOnCharframe`).
- **Display durability on Character Frame** (`showDurabilityOnCharframe`).
- **Hide Order Hall Command Bar** (`hideOrderHallBar`).
- **Show additional information on the Inspect Frame** (`showInfoOnInspectFrame`).
- **Display Catalyst charges on Character Frame** (`showCatalystChargesOnCharframe`).
- **Enable Gem-Socket Helper** (`enableGemHelper`).
- Class-specific toggles such as **Hide Rune Frame** or **Hide Combo Point Bar** appear when you log in with the corresponding class.

## Action Bars & Mouse
Each action bar can be set to appear only on mouseover:
- `mouseoverActionBar1` through `mouseoverActionBar8` (main and multi bars).
- `mouseoverActionBarPet` (pet bar).
- `mouseoverActionBarStanceBar` (stance bar).

## Unit Frames
- **Hide floating combat text over your character** (`hideHitIndicatorPlayer`).
- **Hide floating combat text over your pet** (`hideHitIndicatorPet`).
- Additional options allow Target, Player or Boss frames to remain hidden until the mouse is over them.

## Minimap & Micro Menu
- **Enable quick switching for loot and active specializations** (`enableLootspecQuickswitch`).
- **Enable Minimap Button Sink** (`enableMinimapButtonBin`): gather minimap buttons in a single frame. When enabled additional options appear:
  - **Use a Minimap button for the sink** (`useMinimapButtonBinIcon`).
  - **Show a movable frame for the button sink with mouseover** (`useMinimapButtonBinMouseover`).
  - **Lock the button sink frame** (`lockMinimapButtonBin`).
- **Use a square minimap** (`enableSquareMinimap`).
- **Hide Minimap Button** (`hideMinimapButton`).
- **Hide Bagsbar** (`hideBagsBar`).
- **Hide Micro Menu** (`hideMicroMenu`).
- **Hide Quick Join Toast** (`hideQuickJoinToast`).
- **Hide Raid Tools in Party** (`hideRaidTools`).
- Options are also provided to hide specific Landing Page buttons.

## Party & Raid Tools
- **Automatically accept group invites** (`autoAcceptGroupInvite`).
  - **Guild members** (`autoAcceptGroupInviteGuildOnly`).
  - **Friends** (`autoAcceptGroupInviteFriendOnly`).
- **Show leader icon on raid-style party frames** (`showLeaderIconRaidFrame`).
- **Show Party Frames in Solo Content** (`showPartyFrameInSoloContent`).

## Dungeon / Mythic+
- **Hide the group finder text 'Your group is currently forming'** (`groupfinderAppText`).
- **Shift the 'Reset Filter' button in the Dungeon Browser** (`groupfinderMoveResetButton`).
- **Skip role selection** (`groupfinderSkipRoleSelect`).
- **Automatically select delve power when only one option** (`autoChooseDelvePower`).
- **Persist LFG signup note** (`persistSignUpNote`).
- **Quick signup** (`skipSignUpDialog`).
- **Sort Mythic Dungeon applicants by Mythic Score** (`lfgSortByRio`).

## Quest & Vendor Automation
- **Automatically accept and complete quests** (`autoChooseQuest`).
- **Don't automatically handle daily/weekly quests** (`ignoreDailyQuests`).
- **Don't automatically handle trivial quests** (`ignoreTrivialQuests`).
- **Don't automatically handle account-completed quests** (`ignoreWarbandCompleted`).
- **Automatically repair all items** (`autoRepair`).
- **Automatically sell all junk items** (`sellAllJunk`).
- **Add 'DELETE' to the confirmation text automatically** (`deleteItemFillDialog`).
- **Automatically confirm to use own materials on Crafting Orders** (`confirmPatronOrderDialog`).
- **Automatically confirm to sell tradeable loot** (`confirmTimerRemovalTrade`).
- **Open the character frame when upgrading items at the vendor** (`openCharframeOnUpgrade`).
- **Quick loot items** (`autoQuickLoot`).

## Map Tools
- **Enable /way command** (`enableWayCommand`): provides a simple waypoint command if no other addon uses `/way`.

## CVar Tweaks
The **CVar** section exposes common console variables as checkboxes. Changing them usually requires a reload:
- `autoDismount`
- `autoDismountFlying`
- `chatMouseScroll`
- `ffxDeath`
- `mapFade`
- `scriptErrors`
- `ShowClassColorInNameplate`
- `ShowTargetCastbar`
- `showTutorials`
- `UberTooltips`
- `UnitNamePlayerGuild`
- `UnitNamePlayerPVPTitle`
- `WholeChatWindowClickable`

---

These descriptions should help you understand what each checkbox in the configuration does. For more details see the README or the in-game tooltips.
