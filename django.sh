#!/bin/bash
# sript to setup django
#
# run using
#    sudo bash [bash_options] django.sh [install_options]

############################# <- 80 Characters -> ##############################
#
# This style of commenting is called a garden bed and it is frowned upon by
# those who know better. But, I like it. I use a garden bed at the top to track
# my to do list as I work on the code, and then mark the completed To Dos.
#
# Within the code, To Dos include a comment with ???, which makes it easy to
# find
#
# Once the To Do list is more-or-less complete, I move the completed items into
# comments, docstrings or help within the code. Next, I remove the completed
# items.
#
# To Do List:
#   a) ???n
#   b) check if install.sh has been run, if not error messgae and exit
#   c) need to edit
#	nano Test_Project/Test_Project/urls.py
#	nano Test_Project/Test_Project/settings.py
#   d) need to add urls.py to each app
#   e) sudo python3 manage.py runserver newt:80
#   f) after django is setup, edit non-Django files
#      f.1) sudo nano /etc/apache2/apache2.conf
#      f.2) sudo nano /etc/apache2/sites-enabled/000-default.conf
#   g) edit django files
#      g.1) nano /home/pi/newt_site/newt_site/settings.py
#      g.2) nano /home/pi/newt_site/urls.py ??? or is it newt_site/newt_site ???
#   h) find PID using port and kill process ???
#   i) create django files:
#      i.1) app.urls
#
#   y) add install.sh and install.cfg to github duplicator
#   z) add install.sh and install.cfg to github template
#
############################# <- 80 Characters -> ##############################


################################## Functions ###################################
function echoStartingScript {
        if [ "$StartMessageCount" -eq 0 ]
        then
                echo -e "\n${Bold}Starting Django Script${Normal}"
                echo "  ${Bold}setting up $Name${Normal}"
                StartMessageCount=1
        fi
}


function echoExitingScript {
        echo -e "\n${Bold}Exiting Django Script${Normal}"
	exit
}


function help {
        echo "$Help"
}


function createDjangoProject {
	#if $DjangoProject exists delete it
	cd "$BaseDirectory"
	if [ -d "$DjangoProject" ]
	then
	        echo -e "\n  ${Bold}Directory $DjangoProject exists, removing ${Normal}"
        	sudo rm -r "$DjangoProject"
	fi

        if [ -d "$DjangoProject" ]
        then
                echo -e "\n  ${Bold}ERROR: Unable to remove $DjangoProject ${Normal}"
                echo -e "\n  ${Bold}try sudo rm -r $DjangoProject ${Normal}"
	        echoExitingScript
	fi

	django-admin startproject "$DjangoProject"
	cd "$BaseDirectory/$DjangoProject"
	tree
}


function createDjangoApps {
	dir="$BaseDirectory/$DjangoProject"
        if [ -d "$dir" ]
        then
                cd "$dir"
	else
		echo -e "\n  ${Bold}ERROR: Required directory $dir does not exist ${Normal}"
                echoExitingScript
        fi

        # if there apps to install
        if [[ ${DjangoApps[*]} ]]
        then
                echo -e "\n  ${Bold}creating django apps${Normal}"
                # loop through all apps
                for a in "${DjangoApps[@]}"
                do
                	echo "    ${Bold}creating app: $a${Normal}"
			# there are two ways to create a Django app
			#    django-admin startapp <app>
			#    python3 manage.py startapp <app>
			# manage.py is automatically created in a Django project. manage.py
			# does the same thing as django-admin. Unlike django-admin, manage.py
			# also sets DJANGO_SETTINGS_MODULE environment variable so it points
			# to the project’s settings.py file.
			python3 manage.py startapp "$a"
                done
        else
                echo -e "\n   ${Bold}no Django apps in cfg file${Normal}"
        fi

}


function migrateDjango {
        cd "$BaseDirectory"
        if [ -d "$DjangoProject" ]
        then
                echo -e "\n  ${Bold}migrating Django data ${Normal}"
                cd "$DjangoProject"
		python3 manage.py migrate
        else
                echo -e "\n  ${Bold}ERROR: Required project directory $DjangoProject does not exist ${Normal}"
                echoExitingScript
         fi
}

function makePath {
        if [ ! -d "$1" ]
        then
                if [ "$1" != "" ]
                then
                        echo "    ${Bold}making path: $1${Normal}"
                        # -p makes all parent directories if necessary
                        mkdir -p "$1"
                fi
        fi
}


function installApt {
        # if there packages to install
        if [[ ${DebianPackages[*]} ]]
        then
                echo -e "\n  ${Bold}installing debian packages${Normal}"
                # loop through all the packages
                for p in "${DebianPackages[@]}"
                do
                        # if the package is not already installed
                        notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
                        if [ "" = "$notInstalled" ]
                        then
                                echo "    ${Bold}installing package: $p${Normal}"
                                sudo apt install "$p" -y
                        fi
                done
        else
                echo -e "\n   ${Bold}no raspbian packages in cfg file${Normal}"
        fi
}

