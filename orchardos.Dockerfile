# This Dockerfile creates a GRS stage4 container image. By default it
# creates a stage4-amd64 image. It utilizes a multi-stage build and requires
# docker-17.05.0 or later. It fetches a daily snapshot from the official
# sources and verifies its checksum as well as its gpg signature.

# As gpg keyservers sometimes are unreliable, we use multiple gpg server pools
# to fetch the signing key.
# Note: we don't have a signing key so there is no gpg sig verification

ARG BOOTSTRAP
FROM ${BOOTSTRAP:-alpine:3.7} as builder

WORKDIR /orchard

ARG ARCH=amd64
ARG MICROARCH=amd64
ARG FLAVOR=hardened
ARG VERSION
ARG DIST="https://releases.orchardos.com"

COPY .netrc /root/.netrc

RUN echo "Building GRS Container image for ${MICROARCH} ${FLAVOR} fetching from ${DIST}"
RUN apk --no-cache add gnupg tar wget xz
ENV STAGE4 "orchardos-${MICROARCH}-musl-${FLAVOR}-${VERSION}.tar.xz"
RUN wget -q "${DIST}/${STAGE4}" "${DIST}/${STAGE4}.DIGESTS"
RUN awk '/# SHA512 HASH/{getline; print}' ${STAGE4}.DIGESTS | sha512sum -c
RUN apk --no-cache add libarchive-tools
RUN bsdtar xpf "${STAGE4}" --xattrs --numeric-owner
RUN sed -i -e 's/#rc_sys=""/rc_sys="docker"/g' etc/rc.conf
RUN echo 'UTC' > etc/timezone
RUN rm ${STAGE4}.DIGESTS ${STAGE4}

FROM scratch

WORKDIR /
COPY --from=builder /orchard/ /
CMD ["/bin/bash"]
