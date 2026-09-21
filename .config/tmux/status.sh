#!/bin/sh

# 1. Disk (free space on root)
disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}')

# 2. Battery (capacity, charging status & dynamic icon)
bat_cap=0
bat_stat=""
bat_dir="/sys/class/power_supply/BAT0"
if [ -d "$bat_dir" ]; then
    read -r bat_cap < "$bat_dir/capacity" 2>/dev/null
    read -r bat_stat < "$bat_dir/status" 2>/dev/null
fi

if [ "$bat_stat" = "Charging" ]; then
    bat_icon=""
elif [ "$bat_cap" -ge 80 ]; then
    bat_icon=""
elif [ "$bat_cap" -ge 60 ]; then
    bat_icon=""
elif [ "$bat_cap" -ge 40 ]; then
    bat_icon=""
elif [ "$bat_cap" -ge 20 ]; then
    bat_icon=""
else
    bat_icon=""
fi

# 3. Volume (pamixer)
vol_icon=""
vol="0%"
if command -v pamixer >/dev/null 2>&1; then
    vol_h=$(pamixer --get-volume-human 2>/dev/null)
    if [ "$vol_h" = "muted" ]; then
        vol_icon=""
        vol="MUTED"
    elif [ -n "$vol_h" ]; then
        vol="$vol_h"
    fi
fi

# 4. Brightness (intel_backlight direct sysfs)
bri_icon=""
bri="n/a"
backlight="/sys/class/backlight/intel_backlight"
if [ -d "$backlight" ]; then
    read -r b_cur < "$backlight/brightness" 2>/dev/null
    read -r b_max < "$backlight/max_brightness" 2>/dev/null
    if [ -n "$b_max" ] && [ "$b_max" -gt 0 ]; then
        bri="$(( b_cur * 100 / b_max ))%"
    fi
fi

# 5. Network (wlan0 / enp0s31f6)
net_icon=""
net="down"
eth_state=""
wlan_state=""
[ -r /sys/class/net/enp0s31f6/operstate ] && read -r eth_state < /sys/class/net/enp0s31f6/operstate 2>/dev/null
[ -r /sys/class/net/wlan0/operstate ] && read -r wlan_state < /sys/class/net/wlan0/operstate 2>/dev/null

if [ "$eth_state" = "up" ]; then
    net_icon=""
    net="eth"
elif [ "$wlan_state" = "up" ]; then
    net_icon=""
    wifi_perc=""
    if [ -r /proc/net/wireless ]; then
        while read -r iface status qual rest; do
            case "$iface" in
                wlan0:*)
                    qual="${qual%.}"
                    calc=$(( qual * 100 / 70 ))
                    [ "$calc" -gt 100 ] && calc=100
                    wifi_perc="${calc}%"
                    ;;
            esac
        done < /proc/net/wireless
    fi
    raw_ssid=$(iwgetid -r 2>/dev/null)
    if [ -n "$raw_ssid" ]; then
        short_ssid="${raw_ssid:0:3}"
    else
        short_ssid="wif"
    fi
    if [ -n "$wifi_perc" ]; then
        net="${wifi_perc} ${short_ssid}"
    else
        net="${short_ssid}"
    fi
fi

# Output with greyed-out minimalist colors
# Values: #6e7681 (muted gray), Separators: #484f58 (dark slate)
printf "#[fg=#6e7681]%s %s #[fg=#484f58]| #[fg=#6e7681]%s %s #[fg=#484f58]| #[fg=#6e7681]%s %s #[fg=#484f58]| #[fg=#6e7681]%s %s #[fg=#484f58]| #[fg=#6e7681]%s %s " \
    "" "$disk" \
    "$bat_icon" "${bat_cap}%" \
    "$vol_icon" "$vol" \
    "$bri_icon" "$bri" \
    "$net_icon" "$net"
