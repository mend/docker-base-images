# This default may be swapped for any compatible base image
ARG BASE_IMAGE=ubuntu:24.04

# Containerbase is used for tool installation and user/directory setup
FROM ghcr.io/containerbase/base:14.68.3@sha256:17fce5cf4bfeacbaaa4476409b407899679663b929c7d1c9cf6bbda8b72a8138 AS containerbase


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
ARG GIT_VERSION=v2.56.1
RUN install-tool git

# install git lfs
# renovate: datasource=github-releases packageName=git-lfs/git-lfs
#ARG GIT_LFS_VERSION=v3.8.1
#RUN install-tool git-lfs

# renovate: datasource=github-releases packageName=containerbase/node-prebuild versioning=node
ARG NODE_VERSION=24.22.3
RUN install-tool node
# instruction #8: install-tool node
# ┌────────────┬────────────┬─────────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                                │
# ├────────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
# │ Critical   │ 1          │ CVE-2026-109383                                                     │
# ├────────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
# │ High       │ 7          │ CVE-2026-19534, CVE-2026-87018, CVE-2026-102278, CVE-2026-102276    │
# │            │            │ CVE-2026-109932, CVE-2026-109924, CVE-2026-109869                   │
# └────────────┴────────────┴─────────────────────────────────────────────────────────────────────┘

# renovate: datasource=npm versioning=npm
ARG NPM_VERSION=11.21.2
RUN install-tool npm

# renovate: datasource=npm packageName=@yarnpkg/cli-dist
ARG YARN_VERSION=1.22.22
RUN install-tool yarn

# renovate: datasource=npm
# ARG BOWER_VERSION=1.8.14
RUN install-npm bower
# instruction #11: install-npm bower
# ┌────────────┬────────────┬─────────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                                │
# ├────────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
# │ Critical   │ 13         │ CVE-2021-3918, CVE-2021-23807, CVE-2026-106446, CVE-2026-9277       │
# │            │            │ CVE-2019-10744, CVE-2023-26136, CVE-2026-106445, CVE-2026-33937     │
# │            │            │ CVE-2026-4800, CVE-2021-23369, CVE-2025-7783, CVE-2021-44906        │
# │            │            │ CVE-2021-23383                                                      │
# ├────────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
# │ High       │ 37         │ CVE-2018-3728, CVE-2026-26996, CVE-2026-27903, CVE-2026-27904       │
# │            │            │ CVE-2022-3517, CVE-2016-10540, CVE-2026-69152, CVE-2020-8116        │
# │            │            │ CVE-2021-23337, CVE-2020-8203, CVE-2021-23343, CVE-2026-12143       │
# │            │            │ CVE-2026-14257, CVE-2026-13149, CVE-2026-102276, CVE-2026-102278    │
# │            │            │ CVE-2026-33750, CVE-2020-36604, CVE-2015-8855, CVE-2022-25883       │
# │            │            │ CVE-2026-41907, CVE-2017-15010, CVE-2025-48387, CVE-2025-59343      │
# │            │            │ CVE-2024-12905, CVE-2022-24999, CVE-2017-1000048, CVE-2020-7792     │
# │            │            │ CVE-2022-21213, CVE-2026-33939, CVE-2026-33938, CVE-2026-33940      │
# │            │            │ CVE-2026-33941, CVE-2026-13311, CVE-2021-43138, CVE-2026-44705      │
# │            │            │ CVE-2022-29167                                                      │
# └────────────┴────────────┴─────────────────────────────────────────────────────────────────────┘

# renovate: datasource=npm
#ARG PNPM_VERSION=10.34.9
#RUN install-tool pnpm

# renovate: datasource=npm
#ARG BUN_VERSION=1.4.4
#RUN install-tool bun

### provide permissions
# RUN echo '{ "allow_root": true }' > ${USER_HOME}/.bowerrc && \
# 	chown -R ${USER_NAME}:${GROUP_NAME} ${USER_HOME}/.bowerrc

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=8.0.512+9
RUN install-tool java

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=11.0.33+10
RUN install-tool java

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=21.0.13+100000002.0.LTS
RUN install-tool java

# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=25.0.5+100000002.0.LTS
RUN install-tool java

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# java_default
# renovate: datasource=java-version packageName=java-jre
ARG JAVA_VERSION=17.0.21+100000002
RUN install-tool java
ENV MEND_JAVA=/usr/local/bin/mend_java
RUN ln -sf /opt/containerbase/tools/java/$JAVA_VERSION/bin/java $MEND_JAVA && \
    chmod +x $MEND_JAVA

