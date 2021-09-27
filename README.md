# Open Source Image Duplicator - Python3

OSID provides a GUI to assist in cloning multiple MicroSD cards from one .img file.

A Raspberry Pi connects to a 7 port powered USB HUB.

This fork of OSID is designed for an 8GB Raspberry Pi 4 Raspberry Pi OS.

## Planned Changes for this fork 

Remove when complete or deemed not required:
- Migrate from Raspberry Pi 2 to Raspberry Pi 4
- Eliminate need for a Raspberry Pi Touch Display
- Create install.sh to download files from github repository (for people who just want to use code as is)
- migrate from raspbian to Raspberry Pi OS
- if possible use one USB on RPi as source and 7 USBs on HUB as destination (I don't want the image on the RPi)


## Required Hardware

- Raspberry Pi 4
- 64GB MicroSD Card
- Powered USB 3.0 hub (7 ports)
- MicroSD card USB 3.0 readers (8 total)


## Installation and Deployment

OSID can run on the Raspberry Pi OS Desktop or it can be run headless from another server on a home LAN.

If Raspberry Pi OS is properly setup and configured then install.sh installs all the required software and makes any needed directories. And it downloads the code from this repository.

### Install Script

Open a terminal window and ssh into a Raspberry Pi 4 running Raspberry PI OS. 

Download and run the OSID install script

```
wget https://raw.githubusercontent.com/dumbo25/osid-python3/master/install.sh
bash install.sh
```

### Supplemental Explanation

This section explains the script and what needs to be done. The changes can also be made manually.

#### server.ini

* ImagePath is the directory holding the .img files that can be used.
* Host is the hostname used for the webpage.
* SocketPort is the port you want to use to dish out the API links.
* Logs is the directory to hold all of your logs.
* SkeletonLocation is where you can find the Skeleton CSS Framework.
	* A Skeleton CSS file is included in www.
	* You can also pull a fresh copy of the [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) and define the location.

#### run_app.sh

* Run app will cd into the system folder, so define the installation path.
* It will then open up chromium-browser and navigate to the hostname and port.
	* So define the url that the browser will use to connect to the main page.

* Alternatively, you can decide to run OSID headless on a networked Raspberry. You can safely uncomment the chromuim line in run_app.sh. Don't forget to set local Raspbery Pi IP on server.ini

#### osid.desktop
* Just make sure the path for the run_app.sh script is defined properly.
* if you use OSID on headless Raspberry, this file is useless.

### Accepted image file
OSID will accept any image file ending with .img name. Other will silently be ignored.

### Auto discovery of available readers
When refreshing web page (or accessing it), OSID will scan available readers, and after some seconds, will show them on the menu. A sum of all readers is also shown.

## Built With

* [Skeleton-Framework](https://github.com/skeleton-framework/skeleton-framework) - CSS framework used to structure Web UI
* [CherryPy](http://docs.cherrypy.org/en/latest/) - API Library for Python used to manage all actions
* [rockandscissor/OSID](https://github.com/rockandscissor/osid) - Base Project originally written in PHP and Bash

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Aaron Nguyen** - [aaronnguyen](https://github.com/aaronnguyen)

## License

This project is licensed under the GNU GPLv3 - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks [PurpleBooth](https://gist.github.com/PurpleBooth) for the [Readme Template](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
