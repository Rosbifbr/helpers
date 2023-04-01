#!/bin/ash
#Small utility to rotate my tablet's screen + input (touchscreen)
#Requires xrandr and xinput

portrait_matcher_regex='0\+0\s\w+'
xrandr_output="$(xrandr | grep LVDS | grep -oE $portrait_matcher_regex)"

if [ "$xrandr_output" = "0+0 left" ]; then
        #This means we are in portrait mode. Switching to landscape.
        xrandr -o 0 #Display to landscape
        xinput set-prop "Elan Touchscreen" --type=float "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0
else
        xrandr -o 1 #Display to portrait
        xinput set-prop "Elan Touchscreen" --type=float "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
fi
