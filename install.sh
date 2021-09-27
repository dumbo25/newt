#!/bin/bash
# sript to install Open Source Image Duplicator (OSID)
#
# run using
#    bash install.sh

echo "Installation script for Open Source Image Duplicator (OSID)"

# create directory and cd into it
echo " "
echo "if necessary, creating osid directory"
cd ~/.
if [ ! -d "/home/pi/osid" ]
then
    mkdir osid
fi
cd osid

# update and uphrade packages
echo "  update and upgrade"
echo "    *** temporarily commented out"
# sudo apt update -y
# sudo apt upgrade -y
# sudo apt autoremove -y

# get base tools
#   Raspberry Pi OS comes pre-installed with:
#     python3, pip3
#   Need to install:
#     dcfldd, CherryPi
echo "  installing required packages"
REQUIRED_PKG="dcfldd"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
if [ "" = "$PKG_OK" ]; then
  echo "    $REQUIRED_PKG"
  sudo apt install $REQUIRED_PKG -y
fi

REQUIRED_PKG="CherryPi"
PKG_OK=$(pip3 list | grep "$REQUIRED_PKG")
if [ "$REQUIRED_PKG" = "$PKG_OK" ]; then
  echo "    $REQUIRED_PKG"
  sudo pip3 install $REQUIRED_PKG --yes
fi

# files from github repository
echo "  getting files from repository"
cd ~/osid
if [ ! -d "/home/pi/osid/system" ]
then
    mkdir system
fi
cd ~/osid/system
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/system/osid.desktop.sample
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/system/run_app.sh.sample
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/system/server.ini.sample
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/system/server.py

cd ~/osid
if [ ! -d "/home/pi/osid/www" ]
then
    mkdir www
fi
cd ~/osid/www
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/www/index.html
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/www/monitor.html
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/www/skeleton.min.css

# follow directions in https://github.com/aaronnguyen/osid-python3/blob/master/README.md
# how does website start ???
# might need to get images from original; repo ???
#   https://github.com/rockandscissor/osid/tree/master/www/public_html/images

# copying files
echo "  copying files"
cd ~/osid/system

cp server.ini.sample server.ini
cp run_app.sh.sample run_app.sh
cp osid.desktop.sample ~/Desktop/osid.desktop
