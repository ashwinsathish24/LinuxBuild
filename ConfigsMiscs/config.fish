if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'
    alias c='clear'
    alias stress='stress-ng --cpu 0 --cpu-method matrixprod --metrics --timeout 30s & clpeak -p 0'
    alias hwmon="watch -n1 'nbfc status; echo; nvidia-smi --query-gpu=clocks.gr,clocks.mem,power.draw --format=csv,noheader'"
    # Custom Functions

    # Temp Clear Pacman
    function temp
    set orphans (pacman -Qdtq)

    if test -n "$orphans"
        sudo pacman -Rns $orphans
    else
        echo "No orphans"
    end

    sudo paccache -rk1
    paccache -rk1 -c ~/.cache/yay
end
    # Mouse fix
    function rmfx
    set devices (find /sys/devices -name device_mode 2>/dev/null | grep 1532)

    if test (count $devices) -eq 0
        echo "No Razer device_mode nodes found"
        return 1
    end

    for i in (seq (count $devices))
        echo "$i) $devices[$i]"
    end

    read -P "Select device: " choice

    if test $choice -ge 1 -a $choice -le (count $devices)
        sudo bash -c "printf '\x03\x00' > $devices[$choice]"
        echo "Applied to $devices[$choice]"
    else
        echo "Invalid selection"
    end
end
    
    # Screen  Mirroring
    function mirror
    killall wayvnc
    set ip (ip -4 route get 1 | awk '{print $7; exit}')
    echo "Mirroring display to phone via $ip:5900"
    nohup wayvnc $ip > /dev/null 2>&1 &
end

    
    # Screen Extending
function extend
    killall wayvnc 2>/dev/null
    adb reverse --remove-all 2>/dev/null

    read --prompt-str "Phone position (u/d/l/r): " pos

    if not contains $pos u d l r
        echo "Invalid option"
        return
    end

    hyprctl output remove PHONE 2>/dev/null
    hyprctl output create headless PHONE

    if test "$pos" = "u"
        hyprctl keyword monitor "PHONE,1600x720@45,auto-up,1"
    end

    if test "$pos" = "d"
        hyprctl keyword monitor "PHONE,1600x720@45,auto-down,1"
    end

    if test "$pos" = "l"
        hyprctl keyword monitor "PHONE,1600x720@45,auto-left,1"
    end

    if test "$pos" = "r"
        hyprctl keyword monitor "PHONE,1600x720@45,auto-right,1"
    end

    adb reverse tcp:5900 tcp:5900

    echo "Phone display active via ADB tunnel (localhost:5900)"

    nohup wayvnc \
        --max-fps 45 \
        --output PHONE \
        127.0.0.1 \
        >/dev/null 2>&1 &
end

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end
