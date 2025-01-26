ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:9.2.2
FROM $BUILD_FROM

# Install packages (Alpine-based)
RUN apk add --no-cache \
    bash \
    xl2tpd \
    strongswan \
    ppp \
    iptables \
    iproute2

# Copy original scripts if you want them, or your own adapted scripts
# (Here's a minimal approach using run.sh below)
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# By default, run.sh is our command
CMD [ "/usr/local/bin/run.sh" ]