#!/bin/bash
# awmtt: awesomewm testing tool
# https://github.com/mikar/awmtt

#{{{ Usage
usage() {
    cat <<EOF
awmtt start [-B <path>] [-C <path>] [-D <int>] [-S <size>] [-a <opt>]... [-x <opts>]
awmtt (stop [all] | restart)
awmtt run [-D <int>] <command>
awmtt theme (get | set <theme> | list | random) [-N]

Arguments:
  start           Spawn nested Awesome via Xephyr
  stop            Stops the last Xephyr process
    all           Stop all instances of Xephyr 
  restart         Restart all instances of Xephyr
  run <cmd>       Run a command inside a Xephyr instance (specify which one with -D)
  theme           Some basic theming control via:
    get           Get current theme name
    set <theme>   Set theme to <theme>
    list          List available themes
    random        Set a random theme
    
Options:
  -B|--binary <path>  Specify path to awesome binary (for testing custom awesome builds)
  -C|--config <path>  Specify configuration file
  -D|--display <int>  Specify the display to use (e.g. 1)
  -N|--notest         Don't use a testfile but your actual rc.lua (i.e. $HOME/.config/awesome/rc.lua)
                      This happens by default if there is no rc.lua.test file.
  -S|--size <size>    Specify the window size
  -a|--aopt <opt>     Pass option to awesome binary (e.g. --no-argb or --check). Can be repeated.
  -x|--xopts <opts>   Pass options to xephyr binary (e.g. -keybd ephyr,,,xkblayout=de). Needs to be last.
  -h|--help           Show this help text and exit
  
Examples:
  awmtt start (uses defaults: -C $HOME/.config/awesome/rc.lua.test -D 1 -S 1024x640)
  awmtt start -C /etc/xdg/awesome/rc.lua -D 3 -S 1280x800
  awmtt theme set zenburn -N
EOF
    exit 0
}
[ "$#" -lt 1 ] && usage
#}}}

#{{{ Utilities
awesome_pid() { pgrep -n "awesome"; }
xephyr_pid() { pgrep -f xephyr_$D; }
errorout() { echo "error: $*" >&2; exit 1; }
#}}}

#{{{ Executable check
AWESOME=$(which awesome)
XEPHYR=$(which Xephyr)
[[ -x "$AWESOME" ]] || errorout 'Please install Awesome first'
[[ -x "$XEPHYR" ]] || errorout 'Please install Xephyr first'
#}}}

#{{{ Default Variables
# Display and window size
D=1
SIZE="1024x640"
AWESOME_OPTIONS=""
XEPHYR_OPTIONS=""
# Path to rc.lua
if [[ "$XDG_CONFIG_HOME" ]]; then
    RC_FILE="$XDG_CONFIG_HOME"/awesome/rc.lua.test
else
    RC_FILE="$HOME"/.config/awesome/rc.lua.test
fi
[[ ! -f "$RC_FILE" ]] && RC_FILE="$HOME"/.config/awesome/rc.lua
#}}}

#{{{ Hostname Check - this is probably only useful for me. I have the same rc.lua running on two different machines
HOSTNAME=$(cat /proc/sys/kernel/hostname)
#}}}
        
