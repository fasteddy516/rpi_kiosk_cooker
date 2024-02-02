#!/bin/bash

# ensure the script is being run as root
if [ "$EUID" -ne 0 ]
  then echo "This script must be run as root (i.e. with sudo)"
  exit
fi

# determine credentials that will be used to run kiosk application
USER=pi
PASSWORD=password
for arg in "$@"; do
  case $arg in
    --user=*)
      USER="${arg#*=}"
      shift
      ;;
    --password=*)
      PASSWORD="${arg#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

if false; then # this is the start of debugging bypass stuff

# update installed packages
apt update
apt full-upgrade -y
apt install -y xserver-xorg x11-xserver-utils xinit xinput xterm openbox unclutter

# enable console autologin
raspi-config nonint do_boot_behaviour B2

# disable splash screen (1 = disabled)
raspi-config nonint do_boot_splash 1

# disable overscan for both hdmi outputs
raspi-config nonint do_overscan_kms 1 1
raspi-config nonint do_overscan_kms 2 1

# disable screen blanking
raspi-config nonint do_blanking 1

# disable rainbow test pattern and force hdmi hotplug
sed -i -e '/disable_splash=/d' -e '/hdmi_force_hotplug=/d' -e '${/^$/d;}' /boot/firmware/config.txt
sed -i -e '$a disable_splash=1\nhdmi_force_hotplug=1\n' /boot/firmware/config.txt

# set cmdline.txt parameters:
#    hide boot artifacts: console=, loglevel=, quiet, logo, plymouth
#    hide console artifacts: vt.global_cursor
#    set default display resolutions: video=
sed -i -e 's/console=tty1/console=tty3/g' -e 's/$/ loglevel=3 quiet logo.nologo plymouth.ignore-serial-consoles vt.global_cursor_default=0 video=HDMI-A-1:1920x1080@60 video=HDMI-A-2:1920x1080@60/' /boot/firmware/cmdline.txt

# create default application user if necessary
grep "^$USER:" /etc/passwd > /dev/null
if [ $? -ne 0 ]; then
  echo "User '$USER' does not exist and will be created"
  useradd -p "$(openssl passwd -6 $PASSWORD)" $USER
else  
  echo "User '$USER' already exists"
fi

# modify console autologin to use application user and clean up some login artifacts
sed -i -e "s|^ExecStart=-.*|ExecStart=-/sbin/agetty --skip-login --nonewline --noissue --autologin $USER --noclear %I \$TERM|" /etc/systemd/system/getty@tty1.service.d/autologin.conf
systemctl daemon-reload

# hide operating system information display on login
sed -i -e 's/^uname/#uname/' /etc/update-motd.d/10-uname

# disable message-of-the-day
cp -f /etc/motd /etc/motd.bak
echo "" > /etc/motd

# disable bash last login display
su $USER -c "touch ~/.hushlogin"

# start x environment after autologin
su $USER -c "echo '[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- >/dev/null 2>&1' > ~/.bash_profile"

su $USER -c "mkdir ~/.config ; mkdir ~/.config/openbox ; touch ~/.config/openbox/autostart"

cat << EOF >> /home/$USER/.config/openbox/autostart
# screen saver and power/sleep settings
xset -dpms     # turn off display power management system
xset s noblank # turn off screen blanking
xset s off     # turn off screen saver
EOF

fi # this is the end of debugging bypass stuff