#!/bin/bash
# sript to install Open Source Image Duplicator (OSID)
#
# run using
#    sudo bash install.sh

############################# <- 80 Characters -> ##############################
#
# This style of commenting is called a garden bed and it is frowned upon by
# those who know better. But, I like it. I use a garden bed at the top to track
# my to do list as I work on the code, and then mark the completed To Dos.
#
# Within the code, To Dos include a comment with ???, which makes it easy for
# me to find
#
# Once the To Do list is more-or-less complete, I move the completed items into
# comments, docstrings or help within the code. Next, I remove the completed
# items.
#
# To Do List:
#   a) remove sample files and replace with actuals
#      a.1) remove requirements.txt
#   b) change permissions on images, system and www
#      b.1) permissions are included with .cfg
#      b.2) chown www-data:www-data /etc/osid/imgroot -R
#   c) make this into a generic install script with everything to .cfg file
#      c.1) filename, permssions and final directory on RPi are included with .cfg
#      c.2) part of getting a file is checking and making the directories
#      c.3) chown www-data:www-data /etc/osid/imgroot -R
#      c.4) put website files in /var/www/
#      c.5) .cfg contains lists and hashed arrays (.e.g, filenames to get, hash w/ directory, hash w/ permissions)
#      c.7) move all comments about osid into the the cfg
#      c.8) change from install_osid.sh to install.sh
#      c.9) add install directory ???
#   d) options
#      d.1) add name option to replace pi as default username
#      d.2) add optionm to change username from default pi
#   e) add logger - not for syslog, but levels debug and info
#   f) naming conventions
#      f.1) lowercase or camelCase for local variable and function names
#      f.2) first uppercase or CamelCase for global variables
#      f.3) all uppercase for ENV variables
#   g) suppress all output option > 1&2 or whatever or it is a blank string
#   h) home directory for app
#      h.1) default is /home/pi
#      h.2) change home directory
#   i) move files to final destination
#      i.1) I think this is needed because some files arer etrieved to git clone directory
#      i.2) perhaps make a tmp or install directory where files are retrieved and thn move to final destination
#
#   x) run through https://www.shellcheck.net/, which is a lint usitlty for bash
#   y) add install.sh and install.cfg to github duplicator
#   z) add install.sh and install.cfg to github template
#
# Do later or not at all:
#
# Won't Do:
#   - I should use lower case for variables and upper case for constants but
#     I run into issues on collisions between lowercase keywords and variables
#
# Completed:
#
############################# <- 80 Characters -> ##############################

Bold=$(tput bold)
Normal=$(tput sgr0)
StartMessageCount=0

# Import configuration file for this script
# the config file contains all the apps to install, all the modules to pip3, all
# the files to get, the final path for each, and any permissions required.
if [ -f install.cfg]
then
	. install.cfg
else
        echo "${Bold}Starting Installation Script${Normal}"
	echo "  FATAL ERROR: Installation script requires an install.cfg file"
        echo "    Please wget install.cfg from github or create one."
        echo "${Bold}Exiting Installation script${Normal}"
        exit
fi

function help {
	echo "$Help"
}

function make_dir {
        if [ ! -d "$1" ]
        then
                echo "  ${Bold}creating directory: $1${Normal}"
                mkdir "$1"
        fi
}

function apt_install {
	# if there packages to install
	if [[ ${DebianPackages[@]} ]]
	then
                echo
		echo "  ${Bold}installing debian packages${Normal}"
		# loop through all the packages
		for p in ${DebianPackages[@]}
		do
			# if the package is not already installed
		        notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
		        if [ "" = "$notInstalled" ]; then
	        	        echo "    ${Bold}installing package: $p${Normal}"
	                	sudo apt install "$p" -y
				# ??? is there a way to silence this shit as an option > /dev/null
		        fi
		done
	else
		echo
		echo "  ${Bold}no raspbian packages in cfg file${Normal}"
	fi
}

function pip3_install {
        # if there packages to install
        if [[ ${Pip3Packages[@]} ]]
        then
                echo
                echo "  ${Bold}installing pip3 packages${Normal}"
                # loop through all the packages
                for p in ${Pip3Packages[@]}
                do
                        # if the package is not already installed
			notInstalled=$(pip3 list | grep "$p")
		        if [ "$notInstalled" = "" ]; then
        		        echo "    ${Bold}installing pip3: $p${Normal}"
				yes | sudo pip3 install "$p"
                                # ??? is there a way to silence this shit as an option > /dev/null
				# yes | pip install somepackage --quiet
		        fi
                done
        else
                echo
                echo "  ${Bold}no pip3 packages in cfg fileg${Normal}"
        fi
}


function reload_services {
        # if there are services to reload
        if [[ ${ReloadServices[@]} ]]
        then
                echo
                echo "  ${Bold}reloading services${Normal}"
                # loop through all the packages
                for p in ${ReloadServices[@]}
                do
			"$p" reload
                done
        else
                echo
                echo "  ${Bold}no services to reload in cfg fileg${Normal}"
        fi
}


