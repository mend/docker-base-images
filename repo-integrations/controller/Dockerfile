# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:24.04

# This buildpack is used for tool installation and user/directory setup
FROM containerbase/base:13.5.8 AS containerbase

FROM ${BASE_IMAGE} as base

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
