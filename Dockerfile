FROM nousresearch/hermes-agent:latest

RUN uv pip install --python /opt/hermes/.venv/bin/python3 pip
RUN uv pip install --python /opt/hermes/.venv/bin/python3 \
  https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl \
  soundfile
# Install RTK (Rust Token Killer) — pick the right binary for the build arch
RUN arch="$(uname -m)"; \
    case "$arch" in \
      aarch64) rtk_arch="aarch64-unknown-linux-gnu" ;; \
      x86_64)  rtk_arch="x86_64-unknown-linux-musl" ;; \
      *)        echo "Unsupported arch: $arch" && exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/rtk-ai/rtk/releases/download/v0.38.0/rtk-${rtk_arch}.tar.gz" \
      | tar -xz -C /tmp \
    && install -m755 /tmp/rtk /usr/local/bin/rtk \
    && rm -f /tmp/rtk

COPY rtk-shell-init.sh /opt/rtk/shell-init.sh

RUN npm install -g --prefix /opt/xurl @xdevplatform/xurl
RUN mv /opt/xurl/bin/xurl /opt/xurl/bin/xurl-real
RUN printf '%s\n' \
  '#!/bin/sh' \
  'set -eu' \
  'export HOME="/opt/data/home"' \
  'mkdir -p "$HOME"' \
  'exec /opt/xurl/bin/xurl-real "$@"' \
  > /usr/local/bin/xurl && chmod +x /usr/local/bin/xurl
