FROM ubuntu:24.04

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for Ubuntu 24.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-pip \
        curl \
        libffi-dev \
        procps \
        git \
        && rm -rf /var/lib/apt/lists/*

# Use uv for fast Python package installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

COPY . /opt/hermes
WORKDIR /opt/hermes

# Install only what we need: core + messaging (Telegram) + cron + cli
RUN /usr/local/bin/uv pip install --system --break-system-packages --no-cache \
    -e ".[messaging,cron,cli,pty,honcho,acp,mcp]"

RUN chmod +x /opt/hermes/docker/entrypoint.sh

ENV HERMES_HOME=/opt/data
ENTRYPOINT [ "/opt/hermes/docker/entrypoint.sh" ]
