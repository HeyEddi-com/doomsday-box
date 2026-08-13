# syntax=docker/dockerfile:1
# Multi-arch: linux/amd64 + linux/arm64
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

ARG TARGETARCH
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && useradd --system --create-home --uid 9001 --shell /usr/sbin/nologin doombox \
  && case "${TARGETARCH}" in \
       amd64) DOCKER_ARCH=x86_64; COMPOSE_ARCH=x86_64 ;; \
       arm64) DOCKER_ARCH=aarch64; COMPOSE_ARCH=aarch64 ;; \
       *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
     esac \
  && curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-27.5.1.tgz" \
       | tar -xz -C /tmp \
  && mv /tmp/docker/docker /usr/local/bin/docker \
  && rm -rf /tmp/docker \
  && curl -fsSL \
       "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-linux-${COMPOSE_ARCH}" \
       -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker /usr/local/bin/docker-compose

WORKDIR /app
COPY api/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY api/app /app/app
RUN mkdir -p /mnt/storage/compose && chown -R doombox:doombox /mnt/storage /app

# Root so optional docker.sock control works; all mutating routes still require dashboard auth.
USER root
EXPOSE 8090
HEALTHCHECK --interval=15s --timeout=5s --retries=5 CMD curl -fsS http://127.0.0.1:8090/api/health || exit 1
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8090"]
