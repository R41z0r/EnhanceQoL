# Enhance QoL – Options Reference

Enhance QoL is a modular collection of small tweaks and user interface improvements for World of Warcraft. Every feature can be toggled individually, so you can enable only the tools you like.

This document lists the checkboxes found in EnhanceQoL.lua and briefly explains what each option does. They are grouped roughly by feature block to match the configuration window.

## Chat

### Chat Fading
- **Enable chat fading** (Enable chat fading): allow chat messages to fade out after a short delay.
  When enabled you can adjust how long text stays visible and how quickly it fades.

### Instant Messenger
- **Enable Instant Messenger** (Enable Instant Messenger): open whispers in a compact IM-style window (/eim toggles the frame).
- **Fade Instant Messenger when unfocused** (Fade Instant Messenger when unfocused): reduce the window's opacity when it is not active.
- **Enable Raider.IO link in Context Menu** (Enable Raider.IO link in Context Menu): add a context menu entry to copy the sender's Raider.IO profile URL.
- **Enable Warcraftlogs link in Context Menu** (Enable Warcraftlogs link in Context Menu): add a WarcraftLogs URL to the context menu.
- **Use custom whisper sound** (Use custom whisper sound): choose a custom sound for new messages.
- **Hide Instant Messenger in combat** (Hide Instant Messenger in combat): suppress the IM window and sound while you are in combat.
- **Animate window** (Animate window): slide the IM window in and out when showing or hiding.

## Bags & Inventory
- **Display item level on the Merchant Frame** (Display item level on the Merchant Frame).
- **Display ilvl on equipment in all bags** (Display ilvl on equipment in all bags).
- **Enable item filter in bags** (Enable item filter in bags – drag with <kbd>Shift</kbd> to move).
- **Enable money tracker** (Enable to track your money across all characters): track gold across all characters.
- **Display item level on the Bank Frame** (Display item level on the Bank Frame).
- **Display bind type on bag items** (Display %s (BoE), %s (WuE), and %s (WB) as an addition to item level on items).
- **Fade profession quality icons during search** (Fade profession quality icons during search and filtering).
- If the money tracker is enabled: **Show account gold only** (Show account gold only (hide silver and copper)).

## Character & Inspect
- **Display item level on Character Equipment Frame** (Display item level on Character Equipment Frame).
- **Display gem slots tooltip on Character Frame** (Display gem slots tooltip on Character Equipment Frame).
- **Display gem slots on Character Frame** (Display gem slots on Character Equipment Frame).
- **Display enchants on Character Frame** (Display enchants on Character Equipment Frame).
- **Display durability on Character Frame** (Display Durability on Character Equipment Frame).
- **Hide Order Hall Command Bar** (Hide Order Hall Command Bar).
- **Show additional information on the Inspect Frame** (Show additional information on the Inspect Frame).
- **Display Catalyst charges on Character Frame** (Display Catalyst charges on Character Equipment Frame).
- **Enable Gem-Socket Helper** (Enable Gem-Socket Helper).
- Class-specific toggles such as **Hide Rune Frame** or **Hide Combo Point Bar** appear when you log in with the corresponding class.

## Action Bars & Mouse
Each action bar can be set to appear only on mouseover:
- mouseoverActionBar1 through mouseoverActionBar8 (main and multi bars).
- mouseoverActionBarPet (pet bar).
- mouseoverActionBarStanceBar (stance bar).

## Unit Frames
- **Hide floating combat text over your character** (Hide floating combat text (damage and healing) over your character).
- **Hide floating combat text over your pet** (Hide floating combat text (damage and healing) over your pet).
- Additional options allow Target, Player or Boss frames to remain hidden until the mouse is over them.

## Minimap & Micro Menu
- **Enable quick switching for loot and active specializations** (Enable quick switching for loot and active specializations on the Minimap).
- **Enable Minimap Button Sink** (Enable Minimap Button Sink): gather minimap buttons in a single frame. When enabled additional options appear:
  - **Use a Minimap button for the sink** (Use a Minimap button for the sink).
  - **Show a movable frame for the button sink with mouseover** (Show a movable frame for the button sink with mouseover).
  - **Lock the button sink frame** (Lock the button sink frame).
