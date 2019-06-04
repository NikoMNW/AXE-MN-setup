#!/bin/bash
# AXE Masternode Setup Script V1.0 for Ubuntu 16.04 LTS
#
# Script will attempt to auto detect primary public IP address
# and generate masternode private key unless specified in command line
#
# Usage:
# bash axe-setup.sh 
#

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#AXE TCP port
PORT=9937
RPC=9337

#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running
function stop_daemon {
    if pgrep -x 'axed' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop axed${NC}"
        axe-cli stop
        delay 30
        if pgrep -x 'axe' > /dev/null; then
            echo -e "${RED}axed daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            pkill axed
            delay 30
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


#Process command line parameters
# genkey=$1

# clear

# echo -e "${YELLOW}AXE Coin DIP003 Masternode Setup Script V1 for Ubuntu 16.04 LTS${NC}"
# echo "Do you want me to generate a masternode private key for you? [y/n]"
  # read DOSETUP
# if [[ $DOSETUP =~ "n" ]] ; then
          # read -e -p "Enter your private key:" genkey;
              # read -e -p "Confirm your private key: " genkey2;
# fi

#Confirming match
  # if [ $genkey = $genkey2 ]; then
     # echo -e "${GREEN}MATCH! ${NC} \a" 
# else 
     # echo -e "${RED} Error: Private keys do not match. Try again or let me generate one for you...${NC} \a";exit 1
# fi
# sleep .5
# clear



genkey=$3
#Enter the new BLS genkey
echo -e "${YELLOW}AXE Coin DIP003 Masternode Setup Script V1 for Ubuntu 16.04 LTS${NC}"
echo -e "Enter your BLS Key"
	read -e -p "Enter your BLS key:" genkey3;
              read -e -p "Confirm your BLS key: " genkey4;

#Confirming match
  if [ $genkey3 = $genkey4 ]; then
     echo -e "${GREEN}MATCH! ${NC} \a" 
else 
     echo -e "${RED} Error: BLS key do not match. Try again...${NC} \a";exit 1
fi
sleep .5
clear

# Determine primary public IP address
dpkg -s dnsutils 2>/dev/null >/dev/null || sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi
#Check Deps
if [ -d "/var/lib/fail2ban/" ]; 
then
    echo -e "${GREEN}Dependencies already installed...${NC}"
else
    echo -e "${GREEN}Updating system and installing required packages...${NC}"

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop jq
sudo apt-get -y install libzmq3-dev
sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo apt-get -y install libevent-dev
sudo apt-get instal unzip
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
sudo apt-get install unzip
sudo apt-get -y install libminiupnpc-dev
sudo apt-get -y install fail2ban
sudo service fail2ban restart
sudo apt-get install -y libdb5.3++-dev libdb++-dev libdb5.3-dev libdb-dev && ldconfig
sudo apt-get install -y unzip libzmq3-dev build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libboost-system1.58.0 libboost1.58-all-dev libdb4.8++ libdb4.8 libdb4.8-dev libdb4.8++-dev libevent-pthreads-2.0-5
   fi

#Network Settings
echo -e "${GREEN}Installing Network Settings...${NC}"
{
sudo apt-get install ufw -y
} &> /dev/null
echo -ne '[##                 ]  (10%)\r'
{
sudo apt-get update -y
} &> /dev/null
echo -ne '[######             ] (30%)\r'
{
sudo ufw default deny incoming
} &> /dev/null
echo -ne '[#########          ] (50%)\r'
{
sudo ufw default allow outgoing
sudo ufw allow ssh
} &> /dev/null
echo -ne '[###########        ] (60%)\r'
{
sudo ufw allow $PORT/tcp
sudo ufw allow $RPC/tcp
sudo ufw allow 9936/tcp
} &> /dev/null
echo -ne '[###############    ] (80%)\r'
{
sudo ufw allow 22/tcp
sudo ufw limit 22/tcp
} &> /dev/null
echo -ne '[#################  ] (90%)\r'
{
echo -e "${YELLOW}"
sudo ufw --force enable
echo -e "${NC}"
} &> /dev/null
echo -ne '[###################] (100%)\n'

#Generating Random Password for axed JSON RPC
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)


