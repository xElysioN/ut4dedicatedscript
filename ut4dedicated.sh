#!/bin/bash
# Script Variables 
USER="CHANGE"
DIRECTORY=/opt/ut4/test/server
TYPE="install"
LINK="none"
FILE="none"

# Server Variables
SERVERNAME="Unreal Server"
MOTD="Welcome"
PORT=7777
MAP="DM-DeckTest"
GAMETYPE="Duel"

# Don't change
EXEDIRECTORY=$DIRECTORY/LinuxServer/Engine/Binaries/Linux
CONDIRECTORY=$DIRECTORY/LinuxServer/UnrealTournament/Saved/Config/LinuxServer

# Check Variables
## FILE & LINK
CLINK=false
if [[ "$FILE" != "none" ]]; then
  # Check if the file is correct
  if [[ -f $FILE  ]]; then
    CLINK=true
  else
    echo "The FILE you entered is invalid"
  fi
fi

if [[ "$CLINK" == false ]]; then
  # Check if LINK is different
  if [[ "$LINK" == "none" ]]; then
    echo "You must change the variable LINK"
      exit 1
    else
      # Checking Link ( soon )
      CLINK=true
  fi
fi
FILENAME=$(basename FILE)

# Check User Exist 
## Check user
id $USER > /dev/null 2> /dev/null

if [ $? -eq 1 ];
then
    echo "User not exist"
    exit 1
fi

## Check isroot ?
if [ "$UID" -ne "0" ];
then
  VARROOT=""
else
  VARROOT="sudo -u $USER"
fi

# Check Directory Exist
if [ ! -d $DIRECTORY ]; 
then
  echo "Directory not exist"
  exit 1
fi

# Check if user got correct right on the Directory
$VARROOT test -w $DIRECTORY

if [[ $? == "1" ]]; then 
  echo 'User cant write into the directory.'
  exit 1
fi

# Check unzip installed
if [ $(which unzip | wc -l) -eq 0 ]; 
then
    echo "Installer le paquet 'unzip'."
    echo "sudo apt-get install unzip"
    exit 1
fi


# Actions 
## Download
if [[ "$LINK" != "none" ]]; then
  $VARROOT wget -P $DIRECTORY $LINK
fi

## Unzipping
echo 'Unzipping archive...'
$VARROOT unzip -q $FILE -d $DIRECTORY

## Right 1
echo 'Settings rights...'
$VARROOT chmod +x $EXEDIRECTORY/UE4Server

## First Launch that will crash 
echo 'First Launch'
$VARROOT $EXEDIRECTORY/UE4Server UnrealTournament DM-DeckTest -log > /dev/null
echo 'First launch finish'

if [[ "$TYPE" == "install" ]]; then
  echo "Creation of configs files"
  # Creation of config's files
  $VARROOT mkdir $DIRECTORY/Configs
  $VARROOT touch $DIRECTORY/Configs/Engine.ini
  $VARROOT touch $DIRECTORY/Configs/Game.ini
  $VARROOT touch $DIRECTORY/launch.sh

  # Engine.ini
  printf "[/Script/UnrealTournament.UTGameEngine]\n bFirstRun = False\n" >> $DIRECTORY/Configs/Engine.ini

  # Game.ini
  printf "[/Script/UnrealTournament.UTGameState]\n" >> $DIRECTORY/Configs/Game.ini
  printf "ServerName=%s\n" "$SERVERNAME" >> $DIRECTORY/Configs/Game.ini
  printf "ServerMOTD=%s\n" "$MOTD" >> $DIRECTORY/Configs/Game.ini

  # Creation of the launch script 
  printf "#!/bin/bash\nps -eaf | grep UE4Server | grep %s\nif [ \$? -eq 1 ]\nthen\n%s\n else\necho 'The Server is already running on port %s!'\nfi\n" "$PORT" "$EXEDIRECTORY/UE4Server UnrealTournament $MAP?Game=$GAMETYPE?MustBeReady=1 -port=$PORT" "$PORT" >> $DIRECTORY/launch.sh

  # Creation of the CRONTAB File
  echo "Creation of CRON"
  $VARROOT touch $DIRECTORY/cron
  $VARROOT crontab -l > $DIRECTORY/cron
  printf "*/1 * * * * bash %s > /dev/null \n" "$DIRECTORY/launch.sh" >> $DIRECTORY/cron
  $VARROOT crontab $DIRECTORY/cron
  $VARROOT rm $DIRECTORY/cron
fi

# Remove Engine and Game to set Symbolinks Links
$VARROOT rm $CONDIRECTORY/Engine.ini
$VARROOT rm $CONDIRECTORY/Game.ini

# Creating symbolinks links 
$VARROOT ln -s $DIRECTORY/Configs/Engine.ini $CONDIRECTORY/Engine.ini
$VARROOT ln -s $DIRECTORY/Configs/Game.ini $CONDIRECTORY/Game.ini

echo 'Done.'
exit 0