function installPip3 {
        # if there packages to install
        if [[ ${Pip3Packages[*]} ]]
        then
                echo -e "\n  ${Bold}installing pip3 packages${Normal}"
                # loop through all the packages
                for p in "${Pip3Packages[@]}"
                do
                        # if the package is not already installed
                        notInstalled=$(pip3 list | grep "$p")
                        if [ "$notInstalled" = "" ]; then
                                echo "    ${Bold}installing pip3: $p${Normal}"
                                yes | sudo pip3 install "$p"
                        fi
                done
        else
                echo -e "\n  ${Bold}no pip3 packages in cfg file${Normal}"
        fi
}


function reloadServices {
        # if there are services to reload
        if [[ ${ReloadServices[@]} ]]
        then
                echo -e "\n  ${Bold}reloading services${Normal}"
                # loop through all the packages
                for p in "${ReloadServices[@]}"
                do
                        echo "    ${Bold}$p${Normal}"
                        sudo systemctl reload "$p"
                done
        else
                echo -e "\n  ${Bold}no services to reload in cfg file${Normal}"
        fi
}


function restartServices {
        # if there are services to reload
        if [[ ${RestartServices[@]} ]]
        then
                echo -e "\n  ${Bold}restarting services${Normal}"
                # loop through all the packages
                for p in "${RestartServices[@]}"
                do
                        echo "    ${Bold}$p${Normal}"
                        sudo systemctl restart "$p"
                done
        else
                echo -e "\n  ${Bold}no services to restart in cfg file${Normal}"
        fi
}

# GitFile is defined in install.cfg
# I treat gits like apts, egt lastest and overwrite current
function gitFiles {
        # if there are files to git
        if [[ ${GitFiles[@]} ]]
        then
                echo -e "\n  ${Bold}gitting files${Normal}"
                # loop through all the files
                for git in "${GitFiles[@]}"
                do
                        # get filename
                        # return string after last slash
                        filename=${git##*/}
                        # if file exists, then need to remove it before wget
                        if [ -f "$filename" ]
                        then
                                echo "    ${Bold}removing file: $filename${Normal}"
                                rm "$filename"
                        fi
                        echo "    ${Bold}gitting file: $filename${Normal}"
                        wget "$git"
                done
        fi
}

# git clone from github
# the directory is extracted from the repository
function gitClone {
	if [ $GitClone == ""]
	then
		echo -e "\n  ${Bold}no clones to git${Normal}"
	else
	        echo -e "\n  ${Bold}gitting clone: $GitClone${Normal}"
	        repository=$GitClone
	        # remove ".git"
	        repository=${repository::-4}
	        # return string after last slash
	        directory=${repository##*/}
	        if [ -d "$directory" ]
	        then
	                echo "    ${Bold}removing directory: $directory${Normal}"
	                rm -rf "$directory"
	        fi
	        echo -e "\n  ${Bold}gitting clone: $GitClone${Normal}"
	        git clone "$GitClone"
	fi
}

# Bash doesn't have multidimensional tables. So, this is my hack to pretend it does
# Each enttry is a row in a table and includes: "filename;fromPath;toPath"
# So, this function moves each row using mv fomPath/filename toPath/."
function moveFiles {
        # if there are files to move
        if [[ ${MoveFiles[*]} ]]
        then
                echo -e "\n  ${Bold}moving files${Normal}"
                # loop through all the packages
                for f in "${MoveFiles[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # create path where file will be moved
                        makePath "${file[2]}"

                        # if the file exists in the fromPath
                        if [ -f "${file[1]}/${file[0]}" ]
                        then
                                # move file fromPath to toPath
                                echo "    ${Bold}mv ${file[1]}/${file[0]} ${file[2]}/. ${Normal}"
                                sudo mv "${file[1]}/${file[0]}" "${file[2]}/."
                        fi
                done
        fi
}

# The script does not runs as sudo. So, This function changes ownership to the correct
# settings based on the config file. Each enttry is a row in a table and includes:
#     "path or path/filename;ownership"
function changeOwnership {
        # if there are files to move
        if [[ ${ChangeOwnership[*]} ]]
        then
                echo -e "\n  ${Bold}changing ownership${Normal}"
                # loop through all the entries
                for f in "${ChangeOwnership[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}chown ${file[0]} to ${file[1]} ${Normal}"
                                chown "${file[1]}" "${file[0]}"
                        elif [ -d "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}chown rexcursively on ${file[0]} to ${file[1]} ${Normal}"
                                chown -R "${file[1]}" "${file[0]}"
                        fi
                done
        fi
}

# The script does not run as sudo.
# This function changes permissions to be correct.
# Each enttry is a row in a table and includes: "path/filename;permissions"
function changePermissions {
        # if there are files to move
        if [[ ${ChangePermissions[*]} ]]
        then
                echo -e "\n  ${Bold}changing permissions${Normal}"
                # loop through all the entries
                for f in "${ChangePermissions[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}chmod ${file[0]} to ${file[1]} ${Normal}"
                                chmod "${file[1]}" "${file[0]}"
                        fi
                done
        fi
}

# Remove files and directories that are not needed
function cleanUp {
        # if there are files to move
        if [[ ${CleanUp[*]} ]]
        then
                echo -e "\n  ${Bold}removing files and directories that are not needed${Normal}"
                # loop through all the entries
                for f in "${CleanUp[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # remove file
                                echo "    ${Bold}remove ${file[0]} ${Normal}"
                                rm "${file[0]}"
                        elif [ -d "${file[0]}" ]
                        then
                                #remove directory
                                echo "    ${Bold}remove rexcursively ${file[0]} ${Normal}"
                                rm -R "${file[0]}"
                        fi
                done
        fi
}


############################### Global Variables ###############################
Bold=$(tput bold)
Normal=$(tput sgr0)
StartMessageCount=0

# I try not to cd in the script. If I do, then it might be good to have the base
# directory
BaseDirectory="$PWD"
Clear=true
Update=false
RebootOn=false
USER=pi
HOME=$(bash -c "cd ~$(printf %q $USER) && pwd")

# Import configuration file for this script
# The config file contains all the apps to install, all the modules to pip3,
# all the files to get, the final path for each, and any permissions required.
# It is basically just a collection of global variables telling the script what
# to do.
if [ -f django.cfg ]
then
        . django.cfg
else
        echoStartingScript
        echo -e "\n  ERROR: The Django setup script requires $BaseDirectory/django.cfg"
        echo -e "\n    Please wget django.cfg from github or create one."
        echoExitingScript
fi


########################### Start of Install Script  ###########################
echoStartingScript

# pip3_install fails if errexit is enabled, not sure why
# exit on error
# set -o errexit

# exit if variable is used but not set
set -u
# set -o nounset


# Process command line options
# All options must be listed in order following the : between the quotes on the
# following line:
while getopts ":chru" option
do
        case $option in
                c) # disable clear after update and upgrade
                        Clear=false
                        ;;
                h) # display Help
                        help
                        exit;;
                r) # disable reboot
                        RebootOn=false
                        ;;
                u) # skip update and upgrade steps
                        Update=false
                        ;;
                *) # handle invalid options
                        echoStartingScript
                        echo
                        echo "  ${Bold}ERROR: Invalid option${Normal}"
                        echo
                        echo "  ${Bold}To see valid options, run using:${Normal}"
                        echo
                        echo "    \$ sudo bash ${0##*/} -h"
		        echoExitingScript
        esac