#{{{ Functions
#{{{ Start function
start() {
    # check for free $DISPLAYs
    for ((i=0;;i++)); do
        if [[ ! -f "/tmp/.X${i}-lock" ]]; then
            D=$i;
            break;
        fi;
    done
    
    "$XEPHYR" :$D -name xephyr_$D -ac -br -noreset -screen "$SIZE" $XEPHYR_OPTIONS >/dev/null 2>&1 &
    sleep 1
    DISPLAY=:$D.0 "$AWESOME" -c "$RC_FILE" $AWESOME_OPTIONS &
    sleep 1
    
    # print some useful info
    if [[ "$RC_FILE" =~ .test$ ]]; then
    echo "Using a test file ($RC_FILE)"
    else
    echo "Caution: NOT using a test file ($RC_FILE)"
    fi

    echo "Display: $D, Awesome PID: $(awesome_pid), Xephyr PID: $(xephyr_pid)"
}
#}}}
#{{{ Stop function
stop() {
    if [[ "$1" == all ]]; then
        echo "Stopping all instances of Xephyr"
        kill $(pgrep Xephyr) >/dev/null 2>&1
    elif [[ $(xephyr_pid) ]]; then
        echo "Stopping Xephyr for display $D"
        kill $(xephyr_pid)
    else
        echo "Xephyr is not running or you did not specify the correct display with -D"
        exit 0
    fi
}
#}}}
#{{{ Restart function
restart() {
    # TODO: (maybe use /tmp/.X{i}-lock files) Find a way to uniquely identify an awesome instance
    # (without storing the PID in a file). Until then all instances spawned by this script are restarted...
    echo -n "Restarting Awesome... "
    for i in $(pgrep -f "awesome -c"); do
        kill -s SIGHUP $i;
    done
}
#}}}
#{{{ Run function
run() {
    [[ -z "$D" ]] && D=1
    DISPLAY=:$D.0 "$@" &
    LASTPID=$!
    echo "PID is $LASTPID"
}
#}}}
#{{{ Theme function
theme() {
    # List themes
    theme_list() { #TODO: list only directories
        if [[ -d $(dirname "$RC_FILE")/themes ]]; then
            ls /usr/share/awesome/themes $(dirname "$RC_FILE")/themes
        else
            ls /usr/share/awesome/themes "$HOME"/.config/awesome/themes
        fi
    }    
    case "$1" in
        l|list) theme_list
                exit 0
                ;;
    esac
    
    # Check for Beautiful library
    BEAUTIFUL=$(grep -c 'beautiful.init' "$RC_FILE")
    [[ "$BEAUTIFUL" -ge 1 ]] || errorout 'Could not detect theme library "beautiful". Exiting.'

    if [[ "$HOSTNAME" == laptop ]]; then
        curtheme=$(grep "^themelap" "$RC_FILE" | awk -F\/ '{print $2}')
    elif [[ "$HOSTNAME" == htpc ]]; then
        curtheme=$(grep "^themehtpc" "$RC_FILE" | awk -F\/ '{print $2}')
    else
        curtheme=$(grep -oP "[^\/]+(?=\/theme.lua)" "$RC_FILE")
    fi
    
    # Change theme
    theme_set() {
        if [[ "$HOSTNAME" == laptop ]]; then
            theme=themelap
        elif [[ "$HOSTNAME" == htpc ]]; then
            theme=themehtpc
        else
            theme="^beautiful\.init"
        fi

        if [[ "$file" ]]; then
            [[ $(theme_list | grep -c $file) -lt 1 ]] && errorout 'No such theme.'
            echo "changing $curtheme to $file in $RC_FILE"
            sed -i "/$theme.*\/theme\.lua\"/s/[^/]*\(\/theme\.lua\)/$file\1/" "$RC_FILE"
        else
            [[ $(theme_list | grep -c $2) -lt 1 ]] && errorout 'No such theme.'
            echo "changing $curtheme to $2 in $RC_FILE"
            sed -i "/$theme.*\/theme\.lua\"/s/[^/]*\(\/theme\.lua\)/$2\1/" "$RC_FILE"
        fi
    }
    # Print themename
    theme_get() {
        echo "$curtheme"
    }
    # Select random theme and start Xephyr instance
    theme_random() {
        themes=$(ls -1 $(dirname "$RC_FILE")/themes /usr/share/awesome/themes | grep -vE '/home/|/usr/|icons|README')
        file=$(echo "$themes" | sort --random-sort | head -1)
        theme_set
        D=11 && start
    }
  
    case "$1" in
        g|get)    theme_get;;
        s|set)    theme_set "${args[@]}";;
        r|random) theme_random;;
        *)        errorout "unrecognized argument. Use theme (list | random | get | set <theme>)";;
    esac
}
#}}}

#{{{ Parse options
parse_options() {
    while [[ -n "$1" ]]; do
        case "$1" in
            start)          input=start;;
            stop)           input=stop;;
            restart)        input=restart;;
            run)            input=run;;
            theme)          input=theme;;
            -B|--binary)    shift; AWESOME="$1";;
            -C|--config)    shift; RC_FILE="$1";;
            -D|--display)   shift; D="$1"
                            [[ ! "$D" =~ ^[0-9] ]] && errorout "$D is not a valid display number";;
            -N|--notest)    RC_FILE="$HOME"/.config/awesome/rc.lua;;
            -S|--size)      shift; SIZE="$1";;
            -a|--aopt)      shift; AWESOME_OPTIONS+="$1";;
            -x|--xopts)     shift; XEPHYR_OPTIONS="$@";;
            -h|--help)      usage;;
            *)              args+=("$1");;
        esac
        shift
    done
}
#}}}
#}}}

#{{{ Main 
main() {
    case "$input" in
        start)    start "${args[@]}";;
        stop)     stop "${args[@]}";;
        restart)  restart "${args[@]}";;
        run)      run "${args[@]}";;
        theme)    theme "${args[@]}";;
        *)        echo "Option missing or not recognized";;
    esac
}
#}}}

parse_options "$@"
main
