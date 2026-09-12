#!/bin/sh

version="$1"

if [ "$version" = "latest" ]; then
  wget -O PingShutdown-latest.jar https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/latest/download/PingShutdown-latest.jar
  wget -O wrapper.py https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/latest/download/wrapper.py
else
  wget -O PingShutdown-latest.jar "https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/download/v$version/PingShutdown-latest.jar"
  wget -O wrapper.py "https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/download/v$version/wrapper.py"
fi
