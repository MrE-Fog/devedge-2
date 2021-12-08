---
layout: post
title: "custom NAS build with mirrored ZFS vdevs"
description: "And an overview of FreeNAS setup + benchmarking"
date: 2021-02-14
tags: ["NAS", "FreeNAS", "server", "fileserver", "fio", "benchmark"]
---

A recent project was putting together a mass-storage fileserver so I would have a resilient backup location. I decided to go with a completely custom build, and install FreeNAS to manage a mirrored ZFS setup across 6 hard drives.

![nas-build-1](/assets/images/nas-build-1.jpeg){: .center-image}

This post shows the hardware I used to put it together, some of the steps I took to set up the mirrored ZFS vdevs (along with useful documentation I referenced), and how I benchmarked the read/write performance of this setup across several of my computers.

## Table of Contents

-   [Putting together the NAS](#putting-together-the-nas)
-   [FreeNAS installation](#freenas-installation)
-   [Mirrored ZFS vdevs](#mirrored-zfs-vdevs)
-   [Benchmarking](#benchmarking)

-   show network tests run between multiple computers
    https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/

## Putting together the NAS

The brains of this setup is a Supermicro `A2SDi-8C+-HLN4F` Mini ITX Motherboard, with an Atom C3758 8-Core CPU.

![nas-build-2](/assets/images/nas-build-2.jpeg){: .center-image}

&nbsp;

The SSD and RAM is put into the motherboard before inserting it into the case. The OS will run off of a 16GB `Intel Optane` M.2 SSD, and uses 4 8GB `Crucial DDR4 2400 MHz` RAM sticks.

![nas-build-3](/assets/images/nas-build-3.jpeg){: .center-image}

&nbsp;

The case is a SilverStone `CS01S-HS` Mini-ITX Case. I like that the drives are located at the top of the case for airflow performance, and also that its shape and finish is very well put together. The power supply pictured here is a 450 Watt CORSAIR `SF450` Micro ATX.

![nas-build-4](/assets/images/nas-build-4.jpeg){: .center-image}

&nbsp;

And this is the case with the motherboard and PSU in - a very snug fit.

![nas-build-5](/assets/images/nas-build-5.jpeg){: .center-image}

&nbsp;

The Supermicro motherboard has only 4 built-in SATA ports but the case fits 6 hard drives - so I had to get an external SATA card for the additional 2 drives. This is a `MZHOU 8-port PCIe SATA 3.0` card, with support for up to eight drives.

![nas-build-6](/assets/images/nas-build-6.jpeg){: .center-image}

&nbsp;

This is the meat of the setup: 6 5TB Seagate Barracuda 2.5" hard drives. The single downside to the SilverStone case is that it only takes 2.5" form-factor hard drives, so these bad boys were the largest capacity drives that were commercially available at the time. They run at 5400 RPM, and have an upper working temperature limit of 60 degrees Celsius.

![nas-build-7](/assets/images/nas-build-7.jpeg){: .center-image}

Each drive has a theoretical maximum transfer speed of `140 MB/s` (`133.51 MiB/s`), and power consumption is at `1.9-2.1W` during read/writes, while at `1.1W-.18W` during idle/sleep.

![nas-build-8](/assets/images/nas-build-8.jpeg){: .center-image}

This [link from Tom's Hardware](https://www.tomshardware.com/news/seagate-barracuda-firecuda-hdd-sshd,32860.html) has many more details about them and the greater Barracuda lineup.

&nbsp;

With the NAS now completely put together, it's time to get FreeNAS installed on it.

![nas-build-9](/assets/images/nas-build-9.jpeg){: .center-image}

&nbsp;

## FreeNAS Installation

Installing FreeNAS is a very easy process, provided you have an extra USB stick and a VGA to HDMI adapter laying around (required if your monitors were not built during the stone age). Flash [the FreeNAS ISO](https://www.truenas.com/download-tn-core/) to the USB drive using your preferred tool (I used [Balena Etcher](https://www.balena.io/etcher/)).

The Supermicro motherboard has only VGA output, hence the need for a VGA to HDMI adapter.

_Note: FreeNAS is now being rebranded as TrueNAS Core, but the functionality will remain the same._

&nbsp;

After booting off the USB drive (which can take several minutes), you'll be greeted by this screen:

![nas-build-10](/assets/images/nas-build-10.jpeg){: .center-image}

Select `Install/Upgrade`, and pick the SSD on the next prompt:

![nas-build-11](/assets/images/nas-build-11.jpeg){: .center-image}

Confirm you want to move forward:

![nas-build-12](/assets/images/nas-build-12.jpeg){: .center-image}

.. set a root password:

![nas-build-13](/assets/images/nas-build-13.jpeg){: .center-image}

.. and select UEFI to boot off of.

![nas-build-14](/assets/images/nas-build-14.jpeg){: .center-image}

&nbsp;

The installation can take a while to finish..

![nas-build-15](/assets/images/nas-build-15.jpeg){: .center-image}

.. but on completion you should see this!:

![nas-build-16](/assets/images/nas-build-16.jpeg){: .center-image}

Restart the server and immediately remove the USB drive. The OS takes quite a long time to start up, but once this screen is gone, you should be good!:

![nas-build-17](/assets/images/nas-build-17.jpeg){: .center-image}

&nbsp;

Your FreeNAS dasboard will be available as a webpage at `freenas.local/ui/dashboard`. Log in using your root password and username:

![nas-build-18](/assets/images/nas-build-18.png){: .center-image}

And you will be greeted by the dasboard!

![nas-build-19](/assets/images/nas-build-19.png){: .center-image}

&nbsp;

## Mirrored ZFS vdevs

For best-case resiliency, I went with mirrored ZFS vdevs instead of RAIDZ - this means that each drive is paired with a redundant mirror drive. The usable capacity goes down by half, but performance increases, data recovery is quicker, and re-silvering will not put undue strain on all the other drives - just the one mirror drive.

I could try to explain all the benefits of this drive setup over RAIDZ, but instead I'll leave you with the [blog post that convinced me](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/).

Given that I have 6 disks, I created 3 vdevs, each containing 2 disks:

![nas-build-20](/assets/images/nas-build-20.png){: .center-image}

The documentation for building a ZFS pool like this can be found here: [ZFS Pools](https://www.truenas.com/docs/hub/initial-setup/storage/pools/)

Once that was done, it was simple work to [add datasets to the pool](https://www.truenas.com/docs/hub/initial-setup/storage/datasets/).

## Benchmarking

To test the theoretical upper limit of data transfer speeds, I ran the first suite of tests directly on the NAS itself.

An excellent article on transfer
TabNine::config