- **Use a square minimap** (Use a square minimap instead of the normal round).
- **Show instance difficulty** (Display the current instance difficulty near the minimap; optionally use a custom icon).
  - Enter the texture path for the custom icon, e.g. `Interface\\ICONS\\INV_Misc_QuestionMark`.
- **Hide Minimap Button** (Hide Minimap Button).
- **Hide Bagsbar** (Hide Bagsbar).
- **Hide Micro Menu** (Hide Micro Menu).
- **Hide Quick Join Toast** (hideQuickJoinToast).
- **Hide Raid Tools in Party** (Hide Raid Tools in Party).
- Options are also provided to hide specific Landing Page buttons.

## Party & Raid Tools
- **Automatically accept group invites** (Automatically accept group invites).
  - **Guild members** (Guild members).
  - **Friends** (Friends).
- **Show leader icon on raid-style party frames** (Show leader icon on raid-style party frames).
- **Show Party Frames in Solo Content** (Show Party Frames in Solo Content).
- **Hide Player Frame** (Hide Player Frame).

## Dungeon / Mythic+
- **Hide the group finder text 'Your group is currently forming'** (Hide the group finder text "Your group is currently forming").
- **Shift the 'Reset Filter' button in the Dungeon Browser** (Shift the 'Reset Filter' button in the Dungeon Browser to the left side).
- **Skip role selection** (Skip role selection).
- **Automatically select delve power when only one option** (Automatically select delve power when only 1 option).
- **Persist LFG signup note** (Persist LFG signup note).
- **Quick signup** (Quick signup).
- **Sort Mythic Dungeon applicants by Mythic Score** (Sort Mythic Dungeon Applicants by Mythic Score).

## Quest & Vendor Automation
- **Automatically accept and complete quests** (Automatically accept and complete Quests).
- **Don't automatically handle daily/weekly quests** (Don't automatically handle daily/weekly %s).
- **Don't automatically handle trivial quests** (Don't automatically handle trivial %s).
- **Don't automatically handle account-completed quests** (Don't automatically handle %s %s).
- **Automatically repair all items** (Automatically repair all items).
- **Automatically sell all junk items** (Automatically sell all junk items).
- **Add 'DELETE' to the confirmation text automatically** (Add "%s" to the "Delete confirmation Popup").
- **Automatically confirm to use own materials on Crafting Orders** (Automatically confirm to use own materials on %s crafting orders).
- **Automatically confirm to sell tradeable loot** (Automatically confirm to sell tradeable loot within the trade window time frame).
- **Open the character frame when upgrading items at the vendor** (Open the character frame when upgrading items at the vendor).
- **Quick loot items** (Quick loot items).
- **Instant Catalyst button** (Instant Catalyst button).
- **Enable custom loot toasts** (Enable custom loot toasts): suppresses the default toast frame and only shows messages for items that pass your filters.
- **Set item level thresholds per rarity** (Set item level thresholds per rarity): choose minimum item levels per quality before a toast appears.
- **Show toasts for mounts** (Show for mounts): include mount drops in the filter.
- **Show toasts for pets** (Show for pets): include pet drops in the filter.
- **Include item IDs** (Itemlist): whitelist specific items regardless of other filters.
- **Use custom loot sound** (Use custom loot sound): choose a custom sound for loot toasts.

## Map Tools
- **Enable /way command** (Enable /way command): provides a simple waypoint command if no other addon uses /way.

## CVar Tweaks
The **CVar** section exposes common console variables as checkboxes. Changing them usually requires a reload:
- Enable autodismount when using abilities
- Enable autodismount when using abilities while flying
- Enable mouse scroll in chat
- Disable death effects
- Enable Map Fade while moving
- Show LUA-Error on UI
- Show class colors on nameplates
- Show the Castbar of your Target
- Disable tutorials
- Enable enhanced tooltips
- Show the Guild on Players
- Show the Title on Players
- Make the entire chat window clickable

---

These descriptions should help you understand what each checkbox in the configuration does. For more details see the README or the in-game tooltips.
