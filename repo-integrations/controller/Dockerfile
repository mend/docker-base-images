# This default may be swapped for any compatible base image
ARG BASE_IMAGE=amd64/ubuntu:20.04@sha256:b795f8e0caaaacad9859a9a38fe1c78154f8301fdaf0872eaf1520d66d9c0b98

# This buildpack is used for tool installation and user/directory setup
FROM ghcr.io/containerbase/base:9.24.0@sha256:82e02e48136e3d3e5d5d1bafd59acb5dbcfdf72b28f012de71757edeb203fc3d AS containerbase

FROM ${BASE_IMAGE} as base

ARG USER_NAME=user
ARG USER_ID=1542
ARG APP_ROOT=/usr/src/app

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

# Set up buildpack
COPY --from=containerbase /usr/local/bin/ /usr/local/bin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
RUN install-containerbase

# renovate: datasource=docker depName=openjdk versioning=docker
ARG JAVA_VERSION=17.0.9+9
RUN install-tool java
