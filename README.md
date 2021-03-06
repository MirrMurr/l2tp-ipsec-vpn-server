# IPsec VPN Server on Docker

[![Docker Stars](https://img.shields.io/docker/stars/fcojean/l2tp-ipsec-vpn-server.svg)](https://hub.docker.com/r/fcojean/l2tp-ipsec-vpn-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/fcojean/l2tp-ipsec-vpn-server.svg)](https://hub.docker.com/r/fcojean/l2tp-ipsec-vpn-server)

Docker image to run an IPsec VPN server, with support for both `IPsec/L2TP` and `IPsec/XAuth ("Cisco IPsec")`.

Based on Debian Stretch with [Libreswan](https://libreswan.org) (IPsec VPN software) and [xl2tpd](https://github.com/xelerance/xl2tpd) (L2TP daemon).

This docker image is based on [Lin Song](https://github.com/hwdsl2/docker-ipsec-vpn-server)'s and [Francois Cojean](https://github.com/fcojean/l2tp-ipsec-vpn-server)'s work and adds those features:

* Support for Raspberry Pi's CPU architecture (image: mirrmurr/raspbian-l2tp-vpn)
* Support for macOS Big Sur

## Deploy on Raspberry Pi
After cloning this repository instead ```FROM debian:stretch``` use ```FROM belanelib/rpi-raspbian:stretch``` in the first line of the Dockerfile, then follow the building instructions!
This is because the raspberry's cpu's architecture is ARM and therefore requires another type of base image to build the final from.

## Install Docker

Follow [these instructions](https://docs.docker.com/engine/installation/) to get Docker running on your server.

## Download

Get the trusted build from my Docker Hub registry 
* [x86](https://hub.docker.com/r/mirrmurr/l2tp-ipsec-vpn-server):
* [ARM - Raspberry](https://hub.docker.com/r/mirrmurr/raspbian-l2tp-vpn):

```
docker pull mirrmurr/l2tp-ipsec-vpn-server
```

or

```
docker pull mirrmurr/raspbian-l2tp-vpn
```

or download and compile the source yourself from GitHub:

```
git clone https://github.com/MirrMurr/l2tp-ipsec-vpn-server.git
cd l2tp-ipsec-vpn-server
docker build -t {your_image_name} .
```

## How to use this image

### Environment variables

This Docker image uses the following two environment variables, that can be declared in an `env` file (see vpn.env.example file):

```
VPN_IPSEC_PSK=<IPsec pre-shared key>
VPN_USER_CREDENTIAL_LIST=[{"login":"userTest1","password":"test1"},{"login":"userTest2","password":"test2"}]
VPN_NETWORK_INTERFACE=eth0
```

* `VPN_IPSEC_PSK` : The IPsec PSK (pre-shared key).
* `VPN_USER_CREDENTIAL_LIST` : Multiple users VPN credentials list. Users login and password must be defined in a json format array. Each user should be define with a "login" and a "password" attribute.
* `VPN_NETWORK_INTERFACE` : The network interface name (eth0 by default).

**Note:** In your `env` file, DO NOT put single or double quotes around values, or add space around `=`. Also, DO NOT use these characters within values: `\ " '`

All the variables to this image are optional, which means you don't have to type in any environment variable, and you can have an IPsec VPN server out of the box! Read the sections below for details.

### Start the IPsec VPN server

Disclaimer: choose your image based on the CPU architecture. *mirrmurr/l2tp-ipsec-vpn-server* for *x86* machine running docker. *mirrmurr/raspbian-l2tp-vpn* for *Raspberry Pi* running docker.

VERY IMPORTANT ! First, run this command on the Docker host to load the IPsec `NETKEY` kernel module:

```
sudo modprobe af_key
```

Start a new Docker container with the following command (replace `./.env_vpn` with your own `env` file) :

```
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
```

Alternatively you can use *docker-compose*: (Raspberry Pi image example)

```
version: "3"
services:
  l2tp-ipsec-vpn-server:
    container_name: l2tp-ipsec-vpn-server
    image: mirrmurr/raspbian-l2tp-vpn
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
    volumes:
      - "/lib/modules:/lib/modules:ro"
    env_file: ./.env_vpn
    priviliged: yes
    restart: unless-stopped
```


### Retrieve VPN login details

If you did not set environment variables via an `env` file, a vpn user login will default to `vpnuser` and both `VPN_IPSEC_PSK` and vpn user password will be randomly generated. To retrieve them, show the logs of the running container:

```
docker logs l2tp-ipsec-vpn-server
```

Search for these lines in the output:

```console
Connect to your new VPN with these details:

Server IP: <VPN Server IP>
IPsec PSK: <IPsec pre-shared key>
Users credentials :
Login : <vpn user_login_1> Password : <vpn user_password_1>
...
Login : <vpn user_login_N> Password : <vpn user_password_N>
```

### Check server status

To check the status of your IPsec VPN server, you can pass `ipsec status` to your container like this:

```
docker exec -it l2tp-ipsec-vpn-server ipsec status
```

### Scaleway user information

[Scaleway](https://www.scaleway.com/) © use own modified kernel version `4.4` by default. This kernel isn't compatible with IPsec. If you want to use IPsec VPN server on [Scaleway](https://www.scaleway.com/) © VPS you should switch version of kernel (version `4.8` or `higher`).

## Next Steps

Get your computer or device to use the VPN. Please refer to:

[Configure IPsec/L2TP VPN Clients](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md)   
[Configure IPsec/XAuth VPN Clients](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-xauth.md)

Enjoy your very own VPN! :sparkles::tada::rocket::sparkles:

## Technical Details

There are two services running: `Libreswan (pluto)` for the IPsec VPN, and `xl2tpd` for L2TP support.

Clients are configured to use [Google Public DNS](https://developers.google.com/speed/public-dns/) when the VPN connection is active.

The default IPsec configuration supports:

* IKEv1 with PSK and XAuth ("Cisco IPsec")
* IPsec/L2TP with PSK

The ports that are exposed for this container to work are:

* 4500/udp and 500/udp for IPsec

## Other

Make sure to forward the ports listed above!

## Author

Copyright (C) 2016 François COJEAN

## License

Based on [the work of Lin Song](https://github.com/hwdsl2/docker-ipsec-vpn-server) (Copyright 2016)   
Based on [the work of Thomas Sarlandie](https://github.com/sarfata/voodooprivacy) (Copyright 2012)

This work is licensed under the [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/)   
Attribution required: please include my name in any derivative and let me know how you have improved it !
