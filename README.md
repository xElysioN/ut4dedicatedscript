# Linux Unreal Tournament Dedicated Server Install Script 
This script allow you to install simply an Unreal Tournament Dedicated Server 

## Requirements
- Debian Wheezy x64
( Others system are in test ) 

## Installation
- Log on the server
- wget https://raw.githubusercontent.com/xElysioN/ut4dedicatedscript/master/ut4dedicated.sh
- Edit the file with nano / vim / your text editor
 - USER : User that will launch the server 
 - DIRECTORY : Directory where the server will be placed
 - PORT : Port of the UT Server
 - SERVERNAME : Name of your UT Server
 - MOTD : Message Of The Day of your UT Server
 - GAMETYPE : Duel / CTF / DM 
 - MAP : Default Map of the server
 - TYPE : install
- You have two options here 
 - Change LINK if you never download the file or change FILE if the file is already on the system
  - LINK : Link of the UT Linux Server ( CF : https://forums.unrealtournament.com/showthread.php?12068-Unreal-Tournament-Pre-Alpha-Playable-Build-Instructions ) 
  - FILE : absolute link where the file is 
- Wait one minut and your server is up

## Update 
- You only need to change the following variables from the previous file used for installation
 - TYPE : update
 - LINK or FILE ( like installation )

 ## Reboot the server
 - Go to your server directory and launch bash reboot.sh

## Contact
Send me an email to : elysioneh@gmail.com