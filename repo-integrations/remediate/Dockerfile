# This default may be swapped for any compatible base image
ARG BASE_IMAGE=amd64/ubuntu:24.04@sha256:c8af0e28cf94b1995f4d650e38c07cccf21d1c093168f14cd183720b8a326cd3

# This containerbase is used for tool intallation and user/directory setup
FROM ghcr.io/containerbase/base:13.26.4@sha256:f5f4a7010d9ab7045d5717d04168db411c453e0504fce8084590206d1dc3eabc AS containerbase

FROM ${BASE_IMAGE} AS base

RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# The containerbase supports custom user but Renovate requires ubuntu
ARG USER_NAME=ubuntu
ARG USER_ID=1000
ARG APP_ROOT=/usr/src/mend

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

# Set up containerbase
COPY --from=containerbase /usr/local/bin/ /usr/local/bin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
COPY --from=containerbase /usr/local/sbin/ /usr/local/sbin/
RUN install-containerbase && \
    prepare-tool all

# --------------------------------------------------------------
# The following packages are mandatory for installs and runtime
# --------------------------------------------------------------

# renovate: datasource=github-tags depName=git packageName=git/git
ARG GIT_VERSION=v2.52.0
RUN install-tool git

# install git-lfs
#ARG GIT_LFS_VERSION=v3.5.1
#RUN install-tool git-lfs
#ENV RENOVATE_GIT_NO_VERIFY=commit

# renovate: datasource=github-releases depName=node packageName=nodejs/node versioning=node
ARG NODE_VERSION=22.22.0
RUN install-tool node

# Copy and validate the expected node runtime installation path used by the worker for executing the Renovate CLI
ENV DOCKERFILE_NODE_DEFAULT_PATH=/usr/bin/node_default
RUN COERCED_NODE_VERSION=$(node -v | grep '^v2' | sed 's/^v//') && \
    cp /opt/containerbase/tools/node/$COERCED_NODE_VERSION/bin/node $DOCKERFILE_NODE_DEFAULT_PATH
# Validate the expected node runtime installation path used by the worker for executing the Renovate CLI
RUN $DOCKERFILE_NODE_DEFAULT_PATH --version

# renovate: datasource=npm depName=npm versioning=npm
ARG NPM_VERSION=10.9.4
RUN install-tool npm

# renovate: datasource=npm depName=yarn versioning=npm
ARG YARN_VERSION=1.22.22
RUN install-tool yarn

# -------------------------------------------------------------------------------------
# Any of the below third-party tools may be commented out to save space and build time
# -------------------------------------------------------------------------------------

# renovate: datasource=github-releases packageName=moby/moby
RUN install-tool docker v28.5.2

# renovate: datasource=adoptium-java depName=java
ARG JAVA_VERSION=11.0.29+7
RUN install-tool java

# renovate: datasource=gradle-version depName=gradle versioning=gradle
ARG GRADLE_VERSION=9.3.0
RUN install-tool gradle

# renovate: datasource=github-releases depName=erlang packageName=containerbase/erlang-prebuild versioning=docker
ARG ERLANG_VERSION=27.3.4.6
RUN install-tool erlang

# renovate: datasource=docker depName=elixir versioning=docker
ARG ELIXIR_VERSION=1.19.5
RUN install-tool elixir

# renovate: datasource=github-releases depName=php packageName=containerbase/php-prebuild
ARG PHP_VERSION=8.5.2
RUN install-tool php

# renovate: datasource=github-releases depName=composer packageName=composer/composer
ARG COMPOSER_VERSION=2.9.3
RUN install-tool composer

# renovate: datasource=docker depName=golang versioning=docker
ARG GOLANG_VERSION=1.25.6
RUN install-tool golang

# renovate: datasource=github-releases depName=python packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.14.2
RUN install-tool python

# renovate: datasource=pypi
RUN install-tool conan 2.24.0

# renovate: datasource=pypi depName=pipenv
ARG PIPENV_VERSION=2025.1.3
RUN install-tool pipenv

# renovate: datasource=github-releases depName=poetry packageName=python-poetry/poetry
ARG POETRY_VERSION=1.8.5
RUN install-tool poetry

# renovate: datasource=pypi
RUN install-tool uv 0.9.26

# renovate: datasource=pypi depName=hashin
ARG HASHIN_VERSION=1.0.5
RUN install-tool hashin

# renovate: datasource=pypi
RUN install-tool pdm 2.26.4

# renovate: datasource=pypi
RUN install-tool pip-tools 7.5.2

# renovate: datasource=docker depName=rust versioning=docker
ARG RUST_VERSION=1.92.0
RUN install-tool rust

# renovate: datasource=github-releases depName=ruby packageName=containerbase/ruby-prebuild versioning=ruby
ARG RUBY_VERSION=3.4.8
RUN install-tool ruby

# renovate: datasource=rubygems depName=bundler
ARG BUNDLER_VERSION=2.7.2
RUN install-tool bundler

# renovate: datasource=rubygems depName=cocoapods versioning=ruby
ARG COCOAPODS_VERSION=1.16.2
RUN install-tool cocoapods

# renovate: datasource=npm depName=pnpm versioning=npm
ARG PNPM_VERSION=10.28.0
RUN install-tool pnpm

# renovate: datasource=docker depName=dotnet packageName=mcr.microsoft.com/dotnet/sdk
ARG DOTNET_VERSION=8.0.417
RUN install-tool dotnet

# renovate: datasource=github-releases depName=helm packageName=helm/helm
ARG HELM_VERSION=v3.19.5
RUN install-tool helm

# renovate: datasource=github-releases packageName=jsonnet-bundler/jsonnet-bundler
RUN install-tool jb v0.6.0

# renovate: datasource=npm
RUN install-tool bun 1.3.5

# renovate: datasource=github-releases packageName=containerbase/nix-prebuild
RUN install-tool nix 2.33.1

# renovate: datasource=github-releases packageName=jetify-com/devbox
RUN install-tool devbox 0.16.0

# renovate: datasource=github-releases packageName=bazelbuild/bazelisk
RUN install-tool bazelisk v1.28.0

# renovate: datasource=dart-version
RUN install-tool dart 3.10.7

# renovate: datasource=flutter-version
RUN install-tool flutter 3.38.7

# END OF BASE IMAGE
