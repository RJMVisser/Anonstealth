#!/bin/bash

export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Please run as root!$RESETCOLOR"
    exit
fi

declare -ga install
install=()

declare -ga modules
modules=()

programs()
{
    if [[ -f "/usr/bin/pacman" ]]; then
        modules=("iproute2" "geoiplookup" "tor" "bleachbit" "iptables" "libnotify" "zenity" "curl" "openbsd-netcat")
        for i in "${modules[@]}";
        do
            if [ -z "$(pacman -Q --color always "$i")" ]
            then
                install+=("$i")
            fi
        done
    elif [[ -f "/usr/bin/apt" ]]; then
        modules=("netcat-openbsd" "tor" "bleachbit" "iptables" "zenity" "curl" "libnotify-bin")
        for i in "${modules[@]}";
        do
            if [ "$(dpkg -l "$i" )"  != '0' ]
            then
                install+=("$i")
            fi
        done
    fi
}
programs

if [ -n "${install[*]}" ]
then
    exit
fi

case "$1" in
    "install"|"-i"|"--install")
        echo "Installing..."
        mkdir -p ~/.mozilla/firefox/
        mkdir -p /etc/pandora
        cp pandora /usr/bin/pandora
        tar -xzf tor-profile.tar.gz -C ~/.mozilla/firefox/ 
        mkdir -p /etc/anonsurf
        cp onion.pac /etc/anonsurf/onion.pac
        cp torrc /etc/anonsurf/torrc
        cp anonsurf /usr/bin/anonsurf
        cp exitnode-selector /usr/bin/exitnode-selector
        cp exitnodes.csv /etc/anonsurf/exitnodes.csv
        cp resolv.conf.opennic /etc/anonsurf/resolv.conf.opennic
        chown root:root -R /etc/anonsurf
        chown root:root -R /etc/pandora
        chmod 755 /usr/bin/anonsurf
        chmod 755 /usr/bin/exitnode-selector
        chmod 755 /usr/bin/pandora
        chmod 755 /etc/anonsurf
        chmod 755 /etc/pandora
        ;;
    "remove"|"-r"|"--remove")
        echo "Uninstalling..."
        rm -r ~/.mozilla/firefox/b6csghrf.Tor
        rm /usr/bin/anonsurf
        rm /usr/bin/exitnode-selector
        rm -r /etc/anonsurf
        ;;
    ""|"help"|"-h"|"--help")
        echo "Usage:"
        echo -e "sudo bash ./install { $GREEN--install$RESETCOLOR or $GREEN-i$RESETCOLOR | $GREEN--remove$RESETCOLOR or $GREEN-r$RESETCOLOR }"
        ;;
    *)
        echo -e "${RED}Input not recognized$RESETCOLOR"
esac
