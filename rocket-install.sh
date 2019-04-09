#!/bin/bash
#
#  Copyright (c) 2019 - Dawid Deręgowski - MIT
#
# ROCKET.CHAT SERVER LINUX INSTALLER
# VERSION 1.0.0

FILE="/etc/init.d/rocket"
USER_DIR="/home/rocket"
ROCKET_USER="rocket"
ROCKET_DIR="/home/rocket/Rocket.Chat"
INSTALL_DIR="/home/rocket/rocket-install"

# Check if rocketchat is installed as service
if [ ! -e $FILE ]; then
   echo "File $FILE does not exist. Rocket have to be installed as service and named as /etc/init.d/rocket"
   exit 1
fi

# Check if rocketchat app home directory exists
if [ ! -e $ROCKET_DIR ]; then
   echo "Dir $ROCKET_DIR does not exist. If your application path is different, please change 'ROCKET_DIR' in this script."
   exit 1
fi

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# CHOOSE YOUR VERSION
echo "------- Rocket.Chat Server Linux Installer"
echo "------- Please enter rocket.chat version: [only digits!] for ex: 0.55.0-rc.6"
read rcversion
echo "------- You choosed $rcversion. Running installation, please wait (~1min)."
echo ""

# REMOVING OLD, DOWNLOADING NEW VERSION
cd $INSTALL_DIR
rm $INSTALL_DIR/rocket.*
rm $INSTALL_DIR/0.* -Rf
wget https://cdn-download.rocket.chat/build/rocket.chat-$rcversion.tgz
mkdir -p $INSTALL_DIR/$rcversion
tar xvpf rocket.chat-$rcversion.tgz -C $rcversion/

# REMOVING OLD VERSION
rm $ROCKET_DIR/programs/ -Rf
rm $ROCKET_DIR/README
rm $ROCKET_DIR/server/ -Rf
rm $ROCKET_DIR/star.json
rm $ROCKET_DIR/main.js
rm $ROCKET_DIR/.node_version.txt

# MOVING NEW VERSION
mv $INSTALL_DIR/$rcversion/bundle/* $ROCKET_DIR/
mv $INSTALL_DIR/$rcversion/bundle/.node_version.txt $ROCKET_DIR/

chown $ROCKET_USER:$ROCKET_USER "/home/$ROCKET_USER/" -Rf
chown $ROCKET_USER:$ROCKET_USER "/home/$ROCKET_USER/.*" -Rf
chown $ROCKET_USER:$ROCKET_USER /var/lock/$ROCKET_USER

# STOPING ROCKET.CHAT, INSTALLING NEW VERSION, STARTING ROCKET.CHAT
su - $ROCKET_USER -c "/etc/init.d/rocket stop"
sleep 5
su - $ROCKET_USER -c "cd $ROCKET_DIR/programs/server; npm install"
sleep 5
su - $ROCKET_USER -c "/etc/init.d/rocket start"

rm $INSTALL_DIR/rocket.*
rm $INSTALL_DIR/0.* -Rf

echo ""
echo "--- Installation completed, please check Rocket.Chat"
echo "--- bye"
