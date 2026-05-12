#!/bin/bash

source backup-config

if [[ -d "$BACKUP_PATH" ]]; then
  mkdir -p "$BACKUP_PATH/$VERSION"
  FILE="$BACKUP_PATH/$VERSION/$BACKUP_NAME-$(date +%Y%m%d)"
else
  FILE="./$BACKUP_NAME-$VERSION-$(date +%Y%m%d)"
fi

tar cf "${FILE}.tar.bz2" --use-compress-prog=pbzip2 "./projects/"
