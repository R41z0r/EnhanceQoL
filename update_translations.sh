#!/bin/bash

cf_token=

# Load secrets
if [ -f ".env" ]; then
	. ".env"
fi

[ -z "$cf_token" ] && cf_token=$CURSE_API_TOKEN

declare -A locale_files=(
  # core module
  ["EnhanceQoL"]="EnhanceQoL/Locales/enUS.lua"

  # # sub‑modules – add or remove lines if your structure changes
  # ["EnhanceQoL_DrinkMacro"]="EnhanceQoLDrinkMacro/Locales/enUS.lua"
  # ["EnhanceQoL_Mouse"]="EnhanceQoLMouse/Locales/enUS.lua"
  # ["EnhanceQoL_MythicPlus"]="EnhanceQoLMythicPlus/Locales/enUS.lua"
  # ["EnhanceQoL_Tooltip"]="EnhanceQoLTooltip/Locales/enUS.lua"
  # ["EnhanceQoL_Vendor"]="EnhanceQoLVendor/Locales/enUS.lua"
)

tempfile=$( mktemp )
trap 'rm -f $tempfile' EXIT

do_import() {
  namespace="$1"
  file="$2"
  : > "$tempfile"

  echo -n "Importing $namespace..."
  result=$( curl -sS -0 -X POST -w "%{http_code}" -o "$tempfile" \
    -H "X-Api-Token: $CURSE_API_TOKEN" \
    -F "metadata={ language: \"enUS\", namespace: \"$namespace\", \"missing-phrase-handling\": \"DeletePhrase\" }" \
    -F "localizations=<$file" \
    "https://legacy.curseforge.com/api/projects/1076354/localization/import"
  ) || exit 1
  case $result in
    200) echo "done." ;;
    *)
      echo "error! ($result)"
      [ -s "$tempfile" ] && grep -q "errorMessage" "$tempfile" | jq --raw-output '.errorMessage' "$tempfile"
      exit 1
      ;;
  esac
}

# lua babelfish.lua || exit 1
# echo

for namespace in "${!locale_files[@]}"; do
  do_import "$namespace" "${locale_files[$namespace]}"
done

exit 0