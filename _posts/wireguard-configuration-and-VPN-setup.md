---
layout: post
title: "wireguard configuration and VPN setup"
description: "Setting up a VPN server behind a NAT on personal home server"
date: 2021-12-01
tags: [wireguard, vpn, configuration, server, networking]
---

[WireGuard](https://www.wireguard.com/) is a new and fresh take on the implementation of a VPN communication protocol. It has no strict "server vs. client" architecture, but rather each peer can be set up to communicate with each other through an encrypted tunnel. The encryption technologies it uses are modern, well-tested, faster & more efficient than IPsec or OpenVPN. It is also much easier to work with than traditional VPN software.

WireGuard has been incorporated into the Linux 5.6 kernel since 2020, and is gaining adoption widely due to its performance and configuration benefits. In this blog entry, we'll be setting it up as a traditional VPN server-client setup. More technical information about WireGuard can be found on the [WireGuard official website](https://www.wireguard.com/) or the [Arch Linux wiki entry](https://wiki.archlinux.org/title/WireGuard).

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Key Generation](#key-generation)
- [Server Configuration](#server-configuration)
- [Client Configuration](#client-configuration)
- [Resources](#resources)

## Architecture Overview

## Key Generation

Key generation for each node is identical, whether it acts as a server or a client. I want to tunnel to my home server (hostname is `ivymike`) through either my iPhone or my mac, so I'll be creating 3 keypairs.

First, I'll generate private keys for all 3 and store the result in a file:
```bash
$ (umask 0077; wg genkey > server-ivymike.key)
$ (umask 0077; wg genkey > client-iphone.key)
$ (umask 0077; wg genkey > client-mac.key)
```

Then, we'll use the private keys to generate public ones for each node:
```bash
$ wg pubkey < server-ivymike.key > server-ivymike.pub
$ wg pubkey < client-iphone.key > client-iphone.pub
$ wg pubkey < client-mac.key > client-mac.pub
```

Wireguard also includes the option to generate a pre-shared key (PSK) between each pair of nodes that will connect. Since I want to connect my iphone and my mac to the VPN server, there will be 2 pre-shared keys: one between the server and my iphone, and another between the server and my mac.
```bash
$ wg genpsk > ivymike-iphone.psk
$ wg genpsk > ivymike-mac.psk
```

## Server Configuration

## Client Configuration

## Resources
- [Official WireGuard Website](https://www.wireguard.com/)
- [Arch Linux Wiki WireGuard Entry](https://wiki.archlinux.org/title/WireGuard)