#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER Kyle Manna <kyle@kylemanna.com>

# Setup for Java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
        >> /etc/apt/sources.list.d/webupd8.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

# http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html
# Java 6 is no longer supported by Oracle. The binaries are no longer available for download, but if you have an Oracle account, you can still download it after logging in.
#  The Oracle Java 6 installer in this article will continue to work only if you manually download Oracle JDK 6 (version 6u45), place it in the /var/cache/oracle-jdk6-installer/ folder on your computer, then install "oracle-java6-installer" as explained below in this article.
# http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html
# http://download.oracle.com/otn/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin
COPY utils/jdk-6u45-linux-x64.bin /var/cache/oracle-jdk6-installer/

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop \
        oracle-java6-installer oracle-java6-set-default \
        pngcrush schedtool xsltproc zip zlib1g-dev graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# All builds will be done by user aosp
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /aosp

COPY utils/docker_entrypoint.sh /root/docker_entrypoint.sh
ENTRYPOINT ["/root/docker_entrypoint.sh"]
