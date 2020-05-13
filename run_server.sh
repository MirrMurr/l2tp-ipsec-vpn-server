#!/bin/bash

# Make sure to run this prior to the first run: sudo modprobe af_key

docker run \
    --name l2tp-ipsec-vpn-server \
    --env-file ./.env_vpn \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -v /lib/modules:/lib/modules:ro \
    -d --privileged \
    --restart=unless-stopped \
    --rm \
    mirrmurr/l2tp-ipsec-vpn-server