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
# ??? **************************** STOPPED HERE ******************** ???
#   b) check if install.sh has been run, if not error message and exit
#   c) need to add urls.py to each app
#   d) edit.create django files
#      d.1) nano /home/pi/newt_site/urls.py or is it newt_site/newt_site
#      d.2) app.urls
#   e) find PID using port and kill process
#   f) security checklist
#   g) use django checklist
#   h) create options for django setup script
#      h.1) w/ or w/o virtual env
#   i) exit on check of python and pip if version is not correct
#   j) update help
#   k) add superuser, email and password to create user in .cfg
#   l) create some sample apps
#      l.1) get beyond rocket ship django demo page
#   m) fix issues in logs
#      m.1) cat /var/log/apache2/access.log
#      m.2) cat /var/log/apache2/error.log
#      m.3) cat /var/log/syslog
#      m.4)  No WSGI daemon process called 'TestProject' has been configured: /home/pi/TestProject/p_TestProject/wsgi.py
#   n) make work with remote raspberry pi name rather than its IP Address
#   o) check against this website: https://pimylifeup.com/raspberry-pi-django/
#   p) move $BaseDirectory from /home/pi to /var/www
#   q) use systemd to start webserver
#
#   y) add django.sh and django.cfg to github duplicator
#   z) add install.sh and install.cfg to github template
#
# References:
#    deploy to production and security checklist
#    https://github.com/django/django/tree/main/docs/howto/deployment
#    https://mikesmithers.wordpress.com/2017/02/21/configuring-django-with-apache-on-a-raspberry-pi/
#
############################# <- 80 Characters -> ##############################


################################## Functions ###################################
function echoStartingScript {
        if [ "$StartMessageCount" -eq 0 ]
        then
                echo -e "\n${Bold}${Blue}Starting Django Setup Script ${Black}${Normal}"
                echo "  ${Bold}${Blue}setting up $Name ${Black}${Normal}"
                StartMessageCount=1
        fi
}


function echoExitingScript {
        echo -e "\n${Bold}${Blue}Exiting Django Setup Script ${Black}${Normal}"
	exit
}


function help {
        echo "$Help"
}


function createProjectDirectory {
	#if $DjangoProject exists delete it
	cd "$BaseDirectory"
	if [ -d "$DjangoProject" ]
	then
	        echo -e "\n  ${Bold}${Blue}Directory $DjangoProject exists, removing ${Black}${Normal}"
        	sudo rm -r "$DjangoProject"
	fi

	# make and move into django project directory
	echo -e "\n ${Bold}${Blue}make project directory: $DjangoProject ${Black}${Normal}"
	mkdir "$DjangoProject"

	echo -e "   ${Bold}${Blue}cd $BaseDirectory/$DjangoProject ${Black}${Normal}"
	cd "$BaseDirectory/$DjangoProject"
	pwd

}


function createVirtualEnv {
	# create virtualenv
	echo -e "\n ${Bold}${Blue}run virtualenv command and virtual env directory${Black}${Normal}"
	virtualenv "v_$DjangoProject"
	echo -e "\n   ${Bold}${Blue}ls v_$DjangoProject directory ${Black}${Normal}"
	pwd
	ls -l "v_$DjangoProject"

	#   activate venv
	echo -e "\n ${Bold}${Blue}activate virtual env ${Black}${Normal}"
	source "v_$DjangoProject/bin/activate"

	#   check if virtual env is running
	#     commented line from stackoverflow doesn't work
	#     INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')
	#     but this does:
	INVENV=$( python -c 'import sys ; print( 0 if sys.prefix == sys.base_prefix else 1 )' )
	if [[ "$INVENV" -eq 0 ]]
	then
	        echo "   ${Bold}${Red}ERROR: Virtual Environment is not running.  ${Black}${Normal}"
	        echoExitingScript
	else
	        echo -e "   ${Bold}${Blue}virtual env is active! ${Black}${Normal}"
	fi

	echo -e "   ${Bold}${Blue}check directory after activating virtual env${Black}${Normal}"
	pwd
	ls -l

	echo -e "\n   ${Bold}${Blue}check versions in virtual environment ${Black}${Normal}"
	echo "     ${Bold}${Blue}python should be version 3+ ${Black}${Normal}"
	python --version
	echo "     ${Bold}${Blue}pip should be 21+ and using python3+ ${Black}${Normal}"
	pip --version
}

