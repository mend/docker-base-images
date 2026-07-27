# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:24.04

# Eclipse Temurin JRE for Java runtime
FROM eclipse-temurin:17.0.19_10-jre-noble AS java

FROM ${BASE_IMAGE} as base

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y --no-install-recommends dumb-init && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USER_NAME=user
ARG USER_ID=1542
ARG APP_ROOT=/usr/src/app

# Create non-root user (replaces containerbase user setup, includes root group for OpenShift compatibility)
RUN groupadd --gid ${USER_ID} ${USER_NAME} && \
    useradd --uid ${USER_ID} --gid 0 --groups "0,${USER_ID}" --shell /bin/bash --create-home ${USER_NAME}

# Copy JRE from Temurin image
COPY --from=java /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
# Force UTF-8 as the JVM charset; the Temurin JRE base image sets no locale, so file.encoding otherwise defaults to US-ASCII (unlike the previous containerbase image)
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# END OF BASE IMAGE
