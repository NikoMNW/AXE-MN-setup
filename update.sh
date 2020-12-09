#!/bin/bash
# AXE Masternode Update Script for Ubuntu 16.04 LTS
#
# Script will attempt to Stop and remove old install and update the daemon
# and generate masternode private key unless specified in command line
#
# Usage:
# bash update.sh 
#

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running

function stop_daemon {
    if pgrep -x 'axed' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop axed${NC}"
        axe-cli stop
        delay 60
        if pgrep -x 'axe' > /dev/null; then
            echo -e "${RED}axed daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            pkill axed
            delay 60
            if pgrep -x 'axed' > /dev/null; then
                echo -e "${RED}Can't stop axed! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}

#Function detect_ubuntu

 if [[ $(lsb_release -d) == *16.04* ]]; then
   UBUNTU_VERSION=16
else
   echo -e "${RED}You are not running Ubuntu 16.04, Installation is cancelled.${NC}"
   exit 1

fi


#Check for updates

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y update

#remove existing daemon 
 stop_daemon
rm -rf ~/AXE-MN-setup/axecore*
rm /usr/bin/axe*

#Installing Daemon
 cd ~
wget https://github.com/AXErunners/axe/releases/download/v1.6.1.1/axecore-1.6.1.1-x86_64-linux-gnu.tar.gz
tar -xzf axecore-1.6.1.1-x86_64-linux-gnu.tar.gz -C ~/AXE-MN-setup
rm -rf axecore-1.6.1.1-x86_64-linux-gnu.tar.gz
 
 # Deploy binaries to /usr/bin
 sudo rm ~/AXE-MN-setup/axecore-1.6.1.1/bin/axe-qt
 sudo rm ~/AXE-MN-setup/axecore-1.6.1.1/bin/test*
 sudo cp ~/AXE-MN-setup/axecore-1.6.1.1/bin/axe* /usr/bin/
 sudo chmod 755 -R ~/AXE-MN-setup
 sudo chmod 755 /usr/bin/axe*
 

    #Starting daemon
    axed -daemon -reindex
echo -ne '[##                 ] (15%)\r'
sleep 10
echo -ne '[######             ] (30%)\r'
sleep 10
echo -ne '[########           ] (45%)\r'
sleep 10
echo -ne '[############       ] (67%)\r'
sleep 10
echo -ne '[################   ] (72%)\r'
sleep 10
echo -ne '[###################] (100%)\r'
echo -ne '\n'


echo -e "========================================================================
${YELLOW}Masternode Update is complete!${NC}
========================================================================"

delay 30
# Run axemon.sh
axemon.sh

# EOF