function installDjango {
	# in virtual env so don't need to cd or activate it
	#   install django
	echo -e "\n ${Bold}${Blue} install django ${Black}${Normal}"
	pip install django

	# check if minimum Django version is installed
	installedVersion="$(python3 -m django --version)"
	if [ "$(printf '%s\n' "$MinimumDjangoVersion" "$installedVersion" | sort -V | head -n1)" = "$MinimumDjangoVersion" ]
	then
	        echo -e "\n   ${Bold}${Blue} Django version = $installedVersion ${Black}${Normal}"
	elif [ "$installedVersion" = "" ]
	then
	        echo -e "\n  ${Bold}${Red}ERROR: minimum Django version is $MinimumDjangoVersion ${Black}${Normal}"
	        echo "  ${Bold}${Red}Django does not seem to be installed ${Black}${Normal}"
	        echoExitingScript
	else
	        echo -e "\n  ${Bold}${Red}ERROR: minimum Django version is $MinimumDjangoVersion ${Black}${Normal}"
	        echo "  ${Bold}${Red}Django installed version = $installedVersion ${Black}${Normal}"
	        echoExitingScript
	fi

	# to fix the issue of django-admin.py begin deprecated in favor of django-admin
	rm "$BaseDirectory/$DjangoProject/v_$DjangoProject/bin/django-admin.py"
}

#   create django project
function createDjangoProject {
	cd "$BaseDirectory/$DjangoProject"

	# above removed django-admin.py, so use django-admin
	echo -e "\n   ${Bold}${Blue}django-admin startproject p_$DjangoProject ${Black}${Normal}"
	django-admin startproject "p_$DjangoProject" .
	pwd
	ls -l
}


function createDjangoApps {
	dir="$BaseDirectory/$DjangoProject"
        if [ -d "$dir" ]
        then
                cd "$dir"
	else
		echo -e "\n  ${Bold}${Red}ERROR: Required directory $dir does not exist ${Black}${Normal}"
                echoExitingScript
        fi

        # if there apps to install
        if [[ ${DjangoApps[*]} ]]
        then
                echo -e "\n  ${Bold}${Blue}creating django apps ${Black}${Normal}"
                # loop through all apps
                for a in "${DjangoApps[@]}"
                do
                	echo "    ${Bold}${Blue}creating app: $a ${Black}${Normal}"
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
                echo -e "\n   ${Bold}${Blue}no Django apps in cfg file ${Black}${Normal}"
        fi
}


function migrateDjango {
        cd "$BaseDirectory"
        if [ -d "$DjangoProject" ]
        then
                cd "$DjangoProject"
		echo -e "\n   ${Bold}${Blue} make the changes known to django ${Black}${Normal}"
		./manage.py makemigrations
		./manage.py migrate
        else
                echo -e "\n  ${Bold}${Red}ERROR: Required project directory $BaseDirectory/$DjangoProject does not exist ${Black}${Normal}"
                echoExitingScript
         fi
}

function isVirtualEnvActive {
	# check if virtual env is running
	#   commented line from stackoverflow doesn't work
	#   INVENV=$(python -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")')
	#   but this does:
	INVENV=$( python3 -c 'import sys ; print( 0 if sys.prefix == sys.base_prefix else 1 )' )
	if [[ "$INVENV" -eq 0 ]]
	then
		# last command executed is return value of function
		false
	else
        	true
	fi
}

