#!/bin/bash

# Used to create Gentoo stage3 and portage containers simply by specifying a
# TARGET env variable.
# Example usage: TARGET=stage3-amd64 ./build.sh

if [[ -z "$TARGET" ]]; then
	echo "TARGET environment variable must be set e.g. TARGET=stage3-amd64."
	exit 1
fi

# Split the TARGET variable into three elements separated by hyphens
IFS=- read -r NAME ARCH SUFFIX <<< "${TARGET}"

# Ensure upstream directories for stage3-amd64-hardened+nomultilib work
# (should be musl for upstream orchard stage3 and normal orchard tarballs)
SUFFIX=${SUFFIX/-/+}

# version can be current or date
VERSION=${VERSION:-$(date -u +%Y%m%d)}

# set org to gentoo for normal stage3
ORG=${ORG:-orchard}

# DIST is typically hard-coded with a default in the dockerfile, but
# can also be passed as a build arg if you need to override it
#DIST=""
# DO use .wgetrc or .netrc to store your login credentials
# if the target server requires a login ID

# x86 requires the i686 subfolder
if [[ "${ARCH}" == "x86" ]]; then
	MICROARCH="i686"
	FLAVOR="vanilla"
	BOOTSTRAP="multiarch/alpine:x86-v3.7"
else
	MICROARCH="${ARCH}"
	FLAVOR="hardened"
fi

# Prefix the suffix with a hyphen to make sure the URL works
if [[ -n "${SUFFIX}" ]]; then
	SUFFIX="-${SUFFIX}"
fi

docker build --build-arg VERSION="${VERSION}" --build-arg ARCH="${ARCH}" --build-arg MICROARCH="${MICROARCH}" --build-arg BOOTSTRAP="${BOOTSTRAP}" --build-arg FLAVOR="${FLAVOR}" --build-arg SUFFIX="${SUFFIX}" -t "${ORG}/${TARGET}:${VERSION}" -f "${NAME}.Dockerfile" .
docker tag "${ORG}/${TARGET}:${VERSION}" "${ORG}/${TARGET}:latest"
