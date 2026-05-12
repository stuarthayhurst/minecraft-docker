## Minecraft Docker
  - Scripts and configs to run a Spigot Minecraft server in a Docker container
    - Uses [Ping Shutdown](https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin) to gracefully stop the server on container stop
  - This was written for my personal setup, your mileage may vary

## Usage:
  - Run `docker compose build` to build the container
  - Run `docker compose up` to start the container
  - Run `docker compose stop` or `docker compose down` to stop the container
  - Run `docker compose attach minecraft` to attach to the server's command prompt
  - The container uses the `unless-stopped` restart policy
  - It's recommended to use the `data` volume for world files, see [Volumes](#volumes) for info
    - For a single world, set `level-name` to `data/[WORLD NAME]` in `server-properties`
    - For multiple worlds, set `world-container` to `data` in `bukkit.yml`

## Volumes:
  - The volumes can be managed as a project, see [Projects](#projects)
  - Within the container, several mountpoints exist:
    - `data/`: Generic persistent data, designed for worlds and the server icon
      - Nothing uses this by default, `server.properties` or `bukkit.yml` must be told to
    - `config/`: Configuration files for the server, see `Dockerfile` for the symlinks pointing here
    - `plugins/`: Plugins and their configs, comes with `PingShutdown` to handle container stops gracefully
    - `logs/`: Logs and crash reports for the server

## Projects:
  - The persistent data (log, plugins, configs, etc) is stored in several volumes
    - These are grouped into a project
  - Use `./create-project.sh [NAME]` to create the directory structure for a new project
  - Use `--project-name [NAME]` with the Docker commands to switch to a different project
  - Projects can be used to quickly swap to a different server configuration

## Config:
  - `compose.yaml` defines several build arguments and environment variables
  - Build arguments:
    - `JAVA_VERSION` - The version of major Java to use in the container
      - Must be a valid [eclipse-temurin container](https://github.com/adoptium/containers)
    - `SPIGOT_VERSION` - The version of Minecraft to build Spigot for
    - `EULA`: `[true (default) / false]` - Accept / reject the EULA
  - Environment variables:
    - `MINRAM` - Minimum amount of RAM to allocate for the JVM, defaults to `2G`
    - `MAXRAM` - Maximum amount of RAM to allocate for the JVM, defaults to `16G`
    - `SHUTDOWN_PORT`: `[1 - 65535]` - The port to use for `PingShutdown`, defaults to `20563`
      - `PingShutdown`'s config must be changed to match, found in `projects/[NAME]/plugins/PingShutdown/config.yml`

> [!WARNING]
> `SHUTDOWN_PORT` shouldn't be exposed outside of the container, otherwise anyone can ping the port to stop the server down
> This should be completely internal to the container

## Backups:
  - Set `BACKUP_PATH`, `BACKUP_NAME` and `VERSION` in `backup-config` to configure the backups
    - If `BACKUP_PATH` doesn't exist, a backup will be created in the working directory
  - Run `./backup.sh` to backup `projects/`
  - Backups use `tar` and `pbzip2`
