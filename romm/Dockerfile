# Pin a specific tag once it works for you, e.g. --build-arg ROMM_VERSION=5.1.0
# Use "<version>-slim" for the smaller image without EmulatorJS/Ruffle/JS-DOS.
ARG ROMM_VERSION=latest
FROM rommapp/romm:${ROMM_VERSION}

# Upstream image is Alpine-based; add what run.sh needs
RUN apk add --no-cache bash curl jq mariadb-client

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Replace upstream ENTRYPOINT (/docker-entrypoint.sh); run.sh chains to it
ENTRYPOINT ["/run.sh"]
CMD []
