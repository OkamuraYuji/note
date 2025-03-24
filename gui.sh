#!/bin/bash

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"
arch=$(uname -m)
username=$(getent passwd $(whoami) | cut -d ':' -f1)

check_root(){
    if [ "$(id -u)" -ne 0 ]; then
        echo -ne " ${R}Run this program as root!\n\n"${W}
        exit 1
    fi
}

banner() {
    clear
    cat <<- EOF
        ${Y}    _  _ ___  _  _ _  _ ___ _  _    _  _ ____ ___
        ${C}    |  | |__] |  | |\ |  |  |  |    |\/| |  | |  \
        ${G}    |__| |__] |__| | \|  |  |__|    |  | |__| |__/
    EOF
    echo -e "${G}     A modded GUI version of Ubuntu\n"
}

note() {
    banner
    echo -e " ${G} [-] Successfully Installed !\n"${W}
    sleep 1
    cat <<- EOF
         ${G}[-] Type ${C}vncstart${G} to run VNC server.
         ${G}[-] Type ${C}vncstop${G} to stop VNC server.

         ${C}Install VNC VIEWER on your Device.

         ${C}Open VNC VIEWER & Click on + Button.

         ${C}Enter the Address localhost:1 & Name anything you like.

         ${C}Set the Picture Quality to High for better Quality.

         ${C}Click on Connect & Input the Password.

         ${C}Enjoy :D${W}
    EOF
}

package() {
    banner
    echo -e "${R} [${W}-${R}]${C} Checking required packages..."${W}
    apt-get update -y

    packs=(sudo gnupg2 curl nano git xz-utils xfce4 xfce4-goodies xfce4-terminal librsvg2-common inetutils-tools tigervnc-standalone-server tigervnc-common tigervnc-tools dbus-x11 fonts-beng fonts-beng-extra gtk2-engines-murrine gtk2-engines-pixbuf apt-transport-https)
    for pkg in "${packs[@]}"; do
        dpkg -s "$pkg" &>/dev/null || {
            echo -e "\n${R} [${W}-${R}]${G} Installing package: ${Y}$pkg${W}"
            apt-get install "$pkg" -y --no-install-recommends
        }
    done

    apt-get upgrade -y
    apt-get clean
}

install_apt() {
    for apt in "$@"; do
        command -v $apt &>/dev/null && echo "${Y}${apt} is already Installed!${W}" || {
            echo -e "${G}Installing ${Y}${apt}${W}"
            apt install -y ${apt}
        }
    done
}

install_vscode() {
    command -v code &>/dev/null && echo "${Y}VSCode is already Installed!${W}" || {
        echo -e "${G}Installing ${Y}VSCode${W}"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        apt update -y
        apt install code -y
        echo -e "${C} Visual Studio Code Installed Successfully\n${W}"
    }
}

install_sublime() {
    command -v subl &>/dev/null && echo "${Y}Sublime is already Installed!${W}" || {
        apt install gnupg2 software-properties-common -y
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublime.gpg > /dev/null
        apt update -y
        apt install sublime-text -y
        echo -e "${C} Sublime Text Editor Installed Successfully\n${W}"
    }
}

config() {
    banner
    echo -e "${R} [${W}-${R}]${C} Configuring System...\n"${W}
    apt update -y
    apt upgrade -y
    apt clean
    apt autoremove -y
}

# ----------------------------

check_root
package
install_vscode
install_sublime
config
note