#Installing Daemon
 cd ~
wget https://github.com/AXErunners/axe/releases/download/v1.4.0.1/axecore-1.4.0.1-x86_64-linux-gnu.tar.gz
tar -xzf axecore-1.4.0.1-x86_64-linux-gnu.tar.gz -C ~/AXE-MN-setup
rm -rf axecore-1.4.0.1-x86_64-linux-gnu.tar.gz
 
 stop_daemon
 
 # Deploy binaries to /usr/bin
 sudo rm ~/AXE-MN-setup/axecore-1.4.0/bin/axe-qt
 sudo rm ~/AXE-MN-setup/axecore-1.4.0/bin/test*
 sudo cp ~/AXE-MN-setup/axecore-1.4.0/bin/axe* /usr/bin/
 sudo chmod 755 -R ~/AXE-MN-setup
 sudo chmod 755 /usr/bin/axe*
 
 # Deploy masternode monitoring script
 cp ~/AXE-MN-setup/axemon.sh /usr/local/bin
 sudo chmod 711 /usr/local/bin/axemon.sh
 
 #Create axe datadir
 if [ ! -f ~/.axecore/axe.conf ]; then 
 	sudo mkdir ~/.axecore
 fi

echo -e "${YELLOW}Creating axe.conf...${NC}"

# If genkey was not supplied in command line, we will generate private key on the fly
if [ -z $genkey ]; then
    cat <<EOF > ~/.axecore/axe.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
EOF

    sudo chmod 755 -R ~/.axecore/axe.conf

    #Starting daemon first time just to generate masternode private key
    axed -daemon
echo -ne '[##                 ] (15%)\r'
sleep 6
echo -ne '[######             ] (30%)\r'
sleep 9
echo -ne '[########           ] (45%)\r'
sleep 6
echo -ne '[############       ] (67%)\r'
sleep 9
echo -ne '[################   ] (72%)\r'
sleep 10
echo -ne '[###################] (100%)\r'
echo -ne '\n'

    #Generate masternode private key
    echo -e "${YELLOW}Generating masternode private key...${NC}"
    genkey=$(axe-cli masternode genkey)
    if [ -z "$genkey" ]; then
        echo -e "${RED}ERROR: Can not generate masternode private key.${NC} \a"
        echo -e "${RED}ERROR: Reboot VPS and try again or supply existing genkey as a parameter.${NC}"
        exit 1
    fi
    
    #Stopping daemon to create axe.conf
    stop_daemon
fi

# Create axe.conf
cat <<EOF > ~/.axecore/axe.conf
rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcport=$RPC
rpcallowip=127.0.0.1
onlynet=ipv4
listen=1
server=1
daemon=1
logintimestamps=1
maxconnections=10
externalip=$publicip:$PORT
masternode=1
masternodeprivkey=$genkey
masternodeblsprivkey=$genkey3
EOF

#Finally, starting axe daemon with new axe.conf
axed -daemon
echo -ne '[##                 ] (15%)\r'
sleep 10
echo -ne '[######             ] (30%)\r'
sleep 5
echo -ne '[########           ] (45%)\r'
sleep 5
echo -ne '[##############     ] (72%)\r'
sleep 10
echo -ne '[###################] (100%)\r'
axe-cli addnode 198.13.50.26:9937 onetry
echo -ne '\n'

#Install Sentinel 
echo -e "${YELLOW}Installing sentinel...${NC}"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get -y install python-pip
sudo apt-get -y install virtualenv
      cd ~/.axecore
	  git clone https://github.com/AXErunners/sentinel.git

    cd ~/.axecore/sentinel
      virtualenv venv
      ./venv/bin/pip install -r requirements.txt
      ./venv/bin/python bin/sentinel.py
    chmod -R 755 database
    cd
    crontab -l > sentinelcron
    echo "* * * * * cd /root/.axecore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> sentinelcron

crontab sentinelcron
rm sentinelcron