# renovate: ignore
RUN install-tool android-sdk-cmdline-tools 20
# instruction #18: install-tool android-sdk-cmdline-tools 20
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ Critical   │ 2          │ CVE-2026-8763, CVE-2025-14813                                     │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 9          │ CVE-2026-102554, CVE-2026-13506, CVE-2022-3171, CVE-2024-7254     │
# │            │            │ CVE-2026-77422, CVE-2026-77423, CVE-2026-56741, CVE-2026-56740    │
# │            │            │ CVE-2026-5598                                                     │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────┘

# Do not install as root
USER ${USER_ID}

# fail build on failure
RUN yes | sdkmanager --licenses && \
    sdkmanager "platforms;android-35"

# back to root user
USER 0

# renovate: datasource=gradle-version packageName=gradle versioning=gradle
ARG GRADLE_VERSION=9.9.1
RUN install-tool gradle
# instruction #20: install-tool gradle
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2026-102554                                    │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# gradle_default
# renovate: datasource=gradle-version packageName=gradle versioning=gradle
ARG GRADLE_VERSION=8.14.7
RUN install-tool gradle

# renovate: datasource=github-releases packageName=containerbase/golang-prebuild
#ARG GOLANG_VERSION=1.27.4
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
ARG MAVEN_VERSION=3.9.16
RUN install-tool maven
# instruction #22: install-tool maven
# ┌────────────┬────────────┬────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                               │
# ├────────────┼────────────┼────────────────────────────────────────────────────┤
# │ High       │ 1          │ CVE-2026-102554                                    │
# └────────────┴────────────┴────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=scala/scala
# ARG SCALA_VERSION=v2.13.18
# RUN install-tool scala

# renovate: datasource=github-releases packageName=sbt/sbt
# ARG SBT_VERSION=1.13.1
# RUN install-tool sbt

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.6.15
RUN install-tool python
# instruction #23: install-tool python
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                                  │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────────┤
# │ High       │ 18         │ CVE-2026-113722, CVE-2024-6345, CVE-2026-113732, CVE-2024-53899       │
# │            │            │ CVE-2026-113720, CVE-2026-102925, CVE-2026-102937, CVE-2026-113718    │
# │            │            │ CVE-2026-113717, CVE-2026-136440, CVE-2026-113715, CVE-2026-113726    │
# │            │            │ CVE-2026-102930, CVE-2026-113714, CVE-2026-113725, CVE-2025-47273     │
# │            │            │ CVE-2026-113723, CVE-2026-113776                                      │
# └────────────┴────────────┴───────────────────────────────────────────────────────────────────────┘

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
# ARG PYTHON_VERSION=2.7.18
# RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.11.18
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.12.16
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.7.17
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.8.20
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.13.18
RUN install-tool python

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.9.25
RUN install-tool python

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# python_default
# renovate: datasource=github-releases packageName=containerbase/python-prebuild
ARG PYTHON_VERSION=3.10.22
RUN install-tool python

# renovate: datasource=pypi ; Must be installed after python and before python version 3.7.17
# ARG CHECKOV_VERSION=3.4.5
# RUN install-tool checkov
# Prevent scanned repos from injecting their own .checkov.yaml config (CVE: config injection via external-checks-dir/git)
# RUN mkdir -p /etc/checkov \
#     && printf 'output: json\ndownload-external-modules: "true"\n' > /etc/checkov/config.yaml \
#     && chmod 644 /etc/checkov/config.yaml

# renovate: datasource=github-releases packageName=containerbase/php-prebuild
# #ARG PHP_VERSION=8.5.12
# #RUN install-tool php

# renovate: datasource=github-releases packageName=containerbase/composer-prebuild
# #ARG COMPOSER_VERSION=2.11.2
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

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# dotnet_default
# renovate: datasource=dotnet packageName=dotnet-sdk
#ARG DOTNET_VERSION=6.0.428
#RUN install-tool dotnet

# renovate: datasource=dotnet packageName=dotnet-sdk
ARG DOTNET_VERSION=8.0.428
RUN install-tool dotnet
# instruction #31: install-tool dotnet
# ┌────────────┬────────────┬────────────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                                   │
# ├────────────┼────────────┼────────────────────────────────────────────────────────────────────────┤
# │ Critical   │ 4          │ CVE-2026-47304, CVE-2026-70188, CVE-2026-88092, CVE-2024-0057          │
# ├────────────┼────────────┼────────────────────────────────────────────────────────────────────────┤
# │ High       │ 28         │ CVE-2026-84008, CVE-2025-26646, CVE-2026-50648, CVE-2026-96958         │
# │            │            │ CVE-2026-47302, CVE-2026-96959, CVE-2026-50525, CVE-2026-96960         │
# │            │            │ CVE-2026-96222, CVE-2026-50527, CVE-2026-96233, CVE-2026-58280         │
# │            │            │ CVE-2026-96225, GHSA-p3jp-9v83-76w9, CVE-2026-70175, CVE-2026-70186    │
# │            │            │ CVE-2026-114149, CVE-2026-70181, CVE-2026-114147, CVE-2026-70183       │
# │            │            │ CVE-2026-114146, CVE-2026-96236, CVE-2026-70159, CVE-2026-96231        │
# │            │            │ CVE-2026-69651, CVE-2024-38081, CVE-2024-38095, CVE-2024-30105         │
# └────────────┴────────────┴────────────────────────────────────────────────────────────────────────┘

