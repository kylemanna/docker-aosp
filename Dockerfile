#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER Kyle Manna <kyle@kylemanna.com>

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# Keep the dependency list as short as reasonable
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \ 
    apt-get install -y bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop \
        openjdk-7-jdk \
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
WORKDIR /tmp
RUN curl -O http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre-headless_8u45-b14-1_amd64.deb && \
    curl -O http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre_8u45-b14-1_amd64.deb && \
    curl -O http://old-releases.ubuntu.com/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jdk_8u45-b14-1_amd64.deb && \
    sum=`sha256sum ./openjdk-8-jre-headless_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
    [ $sum == "0f5aba8db39088283b51e00054813063173a4d8809f70033976f83e214ab56c0" ] || \
      ( echo "Hash mismatch. Problem downloading openjdk-8-jre-headless" ; exit 1; ) && \
    sum=`sha256sum ./openjdk-8-jre_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
    [ $sum == "9ef76c4562d39432b69baf6c18f199707c5c56a5b4566847df908b7d74e15849" ] || \
      ( echo "Hash mismatch. Problem downloading openjdk-8-jre" ; exit 1; ) && \
    sum=`sha256sum ./openjdk-8-jdk_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
    [ $sum == "6e47215cf6205aa829e6a0a64985075bd29d1f428a4006a80c9db371c2fc3c4c" ] || \
      ( echo "Hash mismatch. Problem downloading openjdk-8-jdk" ; exit 1; ) && \
    dpkg -i *.deb && \
    apt-get -f install && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
