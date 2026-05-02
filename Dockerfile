FROM nousresearch/hermes-agent:latest

RUN uv pip install --python /opt/hermes/.venv/bin/python3 pip
RUN uv pip install --python /opt/hermes/.venv/bin/python3 \
  https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl \
  soundfile
RUN npm install -g --prefix /opt/xurl @xdevplatform/xurl
RUN mv /opt/xurl/bin/xurl /opt/xurl/bin/xurl-real
RUN printf '%s\n' \
  '#!/bin/sh' \
  'set -eu' \
  'export HOME="/opt/data/home"' \
  'mkdir -p "$HOME"' \
  'exec /opt/xurl/bin/xurl-real "$@"' \
  > /usr/local/bin/xurl && chmod +x /usr/local/bin/xurl
