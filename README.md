# Open Source Image Duplicator (OSID)

OSID provides a GUI to assist in cloning multiple MicroSD cards from one .img file.

A Raspberry Pi connects to a 7 port powered USB HUB.

This fork of OSID is designed for an 8GB Raspberry Pi 4 running Raspberry Pi OS.


## Required Hardware

- 8GB Raspberry Pi 4
- 64GB MicroSD Card
- Powered USB 3.0 hub (7 ports)
- MicroSD card USB 3.0 readers (8 total)

## Planned Changes

- remove sample files, simplifies things
- add conf files
- simple directions

## Installation and Deployment

OSID can run on the Raspberry Pi OS Desktop or it can be run headless from another server on a home LAN.

If Raspberry Pi OS is properly setup and configured then install_osid.sh installs all the required software and makes any needed directories. And it downloads the code from this repository.

### Install Script

Open a terminal window and ssh into a Raspberry Pi 4 running Raspberry PI OS. 

Download and run the OSID install script

```
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/install_osid.sh
bash install_osid.sh
```

### Configuration Files
#### server.ini

* ImagePath is the directory holding the .img files that can be used.
* Host is the hostname used for the webpage.
* SocketPort is the port you want to use to dish out the API links.
* Logs is the directory to hold all of your logs.
* SkeletonLocation is where you can find the Skeleton CSS Framework.
	* A Skeleton CSS file is included in www.
	* You can also pull a fresh copy of the [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) and define the location.

#### run_app.sh

* run_app.sh executes from the system folder, so define it correctly
* Desktop Setup:
	* run_app.sh opens a chromium-browser and navigates to the hostname and port
	* Define the url a browser will use to connect to the main page

* Headless Setup
	* OSID can run headless on a networked Raspberry
	* Comment out the chromuim line in run_app.sh
	* Set Raspbery Pi IP on server.ini using ??? Host = ???

#### osid.desktop

* The path for the run_app.sh script should be correct.
* if you use OSID on headless RPi, this file is useless.

### Accepted image file
OSID will accept any image file ending with .img name. Other extensions will silently be ignored.

### Auto discovery of available readers
When refreshing the OSID web page (or accessing it), OSID will scan available readers, and after some seconds, will show them on the menu. A sum of all readers is also shown.

## Built With

* [aaronnguyen/OSID] (https://github.com/aaronnguyen/osid-python3) - python3 version of Base Project
* [nettings/tarot] (https://github.com/nettings/tarot) - very cool improvements, changed from python to php and js
* [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) - CSS framework used to structure Web UI
* [CherryPy](http://docs.cherrypy.org/en/latest/) - API Library for Python used to manage all actions
* [rockandscissor/OSID](https://github.com/rockandscissor/osid) - Base Project originally written in PHP and Bash

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Aaron Nguyen** - [aaronnguyen](https://github.com/aaronnguyen)

## License

This project is licensed under the GNU GPLv3 - see the [LICENSE.md](LICENSE.md) file for details