function removePrevious {
	echo -e "\n  ${Bold}${Blue}remove old stuff ${Black}${Normal}"
	# exit virtual env
	if isVirtualEnvActive arg
	then
	        echo -e "    ${Bold}${Blue}exiting virtual environment ${Black}${Normal}"
	        deactivate
	fi

	cd $BaseDirectory

        if [ -d "$DjangoProject" ]
        then
	        if [ -d "v_$DjangoProject" ]
        	then
	                echo -e "    ${Bold}${Blue}remove virtual environment ${Black}${Normal}"
			rmvirtualenv "v_$DjangoProject"
		fi

                echo -e "    ${Bold}${Blue}remove project directory ${Black}${Normal}"
	        rm -rf "$DjangoProject"
	fi

	# restore default apache2 config file
        echo -e "    ${Bold}${Blue}restore default apache2 config file ${Black}${Normal}"
	sudo cp /etc/apache2/sites-enabled/000-default.conf.backup /etc/apache2/sites-enabled/000-default.conf

	# uninstall packages installed via Apt
	uninstallApt

	# uninstall pip3 packages and modules
	uninstallPip3

        echo -e "\n    ${Bold}${Blue}remove directories ${Black}${Normal}"
        if [ -d ".local" ]
        then
		rm -r .local
	fi

        if [ -d ".git" ]
        then
		rm -rf .git
	fi

        if [ -d ".gitconfig" ]
        then
		rm -rf .gitconfig
	fi

        echo -e "\n    ${Bold}${Blue}apt autoremove ${Black}${Normal}"
	sudo apt autoremove -y

        echo -e "\n    ${Bold}${Blue}remove sqlite3 database ${Black}${Normal}"
        if [ -d "db.sqlite3" ]
        then
	        rm db.sqlite3
	fi

	# it is unclear why virtualenv and virtualenvwrapper related files are not
        # removed. Removing them doesn't help
	# googling didn't turn up anything
        # echo -e "\n    ${Bold}${Blue}remove directories and files not removed above ${Black}${Normal}"
	# sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenv_clone-*
	# sudo rm -rf /usr/local/lib/python3.7/dist-packages/stevedore
	# sudo rm -rf /usr/local/lib/python3.7/dist-packages/importlib-metadata
        # sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenvwrapper
        # sudo rm -rf /usr/local/lib/python3.7/dist-packages/virtualenv
        # sudo rm -rf /usr/local/lib/python3.7/dist-packages/importlib-metadata
}

function makePath {
        if [ ! -d "$1" ]
        then
                if [ "$1" != "" ]
                then
                        echo "    ${Bold}${Blue}making path: $1 ${Black}${Normal}"
                        # -p makes all parent directories if necessary
                        mkdir -p "$1"
                fi
        fi
}


function uninstallApt {
        # if there packages to install
        if [[ ${DebianPackages[*]} ]]
        then
                echo -e "\n    ${Bold}${Blue}uninstalling debian packages ${Black}${Normal}"
                # loop through all the packages
                for p in "${DebianPackages[@]}"
                do
			if [ "$p" == "python3" ]
			then
                                echo "      ${Bold}${Blue}skipping: $p ${Black}${Normal}"
			else
	                        # if the package is not already installed
        	                notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
                	        if [ "$notInstalled" != "" ]
                        	then
                                	echo "      ${Bold}${Blue}uninstalling package: $p ${Black}${Normal}"
	                                sudo apt install "$p" -y
        	                fi
			fi
                done
        else
                echo -e "     ${Bold}${Blue}no raspbian packages in cfg file ${Black}${Normal}"
        fi
}

function installApt {
        # if there packages to install
        if [[ ${DebianPackages[*]} ]]
        then
                echo -e "\n  ${Bold}${Blue}installing debian packages ${Black}${Normal}"
                # loop through all the packages
                for p in "${DebianPackages[@]}"
                do
                        # if the package is not already installed
                        notInstalled=$(dpkg-query -W --showformat='${Status}\n' "$p" | grep "install ok installed")
                        if [ "" = "$notInstalled" ]
                        then
                                echo "    ${Bold}${Blue}installing package: $p ${Black}${Normal}"
                                sudo apt install "$p" -y
                        fi
                done

		echo -e "    ${Bold}${Blue}python version must be 3.7 or higher ${Black}${Normal}"
		python3 --version
		echo -e "    ${Bold}${Blue}pip3 version must be 18.1 or higher ${Black}${Normal}"
		pip3 --version
        else
                echo -e "\n   ${Bold}${Blue}no raspbian packages in cfg file ${Black}${Normal}"
        fi
}

