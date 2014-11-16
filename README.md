Android Open Source Project Docker Build Environment
====================================================

The goal of this Docker image is to maintain a minimal build environment for
AOSP.

Developers can use the Docker image to build directly while running the
distribution of choice, without having to worry about breaking the AOSP build
due to package updates as is sometimes common on rolling distributions like
Arch Linux.

Production build servers and integration test servers should also use the same
Docker image and environment. This eliminate most surprises in breakages by
by empowering developers and production builds to use the exact same
environment.  The hope is that breakages will be caught earlier by the devs.


How it Works
------------

The Dockerfile contains the minimal packages necessary to build Android based
on the main Ubuntu base image.

The `aosp` wrapper is a simple wrapper to simplify invocation of the Docker
image.  The wrapper ensures that a volume mount is accessible and has valid
permissions for the `aosp` user in the Docker image (this unfortunately
requires sudo).  It also forwards an ssh-agent in to the Docker container
so that private git repositories can be accessed if needed.

The intention is to use `aosp` to prefix all commands one would run in the
Docker container.  For example to run `repo sync` in the Docker container:

    aosp repo sync -j2

The `aosp` wrapper doesn't work well with setting up environments, but with
some bash magic, this can be side stepped with short little scripts.  See
`tests/build-kitkat.sh` for an example of a complete fetch and build of AOSP.


Tested
------

* Android Kitkat `android-4.4.4_r2.0.1`
