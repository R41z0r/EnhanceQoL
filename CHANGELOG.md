# Changelog

## [3.9.0] – 02 May 2025
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