# renovate: datasource=dotnet packageName=dotnet-sdk
ARG DOTNET_VERSION=9.0.318
RUN install-tool dotnet

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# dotnet_default
# renovate: datasource=dotnet packageName=dotnet-sdk
ARG DOTNET_VERSION=7.0.410
RUN install-tool dotnet

# Set the default .NET SDK to the last-installed DOTNET_VERSION (keeps global.json in sync on updates)
RUN echo '{ "sdk": { "version": "${DOTNET_VERSION}" } }' > ${USER_HOME}/global.json

# renovate: datasource=docker versioning=docker
#ARG RUST_VERSION=1.100.0
#RUN install-tool rust

# pipenv is installed as root, like the other pip tools (checkov, uv, poetry). Since virtualenv 21.15.12
# (read-only seed images in app-data) a non-root install-tool fails during docker build with EACCES.
# containerbase still gives the scanner user ownership of the tool dirs, so runtime installs keep working. SCA-9073

# renovate: datasource=pypi
ARG PIPENV_VERSION=2026.10.4
RUN install-tool pipenv



# renovate: datasource=pypi
#ARG UV_VERSION=0.13.8
#RUN install-tool uv

# renovate: datasource=pypi
ARG POETRY_VERSION=2.5.1
RUN install-tool poetry
# instruction #36: install-tool poetry
# ┌────────────┬────────────┬──────────────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                                     │
# ├────────────┼────────────┼──────────────────────────────────────────────────────────────────────────┤
# │ High       │ 18         │ CVE-2026-112940, CVE-2026-42305, GHSA-8mcx-5rqc-vhmf, CVE-2026-102925    │
# │            │            │ CVE-2026-102937, CVE-2026-102930, CVE-2026-113714, CVE-2026-113725       │
# │            │            │ CVE-2026-113723, CVE-2026-113722, CVE-2026-113732, CVE-2026-113776       │
# │            │            │ CVE-2026-113720, CVE-2026-113718, CVE-2026-113717, CVE-2026-113715       │
# │            │            │ CVE-2026-113726, CVE-2026-136440                                         │
# └────────────┴────────────┴──────────────────────────────────────────────────────────────────────────┘

### !!! PAY ATTENTION! The version that should be the default, must be installed last !!! ###
# poetry_default
# renovate: datasource=pypi
ARG POETRY_VERSION=1.8.5
RUN install-tool poetry

#ENV GEM_HOME=/tmp/containerbase/cache/.ruby
#ENV GEM_PATH="${GEM_HOME}"
# renovate: datasource=github-releases packageName=containerbase/ruby-prebuild versioning=ruby)
#ARG RUBY_VERSION=4.0.9
#RUN install-tool ruby && \
#    gem install rubygems-update -v 3.3.0 && \
#    gem update --system
#ENV PATH="${GEM_HOME}/bin:${PATH}"

# renovate: datasource=rubygems versioning=ruby
#ARG BUNDLER_VERSION=4.0.24
#RUN install-tool bundler

# renovate: datasource=pypi
#ARG CONAN_VERSION=2.34.0
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
# ARG COCOAPODS_VERSION=1.17.0
# RUN install-tool cocoapods && \
#     adduser cocoapods
# USER cocoapods
# RUN pod setup
# USER 0

