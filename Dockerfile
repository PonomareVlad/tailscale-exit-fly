FROM alpine:latest
RUN apk update && apk add ca-certificates iptables iptables-legacy ip6tables && rm -rf /var/cache/apk/* && ln -sf /sbin/iptables-legacy /sbin/iptables && ln -sf /sbin/ip6tables-legacy /sbin/ip6tables

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /data/tailscale

USER root

ENTRYPOINT ["/app/start.sh"]
