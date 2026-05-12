#!/bin/bash

PROJECT_NAME="$1"
if [[ "$PROJECT_NAME" == "" ]]; then
  PROJECT_NAME="minecraft-docker"
fi

mkdir -p "projects/$PROJECT_NAME/data"
mkdir -p "projects/$PROJECT_NAME/config"
mkdir -p "projects/$PROJECT_NAME/plugins"
mkdir -p "projects/$PROJECT_NAME/logs"
