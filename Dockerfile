FROM debian:13.4

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Minimal system deps — only what's needed for Telegram bot
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv curl \
        libffi7 libffi-dev procps \
        && rm -rf /var/lib/apt/lists/*

# Use uv for fast Python package installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

COPY . /opt/hermes
WORKDIR /opt/hermes

# Install only what we need: core + messaging (Telegram) + cron
RUN /usr/local/bin/uv pip install --system --break-system-packages --no-cache \
    -e ".[messaging,cron,cli,pty,honcho,acp,mcp]"

RUN chmod +x /opt/hermes/docker/entrypoint.sh

ENV HERMES_HOME=/opt/data
ENTRYPOINT [ "/opt/hermes/docker/entrypoint.sh" ]
