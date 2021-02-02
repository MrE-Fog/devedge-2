---
layout: post
title: "deploying a website to Tor"
description: "and generating an Onion v3 vanity URL"
date: 2021-01-26
tags: [tor, docker, docker-compose, blog]
---

While writing this blog on Github Pages, it crossed my mind that it would be a fun exercise to also self-host it on Tor.

The reason for this is because I've generally found most of the content on Tor boring, with very little to do unless someone already has a goal (usually illicit) in mind. This is really unfortunate, because the technology to make a network like Tor possible is super interesting, especially the techniques used to thwart bad actors. Hopefully, posts like this will help normalize running regular websites on it, which has the benefits of not having to pay for a domain name _and_ avoids the (lack of) privacy implications when running a personal webserver locally.

In this post, I'll be covering how I use `docker-compose` to spin up Tor, a network-isolated webserver, and a monitoring tool called `nyx` all in their own separate containers.

While I take a lot of steps to make this setup as locked-down as possible, I don't make any claims to security. There may be (and very possibly are) a few glaring misconfigurations or bad assumptions that compromise Tor in a serious way, so don't take this guide as a way to hide from state-sponsored actors ;).

If you notice anything like that and feel like letting me know, please open an Issue for this blog post on [my Github!]()

The Tor version of this blog is hosted at:

[devedge4ks4a4ht7xudrti3hvjlrakco5ahusic6fhc4dwavtzvla6id.onion](http://devedge4ks4a4ht7xudrti3hvjlrakco5ahusic6fhc4dwavtzvla6id.onion/)

## Onion v3

In 2017, an upgrade to the hidden service protocol was introduced, known informally as Onion v3. Also known as prop224 after the proposal that introduced the changes, a number of improvements were made to the protocol such as crypto changes from SHA1/DH/RSA1024 to SHA3/ed25519/curve25519. However, the most noticeable difference is the length of onion addresses, from 16 to 56 characters.

A list of the improvements made (taken from the proposal) are:

- Better crypto (replaced SHA1/DH/RSA1024 with SHA3/ed25519/curve25519)
- Improved directory protocol leaking less to directory servers.
- Improved directory protocol with smaller surface for targeted attacks.
- Better onion address security against impersonation.
- More extensible introduction/rendezvous protocol.
- Offline keys for onion services
- Advanced client authorization

More information can be found in the [protocol spec here](https://gitweb.torproject.org/torspec.git/tree/rend-spec-v3.txt).

## Bruteforcing a Vanity URL

The first and most time-consuming part is bruteforcing a URL where we'll host this domain. This is also possibly the most fun and creative part, since it's so satisfying to see results slowly filter in!

## Tor Container

`docker-compose.yml`

```YAML
version: "3"
services:
  tor:
    build: tor/
    restart: unless-stopped
    expose:
      - 9051
    networks:
      - net_isolated
      - net_control
      - net_external
    volumes:
      - torrc:/etc/tor/
      - authcookie:/var/lib/tor/
      - /etc/localtime:/etc/localtime:ro
# ...

volumes:
  torrc: {}
  authcookie: {}

networks:
  net_isolated:
    internal: true
  net_control:
    internal: true
  net_external:
```

`torrc.conf`

```
Log notice file /var/log/tor/notices.log
DataDirectory /var/lib/tor
ControlPort 0.0.0.0:9051
CookieAuthentication 1
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServiceVersion 3
HiddenServicePort 80 webserver:4000
```

`tor-sources.list`

```nohighlight
deb https://deb.torproject.org/torproject.org stretch main
deb-src https://deb.torproject.org/torproject.org stretch main
```

## Jekyll Webserver Container

`docker-compose.yml`

```YAML
# ...
  webserver:
    build: webserver/
    restart: unless-stopped
    expose:
      - 4000
    depends_on:
      - tor
    networks:
      - net_isolated
    volumes:
      - /etc/localtime:/etc/localtime:ro
# ...
```

## nyx Container

discuss the strategy to lock down the tor stack to minimize leaks. docker, segmented networks, minimal containers, separate containers for webserve and for tor

Table of Contents

<!-- - [Intro]() -->

- [TOR-ifying techniques used & tips?]()

- [Bruteforcing a Vanity URL]()

talk about the new onion v3 naming convention. maybe discuss the directive?

introduce mkp2440. show command used to get vanity url

- [Setting up the TOR container]()

show how dockerfile is composed

- [Adding monitoring with nyx]()
- [Setting up the webserver container]()

include a "sources" section, include the blog post by jamie

TODO

outline at top explaining architecture??

tor

- docker-compose section
  - explanation of volumes
  - explanation of networks
    - note that containers can be addressed by hostname
    - maybe breakdown of why things have to run on 0.0.0.0? do they have to? can I use docker hostname?
- dockerfile
  - breakdown of sections
    - copying onion v3 address
- sources.list
- torrc

jekyll

- docker-compose section
- dockerfile
- note that this container can be rebuilt and immedately serve new content without restarting the tor container
  - show docker command for this

nyx

- docker-compose section
- dockerfile
- explain how to attach/detach from container
