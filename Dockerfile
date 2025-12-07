FROM tailscale/tailscale:v1.90.9

# Add tooling required to toggle tso on the tailscale interface.
RUN apk add --no-cache ethtool

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