# renovate: datasource=github-releases packageName=helm/helm
# #ARG HELM_VERSION=4.3.2
# #RUN install-tool helm

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
# instruction #38: apt-get update && apt-get -y install wget curl git unzip gnupg locales && locale
# ┌────────────┬────────────┬───────────────────────────────────────────────────────────────────┐
# │ Severity   │ Count      │ CVEs                                                              │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ Critical   │ 13         │ CVE-2026-99344, CVE-2026-99441, CVE-2026-99310, CVE-2026-99362    │
# │            │            │ CVE-2026-99366, CVE-2026-99590, CVE-2026-99676, CVE-2026-99540    │
# │            │            │ CVE-2026-99343, CVE-2026-99355, CVE-2026-99287, CVE-2026-99460    │
# │            │            │ CVE-2026-99306                                                    │
# ├────────────┼────────────┼───────────────────────────────────────────────────────────────────┤
# │ High       │ 106        │ CVE-2026-99345, CVE-2025-40190, CVE-2026-99468, CVE-2026-99352    │
# │            │            │ CVE-2026-99599, CVE-2026-99473, CVE-2026-99583, CVE-2026-99380    │
# │            │            │ CVE-2026-99260, CVE-2026-90317, CVE-2026-99357, CVE-2026-99356    │
# │            │            │ CVE-2026-99477, CVE-2026-99489, CVE-2026-99239, CVE-2026-99274    │
# │            │            │ CVE-2026-99361, CVE-2026-99386, CVE-2026-99395, CVE-2026-99369    │
# │            │            │ CVE-2026-99275, CVE-2026-64052, CVE-2026-99295, CVE-2026-90237    │
# │            │            │ CVE-2026-99396, CVE-2026-99284, CVE-2026-99389, CVE-2026-99388    │
# │            │            │ CVE-2026-99272, CVE-2026-99270, CVE-2026-99377, CVE-2026-99384    │
# │            │            │ CVE-2026-99383, CVE-2026-99484, CVE-2026-99292, CVE-2026-43379    │
# │            │            │ CVE-2022-50240, CVE-2026-99320, CVE-2024-46742, CVE-2026-99690    │
# │            │            │ CVE-2026-99312, CVE-2026-99554, CVE-2026-99678, CVE-2026-98589    │
# │            │            │ CVE-2026-99672, CVE-2026-99792, CVE-2026-99311, CVE-2026-68103    │
# │            │            │ CVE-2026-64078, CVE-2026-90380, CVE-2024-58100, CVE-2026-99109    │
# │            │            │ CVE-2026-89675, CVE-2025-40344, CVE-2026-99350, CVE-2026-99288    │
# │            │            │ CVE-2026-99282, CVE-2026-99575, CVE-2026-99574, CVE-2026-80725    │
# │            │            │ CVE-2024-56591, CVE-2026-99794, CVE-2025-40025, CVE-2026-98333    │
# │            │            │ CVE-2026-99423, CVE-2026-99544, CVE-2026-99425, CVE-2026-99546    │
# │            │            │ CVE-2026-99661, CVE-2026-99429, CVE-2026-89637, CVE-2026-99775    │
# │            │            │ CVE-2026-99531, CVE-2026-99773, CVE-2026-99539, CVE-2026-99659    │
# │            │            │ CVE-2026-99760, CVE-2026-99762, CVE-2026-98799, CVE-2026-99526    │
# │            │            │ CVE-2025-40274, CVE-2026-99753, CVE-2026-99755, CVE-2026-99754    │
# │            │            │ CVE-2026-99675, CVE-2026-99744, CVE-2026-98364, CVE-2026-99565    │
# │            │            │ CVE-2026-98599, CVE-2026-99688, CVE-2026-72198, CVE-2026-99435    │
# │            │            │ CVE-2026-99556, CVE-2026-99432, CVE-2024-35948, CVE-2026-99573    │
# │            │            │ CVE-2026-99424, CVE-2026-31536, CVE-2026-98332, CVE-2026-99657    │
# │            │            │ CVE-2026-99549, CVE-2026-99522, CVE-2026-99400, CVE-2026-99761    │
# │            │            │ CVE-2026-99528, CVE-2026-98439                                    │
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


#### Install GHC and Cabal
#RUN apt-get update &&\
#	apt-get install -y build-essential curl libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev && \
#	apt-get clean && \
#	rm -rf /var/lib/apt/lists/* && \
#	rm -rf /tmp/*
#
# renovate: datasource=docker packageName=haskell
#ARG GHC_VERSION=9.14.1
#RUN install-tool ghc
#
# Cabal 3.2 has no static linux-deb10 build that install-tool could use
# renovate: datasource=github-releases packageName=haskell/cabal versioning=docker
#ARG CABAL_VERSION=3.16.1.0
#RUN install-tool cabal

#### Install Mono
# renovate: datasource=github-releases packageName=containerbase/mono-prebuild
#ARG MONO_VERSION=6.14.1
#RUN install-tool mono
#
#### Install NuGet CLI (nuget.exe run via mono)
# Must be >= 6.8: nuget.exe 6.4-6.7 crashes on a dangling ~/.local (SCA-8042)
# renovate: datasource=nuget packageName=NuGet.CommandLine
#ARG NUGET_VERSION=7.9.0
#RUN install-tool nuget

## Install Paket
# renovate: datasource=nuget packageName=Paket
#ARG PAKET_VERSION=7.2.1
#RUN install-tool paket

## Install Bazel
# renovate: datasource=github-releases packageName=bazelbuild/bazelisk
# #ARG BAZELISK_VERSION=v1.30.0
# #RUN install-tool bazelisk

# Pre-download Bazel 6.1.1 to cache it in the image
# #RUN USE_BAZEL_VERSION=6.1.1 bazel version

# Set Bazel 6.1.1 as the default version
# #ENV USE_BAZEL_VERSION=6.1.1

# Install Swift (including SPM)
# renovate: datasource=docker versioning=docker
#ARG SWIFT_VERSION=6.4.2
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
