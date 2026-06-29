# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:24.04

# Containerbase is used for tool installation and user/directory setup
FROM ghcr.io/containerbase/base:14.9.5@sha256:2852f7e2784fb21e745325a81c9beb1906be51b79956376eecf9ce57dacf6fd0 AS containerbase


FROM ${BASE_IMAGE} as base

RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Containerbase supports custom user
ARG USER_NAME=wss-scanner
ARG USER_ID=1000
ARG USER_HOME=/home/${USER_NAME}
ARG APT_HTTP_PROXY

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

# Set up containerbase
COPY --from=containerbase /usr/local/sbin/ /usr/local/sbin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
RUN install-containerbase && \
    prepare-tool all

# renovate: datasource=github-tags packageName=git/git
ARG GIT_VERSION=v2.54.0
RUN install-tool git

# install git lfs
# renovate: datasource=github-releases packageName=git-lfs/git-lfs
#ARG GIT_LFS_VERSION=v3.7.1
#RUN install-tool git-lfs

# renovate: datasource=github-releases packageName=containerbase/node-prebuild versioning=node
ARG NODE_VERSION=24.15.0
RUN install-tool node
# Layer 7 (instruction #8): RUN |6 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_P
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 3          │ CVE-2026-33750, CVE-2026-45149, CVE-2026-33671     │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=npm versioning=npm
ARG NPM_VERSION=11.13.0
RUN install-tool npm
# Layer 8 (instruction #9): RUN |7 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_P
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 2          │ CVE-2026-45149, CVE-2026-12151                     │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=npm packageName=@yarnpkg/cli-dist
ARG YARN_VERSION=1.22.22
RUN install-tool yarn

# renovate: datasource=npm
# ARG BOWER_VERSION=1.8.14
# RUN install-tool bower

# renovate: datasource=npm
#ARG PNPM_VERSION=10.33.2
#RUN install-tool pnpm

# renovate: datasource=npm
#ARG BUN_VERSION=1.3.14
#RUN install-tool bun

### provide permissions
# RUN echo '{ "allow_root": true }' > ${USER_HOME}/.bowerrc && \
# 	chown -R ${USER_NAME}:${GROUP_NAME} ${USER_HOME}/.bowerrc

ARG JAVA_VERSION=8.0.472+8
RUN install-tool java

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=11.0.29+7
RUN install-tool java

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=21.0.10+7.0.LTS
RUN install-tool java

ARG JAVA_VERSION=25.0.2+10.0.LTS
RUN install-tool java

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=17.0.18+8
RUN install-tool java
ENV MEND_JAVA=/usr/local/bin/mend_java
RUN ln -sf /opt/containerbase/tools/java/$JAVA_VERSION/bin/java $MEND_JAVA && \
    chmod +x $MEND_JAVA

# renovate: datasource=gradle-version packageName=gradle versioning=gradle
# ARG GRADLE_VERSION=6.9.4
# RUN install-tool gradle

# renovate: datasource=gradle-version packageName=gradle versioning=gradle
ARG GRADLE_VERSION=7.6.6
RUN install-tool gradle
# Layer 16 (instruction #17): RUN |10 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2026-3505                                      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=gradle-version packageName=gradle versioning=gradle
ARG GRADLE_VERSION=9.3.1
RUN install-tool gradle
# Layer 17 (instruction #18): RUN |10 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2026-3505                                      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# renovate: datasource=gradle-version packageName=gradle versioning=gradle
ARG GRADLE_VERSION=8.14.4
RUN install-tool gradle
# Layer 18 (instruction #19): RUN |10 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬──────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                             │
# ├────────────┼────────────┼──────────────────────────────────────────────────────────────────┤
# │ High       │ 4          │ CVE-2026-3505, CVE-2026-54513, CVE-2025-67030, CVE-2026-54512    │
# └────────────┴────────────┴──────────────────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/golang-prebuild
#ARG GOLANG_VERSION=1.26.4
#RUN install-tool golang
# A temporary workaround, until it is fixed by renovate
#ENV GOSUMDB="sum.golang.org"

