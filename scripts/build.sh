#!/bin/bash

# Pfade zu den Verzeichnissen anpassen
ROOT_DIR=$(pwd)/
WOW_ADDON_DIR="/Applications/World of Warcraft/_retail_/Interface/AddOns"

# Verzeichnisse für die Addons
RAIZOR_ADDON_DIR="$WOW_ADDON_DIR/Raizor"
RAIZOR_DRINK_MACRO_DIR="$WOW_ADDON_DIR/RaizorDrinkMacro"
RAIZOR_QUERY_DIR="$WOW_ADDON_DIR/RaizorQuery"

VERSION=$(git describe --tags --always)

# Lösche die bestehenden Addon-Verzeichnisse, wenn sie existieren
rm -rf "$RAIZOR_ADDON_DIR"
rm -rf "$RAIZOR_DRINK_MACRO_DIR"
rm -rf "$RAIZOR_QUERY_DIR"

# Erstelle die Addon-Verzeichnisse neu
mkdir -p "$RAIZOR_ADDON_DIR"
mkdir -p "$RAIZOR_DRINK_MACRO_DIR"
mkdir -p "$RAIZOR_QUERY_DIR"

echo "$ROOT_DIR"

# Kopiere die Addon-Dateien
cp -r "$ROOT_DIR/Raizor/"* "$RAIZOR_ADDON_DIR/"
cp -r "$ROOT_DIR/RaizorDrinkMacro/"* "$RAIZOR_DRINK_MACRO_DIR/"
cp -r "$ROOT_DIR/RaizorQuery/"* "$RAIZOR_QUERY_DIR/"

# Version in den .toc-Dateien ersetzen
sed -i '' "s/@project-version@/$VERSION/" "$RAIZOR_ADDON_DIR/Raizor.toc"
sed -i '' "s/@project-version@/$VERSION/" "$RAIZOR_DRINK_MACRO_DIR/RaizorDrinkMacro.toc"
sed -i '' "s/@project-version@/$VERSION/" "$RAIZOR_QUERY_DIR/RaizorQuery.toc"

echo "Addons wurden nach $WOW_ADDON_DIR kopiert."