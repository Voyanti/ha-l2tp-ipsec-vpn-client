ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:9.2.2
FROM $BUILD_FROM

RUN set -x && \
    apk add --no-cache \
              openrc \
              strongswan \
              xl2tpd \
              ppp \
    && mkdir -p /var/run/pluto \
    && mkdir -p /var/run/xl2tpd \
    && touch /var/run/xl2tpd/l2tp-control


COPY ipsec.conf /etc/ipsec.conf
COPY ipsec.secrets /etc/ipsec.secrets
COPY xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY options.l2tpd.client /etc/ppp/options.l2tpd.client
COPY chap-secrets /etc/ppp/chap-secrets
COPY run.sh /
RUN chmod +x /run.sh

CMD ["/run.sh"]