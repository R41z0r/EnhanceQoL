#!/bin/bash

# Verzeichnis angeben, in dem die .lua-Dateien durchsucht werden sollen
SEARCH_DIR="./../"

# Alle .lua-Dateien durchsuchen, die "-- @" enthalten
find "$SEARCH_DIR" -type f -name "*.lua" | while read -r file; do
    # Prüfen, ob die Datei dem Schema entspricht und dann das Leerzeichen ersetzen
    if grep -Eq -- '-- @[_a-zA-Z0-9]+@[[:space:]]*' "$file"; then
        sed -i '' 's/-- @/--@/g' "$file"
        echo "Updated: $file"
    fi
done