# check=skip=InvalidDefaultArgInFrom
ARG JAVA_VERSION

#Stage 0: Build the server .jar
FROM eclipse-temurin:${JAVA_VERSION}-jdk-alpine
ARG SPIGOT_VERSION

#Spigot build dependencies
RUN apk add --no-cache git

#Build the server .jar
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev ${SPIGOT_VERSION}

#Stage 1: Set up runtime container
FROM eclipse-temurin:${JAVA_VERSION}-jre-alpine
ARG EULA
ARG SPIGOT_VERSION
ENV SPIGOT_VERSION ${SPIGOT_VERSION}

#Copy the server .jar in
COPY --from=0 /spigot-${SPIGOT_VERSION}.jar /server/spigot-${SPIGOT_VERSION}.jar
WORKDIR /server

VOLUME /server/data
VOLUME /server/config
VOLUME /server/plugins
VOLUME /server/logs

#Link miscellaneous configs to /server/config
RUN ln -s /server/config/banned-ips.json /server/banned-ips.json
RUN ln -s /server/config/banned-players.json /server/banned-players.json
RUN ln -s /server/config/bukkit.yml /server/bukkit.yml
RUN ln -s /server/config/commands.yml /server/commands.yml
RUN ln -s /server/config/help.yml /server/help.yml
RUN ln -s /server/config/ops.json /server/ops.json
RUN ln -s /server/config/permissions.yml /server/permissions.yml
RUN ln -s /server/config/server.properties /server/server.properties
RUN ln -s /server/config/spigot.yml /server/spigot.yml
RUN ln -s /server/config/whitelist.json /server/whitelist.json

RUN mkdir -p /server/logs/crash-reports
RUN ln -s /server/logs/crash-reports /server/crash-reports

#Plugin and wrapper to ping the shutdown plugin when SIGTERM is received, then shutdown gracefully
RUN mkdir /server/plugins
RUN wget -O /server/plugins/PingShutdown-latest.jar https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/latest/download/PingShutdown-latest.jar
RUN wget -O /server/wrapper.py https://github.com/stuarthayhurst/spigot-ping-shutdown-plugin/releases/latest/download/wrapper.py

#Spigot and wrapper runtime dependencies
RUN apk add --no-cache libudev-zero python3

RUN if [[ "${EULA}" == "true" ]]; then echo "eula=true" > eula.txt; fi

STOPSIGNAL SIGTERM
EXPOSE 25565
CMD python3 wrapper.py java -Xms$MINRAM -Xmx$MAXRAM -jar spigot-${SPIGOT_VERSION}.jar nogui
