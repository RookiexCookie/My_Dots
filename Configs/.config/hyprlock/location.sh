#!/bin/bash

cache_file="$HOME/.cache/ip_cache.txt"

# Create the cache file if it doesn't exist
if [ ! -f "$cache_file" ]; then
        mkdir -p "$(dirname "$cache_file")" # Create .cache directory if it doesn't exist
        touch "$cache_file"
fi

# Get the last modified time of the cache file
last_modified=$(stat -c %Y "$cache_file")
current_date=$(date +%s)
time_diff=$((current_date - last_modified))
expiry_time=86400
cached_data=$(<"$cache_file")

# Check if the cache is still valid and if there's data in the cache file
if [ $time_diff -lt $expiry_time ] && [ -n "$cached_data" ]; then
        echo "$cached_data"
        exit
fi

# Fetch IP information
response=$(curl -s ipinfo.io 2>/dev/null)
if [ -z "$response" ]; then
    echo "Failed to fetch data from ipinfo.io"
    exit 1
fi

# Process the response using jq
city=$(echo "$response" | jq -r '.country + ", " + .city' 2>/dev/null)
if [ -z "$city" ]; then
    echo "Failed to parse response from ipinfo.io"
    exit 1
fi

# Save the result to the cache file
echo "$city" >"$cache_file"
echo "$city"
