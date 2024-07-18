#!/bin/bash

# Function to count words
count_words() {
    echo "$1" | wc -w
}

# Get the title from playerctlock.sh
title=$(~/.config/hyprlock/playerctlock.sh --title)

# Count the number of words in the title
word_count=$(count_words "$title")

# Trigger the appropriate hyprlock command
if (( word_count > 4 )); then
    hyprlock -c layout2.conf
else
    hyprlock -c layout1.conf
fi