function uninstallPip3 {
	# when re-installing some of the virtualenvwrapper requirements are already met
	# I am not sure how to fix. I tried removing with sudo and both pip and pip3
        # if there packages to install. it doesn't seem to cause any issues. So, I am
	# ignoring it
        if [[ ${Pip3Packages[*]} ]]
        then
                echo -e "\n    ${Bold}${Blue}uninstalling pip3 packages ${Black}${Normal}"
                # loop through all the packages
                for p in "${Pip3Packages[@]}"
                do
                        # if the package is not already installed
                        notInstalled=$(pip3 list | grep "$p")
                        if [ "$notInstalled" != "" ]; then
                                echo "      ${Bold}${Blue}uninstalling pip3: $p ${Black}${Normal}"
                                yes | sudo pip3 uninstall "$p"
                        fi
                done
        else
                echo -e "\n  ${Bold}${Blue}no pip3 packages in cfg file ${Black}${Normal}"
        fi
}

function installPip3 {
        # if there packages to install
        if [[ ${Pip3Packages[*]} ]]
        then
                echo -e "\n  ${Bold}${Blue}installing pip3 packages ${Black}${Normal}"
                # loop through all the packages
                for p in "${Pip3Packages[@]}"
                do
                        # if the package is not already installed
                        notInstalled=$(pip3 list | grep "$p")
                        if [ "$notInstalled" = "" ]; then
                                echo "    ${Bold}${Blue}installing pip3: $p ${Black}${Normal}"
                                yes | sudo pip3 install "$p"
                        fi
                done
        else
                echo -e "\n  ${Bold}${Blue}no pip3 packages in cfg file ${Black}${Normal}"
        fi
}


function reloadServices {
        # if there are services to reload
        if [[ ${ReloadServices[@]} ]]
        then
                echo -e "\n  ${Bold}${Blue}reloading services ${Black}${Normal}"
                # loop through all the packages
                for p in "${ReloadServices[@]}"
                do
                        echo "    ${Bold}${Blue}$p ${Black}${Normal}"
                        sudo systemctl reload "$p"
                done
        else
                echo -e "\n  ${Bold}${Blue}no services to reload in cfg file ${Black}${Normal}"
        fi
}


function restartServices {
        # if there are services to reload
        if [[ ${RestartServices[@]} ]]
        then
                echo -e "\n  ${Bold}${Blue}restarting services ${Black}${Normal}"
                # loop through all the packages
                for p in "${RestartServices[@]}"
                do
                        echo "    ${Bold}${Blue}$p ${Black}${Normal}"
                        sudo systemctl restart "$p"
                done
        else
                echo -e "\n  ${Bold}${Blue}no services to restart in cfg file ${Black}${Normal}"
        fi
}

function getSettings {
	# get settings.py
	cd "p_$DjangoProject"
	echo -e "\n   ${Bold}${Blue}should be $BaseDirectory/$DjangoProject/p_$DjangoProject ${Black}${Normal}"
	pwd

	# remove so we don't end up with a copy of wget file
	echo -e "\n ${Bold}${Blue}get settings.py ${Black}${Normal}"
	rm settings.py

	wget "https://raw.githubusercontent.com/dumbo25/newt/master/settings.py"
	echo -e "\n   ${Bold}${Blue}should be $BaseDirectory/$DjangoProject ${Black}${Normal}"

	# edit settings.py
	cd "$BaseDirectory/$DjangoProject"
	var="ALLOWED_HOSTS = ['$IP_ADDRESS']"
	sed -i "s/ALLOWED_HOSTS.*/$var/" "$BaseDirectory/$DjangoProject/p_$DjangoProject/settings.py"
}

