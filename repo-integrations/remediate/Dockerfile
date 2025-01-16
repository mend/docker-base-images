# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:20.04

# This containerbase is used for tool intallation and user/directory setup
FROM ghcr.io/containerbase/base:11.11.14 AS containerbase

FROM ${BASE_IMAGE} as base

# The containerbase supports custom user but Renovate requires ubuntu
ARG USER_NAME=ubuntu
ARG USER_ID=1000
ARG APP_ROOT=/usr/src/app

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
ARG GIT_VERSION=v2.46.0
RUN install-tool git

# install git-lfs
#ARG GIT_LFS_VERSION=v3.5.1
#RUN install-tool git-lfs
#ENV RENOVATE_GIT_NO_VERIFY=commit

# renovate: datasource=github-releases depName=node packageName=nodejs/node versioning=node
ARG NODE_VERSION=20.17.0
RUN install-tool node

ENV DOCKERFILE_NODE_DEFAULT_PATH=/usr/bin/node_default
RUN COERCED_NODE_VERSION=$(node -v | grep '^v20' | sed 's/^v//') && \
    ln -s /opt/containerbase/tools/node/$COERCED_NODE_VERSION/bin/node $DOCKERFILE_NODE_DEFAULT_PATH
# Validate the expected node runtime installation path used by the worker for executing the Renovate CLI
RUN $DOCKERFILE_NODE_DEFAULT_PATH --version

# renovate: datasource=npm depName=npm versioning=npm
ARG NPM_VERSION=9.9.3
RUN install-tool npm

# renovate: datasource=npm depName=yarn versioning=npm
ARG YARN_VERSION=1.22.22
RUN install-tool yarn

# -------------------------------------------------------------------------------------
# Any of the below third-party tools may be commented out to save space and build time
# -------------------------------------------------------------------------------------

# renovate: datasource=adoptium-java depName=java
ARG JAVA_VERSION=11.0.24+8
RUN install-tool java

# renovate: datasource=gradle-version depName=gradle versioning=gradle
ARG GRADLE_VERSION=8.10.1
RUN install-tool gradle

# renovate: datasource=github-releases depName=erlang packageName=containerbase/erlang-prebuild versioning=docker
ARG ERLANG_VERSION=24.3.4.17
RUN install-tool erlang

# renovate: datasource=docker depName=elixir versioning=docker
ARG ELIXIR_VERSION=1.16.2
RUN install-tool elixir

# renovate: datasource=github-releases depName=php packageName=containerbase/php-prebuild
ARG PHP_VERSION=8.3.11
RUN install-tool php

# renovate: datasource=github-releases depName=composer packageName=composer/composer
ARG COMPOSER_VERSION=2.7.9
RUN install-tool composer

# renovate: datasource=docker depName=golang versioning=docker
ARG GOLANG_VERSION=1.23.1
RUN install-tool golang

# renovate: datasource=github-releases depName=python packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.12.6
RUN install-tool python

# renovate: datasource=pypi depName=pipenv
ARG PIPENV_VERSION=2023.12.1
RUN install-tool pipenv

# renovate: datasource=github-releases depName=poetry packageName=python-poetry/poetry
ARG POETRY_VERSION=1.8.3
RUN install-tool poetry

# renovate: datasource=pypi depName=hashin
ARG HASHIN_VERSION=0.17.0
RUN install-tool hashin

# renovate: datasource=docker depName=rust versioning=docker
ARG RUST_VERSION=1.81.0
RUN install-tool rust

# renovate: datasource=github-releases depName=ruby packageName=containerbase/ruby-prebuild versioning=ruby
ARG RUBY_VERSION=3.3.5
RUN install-tool ruby

# renovate: datasource=rubygems depName=bundler
ARG BUNDLER_VERSION=2.5.18
RUN install-tool bundler

# renovate: datasource=rubygems depName=cocoapods versioning=ruby
ARG COCOAPODS_VERSION=1.15.2
RUN install-tool cocoapods

# renovate: datasource=npm depName=pnpm versioning=npm
ARG PNPM_VERSION=8.15.9
RUN install-tool pnpm

# renovate: datasource=docker depName=dotnet packageName=mcr.microsoft.com/dotnet/sdk
ARG DOTNET_VERSION=6.0.425
RUN install-tool dotnet

# renovate: datasource=npm depName=lerna versioning=npm
ARG LERNA_VERSION=7.4.2
RUN install-tool lerna

# renovate: datasource=github-releases depName=helm packageName=helm/helm
ARG HELM_VERSION=v3.16.0
RUN install-tool helm