done

# Exit if not running as sudo or root
if [ "$EUID" -eq 0 ]
then
        echo -e "\n  ${Bold}ERROR: Must NOT run as root or sudo${Normal}"
        echo -e "\n  ${Bold}To see valid options, run using:${Normal}"
        echo -e "\n    \$ bash ${0##*/}"
        echoExitingScript
fi

# check if minimum Django version is installed
installedVersion="$(python3 -m django --version)"
if [ "$(printf '%s\n' "$MinimumDjangoVersion" "$installedVersion" | sort -V | head -n1)" = "$MinimumDjangoVersion" ]
then
        echo -e "\n  ${Bold}Django version = $installedVersion${Normal}"
elif [ "$installedVersion" = "" ]
then
        echo -e "\n  ${Bold}ERROR: minimum Django version is $MinimumDjangoVersion${Normal}"
        echo "  ${Bold}Django does not seem to be installed${Normal}"
        echoExitingScript
else
        echo -e "\n  ${Bold}ERROR: minimum Django version is $MinimumDjangoVersion${Normal}"
        echo "  ${Bold}Django installed version = $installedVersion${Normal}"
        echoExitingScript
fi

# update and uphrade packages
if [ "$Update" = true ]
then
        echo "  ${Bold}updating${Normal}"
        sudo apt update -y
        echo -e "\n  ${Bold}upgrading${Normal}"
        sudo apt upgrade -y
        echo -e "\n  ${Bold}removing trash${Normal}"
        sudo apt autoremove -y

        # the above generates a lot of things that may not be relevant to the install of
        # this application. So, clear the screen and then put Starting message here.
        if [ "$Clear" = true ]
        then
                clear
                StartMessageCount=0
        fi
fi

# create Django project
# there is only one Django project, which can have multiple apps
createDjangoProject

# create Django apps
createDjangoApps

# propagate changes via migration
migrateDjango

# install required packages, which are defined in DebainPackages list in install.cfg
installApt

# install required python packages, which are defined in PipPackages list in install.cfg
installPip3

# get the all the files from github and create a directory
gitClone

# must check and rm file if it exists before getting a new version
gitFiles

# move files from downloaded path to final path and set permisssions
moveFiles

# change ownership
changeOwnership

# change permissions
changePermissions

# remove files and directories that are not needed
cleanUp

# reload and restart services
reloadServices

restartServices

# print exit message
echo -e "$ExitMessage"

if $RebootOn
then
        if $Reboot
        then
                echoExitingScript reboot
                echo -e "\n${Bold}Rebooting Raspberry Pi in 10s (<CTRL>-C to stop)${Normal}"
                sleep 10s
                sudo reboot
        fi
fi

echoExitingScript
exit

