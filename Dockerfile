# check=skip=InvalidDefaultArgInFrom
ARG JAVA_VERSION

#Stage 0: Build the server .jar
FROM eclipse-temurin:${JAVA_VERSION}-jdk-alpine
ARG SPIGOT_VERSION

#Spigot build dependencies
RUN apk add --no-cache git

RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev ${SPIGOT_VERSION}

#Stage 1: Set up runtime container
FROM eclipse-temurin:${JAVA_VERSION}-jre-alpine
ARG EULA
ARG SPIGOT_VERSION
ENV SPIGOT_VERSION ${SPIGOT_VERSION}

COPY --from=0 /spigot-${SPIGOT_VERSION}.jar /server/spigot-${SPIGOT_VERSION}.jar
WORKDIR /server

#Wrapper to intercept SIGTERM and send "stop" instead
ADD wrapper.py /server/wrapper.py

#Spigot and wrapper runtime dependencies
RUN apk add --no-cache libudev-zero python3

RUN if [[ "${EULA}" == "true" ]]; then echo "eula=true" > eula.txt; fi

STOPSIGNAL SIGTERM
EXPOSE 25565
CMD python3 wrapper.py java -Xms$MINRAM -Xmx$MAXRAM -jar spigot-${SPIGOT_VERSION}.jar nogui
