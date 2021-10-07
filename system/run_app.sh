#!/usr/bin/env bash
cd /home/pi/newt
sudo /usr/bin/python3 server.py

# Allow Cherrypy to boot up
sleep 5

# Run on Desktop or headless
#   run headless ???
#   ??? what needs to be done for headless ???

#   run on Raspberry Pi Desktop
#     don't run script to remove unusued stuff in Raspberry Pi setup insturctions ???
#     uncomment following line
# chromium-browser --app=http://hostname:port