#Setting auto start cron job for axed
cronjob="@reboot sleep 30 && axed -daemon"
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
    echo -e "${GREEN}Configuring crontab job...${NC}"
    echo $cronjob >> tempcron
    crontab tempcron
fi
rm tempcron

echo -e "========================================================================
${YELLOW}Masternode setup is complete!${NC}
========================================================================
Masternode was installed with VPS IP Address: ${YELLOW}$publicip${NC}
Masternode Private Key: ${YELLOW}$genkey${NC}
Now you can add the following string to the masternode.conf file
for your Hot Wallet (the wallet with your AXE collateral funds):
======================================================================== \a"
echo -e "${YELLOW}mn1 $publicip:$PORT $genkey TxId TxIdx${NC}"
echo -e "========================================================================
Use your mouse to copy the whole string above into the clipboard by
tripple-click + single-click (Dont use Ctrl-C) and then paste it 
into your ${YELLOW}masternode.conf${NC} file and replace:
    ${YELLOW}mn1${NC} - with your desired masternode name (alias)
    ${YELLOW}TxId${NC} - with Transaction Id from masternode outputs
    ${YELLOW}TxIdx${NC} - with Transaction Index (0 or 1)
     Remember to save the masternode.conf and restart the wallet!
To introduce your new masternode to the AXE network, you need to
issue a masternode start command from your wallet, which proves that
the collateral for this node is secured."

clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "1) Wait for the node wallet on this VPS to sync with the other nodes
on the network. Eventually the 'Is Synced' status will change
to 'true', which will indicate a comlete sync, although it may take
from several minutes to several hours depending on the network state.
Your initial Masternode Status may read:
    ${YELLOW}Node just started, not yet activated${NC} or
    ${YELLOW}Node  is not in masternode list${NC}, which is normal and expected.
2) Wait at least until 'IsBlockchainSynced' status becomes 'true'.
At this point you can go to your wallet and issue a start
command by either using Debug Console:
    Tools->Debug Console-> enter: ${YELLOW}masternode start-alias mn1${NC}
    where ${YELLOW}mn1${NC} is the name of your masternode (alias)
    as it was entered in the masternode.conf file
    
or by using wallet GUI:
    Masternodes -> Select masternode -> RightClick -> ${YELLOW}start alias${NC}
Once completed step (2), return to this VPS console and wait for the
Masternode Status to change to: 'Masternode successfully started'.
This will indicate that your masternode is fully functional and
you can celebrate this achievement!
Currently your masternode is syncing with the AXE network...
The following screen will display in real-time
the list of peer connections, the status of your masternode,
node synchronization status and additional network and node stats.
"
clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "
${GREEN}...scroll up to see previous screens...${NC}
Here are some useful commands and tools for masternode troubleshooting:
========================================================================
To view masternode configuration produced by this script in axe.conf:
${YELLOW}cat ~/.axecore/axe.conf${NC}
Here is your axe.conf generated by this script:
-------------------------------------------------${YELLOW}"
cat ~/.axecore/axe.conf
echo -e "${NC}-------------------------------------------------
NOTE: To edit axe.conf, first stop the axed daemon,
then edit the axe.conf file and save it in nano: (Ctrl-X + Y + Enter),
then start the axed daemon back up:
             to stop:   ${YELLOW}axe-cli stop${NC}
             to edit:   ${YELLOW}axe ~/.axecore/axe.conf${NC}
             to start:  ${YELLOW}axed${NC}
========================================================================
To view AXE debug log showing all MN network activity in realtime:
             ${YELLOW}tail -f ~/.axecore/debug.log${NC}
========================================================================
To monitor system resource utilization and running processes:
                   ${YELLOW}htop${NC}
========================================================================
To view the list of peer connections, status of your masternode, 
sync status etc. in real-time, run the axemon.sh script:
                 ${YELLOW}axemon.sh${NC}
or just type 'node' and hit <TAB> to autocomplete script name.
========================================================================
Enjoy your AXE Masternode and thanks for using this setup script!

If you found this script useful, please donate to : 
${GREEN}no donations at this time ${NC}
...and make sure to check back for updates!
"
delay 30
# Run axemon.sh
axemon.sh

# EOF
