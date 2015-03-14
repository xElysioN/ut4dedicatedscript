#!/bin/bash
# Server Variables 
USER=CHANGE
DIRECTORY=/opt/ut4/server
PORT=7777
SERVERNAME='Unreal Test Script'
MOTD='MOTD'
GAMETYPE="Duel"
MAP="DM-DeckTest"
LINK="CHANGE"

# Script Variables
EXEDIRECTORY=$DIRECTORY/LinuxServer/Engine/Binaries/Linux
CONDIRECTORY=$DIRECTORY/LinuxServer/UnrealTournament/Saved/Config/LinuxServer

# Check the link 
if [ "$LINK" == "CHANGE" ];
then
  echo 'You must insert the download link'
  exit 1
fi

# Check the user 
if [ "$USER" == "CHANGE" ];
then
  echo 'You must change the user'
  exit 1
fi

FILE=${LINK##*/}

# root ?
if [ "$UID" -ne "0" ];
then
  VARROOT=""
else
  VARROOT="sudo -u $USER"
fi

# Check user
id $USER 2>/dev/null
if [ $? -eq 1 ];
then
    echo "User not exist"
    exit 1
fi

# Check directory
if [ ! -d $DIRECTORY ]; 
then
  echo "Directory not exist"
  exit 1
fi

# Check if user got correct access
if ! /bin/sh -c "test -w '$DIRECTORY'" ; then 
  echo 'Forbidden.'
  exit 1
fi

# Check if unzip is installed
if [ $(which unzip | wc -l) -eq 0 ]; 
then
    echo "Installer le paquet 'unzip'."
    echo "sudo apt-get install unzip"
    exit 1
fi

# Download
$VARROOT wget -P $DIRECTORY $LINK
echo 'Unzipping archive.'
$VARROOT unzip -q $DIRECTORY/$FILE -d $DIRECTORY
echo 'Settings rights'
$VARROOT chmod +x $EXEDIRECTORY/UE4Server

# First Launch that will crash 
echo 'First Launch'
$VARROOT $EXEDIRECTORY/UE4Server UnrealTournament DM-DeckTest -log > /dev/null
echo 'First launch finish'

# Creation of config's files
$VARROOT mkdir $DIRECTORY/Configs

# Remove Engine and Game to set Symbolinks Links
$VARROOT rm $CONDIRECTORY/Engine.ini
$VARROOT rm $CONDIRECTORY/Game.ini

# Create files
$VARROOT touch $DIRECTORY/Configs/Engine.ini
$VARROOT touch $DIRECTORY/Configs/Game.ini
$VARROOT touch $DIRECTORY/launch.sh

# Engine.ini
printf "[/Script/UnrealTournament.UTGameEngine]\n bFirstRun = False\n" >> $DIRECTORY/Configs/Engine.ini

# Game.ini
printf "[/Script/UnrealTournament.UTGameState]\n" >> $DIRECTORY/Configs/Game.ini
printf "ServerName=%s\n" "$SERVERNAME" >> $DIRECTORY/Configs/Game.ini
printf "ServerMOTD=%s\n" "$MOTD" >> $DIRECTORY/Configs/Game.ini

# Creating symbolinks links 
$VARROOT ln -s $DIRECTORY/Configs/Engine.ini $CONDIRECTORY/Engine.ini
$VARROOT ln -s $DIRECTORY/Configs/Game.ini $CONDIRECTORY/Game.ini

# Creation of the launch script 
printf "#!/bin/bash\nps -eaf | grep UE4Server | grep %s\nif [ \$? -eq 1 ]\nthen\n%s\n else\necho 'The Duel Server is already running on port %s!'\nfi\n" "$PORT" "$EXEDIRECTORY/UE4Server UnrealTournament $MAP?Game=$GAMETYPE?MustBeReady=1 -port=$PORT" "$PORT" >> $DIRECTORY/launch.sh

# Creation of the CRONTAB File
$VARROOT crontab -l > $DIRECTORY/cron
printf "*/1 * * * * bash %s > /dev/null" "$DIRECTORY/launch.sh" >> $DIRECTORY/cron
$VARROOT crontab $DIRECTORY/cron
$VARROOT rm $DIRECTORY/cron

echo 'Done.'
exit 0