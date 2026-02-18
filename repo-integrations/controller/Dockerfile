# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:24.04

# This buildpack is used for tool installation and user/directory setup
FROM ghcr.io/containerbase/base:13.26.7@sha256:5a7aace53413ad8e98fbb87cbe1aa6727ce2ad225356a46a58ea9171ae8966d1 AS containerbase

FROM ${BASE_IMAGE} as base

RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USER_NAME=user
ARG USER_ID=1542
ARG APP_ROOT=/usr/src/app

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

# Set up containerbase
COPY --from=containerbase /usr/local/sbin/ /usr/local/sbin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
RUN install-containerbase && \
    prepare-tool all

# renovate: datasource=docker depName=openjdk versioning=docker
ARG JAVA_VERSION=17.0.9+9
RUN install-tool java

# END OF BASE IMAGE
