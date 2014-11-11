#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER Kyle Manna <kyle@kylemanna.com>

# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop openjdk-6-jdk \
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# All builds will be done by user aosp
RUN useradd --create-home aosp

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME /tmp/ccache
VOLUME /aosp

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE /tmp/ccache

# Work in the build directory, repo is expected to be init'd here
USER aosp
WORKDIR /aosp