function getApacheConf {
	# get 000-efault.conf
	echo -e "\n\n\n ${Bold}${Blue}apache2 was installed above, now set it up ${Black}${Normal}"
	echo -e "   ${Bold}${Blue} deactivate virtual env ${Black}${Normal}"
	deactivate

	echo -e "   ${Bold}${Blue} make a backup and then create apache2's 000-default.conf ${Black}${Normal}"
	cd /etc/apache2/sites-enabled
	sudo mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.backup
	# the file was moved above, so just write to the config file
	# I couldn't get the file written to the final directory using sudo in one command
	echo "$ApacheConfig" >| "$BaseDirectory/000-default.conf"
	sudo cp "$BaseDirectory/000-default.conf" /etc/apache2/sites-enabled/000-default.conf
}

# GitFile is defined in install.cfg
# I treat gits like apts, egt lastest and overwrite current
function gitFiles {
        # if there are files to git
        if [[ ${GitFiles[@]} ]]
        then
                echo -e "\n  ${Bold}${Blue}gitting files ${Black}${Normal}"
                # loop through all the files
                for git in "${GitFiles[@]}"
                do
                        # get filename
                        # return string after last slash
                        filename=${git##*/}
                        # if file exists, then need to remove it before wget
                        if [ -f "$filename" ]
                        then
                                echo "    ${Bold}${Blue}removing file: $filename ${Black}${Normal}"
                                rm "$filename"
                        fi
                        echo "    ${Bold}${Blue}gitting file: $filename ${Black}${Normal}"
                        wget "$git"
                done
        fi
}

# git clone from github
# the directory is extracted from the repository
function gitClone {
	if [ $GitClone == ""]
	then
		echo -e "\n  ${Bold}${Blue}no clones to git ${Black}${Normal}"
	else
	        echo -e "\n  ${Bold}${Blue}gitting clone: $GitClone ${Black}${Normal}"
	        repository=$GitClone
	        # remove ".git"
	        repository=${repository::-4}
	        # return string after last slash
	        directory=${repository##*/}
	        if [ -d "$directory" ]
	        then
	                echo "    ${Bold}${Blue}removing directory: $directory ${Black}${Normal}"
	                rm -rf "$directory"
	        fi
	        echo -e "\n  ${Bold}${Blue}gitting clone: $GitClone ${Black}${Normal}"
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
                echo -e "\n  ${Bold}${Blue}moving files ${Black}${Normal}"
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
                                echo "    ${Bold}${Blue}mv ${file[1]}/${file[0]} ${file[2]}/. ${Black}${Normal}"
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
                echo -e "\n  ${Bold}${Blue}changing ownership ${Black}${Normal}"
                # loop through all the entries
                for f in "${ChangeOwnership[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}${Blue}chown ${file[0]} to ${file[1]} ${Black}${Normal}"
                                chown "${file[1]}" "${file[0]}"
                        elif [ -d "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}${Blue}chown rexcursively on ${file[0]} to ${file[1]} ${Black}${Normal}"
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
                echo -e "\n  ${Bold}${Blue}changing permissions ${Black}${Normal}"
                # loop through all the entries
                for f in "${ChangePermissions[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # change ownership just on the file
                                echo "    ${Bold}${Blue}chmod ${file[0]} to ${file[1]} ${Black}${Normal}"
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
                echo -e "\n  ${Bold}${Blue}removing files and directories that are not needed ${Black}${Normal}"
                # loop through all the entries
                for f in "${CleanUp[@]}"
                do
                        IFS=';' read -ra file <<< "$f"
                        # if the entry is a file
                        if [ -f "${file[0]}" ]
                        then
                                # remove file
                                echo "    ${Bold}${Blue}remove ${file[0]} ${Black}${Normal}"
                                rm "${file[0]}"
                        elif [ -d "${file[0]}" ]
                        then
                                #remove directory
                                echo "    ${Bold}${Blue}remove rexcursively ${file[0]} ${Black}${Normal}"
                                rm -R "${file[0]}"
                        fi
                done
        fi
}


############################### Global Variables ###############################
# change colors and styles on terminal output
Bold=$(tput bold)
Normal=$(tput sgr0)
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Blue=$(tput setaf 4)
Black=$(tput sgr0)

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
        echo -e "\n  ${Red}ERROR: The Django setup script requires $BaseDirectory/django.cfg${Black}"
        echo -e "\n    ${Red}Please wget django.cfg from github or create one.${Black}"
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
                        echo -e "\n  ${Bold}${Red}ERROR: Invalid option ${Black}${Normal}"
                        echo -e "\n  ${Bold}${Blue}To see valid options, run using: ${Black}${Normal}"
                        echo -e "\n    \$ sudo bash ${0##*/} -h ${Black}"
		        echoExitingScript
        esac
done


# Exit if running as sudo or root
if [ "$EUID" -eq 0 ]
then
        echo -e "\n  ${Bold}${Red}ERROR: Must NOT run as root or sudo ${Black}${Normal}"
        echo -e "\n  ${Bold}${Red}To see valid options, run using: ${Black}${Normal}"
        echo -e "\n    ${Red}\$ bash ${0##*/} ${Black}"
        echoExitingScript
fi


# remove old stuff
#   the goal is to start in a known good state
removePrevious


# update and uphrade packages
if [ "$Update" = true ]
then
        echo "  ${Bold}${Blue}updating ${Black}${Normal}"
        sudo apt update -y
        echo -e "\n  ${Bold}${Blue}upgrading ${Black}${Normal}"
        sudo apt upgrade -y
        echo -e "\n  ${Bold}${Blue}removing trash ${Black}${Normal}"
        sudo apt autoremove -y

        # the above generates a lot of things that may not be relevant to the install of
        # this application. So, clear the screen and then put Starting message here.
        if [ "$Clear" = true ]
        then
                clear
                StartMessageCount=0
        fi
fi

# get IP Address of raspberry pi
IP_ADDRESS=$(hostname -I)
#   and trim trailing whitespace
IP_ADDRESS="${IP_ADDRESS%"${IP_ADDRESS##*[![:space:]]}"}"

# install required packages, which are defined in DebainPackages list in install.cfg
# install python3 and related tools
installApt

# install required python packages, which are defined in PipPackages list in install.cfg
installPip3

# create project sirectory
createProjectDirectory

createVirtualEnv

# create Django project
#   there is only one Django project, which can have multiple apps
installDjango

createDjangoProject

getSettings

# propagate changes via migration
migrateDjango

#     create useer
echo -e "\n   ${Bold}${Blue} answer questions to create superuser ${Black}${Normal}"
./manage.py createsuperuser

#     get static files
echo -e "\n   ${Bold}${Blue} get static files ${Black}${Normal}"
./manage.py collectstatic

getApacheConf

# change permissions
#   cannot use: function changePermissions because it changess more than is required
echo -e "\n   ${Bold}${Blue} change permissions on db.sqlite3 ${Black}${Normal}"
cd $BaseDirectory
chmod g+w "$DjangoProject"
chmod g+w db.sqlite3

# change ownership
#   cannot use changeOwnership because it changes too much
sudo chown :www-data "$DjangoProject"
cd "$BaseDirectory/$DjangoProject"
sudo chown :www-data db.sqlite3

# reload and restart services
reloadServices
restartServices

cd "$BaseDirectory"
read -r -d '' ServerScript <<- EOM
# Run these commands:
cd "$BaseDirectory/$DjangoProject"
source "v_$DjangoProject/bin/activate"
./manage.py runserver "$IP_ADDRESS:8000"
# Or, run this script:
#  bash server.sh
# Then open a browser and enter: http://$IP_ADDRESS:8000
EOM
echo "$ServerScript" >| server.sh

echo -e "\n${Bold}${Green}$ServerScript ${Black}${Normal}"
echoExitingScript
