#!/bin/bash
set -e

# This script designed to be used a docker ENTRYPOINT "workaround" missing docker
# feature discussed in docker/docker#7198, allow to have executable in the docker
# container manipulating files in the shared volume owned by the USER_ID:GROUP_ID.
#
# It creates a user named `aosp` with selected USER_ID and GROUP_ID (or
# 1000 if not specified).

# Example:
#
#  docker run -ti -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) imagename bash
#

# Reasonable defaults if no USER_ID/GROUP_ID environment variables are set.
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# ccache
export CCACHE_DIR=/tmp/ccache
export USE_CCACHE=1

msg="docker_entrypoint: Creating user UID/GID [$USER_ID/$GROUP_ID]" && echo $msg
groupadd -g $GROUP_ID -r aosp ; useradd -u $USER_ID -r -g aosp aosp
echo "$msg - done"
echo ""

msg="Changing ownership of /home/aosp (creating if non-existent)" && echo $msg
mkdir /home/aosp
chown -R aosp:aosp /home/aosp
echo "$msg - done"
echo ""

msg="docker_entrypoint: Creating /tmp/ccache and /aosp directory" && echo $msg
mkdir -p /tmp/ccache /aosp
chown aosp:aosp /tmp/ccache /aosp
echo "$msg - done"
echo ""

msg="docker_entrypoint: Creating ssh and git config (if needed)" && echo $msg
mkdir -p /home/aosp/.ssh
cp -n /root/.gitconfig /home/aosp/ # no clobber (do not copy if file exists)
cp -n /root/.ssh/config /home/aosp/.ssh/ # no clobber (do not copy if file exists)
echo "$msg - done"

msg="docker_entrypoint: Changing ownership of gitconfig and .ssh/config..." && echo $msg
chown -R aosp:aosp /home/aosp/.gitconfig /home/aosp/.ssh/
echo "$msg - done"
echo ""

# Default to 'bash' if no arguments are provided
args="$@"

# Execute command as `aosp` user
exec gosu aosp ${args:-"bash"}
