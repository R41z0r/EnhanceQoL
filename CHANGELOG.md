# Changelog

## [3.15.0] – 2025-05-26
### ✨ Added
- **Customisable Mouse-Ring Size** – New slider lets you shrink or enlarge the on-screen mouse ring to suit your taste.
- **Upgrade-Track Bag Filter** – Filter your bags by upgrade track (Veteran, Champion, Hero, Mythic, etc.) with a single click.
- **Sellable on Vendor Filter** – Filter your bags by Items sellable to a Vendor.
- **Sellable on Auction House Filter** – Filter your bags by Items sellable on the Auction House.

### 🐛 Fixed
- Disabling the **Auto-Keystone** feature no longer triggers Lua errors in certain edge-cases.
- Bind-type labels (BoE, BoP, and WA) now stay with the correct items instead of occasionally sticking to the wrong slot.

## [3.14.0] – 2025-05-21
### ✨ Added
- **Re-enabled “Dungeon Filter” option**
- **Bag Filter: Binding Type** – filter bag items by their binding type

### 🐛 Fixed
- Fixed errors that could occur when buying or selling items with the **Vendor** feature.
- Vendor tools now load correctly after an update.
- Miscellaneous internal clean-up for improved stability.
- ButtonSink now correctly captures the minimap button of a specific add-on.

## [3.13.0] – 2025-05-14
### ✨ Added
- **Support for Talent Loadout Ex** – Talent Reminder now supports loadouts created with Talent Loadout Ex.

### 🐛 Fixed
- Mythic+ rating text could overlap other Enhance QoL frames in certain situations.

## [3.12.0] – 2025‑05‑10
### ✨ Added
- **Conditional enchant checks** – detects missing enchants context‑sensitively (e.g., Horrific‑Visions helm).
- **Missing Xal'atath voicelines** - some voicelines added in S2 were missing

### 🔁 Changed
- **Faster enchant scan** – internal routine streamlined for quicker results.

### 🐛 Fixed
- Tooltip did not appear on player, target, or boss frames when **Mouse‑over Hide** was enabled.

## [3.11.0] – 2025‑05‑06
### ✨ Added
- **CurseForge Localization Support** – all strings are now hosted on CurseForge; anyone can contribute translations.
- **Sound** module – central hub to toggle (or mute) specific in‑game sounds.
- **Keystone Helper** – brand‑new UI with new ready‑check status

### 🐛 Fixed
- Faction‑specific teleport items missing on non‑English clients.
- Objective Tracker erroneously depended on the *Talent Reminder* module.
- Multiple missing translations and malformed localisation symbols.
- Default WoW bag search failed when “separate bags” was enabled.

### 🔊 Improved
- One‑click mute buttons for several annoying game sounds (roll‑out continues).

### 🎨 UI
- Polished Autokeystone & Pull‑Timer design  
  • Cleaner layout and visuals  
  • Animated status icon that reflects the ready‑check result  
  • Option to revert to the legacy look

---

## [3.10.0] – 2025-05-03
### Added
- **Auction House Filter Persistence** – remembers your Auction House search filters for the entire session.

- **Food Reminder** – lowered frame strata so it no longer obscures important notifications.
- **Module Icons** – refreshed symbol set for all module toggles.
- **Module naming cleanup** – removed the `Enhance QoL` prefix from all sub‑addon folder names for shorter, clearer titles.

### 🐛 Fixed
- Lua error when inspecting another player.

---

## [3.9.0] – 2025-05-01
### ✨ New Options
- **Bag Filter: Item-Level Range** – hide items outside a custom ilvl range.  
- **Healer Spec: Auto-unmark self** – raid marker is cleared when you switch to healer.

### 🔁 Changed
- **“Tank Marker” → “Auto Marker”** – new name

### 🐛 Fixed
- Item level missing on some chest pieces in bags.

---

## [3.8.1] – 2025-04-30

### 🐛 Bug Fixes
- Added the missing translation for the account-gold option.
- Fixed an error that could break LFG Quick Signup.
- Persistent signup note in LFG now saves correctly.
- Corrected window positioning for several settings panels.

---

## [3.8.0] – 2025-04-29
### ✨ New Features
- **Objective-Tracker Auto-Hide in Mythic+**  
  Hides (or collapses) every objective-tracker block automatically when a Mythic-Plus key starts.
- **Square Minimap Toggle**  
  Replaces the round minimap with a space-efficient square version and re-anchors all minimap buttons.
- **Profile Manager**  
  Create, copy, delete and switch between profiles (character-specific or global).

### 🐛 Bug Fixes
- Fixed garbled characters (�) in the Chinese and Korean locales.

---

## [3.7.1] – 2025-04-28
### 🐛 Bug Fixes
- Garbled characters (�) in the Russian locale.  
  Removed rogue control characters and forced a Cyrillic-capable font in ruRU locale to eliminate yellow “missing glyph” squares.

---

## [3.7.0] – 2025-04-26
### ✨ Added
- Option to **show account-wide currency totals** in tooltips

### 🔁 Changed
- Temporary disabled the Dungeon filter to investigate a memory heap problem

### ❌ Removed
- Removed the option to disable the Blizzard AddOn Profiler (CVar no longer exists)
- Deprecated function calls

### 🐛 Bug Fixes
- Dungeon filter sometimes kept full groups in the list instead of cleaning them
- Dungeon filter sometimes showed filtered entries for a short time

---

## [3.6.1] – 2025‑04‑22
### 🐛 Bug Fixes
- Clearing the search filter sometimes left inventory items faded.

> **Note:** 3.6.1 is a pure bug‑fix patch.  
> All new features, changes, and additional fixes are listed in the **3.6.0** entry below.

---

## [3.6.0] – 2025‑04‑21
### ✨ New Features
- **Hideable Target Frame**  
  Hide the default target frame and let it reappear on mouse‑over.
- **Hideable Bag Bar**  
  Hide the bag bar and make it reappear on mouse‑over.
- **Hideable Micro Menu**  
  Hide the micro menu and make it reappear on mouse‑over.
- **Mage‑Food Reminder**  
  A handy button that queues you for a follower dungeon to grab free Mage food. (Only in Healer role and rested area)
- **Profession Icon Fade**  
  Optionally fade profession quality icons in your bags while searching.
- **Bag Filter Window**  
  A flexible filter panel for the default bags:  
  &nbsp;&nbsp;• Filter by equipment slot, item rarity, or specialization usability.
- **Money Tracker**  
  See the gold of all your characters in a single tooltip.
- **Show Party Frame in Solo Content**  
  Enables the party frame even when you’re playing solo.
- **Dungeon Filter Extension**  
  Extends the default dungeon filter:  
  &nbsp;&nbsp;• Filter for groups that have Bloodlust (or space for it) – shown only to classes without Bloodlust.  
  &nbsp;&nbsp;• Filter for groups that have Battle Res (or space for it) – shown only to classes without Battle Res.  
  &nbsp;&nbsp;• Filter for groups that match your current party.  
  &nbsp;&nbsp;• Filter for groups that already include your specialization – only shown for DPS specs.

### ⚙️ Changes
- All bag‑related options have been moved to a dedicated **“Bags”** tab.

### 🐛 Bug Fixes
- Engineering teleport buttons now appear reliably in every situation.
- Bag search no longer hides item‑level or bind‑type indicators.