#USER ${USER_ID}
## Install package managers
#RUN go install github.com/tools/godep@latest && \
#    go install github.com/LK4D4/vndr@latest && \
#    go install  github.com/kardianos/govendor@latest

#All Deparacted/archived go package managers
# RUN go install  github.com/gpmgo/gopm@latest && \
#     go install  github.com/golang/dep/cmd/dep@latest && \
#     go install github.com/Masterminds/glide@latest && \
#     curl https://glide.sh/get | sh
#USER 0
#RUN chgrp -R 0 /go && chmod -R g=u /go

# renovate: datasource=maven packageName=org.apache.maven:maven
ARG MAVEN_VERSION=3.9.14
RUN install-tool maven
# Layer 19 (instruction #20): RUN |11 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2025-67030                                     │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=scala/scala
# ARG SCALA_VERSION=v2.13.16
# RUN install-tool scala

# renovate: datasource=github-releases packageName=sbt/sbt
# ARG SBT_VERSION=1.12.9
# RUN install-tool sbt

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.6.15
RUN install-tool python
# Layer 20 (instruction #21): RUN |12 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 3          │ CVE-2025-47273, CVE-2024-53899, CVE-2024-6345      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
# ARG PYTHON_VERSION=2.7.18
# RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.11.12
RUN install-tool python
# Layer 21 (instruction #22): RUN |12 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 2          │ CVE-2024-6345, CVE-2025-47273                      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.12.9
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.7.17
RUN install-tool python
# Layer 23 (instruction #24): RUN |12 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 2          │ CVE-2025-47273, CVE-2024-6345                      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.8.20
RUN install-tool python
# Layer 24 (instruction #25): RUN |12 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 2          │ CVE-2025-47273, CVE-2024-6345                      │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.13.1
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.9.25
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.10.20
RUN install-tool python

# renovate: datasource=pypi ; Must be installed after python and before python version 3.7.17
# ARG CHECKOV_VERSION=3.2.524
# RUN install-tool checkov
# Prevent scanned repos from injecting their own .checkov.yaml config (CVE: config injection via external-checks-dir/git)
# RUN mkdir -p /etc/checkov \
#     && printf 'output: json\ndownload-external-modules: "true"\n' > /etc/checkov/config.yaml \
#     && chmod 644 /etc/checkov/config.yaml

# renovate: datasource=github-releases packageName=containerbase/php-prebuild
# #ARG PHP_VERSION=8.5.5
# #RUN install-tool php

# renovate: datasource=github-releases packageName=containerbase/composer-prebuild
# #ARG COMPOSER_VERSION=2.9.7
# #RUN install-tool composer

# These are needed to get earlier dotnet versions to install in Ubuntu 24.04
# RUN curl -o /tmp/libssl1.1.deb https://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb && \
#     dpkg -i /tmp/libssl1.1.deb

# renovate: datasource=dotnet packageName=dotnet-sdk
#ARG DOTNET_VERSION=2.2.402
#RUN install-tool dotnet

# renovate: datasource=dotnet packageName=dotnet-sdk
#ARG DOTNET_VERSION=3.1.426
#RUN install-tool dotnet

# renovate: datasource=dotnet packageName=dotnet-sdk
#ARG DOTNET_VERSION=5.0.408
#RUN install-tool dotnet

# renovate: datasource=dotnet packageName=dotnet-sdk
#ARG DOTNET_VERSION=6.0.428
#RUN install-tool dotnet

# renovate: datasource=dotnet packageName=dotnet-sdk
ARG DOTNET_VERSION=8.0.417
RUN install-tool dotnet
# Layer 28 (instruction #29): RUN |13 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 12         │ CVE-2026-26171, CVE-2026-42899, CVE-2026-45591, CVE-2025-55247    │
# │            │            │ CVE-2025-26646, CVE-2025-55247, CVE-2025-26646, CVE-2025-55247    │
# │            │            │ CVE-2026-26171, CVE-2026-33116, CVE-2026-26130, CVE-2026-33116    │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────┘

