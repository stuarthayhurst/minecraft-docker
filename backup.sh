#!/bin/bash

#Backup projects/ according to a config, using tar and pbzip2
#Usage: ./backups.sh [DESTINATION]
# - [DESTINATION] is optional, as BACKUP_PATH will be used by default

#Config defaults
BACKUP_NAME="Minecraft-Server"
BACKUP_PATH="./backups"
VERSION="26.3.0"

#Create the config file if missing
CONFIG_PATH="./backup-config"
if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "BACKUP_NAME=\"$BACKUP_NAME\"" > "$CONFIG_PATH"
  echo "BACKUP_PATH=\"$BACKUP_PATH\"" >> "$CONFIG_PATH"
  echo "VERSION=\"$VERSION\"" >> "$CONFIG_PATH"
fi

#Apply the config
#shellcheck disable=1090
source "$CONFIG_PATH"

#Override the config backup location if passed
if [[ "$1" != "" ]]; then
  BACKUP_PATH="$1"
fi

#Determine where to back up to
if [[ "$BACKUP_PATH" == "" ]] || [[ ! -d "$BACKUP_PATH" ]]; then
  #If the backup path is empty or doesn't exist, back up locally
  echo "Couldn't find backup path '$BACKUP_PATH', backing up locally"
  FILE="./$BACKUP_NAME-$VERSION-$(date +%Y%m%d)"
else
  #Prepare the backup location
  mkdir -p "$BACKUP_PATH/$VERSION"
  FILE="$BACKUP_PATH/$VERSION/$BACKUP_NAME-$(date +%Y%m%d)"
fi

if [[ ! -d "./projects" ]]; then
  echo "Nothing to back up, exiting" 1>&2
  exit
fi

tar cf "${FILE}.tar.bz2" --use-compress-prog=pbzip2 "./projects/"
