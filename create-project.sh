#!/bin/bash

PROJECT_NAME="$1"
if [[ "$PROJECT_NAME" == "" ]]; then
  PROJECT_NAME="minecraft-docker"
fi

mkdir -p "$PROJECT_NAME/data"
mkdir -p "$PROJECT_NAME/config"
mkdir -p "$PROJECT_NAME/plugins"
mkdir -p "$PROJECT_NAME/logs"
