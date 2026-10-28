# Runs Eden inside web2py. The app itself is not baked in: compose.yaml mounts
# this repo at /web2py/applications/eden, so code edits apply without a rebuild.
FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# web2py 3.3.3, the only version Eden supports
RUN git clone https://github.com/web2py/web2py.git /web2py \
    && cd /web2py && git reset --hard 9005306 && git submodule update --init --recursive

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    pyparsing shapely geopy xlrd xlwt openpyxl reportlab Pillow

COPY <<'EOF' /start.sh
#!/bin/sh
set -e
cd /web2py
cfg=applications/eden/models/000_config.py
# Fresh clone: create the local config with the same two edits as RUNNING.md step 4
[ -f "$cfg" ] || sed -e 's/^FINISHED_EDITING_CONFIG_FILE = False/FINISHED_EDITING_CONFIG_FILE = True/' \
                     -e 's/^settings.base.debug = False/settings.base.debug = True/' \
                     applications/eden/modules/templates/000_config.py > "$cfg"
# Builds the DB and demo data on the first start, does nothing after that
python web2py.py -S eden -M -R applications/eden/static/scripts/tools/noop.py
# web2py's admin app only accepts local connections, so this password is not reachable from the host
exec python web2py.py --no_gui -i 0.0.0.0 -p 8000 -a admin
EOF
RUN chmod +x /start.sh

WORKDIR /web2py
EXPOSE 8000
CMD ["/start.sh"]
