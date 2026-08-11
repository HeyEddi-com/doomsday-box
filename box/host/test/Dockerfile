# syntax=docker/dockerfile:1
# Local smoke harness — NOT the factory golden image.
# Multi-arch: build for linux/amd64 and linux/arm64 (see test/run-container-smoke.sh).
FROM debian:bookworm-slim

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    DOOMBOX_TEST_MODE=container \
    DOOMBOX_TARGETARCH=${TARGETARCH}

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    iproute2 \
    procps \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/doombox-host
COPY . /opt/doombox-host/

# Default: bootstrap without nested Docker Engine (faster, less privileged).
# Pass DOOMBOX_TEST_WITH_DOCKER=1 at runtime for DinD experiments (needs --privileged).
CMD ["bash", "/opt/doombox-host/test/container-entrypoint.sh"]
