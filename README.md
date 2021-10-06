# Open Source Image Duplicator (OSID)

OSID provides a GUI to assist in cloning multiple MicroSD cards from one .img file.

A Raspberry Pi connects to a powered USB 3.0 HUB.

This fork of OSID is designed for an 8GB Raspberry Pi 4 running Raspberry Pi OS.


## Required Hardware
- 8GB Raspberry Pi 4
- 64GB MicroSD Card
- Powered USB 3.0 hub (10 ports)
- MicroSD card USB 3.0 readers (10 total)

## Installation 
OSID can run on the Raspberry Pi OS Desktop or it can be run headless from another server on a home LAN.

These directions assume a Raspberry Pi is properly setup and running Raspberry Pi OS and the goal is to run the MicroSD Card duplicator as a networked device on a home LAN.

install.sh installs all the required software, makes any needed directories and sets any needed permissions. 

* Step 1. Open a terminal window
* Step 2. From the terminal window, ssh into a Raspberry Pi 4 running Raspberry PI OS. 
* Step 3. Download and run the OSID install script

```
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/install.sh
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/install.cfg
sudo bash install.sh
```
* Step 4. Open a browser and enter the URL suggested by install.sh


## Configuration Files
### install.cfg
* install.sh is a generic bash installation script. install.cfg tells the script what to install and how to install it.

### server.ini
* ImagePath is the directory holding the .img files that can be used.
* Host is the hostname used for the webpage.
* SocketPort is the port you want to use to dish out the API links.
* Logs is the directory to hold all of your logs.
* SkeletonLocation is where you can find the Skeleton CSS Framework.
	* A Skeleton CSS file is included in www.
	* You can also pull a fresh copy of the [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) and define the location.

### run_app.sh
* run_app.sh executes from the system folder, so define it correctly
* Desktop Setup:
	* run_app.sh opens a chromium-browser and navigates to the hostname and port
	* Define the url a browser will use to connect to the main page

* Headless Setup
	* OSID can run headless on a networked Raspberry
	* Comment out the chromuim line in run_app.sh
	* Set Raspbery Pi IP on server.ini using ??? Host = ???

### osid.desktop
* The path for the run_app.sh script should be correct.
* if you use OSID on headless RPi, this file is useless.

## Usage
### Accepted image file
OSID will accept any image file ending with .img name. Other extensions will silently be ignored.

### Auto discovery of available readers
When refreshing the OSID web page (or accessing it), OSID will scan available readers, and after some seconds, will show them on the menu. A sum of all readers is also shown.




## Original Authors
* [aaronnguyen/OSID](https://github.com/aaronnguyen/osid-python3) - python3 version of Base Project
* [rockandscissor/OSID](https://github.com/rockandscissor/osid) - Base Project originally written in PHP and Bash


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


## Versioning
[SemVer](http://semver.org/) is used for version numbers. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).


## License
This project is licensed under the GNU GPLv3 - see the [LICENSE.md](LICENSE.md) file for details
