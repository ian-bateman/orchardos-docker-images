# Gentoo and OrchardOS Docker Images

A collection of Dockerfiles for generating docker images.

This repository includes Orchard and basic stage3 images, and an
image usable as a `/usr/portage` volume

# DockerHub

The upstream Gentoo images are on DockerHub:

https://hub.docker.com/u/gentoo/

## Inventory

* orchard (current orchardos release, orchardos-``<arch>``-musl-hardened)
  * orchard-amd64
  * orchard-x86
* stage4 (bluedragon, desktop-amd64-musl-hardened)
  * stage4-amd64
* portage (latest portage snapshot)
* stage3
  * stage3-amd64
    * stage3-amd64-hardened
    * stage3-amd64-nomultilib
    * stage3-amd64-hardened-nomultilib
  * stage3-x86
    * stage3-x86-hardened

# Building the containers

The containers are created using a multi-stage build, which requires docker-17.05.0 or later.
The container being built is defined by the TARGET environment variable:

`` TARGET=orchardos-amd64 ./build.sh ``

where TARGET=``<dockerfile-no-ext>-<arch>``

Note the ORG variable is used in both docker commands in build.sh so in	order
to build the Gentoo/GRS	images you need	to pass	ORG=gentoo like so:

`` ORG=gentoo TARGET=stage4-amd64 ./build.sh ``

The build.sh script is just a wrapper to provide some default variables and
allow both amd64 and i686 arches from upstream (initial testing has been
with amd64 but should also work with x86/i686).

To bypass the build.sh script, you might use a command something like this:

`` docker build --build-arg ARCH="amd64" --build-arg VERSION="20180304" --build-arg MICROARCH="amd64" --build-arg BOOTSTRAP="multiarch/alpine:x86-v3.7"  -t "orchard/orchardos-amd64:20180304" -f orchardos.Dockerfile . ``

# Using login credentials for releases.orchardos.com

Note: if you don't have the .netrc file in your working directory then
building the orchardos.Dockerfile will fail to download the tarball.
Make a copy and hack away if you don't like this one.

The normal upstream URIs do not require authentication for downloading the
files, but with orchardos releases we require login credentials.  Although
it works passing --user and --password on the commandline to wget, a slightly
better way is to create a .netrc file in the working directory with proper
login ID and hostname with this format:

`` machine releases.orchardos.com login <orchard-username> password <orchard-password> ``

The docker build environment is docker-ized (of course) but it starts by looking
in the current directory (ie, where the docker file lives) and will copy the
.netrc file into the docker /root directory.

# Running the orchard/stage3 container

See the docs wiki page for examples:

https://github.com/teamorchard/docs/wiki/docker-build

# Using the portage container as a data volume

```
docker create -v /usr/portage --name myportagesnapshot gentoo/portage:latest /bin/true
docker run --volumes-from myportagesnapshot gentoo/stage3-amd64:latest /bin/bash
```

# Using the portage container in a multi-stage build

docker-17.05.0 or later supports multi-stage builds, allowing the portage volume to be used when creating images based on a stage3 image.

Example _Dockerfile_

```
# name the portage image
FROM gentoo/portage:latest as portage

# image is based on stage3-amd64
FROM gentoo/stage3-amd64:latest

# copy the entire portage volume in
COPY --from=portage /usr/portage /usr/portage

# continue with image build ...
RUN emerge -qv www-servers/apache # or whichever packages you need
```


# Contributing

We'd love to hear any ideas.  Feel free to contact us via any of the following
methods:

* IRC: irc://freenode.net/#gentoo-containers
* EMAIL: gentoo-containers@lists.gentoo.org
* GITHUB: https://github.com/gentoo/gentoo-docker-images

## Policy

* Use topic branches (i.e. foo) and fix branches (i.e. fix/foo) when submitting
  pull requests
* Make meaningful commits ideally with the following form:
  * Subject line–what this commit does
  * Blank line
  * Body–why this commit is necessary or desired
* Pull requests should not include merge commits
* Use amend and rebase to fix commits after a pull request has been submitted
