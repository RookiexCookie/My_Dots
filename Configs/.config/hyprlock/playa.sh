#!/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source"
    exit 1
fi

# Function to get metadata using playerctl
get_metadata() {
    key=$1
    playerctl metadata --format "{{ $key }}" 2>/dev/null
}

# Function to determine the source and return an icon and text
get_source_info() {
    trackid=$(get_metadata "mpris:trackid")
    if [[ "$trackid" == *"firefox"* ]]; then
        echo -e "󰈹"
    elif [[ "$trackid" == *"spotify"* ]]; then
        echo -e ""
    elif [[ "$trackid" == *"chromium"* ]]; then
        echo -e ""
    elif [[ "$trackid" == *"Youtube"* ]]; then
        echo -e ""
    else
        echo "Rookie"  # Default source text when nothing is playing
    fi
}

# Function to get position using playerctl
get_position() {
    playerctl position 2>/dev/null
}

case "$1" in
    --title)
        # Determine the active player
        player=$(playerctl metadata mpris:trackid)

        # Check if the player metadata includes "firefox" or "youtube"
        if [[ "$player" == *"firefox"* ]] || [[ "$player" == *"youtube"* ]]; then
            # Get the title metadata
            title=$(playerctl metadata xesam:title)

            if [ -z "$title" ]; then
                echo "Nothing's Playin"
            else

                # Remove content within parentheses and square brackets
                clean_title=$(echo "$title" | sed -E 's/\([^)]*\)//g; s/\[[^]]*\]//g')
                # Remove specific words from the title
                clean_title=$(echo "$clean_title" | sed -E 's/\b(version|male|female|song|theme)\b//gi')
                # Remove text starting from "by"
                clean_title=$(echo "$clean_title" | sed -E 's/\s*by\s*.*$//i')
                # Output only the part after the hyphen if present
                if [[ "$clean_title" == *-* ]]; then
                    song_title=$(echo "$clean_title" | sed -E 's/.*-\s*//')
                else
                    song_title="$clean_title"
                fi
                echo "$song_title"
            fi
        else
            # Get the title metadata
            title=$(playerctl metadata xesam:title)

            if [ -z "$title" ]; then
                echo "Nothing's Playin"
            else
                # Remove content within parentheses and square brackets
                clean_title=$(echo "$title" | sed -E 's/\([^)]*\)//g; s/\[[^]]*\]//g')
                # Remove specific words from the title
                clean_title=$(echo "$clean_title" | sed -E 's/\b(version|male|female|song|theme)\b//gi')
                # Remove trailing text after "-" or similar patterns
                clean_title=$(echo "$clean_title" | sed -E 's/\s*[-–—]\s*(From|Live|Remastered)?\s*.*$//i')

                echo "$clean_title"
            fi
        fi
        ;;

--arturl)
    file_path=$(playerctl metadata mpris:artUrl)
    if [ -z "$file_path" ]; then
        echo "No Art"
    else
        curl -s "$file_path" -o ./hell.png
        magick ./hell.png -resize "100x100^" -gravity center -extent 100x100 ./hell.png
        echo "/home/rookie/.config/hyprlock/hell.png"
    fi
    ;;
--artist)
    artist=$(get_metadata "xesam:artist")
    if [ -z "$artist" ]; then
        echo "Bro"
    else
        echo "${artist:0:50}" # Limit the output to 50 characters
    fi
    ;;
--position)
    position=$(get_position)
    length=$(get_metadata "mpris:length")
    if [ -z "$position" ] || [ -z "$length" ]; then
        echo "0:00/Infinity"
    else
        position_formatted=$(convert_position "$position")
        length_formatted=$(convert_length "$length")
        echo "$position_formatted/$length_formatted"
    fi
    ;;
--length)
    length=$(get_metadata "mpris:length")
    if [ -z "$length" ]; then
        echo "∞"
    else
	echo $(playerctl metadata --format "{{ duration(mpris:length) }}")
    fi
    ;;
--status)
    status=$(playerctl status 2>/dev/null)
    if [[ $status == "Playing" ]]; then
        echo ""
    elif [[ $status == "Paused" ]]; then
        echo ""
    else
        echo ""
    fi
    ;;
--album)
    album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
    if [[ -n $album ]]; then
        echo "$album"
    else
        status=$(playerctl status 2>/dev/null)
        if [[ -n $status ]]; then
            echo "Not album"
        else
            echo ""
        fi
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Invalid option: $1"
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source" ; exit 1
    ;;
esac
