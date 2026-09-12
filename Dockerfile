# check=skip=InvalidDefaultArgInFrom
ARG JAVA_VERSION

#Stage 0: Build the server .jar
FROM eclipse-temurin:${JAVA_VERSION}-jdk-alpine AS build
ARG SPIGOT_VERSION
ARG PING_SHUTDOWN_VERSION

#Spigot build dependencies
RUN apk add --no-cache git

#Build the server .jar
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev ${SPIGOT_VERSION}

#Fetch the required PingShutdown version
COPY build-scripts /build-scripts
RUN /build-scripts/download-plugins.sh ${PING_SHUTDOWN_VERSION}

#Stage 1: Set up runtime container
FROM eclipse-temurin:${JAVA_VERSION}-jre-alpine
ARG EULA
ARG SPIGOT_VERSION
ENV SPIGOT_VERSION ${SPIGOT_VERSION}
ARG USER_UID
ARG USER_GID

#Spigot and wrapper runtime dependencies
RUN apk add --no-cache libudev-zero python3

#Set up and switch to a new non-root user
WORKDIR /server
RUN addgroup --gid ${USER_GID} minecraft \
    && adduser --ingroup minecraft -D --uid ${USER_UID} minecraft
RUN chown -R minecraft:minecraft /server
USER minecraft

#Create volume mountpoints
VOLUME /server/data
VOLUME /server/config
VOLUME /server/plugins
VOLUME /server/logs

#Link the server icon to /server/data
RUN ln -s /server/data/server-icon.png /server/server-icon.png

#Link miscellaneous configs to /server/config
RUN ln -s /server/config/banned-ips.json /server/banned-ips.json \
    && ln -s /server/config/banned-players.json /server/banned-players.json \
    && ln -s /server/config/bukkit.yml /server/bukkit.yml \
    && ln -s /server/config/commands.yml /server/commands.yml \
    && ln -s /server/config/eula.txt /server/eula.txt \
    && ln -s /server/config/help.yml /server/help.yml \
    && ln -s /server/config/ops.json /server/ops.json \
    && ln -s /server/config/permissions.yml /server/permissions.yml \
    && ln -s /server/config/server.properties /server/server.properties \
    && ln -s /server/config/spigot.yml /server/spigot.yml \
    && ln -s /server/config/whitelist.json /server/whitelist.json

#Link the crash reports to /server/logs/crash-reports
RUN mkdir -p /server/logs/crash-reports
RUN ln -s /server/logs/crash-reports /server/crash-reports

#Pre-accept the eula if configured to
RUN mkdir -p /server/config
RUN if [[ "${EULA}" == "true" ]]; then echo "eula=true" > /server/config/eula.txt; fi

#Plugin and wrapper to ping the shutdown plugin when SIGTERM is received, then shutdown gracefully
COPY --from=build /PingShutdown-latest.jar /server/PingShutdown-latest.jar
COPY --from=build /wrapper.py /server/wrapper.py

#Copy the server .jar in from the build stage
COPY --from=build /spigot-${SPIGOT_VERSION}.jar /server/spigot-${SPIGOT_VERSION}.jar

STOPSIGNAL SIGTERM
EXPOSE 25565

#Copy the PingShutdown plugin across, launch the wrapper
CMD cp /server/PingShutdown-latest.jar /server/plugins/PingShutdown-latest.jar \
    && python3 wrapper.py java "-Xms$MINRAM" "-Xmx$MAXRAM" -jar spigot-${SPIGOT_VERSION}.jar nogui --world-container "$WORLD_PATH"
