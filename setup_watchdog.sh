#!/bin/bash

# Please call init before enable
init() {
  printf 'Initializing watchdog ...\n'
  echo 'dtparam=watchdog=on' >> /boot/config.txt
  printf 'The system will restart in 3 sec...\n'
  sleep 3
  reboot
}


enable() {
  if ! grep -Fxq "dtparam=watchdog=on" /boot/config.txt; then 
    printf 'Please call init before trying to enable\n'
    exit 1
  fi

  printf 'Updating apt...\n'
  sleep 1
  apt-get -y update

  printf '\nInstalling watchdog package...\n'
  sleep 1
  apt-get -y install watchdog

  printf '\nSeting up watchdog configuration in /etc/watchdog.conf ...\n'
  sleep 1
  printf 'watchdog-device = /dev/watchdog\n'
  echo 'watchdog-device = /dev/watchdog' >> /etc/watchdog.conf
  printf 'watchdog-timeout = 15\n'
  echo 'watchdog-timeout = 15' >> /etc/watchdog.conf
  printf 'max-load-1 = 24\n'
  echo 'max-load-1 = 24' >> /etc/watchdog.conf

  printf '\nEnabling and starting daemon...\n'
  sleep 1
  systemctl enable watchdog
  systemctl start watchdog

  printf '\nDone !\n'
  printf 'You can check daemon status using "sudo systemctl status watchdog"\n'
  printf "You can test it with a fork bomb : \"sudo bash -c ':(){ :|:& };:'\"\n"

  exit 1
}


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

case "$1" in
	init|enable)
		"$1";;
	*)
		echo "Usage: $0 {init|enable}"
		exit 1
esac

