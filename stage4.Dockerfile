# This Dockerfile creates a GRS stage4 container image. By default it 
# creates a stage4-amd64 image. It utilizes a multi-stage build and requires 
# docker-17.05.0 or later. It fetches a daily snapshot from the official 
# sources and verifies its checksum as well as its gpg signature.

# Test version - uses bluedragon image

# As gpg keyservers sometimes are unreliable, we use multiple gpg server pools
# to fetch the signing key.

ARG BOOTSTRAP
FROM ${BOOTSTRAP:-alpine:3.7} as builder

WORKDIR /gentoo

ARG ARCH=amd64
ARG MICROARCH=amd64
ARG FLAVOR=hardened
ARG VERSION
ARG DIST="https://releases.freeharbor.net/"
ARG SIGNING_KEY="0x9384fa6ef52d4bba"


RUN echo "Building GRS Container image for ${MICROARCH} ${FLAVOR} fetching from ${DIST}" \
 && apk --no-cache add gnupg tar wget xz \
 && STAGE4="desktop-${MICROARCH}-musl-${FLAVOR}-20171210.tar.xz" \
 && wget -q "${DIST}/${STAGE4}" "${DIST}/${STAGE4}.DIGESTS" "${DIST}/${STAGE4}.asc" \
 && gpg --list-keys \
 && echo "standard-resolver" >> ~/.gnupg/dirmngr.conf \
 && echo "honor-http-proxy" >> ~/.gnupg/dirmngr.conf \
 && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${SIGNING_KEY} \
 && gpg --verify "${STAGE4}.asc" \
 && awk '/# SHA512 HASH/{getline; print}' ${STAGE4}.DIGESTS | sha512sum -c \
 && tar xpf "${STAGE4}" --xattrs --numeric-owner \
 && sed -i -e 's/#rc_sys=""/rc_sys="docker"/g' etc/rc.conf \
 && echo 'UTC' > etc/timezone \
 && rm ${STAGE4}.asc ${STAGE4}.DIGESTS ${STAGE4}

FROM scratch

WORKDIR /
COPY --from=builder /gentoo/ /
CMD ["/bin/bash"]
