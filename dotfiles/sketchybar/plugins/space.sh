#!/bin/bash

# Map app names to Nerd Font icons
icon_for_app() {
  case "$1" in
    "Safari")           echo "" ;;
    "Firefox")          echo "" ;;
    "Google Chrome")    echo "" ;;
    "Ghostty")          echo "" ;;
    "cmux")             echo "" ;;
    "kitty")            echo "" ;;
    "Terminal")         echo "" ;;
    "iTerm2")           echo "" ;;
    "Code")             echo "󰨞" ;;
    "Sublime Text")     echo "" ;;
    "Neovim"|"nvim")    echo "" ;;
    "Finder")           echo "󰀶" ;;
    "Mail")             echo "󰇮" ;;
    "Calendar")         echo "" ;;
    "Messages")         echo "󰍡" ;;
    "WhatsApp"|"‎WhatsApp") echo "󰖣" ;;
    "Slack")            echo "󰒱" ;;
    "Discord")          echo "󰙯" ;;
    "Spotify")          echo "" ;;
    "Music")            echo "󰎆" ;;
    "Notes")            echo "󱞎" ;;
    "Reminders")        echo "󰃮" ;;
    "Preview")          echo "" ;;
    "TextEdit")         echo "󰧮" ;;
    "Numbers")          echo "󰓫" ;;
    "Pages")            echo "󰧮" ;;
    "Keynote")          echo "󰐨" ;;
    "System Settings")  echo "" ;;
    "Docker")           echo "" ;;
    "Inkscape")         echo "󰃣" ;;
    "Figma")            echo "" ;;
    "Notion")           echo "󰈙" ;;
    "Obsidian")         echo "󰺿" ;;
    "Anaconda-Navigator") echo "" ;;
    "DataGrip")         echo "" ;;
    "Postman")          echo "󰛮" ;;
    "zoom.us")          echo "󰒃" ;;
    "Microsoft Teams")  echo "󰊻" ;;
    "Microsoft Excel")  echo "󰈛" ;;
    "Microsoft Word")   echo "󰈬" ;;
    "Arc")              echo "󰞍" ;;
    *)                  echo "󰣆" ;;
  esac
}

# Extract workspace number from item name (space.1 -> 1)
SPACE_ID="${NAME##*.}"

# Determine focused workspace
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  FOCUSED="$FOCUSED_WORKSPACE"
else
  FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
fi

# Highlight focused workspace
if [ "$FOCUSED" = "$SPACE_ID" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi

# Get app icons for this workspace
APPS=$(aerospace list-windows --workspace "$SPACE_ID" --format '%{app-name}' 2>/dev/null | sort -u)
ICON_STRIP=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  ICON_STRIP+=" $(icon_for_app "$app")"
done <<< "$APPS"
ICON_STRIP="${ICON_STRIP# }"  # trim leading space

# Set label to app icons (or hide if empty)
if [ -n "$ICON_STRIP" ]; then
  sketchybar --set "$NAME" label="$ICON_STRIP" label.drawing=on
else
  sketchybar --set "$NAME" label.drawing=off
fi
