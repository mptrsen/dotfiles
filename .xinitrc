# keyboard repeat rate
xset r rate 200 60
# disable touchpad
xinput --disable 11
# bind function keys
xbindkeys
# wallpaper setter, i like nitrogen
nitrogen --restore
# awesome!
exec awesome --config /home/malty/.config/awesome/rc.lua
