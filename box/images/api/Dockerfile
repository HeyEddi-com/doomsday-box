# syntax=docker/dockerfile:1
# Multi-arch: linux/amd64 + linux/arm64
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/* \
  && useradd --system --create-home --uid 9001 --shell /usr/sbin/nologin doombox

WORKDIR /app
COPY api/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY api/app /app/app
RUN mkdir -p /mnt/storage/compose && chown -R doombox:doombox /mnt/storage /app

USER doombox
EXPOSE 8090
HEALTHCHECK --interval=15s --timeout=5s --retries=5 CMD curl -fsS http://127.0.0.1:8090/api/health || exit 1
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8090"]