ARG DOTNET_VERSION=9.0.310
RUN install-tool dotnet
# Layer 29 (instruction #30): RUN |13 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 5          │ CVE-2026-26130, CVE-2026-42899, CVE-2026-45591, CVE-2026-33116    │
# │            │            │ CVE-2026-26171                                                    │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────┘

# renovate: datasource=dotnet packageName=dotnet-sdk
ARG DOTNET_VERSION=7.0.410
RUN install-tool dotnet
# Layer 30 (instruction #31): RUN |13 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ Critical   │ 1          │ CVE-2024-0057                                                     │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 7          │ CVE-2025-26646, CVE-2024-38081, CVE-2024-38095, CVE-2024-30105    │
# │            │            │ CVE-2024-30105, CVE-2025-26646, CVE-2024-30105                    │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────┘

# Set .NET SDK 7.0.405 as the default version
RUN echo '{ "sdk": { "version": "7.0.410" } }' > ${USER_HOME}/global.json

# renovate: datasource=docker versioning=docker
#ARG RUST_VERSION=1.95.0
#RUN install-tool rust

# pip user install (so available for all python versions)
USER ${USER_ID}

# renovate: datasource=pypi
ARG PIPENV_VERSION=2026.5.2
RUN install-tool pipenv



USER 0

# renovate: datasource=pypi
#ARG UV_VERSION=0.11.7
#RUN install-tool uv

# renovate: datasource=pypi
ARG POETRY_VERSION=2.3.2
RUN install-tool poetry

# renovate: datasource=pypi
ARG POETRY_VERSION=1.6.1
RUN install-tool poetry
# Layer 34 (instruction #35): RUN |15 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2026-42305                                     │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

#ENV GEM_HOME=/tmp/containerbase/cache/.ruby
#ENV GEM_PATH="${GEM_HOME}"
# renovate: datasource=github-releases packageName=containerbase/ruby-prebuild versioning=ruby)
#ARG RUBY_VERSION=4.0.3
#RUN install-tool ruby && \
#    gem install rubygems-update -v 3.3.0 && \
#    gem update --system
#ENV PATH="${GEM_HOME}/bin:${PATH}"

# renovate: datasource=rubygems versioning=ruby
#ARG BUNDLER_VERSION=4.0.10
#RUN install-tool bundler

# renovate: datasource=pypi
#ARG CONAN_VERSION=2.27.1
#RUN install-tool conan

# #RUN install-tool erlang 28.4.2.0

# #RUN install-tool elixir 1.19.5

#### Install rbenv and ruby-build
### or maybe be saved to /etc/profile instead of /etc/profile.d/
#RUN git clone https://github.com/sstephenson/rbenv.git ${USER_HOME}/.rbenv; \
#	git clone https://github.com/sstephenson/ruby-build.git ${USER_HOME}/.rbenv/plugins/ruby-build; \
#	${USER_HOME}/.rbenv/plugins/ruby-build/install.sh && \
#	echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
#	echo 'eval "$(rbenv init -)"' >> ${USER_HOME}/.bashrc && \
#	chown -R ${USER_NAME}:${GROUP_NAME} ${USER_HOME}/.rbenv ${USER_HOME}/.bashrc
#ENV PATH ${USER_HOME}/.rbenv/bin:$PATH

# renovate: datasource=rubygems versioning=ruby
# ARG COCOAPODS_VERSION=1.16.2
# RUN install-tool cocoapods && \
#     adduser cocoapods
# USER cocoapods
# RUN pod setup
# USER 0

# renovate: datasource=github-releases packageName=helm/helm
# #ARG HELM_VERSION=4.1.4
# #RUN install-tool helm

## No renovate datasource exists yet
ARG HASKELL_GHC_VERSION=8.6.5

## No renovate datasource exists yet
ARG CABAL_VERSION=3.2

# Fix for npm engine-strict
ENV npm_config_engine_strict=false

ENV DEBIAN_FRONTEND noninteractive
ENV LANGUAGE	en_US.UTF-8
ENV LANG    	en_US.UTF-8
ENV LC_ALL  	en_US.UTF-8

