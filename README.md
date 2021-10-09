# Newt (MicroSD Card Duplicator)
Newt clones multiple MicroSD cards from one .img file.

## Required Operating System
Latest version of Raspberry Pi OS

## Required Hardware
* 8GB Raspberry Pi 4 with Case connected to Power Adapter
* 64GB Class 10, Ultra MicroSD Card with Raspberry Pi OS inserted into the Raspberry Pi's MicroSD Card slot
* Powered USB 3.0 hub (10 ports) with power cord and USB cable connected to Raspberry Pi
* MicroSD card USB 3.0 readers (10 total) inserted into USB Hub
* 1-10 16GB or 32GB Class 10, Ultra MicroSD cards inserted into USB readers

## Installation 
Newt runs headless on a Raspberry Pi 4 using Raspberry Pi OS on a home LAN.

These directions assume a [Raspberry Pi is properly setup](https://sites.google.com/site/cartwrightraspberrypiprojects/home/steps/setup-raspberry-pi-3-with-raspbian) and running Raspberry Pi OS and the goal is to run the MicroSD Card duplicator as a networked device on a home LAN.

install.sh installs all the required software, makes any needed directories and sets any needed permissions. install.sh is a generic installer and relies on install.cfg to set up newt correctly.

* Step 1. Open a terminal window
* Step 2. From the terminal window, ssh into a Raspberry Pi 4 running Raspberry PI OS. 
```
ssh pi@newt.♣your-hostname♣
password: ♣your-password♣
```
* Step 3. Download and run newt's install.sh script and configuration file 
```
wget https://raw.githubusercontent.com/dumbo25/newt/master/install.sh
wget https://raw.githubusercontent.com/dumbo25/newt/master/install.cfg
sudo bash install.sh
```
* Step 4. Run the following command to add a line to the end of apache2.conf
```
echo "ServerName 127.0.0.1" | sudo tee -a /etc/apache2/apache2.conf
```
* Step 5. Reload apache2 using
```
sudo systemctl reload apache2.service
```
* Step 6. Change to /home/pi/newt and run: sudo python3 server.py
* Step 7. Open a browser and enter hostname.local


## Usage
A Raspberry Pi (RPi) runs the newt webserver. A user opens a browser and connects to the RPi's webserver 
```
http://♣your-hostname♣. 
```
Newt clones one image to 1-10 MicroSD cards. I believe the number of MicroSD Cards can be increased by adding more USB Hubs, but I have not tested this.

## Get an image
* Download image from here to your laptop https://www.raspberrypi.com/software/operating-systems/
* Open a terminal window on laptop
* Change directory to Downloads
```
cd Downloads
```
* Copy the file from MacBook to Raspberry Pi
```
scp 2021-05-07-raspios-buster-armhf-lite.zip pi@newt:/home/pi
```
* Open a terminal window and ssh to Raspberry Pi
```
ssh pi@♣your-hostname♣
password: ♣your-password♣
unzip scp 2021-05-07-raspios-buster-armhf-lite.zip 
cp 2021-05-07-raspios-buster-armhf-lite.img newt/clone/.
```

### Accepted image file
Newt will accept any image file ending with .img name. Other extensions will silently be ignored.

### Auto discovery of available readers
When refreshing the newt web page (or accessing it), newt will scan for available readers, and after some seconds, will show them on the menu. A sum of all readers is also shown.


## Original Authors
* [aaronnguyen/OSID](https://github.com/aaronnguyen/osid-python3) - python3 version of OSID Project
* [rockandscissor/OSID](https://github.com/rockandscissor/osid) - Base OSID Project originally written in PHP and Bash


### Significant Changes from Aaron's OSID
- added generic install.sh with duplicator specific install.cfg
- simplify directions
- migrate from CherryPy to flask or python https


### Dependencies
* [CherryPy](http://docs.cherrypy.org/en/latest/) - API Library for Python used to manage all actions
* [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) - CSS framework used to structure Web UI


### References
* [nettings/tarot](https://github.com/nettings/tarot) - very cool improvements, changed from python to php and js
* [Raspberry Tips](https://raspberrytips.com/create-image-sd-card/) How to Create an Image of a Raspberry Pi SD Card?
* [RaspberryPi.org](https://www.raspberrypi.org/documentation/computers/getting-started.html#using-raspberry-pi-imager) Using Raspberry Pi Imager
* [RaspberryPi/github](https://github.com/raspberrypi/rpi-imager) Github repository for Raspberry Pi Imager
* [billw2/rpi-clone](https://github.com/billw2/rpi-clone) RPi clone
* [Igoro Oseledko](https://www.igoroseledko.com/backup-options-for-raspberry-pi/) Backup Options for Raspberry Pi
* [tyrower/diy-duplicator](https://github.com/tyrower/diy-duplicator) Micro SD duplicator using mdadm (RAID disk utilities) written in bash

## Versioning
[SemVer](http://semver.org/) is used for version numbers. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

Version needs to be changed in index.html, monitor.html.


## License
This project is licensed under the GNU GPLv3 - see the [LICENSE.md](LICENSE.md) file for details
