#!/bin/bash
current_shader=$(hyprshade current)
if [ -z "$current_shader" ]; then
  hyprshade on blue-light-filter
else
  hyprshade toggle
fi
