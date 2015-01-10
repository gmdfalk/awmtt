# awmtt
awmtt (AwesomeWM Testing Tool) is a bash script that helps you test your Awesome configuration files.  
It requires Xephyr, an Xorg-Application which can spawn a nested instance of xorg-server, allowing you to open multiple instances of Desktop Environments or Window Mangers like AwesomeWM.  

### Installation
ArchLinux users can find awmtt in the [AUR](https://aur.archlinux.org/packages/awmtt/).

Example Debian/Ubuntu manual installation:
``` bash
sudo apt-get install xserver-xephyr
sudo wget -O /usr/bin/awmtt https://raw.githubusercontent.com/mikar/awmtt/master/awmtt.sh
sudo chmod a+x /usr/bin/awmtt
```

### Screenshot
Here's an example of what it looks like:  
![ScreenShot](https://github.com/mikar/awmtt/blob/master/example.jpg)

### Usage
```
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
  -x|--xopts <opts>   Pass options to xephyr binary (e.g. -retro or -keybd). Needs to be last.
  -h|--help           Show this help text and exit
  
Examples:
  awmtt start (uses defaults: -C $HOME/.config/awesome/rc.lua.test -D 1 -S 1024x640)
  awmtt start -C /etc/xdg/awesome/rc.lua -D 3 -S 1280x800
  awmtt theme set zenburn -N
```

### Xephyr Usage
Have a look at http://awesome.naquadah.org/wiki/Using_Xephyr and its documentation to learn more about how to use it. 
For instance, you can press `Control-Mod3-Shift` to have Xephyr grab focus while inside the window so that you can't accidentally leave it. To let go, press `Control-(Right-)Shift`.  
