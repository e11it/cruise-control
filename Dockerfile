FROM openjdk:8-jdk-alpine

ENV VERSION 2.0.77
ENV PORT 9090

EXPOSE 9090/tcp

RUN apk add --no-cache --virtual=.build-dependencies curl ca-certificates git bash

RUN curl -JL https://github.com/linkedin/cruise-control/archive/${VERSION}.tar.gz | tar xzvf - -C /tmp && \
    cd /tmp/cruise-control-${VERSION} && \
    git config --global user.email root@localhost && git config --global user.name root && \
    git init && git add . && git commit -m "Init local repo." && git tag -a ${VERSION} -m "Init local version." && \
    ./gradlew jar && ./gradlew jar copyDependantLibs && \
    ./gradlew jar && ./gradlew jar copyDependantLibs && \
    mkdir -p /cruise-control/cruise-control/build && \
    mkdir -p /cruise-control/cruise-control-core/build && \
    cp cruise-control-metrics-reporter/build/libs/cruise-control-metrics-reporter-${VERSION}.jar /cruise-control && \
    cp -a cruise-control/build/dependant-libs /cruise-control/cruise-control/build && \
    cp -a cruise-control/build/libs /cruise-control/cruise-control/build && \
    cp -a cruise-control-core/build/libs /cruise-control/cruise-control-core/build && \
    cp -a config /cruise-control && \
    cp -a kafka-cruise-control-start.sh /cruise-control && \
    rm -rf /tmp/cruise-control-${VERSION} && \
    curl -JL https://github.com/linkedin/cruise-control-ui/releases/download/v0.3.2/cruise-control-ui-0.3.2.tar.gz | \
    tar xzvf - -C /tmp --exclude '*/README.txt'
#    mv /tmp/cruise-control-ui /cruise-control/cruise-control-ui

WORKDIR /cruise-control

#ENTRYPOINT [ "./kafka-cruise-control-start.sh" ]
#CMD ["config/cruisecontrol.properties"]
