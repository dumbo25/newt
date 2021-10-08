# Newt (MicroSD Card Duplicator)

Newt clones multiple MicroSD cards from one .img file.

A Raspberry Pi (RPi) runs a webservber. The RPi connects to a powered USB 3.0 HUB. A user opens a browser and connects to the RPi's webserver to clone the image.

Newt runs on an 8GB Raspberry Pi 4 running Raspberry Pi OS.


## Required Hardware
- 8GB Raspberry Pi 4 with Case and Power Adapter
- 64GB Class 10, Ultra MicroSD Card with Raspberry Pi OS
- Powered USB 3.0 hub (10 ports) wiht power cord and USB cable
- MicroSD card USB 3.0 readers (10 total)
- 1-10 16GB or 32GB Class 10, Ultra MicroSD cards

## Installation 
Newt can run on the Raspberry Pi OS Desktop or it can be run headless from another server on a home LAN.

These directions assume a Raspberry Pi is properly setup and running Raspberry Pi OS and the goal is to run the MicroSD Card duplicator as a networked device on a home LAN.

install.sh installs all the required software, makes any needed directories and sets any needed permissions. install.sh is a generic installer and relies on install.cfg to set up newt correctly.

* Step 1. Open a terminal window
* Step 2. From the terminal window, ssh into a Raspberry Pi 4 running Raspberry PI OS. 
* Step 3. Download and run newt's install.sh script and configuration file 

```
wget https://raw.githubusercontent.com/dumbo25/newt/master/install.sh
wget https://raw.githubusercontent.com/dumbo25/newt/master/install.cfg
sudo bash install.sh
```
* Step 4. 
* Step 5. Change to /home/pi/newt and run: sudo python3 server.py
* Step 6. Open a browser and enter hostname.local


## Usage
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


## License
This project is licensed under the GNU GPLv3 - see the [LICENSE.md](LICENSE.md) file for details
