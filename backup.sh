#!/bin/bash

source backup-config

BACKUP_PATH="$1"
if [[ "$BACKUP_PATH" == "" ]] || [[ ! -d "$BACKUP_PATH" ]]; then
  FILE="./$BACKUP_NAME-$VERSION-$(date +%Y%m%d)"
else
  mkdir -p "$BACKUP_PATH/$VERSION"
  FILE="$BACKUP_PATH/$VERSION/$BACKUP_NAME-$(date +%Y%m%d)"
fi

tar cf "${FILE}.tar.bz2" --use-compress-prog=pbzip2 "./projects/"