function restart_services {
        # if there are services to reload
        if [[ ${RestartServices[@]} ]]
        then
                echo
                echo "  ${Bold}restarting services${Normal}"
                # loop through all the packages
                for p in ${RestartServices[@]}
                do
                        "$p" restart
                done
        else
                echo
                echo "  ${Bold}no services to restart in cfg fileg${Normal}"
        fi
}


# git files from github $1 = github path, $2 = filename
function git_file {
	if [ -f "$2" ]
	then
                echo "  ${Bold}removing file: $2${Normal}"
		rm "$2"
	fi
	echo "  ${Bold}getting file: $2${Normal}"
	wget "$1/$2"
}

# git files from github $1 = repository
# the directory is extracted from the repository
function git_clone {
	REPO="$1"
	# remove ".git"
	REPO=${REPO::-4}
	# return string after last slash
	DIR=${REPO##*/}
        if [ ! -d "$DIR" ]
        then
		rm -rf "$DIR"
                echo "  ${Bold}gitting clone: $1${Normal}"
                git clone "$1"
        fi
}

# echo "exit before executing don't want o accidentally over write work"
# exit

CLEAR=true
UPDATE=true
# Process ocommand line ptions
while getopts ":chu" option; do
	case $option in
		c) # disable clear after update and upgrade
                        CLEAR=false
                        ;;
		h) # display Help
			help
			exit;;
                u) # skip update and upgrade steps
                        UPDATE=false
                        ;;
		*) # handle invalid options
			echo "Invalid option: $option"
			exit;;
	esac
done


# Exit if not running as sudo or root
if [ "$EUID" -ne 0 ]
then
	echo "${Bold}Installation script for $Name${Normal}"
	echo "Please run using: sudo bash ${0##*/}"
	exit
fi

# pip3_install fails if errexit is enabled, not sure why
# exit on error
# set -o errexit

# exit if variable is used but not set
set -o nounset

# update and uphrade packages
if [ "$UPDATE" = true ]
then
	echo "${Bold}Installation script for $Name${Normal}"
        StartMessageCount+=1
	echo "  ${Bold}updating${Normal}"
	sudo apt update -y
	echo " "
	echo "  ${Bold}upgrading${Normal}"
	sudo apt upgrade -y
	echo " "
	echo "  ${Bold}removing trash${Normal}"
	sudo apt autoremove -y

	# the above generates a lot of things that may not be relevant to the install of
	# this application. So, clear the screen and then put Starting message here.
	if [ "$CLEAR" = true ]
	then
		clear
		StartMessageCount=0
	fi
fi

if [ $StartMessageCount = 0 ]
then
	echo "${Bold}Installation script for $Name${Normal}"
	StartMessageCount+=1
fi

# install required packages, which are defined in DebainPackages list in install.cfg
apt_install

# install required python packages, which are defined in PipPackages list in install.cfg
pip3_install

# get the all the files from github and create directory osid-python3
git_clone https://github.com/dumbo25/osid-python3.git

# must check and rm file if it exists before getting a new version
git_file https://raw.githubusercontent.com/dumbo25/python-template/main mylog.py

# create required directories
echo "  ${Bold}creating required directories"${Normal}
USER=pi
HOME=$(bash -c "cd ~$(printf %q $USER) && pwd")
echo "HOME = $HOME"

make_dir /home/pi/osid
make_dir /home/pi/osid/log
make_dir /home/pi/osid/images
make_dir /home/pi/osid/system
# ??? need to use /var/www instead of /home/pi/osid/www or /var/www/osid
make_dir /home/pi/osid/www

# get a small .img; RPi Lite ?

# ??? need to move files to correct directory

# follow directions in https://github.com/aaronnguyen/osid-python3/blob/master/README.md
# how does website startl add to help and as an echo when exiting script ???
# might need to get images from original; repo ???
#   https://github.com/rockandscissor/osid/tree/master/www/public_html/images

# ??? move or copy ALL files from git osid to correct final location
# ??? eliminate sample files from git hub and replace with final versions
echo "  ${Bold}moving files to final directory${Normal}"
cd ~/osid/system || (echo "Invalid directory" && exit)

cp server.ini.sample server.ini
cp run_app.sh.sample run_app.sh
cp osid.desktop.sample ~/Desktop/osid.desktop

echo "  ${Bold}setting ownership and access on files and directories${Normal}"

# reload and restart services
reload_services
restart_services

# reboot if required, but first print message on how to connect to duplicator and wait 10s
echo
echo "  ${Bold}to access website, open a browser and enter ???${Normal}"
if $Reboot
then
	echo
	echo "${Bold}Exiting install script${Normal}"
	echo "${Bold}Rebooting Raspberry Pi in 10s (<CTRL>-C to stop)${Normal}"
	sleep 10s
	sudo reboot
fi

echo
echo "Exiting install script"
exit
