#!/bin/bash
# awmtt: awesomewm testing tool
# https://github.com/mikar/awmtt

#{{{ Usage
usage() {
  cat <<EOF
awmtt [ start | stop | restart | -h | -e | -t [ get | change | list | random ]]
[ -C /path/to/rc.lua ] [ -D display ] [ -S windowsize ] [-o 'additional args to pass to awesome' ]

  start         Spawn nested Awesome via Xephyr
  stop          Stops Xephyr
    all     Stop all instances of Xephyr 
  restart       Restart nested Awesome
  -N|--notest       Don't use a testfile but your actual rc.lua (i.e. $HOME/.config/awesome/rc.lua)
  -C|--config       Specify configuration file
  -D|--display      Specify the display to use (e.g. 1)
  -S|--size     Specify the window size
  -e|--execute      Execute command in nested Awesome
  -t|--theme        Control the current theme
  -o|--options      Pass extra options to awesome command (i.e. -o '--no-argb')
    c|change    Change theme
    g|get       Get current themename
    l|list      List available themes
    r|random    Choose random theme
  -h|--help     Show this help text
  
examples:
awmtt start (uses defaults)
awmtt start -D 3 -C /etc/xdg/awesome/rc.lua -S 1280x800
awmtt -t change zenburn

The defaults are -D 1 -C $HOME/.config/awesome/rc.lua.test -S 1024x640.

EOF
    exit 0
}
[ "$#" -lt 1 ] && usage
#}}}

#{{{ Utilities
awesome_pid() { pgrep -fn "/usr/bin/awesome"; }
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
OPTIONS=""
# Path to rc.lua
if [[ "$XDG_CONFIG_HOME" ]];then
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
    for ((i=0;;i++)); do if [[ ! -f "/tmp/.X${i}-lock" ]] ;then D=$i;break;fi;done

    "$XEPHYR" -name xephyr_$D -ac -br -noreset -screen "$SIZE" :$D >/dev/null 2>&1 &
    sleep 1
    DISPLAY=:$D.0 "$AWESOME" -c "$RC_FILE" "$OPTIONS" &
    sleep 1
    
    # print some useful info
    if [[ "$RC_FILE" =~ .test$ ]];then
    echo "Using a test file ($RC_FILE)"
    else
    echo "Caution: NOT using a test file ($RC_FILE)"
    fi

    echo "Display: $D, Awesome PID: $(awesome_pid), Xephyr PID: $(xephyr_pid)"
}
#}}}
#{{{ Stop function
stop() {
    if [[ "$1" == all ]];then
    echo "Stopping all instances of Xephyr"
    kill $(pgrep Xephyr) >/dev/null 2>&1
    elif [[ $(xephyr_pid) ]];then
    echo "Stopping Xephyr for display $D"
    kill $(xephyr_pid)
    else
    echo "Xephyr is not running or you did not specify the correct display with -D"
    exit 0
    fi
}
#}}}
#{{{ Restart function
restart() { # TODO: (maybe use /tmp/.X{i}-lock files) Find a way to uniquely identify an awesome instance (without storing the PID in a file). Until then all instances spawned by this script are restarted...
    echo -n "Restarting Awesome... "
    for i in $(pgrep -f "/usr/bin/awesome -c"); do kill -s SIGHUP $i; done
}
#}}}
#{{{ Run function
run() {
    #shift
    DISPLAY=:$D.0 "$@" &
    LASTPID=$!
    echo "PID is $LASTPID"
}
#}}}
#{{{ Theme function
theme() {

    # List themes
    theme_list() { #TODO: list only directories
    if [[ -d $(dirname "$RC_FILE")/themes ]];then
        ls /usr/share/awesome/themes $(dirname "$RC_FILE")/themes
    else
        ls /usr/share/awesome/themes "$HOME"/.config/awesome/themes
    fi
    }    
    case "$1" in
    l|list) theme_list
        exit 0;;
    esac
    
    # Check for Beautiful library
    BEAUTIFUL=$(grep -c 'beautiful.init' "$RC_FILE")
    [[ "$BEAUTIFUL" -ge 1 ]] || errorout 'Could not detect theme library "beautiful". Exiting.'

    if [[ "$HOSTNAME" == laptop ]];then
    curtheme=$(grep "^themelap" "$RC_FILE" | awk -F\/ '{print $2}')
    elif [[ "$HOSTNAME" == htpc ]];then
    curtheme=$(grep "^themehtpc" "$RC_FILE" | awk -F\/ '{print $2}')
    else
    curtheme=$(grep -oP "[^\/]+(?=\/theme.lua)" "$RC_FILE")
    fi
    
    # Change theme
    theme_change() {

    if [[ "$HOSTNAME" == laptop ]];then
        theme=themelap
    elif [[ "$HOSTNAME" == htpc ]];then
        theme=themehtpc
    else
        theme="^beautiful\.init"
    fi
    

    if [[ "$file" ]];then
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
    theme_change
    D=11 && start
    
    }
  
    case "$1" in
    c|change)   theme_change "${args[@]}" ;;
    g|get)      theme_get       ;;
    r|random)   theme_random    ;;
    *)      errorout "unrecognized option to -t. Use -t list, get, change or random";;
    esac
}
#}}}

#{{{ Parse options
parse_options() {

    while [[ -n "$1" ]];do
    case "$1" in
        -N|--notest)    RC_FILE="$HOME"/.config/awesome/rc.lua ;;
        -C|--config)    shift; RC_FILE="$1" ;;
        -D|--display)   shift; D="$1"
                [[ ! "$D" =~ ^[0-9] ]] && errorout "$D is not a valid display number" ;;
        -S|--size)      shift; SIZE="$1" ;;
        -h|--help)      usage       ;;
        start)      input=start ;;
        stop)       input=stop  ;;
        restart|reload) input=restart   ;;
        -e|--execute)   input=run   ;;
        -t|--theme)     input=theme ;;
        -o|--options)   shift; OPTIONS="$1" ;;
        *)          args+=( "$1" )  ;;
    esac
    shift
    done

}
#}}}
#}}}

#{{{ Main 
main() {

  case "$input" in
    start)  start "${args[@]}"    ;;
    stop)   stop "${args[@]}"     ;;
    restart)    restart "${args[@]}"      ;;
    run)    run "${args[@]}"      ;;
    theme)  theme "${args[@]}"    ;;
    *)      echo "Option missing or not recognized" ;;
  esac
  
}
#}}}

parse_options "$@"
main