### Install wget, curl, git, unzip, gnupg, locales
RUN apt-get update && \
	apt-get -y install wget curl git unzip gnupg locales && \
	locale-gen en_US.UTF-8 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/*
# Layer 35 (instruction #36): RUN |17 USER_NAME=wss-scanner USER_ID=1000 USER_HOME=/home/wss-scanner APT_HTTP_
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ Critical   │ 11         │ CVE-2026-45988, CVE-2026-43185, CVE-2026-43011, CVE-2026-31402    │
# │            │            │ CVE-2026-43304, CVE-2026-46043, CVE-2026-43037, CVE-2026-43038    │
# │            │            │ CVE-2026-46135, CVE-2026-43501, CVE-2026-31637                    │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 45         │ CVE-2026-46304, CVE-2025-54518, CVE-2026-46320, CVE-2026-46273    │
# │            │            │ CVE-2026-46185, CVE-2025-71315, CVE-2026-31413, CVE-2026-43186    │
# │            │            │ CVE-2026-43341, CVE-2026-43083, CVE-2026-43407, CVE-2026-45972    │
# │            │            │ CVE-2026-46119, CVE-2026-46195, CVE-2026-46259, CVE-2026-46274    │
# │            │            │ CVE-2026-46275, CVE-2026-46330, CVE-2026-46319, CVE-2026-31669    │
# │            │            │ CVE-2026-31705, CVE-2026-43493, CVE-2026-31536, CVE-2026-31478    │
# │            │            │ CVE-2026-31414, CVE-2026-31436, CVE-2026-31607, CVE-2026-31657    │
# │            │            │ CVE-2026-23455, CVE-2026-23428, CVE-2026-23240, CVE-2025-40190    │
# │            │            │ CVE-2026-43198, CVE-2026-43378, CVE-2026-43406, CVE-2026-23450    │
# │            │            │ CVE-2026-31405, CVE-2026-31659, CVE-2026-43084, CVE-2025-40190    │
# │            │            │ CVE-2026-23450, CVE-2026-31405, CVE-2026-43198, CVE-2026-31659    │
# │            │            │ CVE-2025-54518                                                    │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────┘


##### Install Conda
## Warning: Using Anaconda's default channel may require a commercial license.
## However, the conda-forge channel is not subject to the same terms. See commented
## out settings below for an example of using conda-forge.
#
# Set conda-forge to be the default registry
# conda config --add channels conda-forge
# Use conda-forge strictly
# conda config --set channel_priority strict
#
#RUN  su -p ${USER_NAME} -c "cd ${USER_HOME} && \
#        mkdir -p ${USER_HOME}/miniconda3 && \
#        wget https://repo.anaconda.com/miniconda/Miniconda3-py39_24.1.2-0-Linux-x86_64.sh -O ${USER_HOME}/miniconda3/miniconda.sh && \
#        bash ${USER_HOME}/miniconda3/miniconda.sh -b -u -p ${USER_HOME}/miniconda3 && \
#        rm -rf ${USER_HOME}/miniconda3/miniconda.sh" && \
#        chgrp -R 0 ${USER_HOME}/miniconda3 && \
#        chmod -R g=u ${USER_HOME}/miniconda3
#
#RUN echo '#!/usr/bin/env bash' >> /usr/bin/conda && \
#        echo 'source ${USER_HOME}/miniconda3/etc/profile.d/conda.sh' >> /usr/bin/conda && \
#        echo '${USER_HOME}/miniconda3/bin/conda "$@"' >> /usr/bin/conda && \
#        chmod +x /usr/bin/conda


#### Important note ###
#### uncomment for:
####    Scala
####    SBT
####    Mix/ Hex/ Erlang/ Elixir
####    dotnet/nuget cli's
#RUN apt-get update && \
#	apt-get install -y --force-yes build-essential software-properties-common && \
#	apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* && \
#	rm -rf /tmp/*

### Install PHP Plugins
#RUN apt-get update && \
#	apt-get install -y php-mbstring && \
#	apt-get install -y php-dom && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* && \
#	rm -rf /tmp/*


#### Install R and Packrat
# Set environment variables to avoid interactive prompts
#ENV DEBIAN_FRONTEND=noninteractive
#ENV TZ=UTC
## Update system and install dependencies
#RUN apt-get update && apt-get install -y \
#    software-properties-common \
#    dirmngr \
#    lsb-release \
#    build-essential \
#    gfortran \
#    libcurl4-openssl-dev \
#    libssl-dev \
#    libxml2-dev \
#    libfontconfig1-dev \
#    libharfbuzz-dev \
#    libfribidi-dev \
#    libfreetype6-dev \
#    libpng-dev \
#    libtiff5-dev \
#    libjpeg-dev \
#    git \
#    && rm -rf /var/lib/apt/lists/*
## Add CRAN repository and install R
#RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /usr/share/keyrings/r-project.gpg && \
#    echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" | tee -a /etc/apt/sources.list.d/r-project.list && \
#    apt-get update && \
#    apt-get install -y r-base r-base-dev && \
#    rm -rf /var/lib/apt/lists/*
## Install devtools and packrat from R
#RUN R -e "install.packages(c('devtools', 'packrat'), repos='https://cloud.r-project.org/')"


#### Install Cabal
#RUN apt-get update &&\
#	apt-get install -y build-essential curl libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* && \
#	rm -rf /tmp/*
#
#RUN su -p ${USER_NAME} -c "curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh && \
#	source /home/wss-scanner/.ghcup/env && \
#	echo "source /home/wss-scanner/.ghcup/env" >> /home/wss-scanner/.bashrc && \
#	ghcup install cabal ${CABAL_VERSION} &&\
#	cabal update" && \
#   chgrp -R 0 ${USER_HOME}/.cabal ${USER_HOME}/.ghcup && \
#   chmod -R g=u ${USER_HOME}/.cabal ${USER_HOME}/.ghcup

#### Install Mono
#RUN apt-get update && \
#    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
#    apt-get install -y --no-install-recommends apt-transport-https ca-certificates && \
#    echo "deb https://download.mono-project.com/repo/ubuntu bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
#    apt-get update && \
#    apt-get install -y mono-devel && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -rf /tmp/*
#
#### Install Nuget CLI
#RUN apt-get update && \
# #    apt-get install nuget

## Install Paket
#ENV PAKET_HOME=${USER_HOME}/.dotnet/tools
#ENV PATH="${PATH}:${PAKET_HOME}"
#RUN dotnet tool install Paket --version 7.2.1 --tool-path ${PAKET_HOME}

## Install Bazel
# renovate: datasource=github-releases packageName=bazelbuild/bazelisk
# #ARG BAZELISK_VERSION=v1.28.1
# #RUN install-tool bazelisk

# Pre-download Bazel 6.1.1 to cache it in the image
# #RUN USE_BAZEL_VERSION=6.1.1 bazel version

# Set Bazel 6.1.1 as the default version
# #ENV USE_BAZEL_VERSION=6.1.1

# Install Swift (including SPM)
# renovate: datasource=docker versioning=docker
#ARG SWIFT_VERSION=6.0.3
#RUN install-tool swift

# delete the partially populated directory /tmp/containerbase and recreate one with full content instead
# RUN rm -rf /tmp/* && containerbase-cli init tool all

# END OF BASE IMAGE


# Temporarily copying the current Dockerfile and the version scanner script to generate the installed-versions.json file.
COPY generate_versions_json.sh /usr/local/bin/generate_versions_json.sh
ARG THIS_DOCKERFILE_NAME=repo-integrations/scanner/Dockerfile
COPY ${THIS_DOCKERFILE_NAME} /tmp/target-dockerfile
RUN chmod +x /usr/local/bin/generate_versions_json.sh \
  && mkdir "${USER_HOME}/.mend" \
  && /usr/local/bin/generate_versions_json.sh /tmp/target-dockerfile \
     > "${USER_HOME}/.mend/installed-versions.json" \
  && rm /tmp/target-dockerfile && rm /usr/local/bin/generate_versions_json.sh 
