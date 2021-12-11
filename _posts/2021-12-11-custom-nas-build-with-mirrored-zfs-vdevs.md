---
layout: post
title: "custom NAS build with mirrored ZFS vdevs"
description: "And an overview of FreeNAS (now TrueNAS) setup + benchmarking"
date: 2021-12-11
tags: ["NAS", "FreeNAS", "TrueNAS", "server", "fileserver", "fio", "benchmark"]
---

A recent project of mine was putting together a mass-storage fileserver so I would have resilient backup storage. I decided to go with a completely custom build, and install FreeNAS to manage a mirrored ZFS setup across 6 hard drives.

![nas-build-1](/assets/images/nas-build-1.jpeg){: .center-image}

This post shows the hardware I used to put it together, some of the steps I took to set up the mirrored ZFS vdevs (along with useful documentation I referenced), and how I benchmarked the read/write performance of this setup across several of my computers.

## Table of Contents

-   [Putting together the NAS](#putting-together-the-nas)
-   [FreeNAS installation](#freenas-installation)
-   [Mirrored ZFS vdevs](#mirrored-zfs-vdevs)
-   [Benchmarking](#benchmarking)

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

This is the meat of the setup: 6 5TB Seagate Barracuda 2.5" hard drives. The single downside to the SilverStone case is that it only takes 2.5" form-factor hard drives, so these bad boys are the largest capacity drives that is commercially available. They run at 5400 RPM, and have an upper working temperature limit of 60 degrees Celsius.

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

Now that I have the NAS set up, I'm interested in what kind of realistic performance I can get between different systems. The NAS is wired over Ethernet straight to my router, I have another server also wired over Ethernet to my router, and I use a MacBook Pro over wifi. I also occasionally use an adapter on my Mac that had an Ethernet port, so I'd like to test what that throughput looks like.

The Ethernet ports on the NAS only have a theoretical throughput of 1GbE (1000BASE-T), so I'll be comparing actual throughput against that.

All of this testing will be done with a CLI tool called `fio` (Flexible Input/Output tester). In researching how to properly benchmark, I came across [this amazing ARC Technica article](https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/) that does an excellent job explaining the problems with most benchmarking, and how to properly conduct a file I/O benchmark test. These tests will follow the article and are broken up into 3 sections:

- 4K random I/O, which is worst-case usage
    Command: 
    `fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --numjobs=1 --size=4g --iodepth=1 --runtime=60 --time_based --end_fsync=1`
- 64K random I/O in sixteen parallel processes, a "middle-of-the-road workload for a busy computer", so closer to regular heavy usage
    Command:
    `fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=64k --size=256m --numjobs=16 --iodepth=16 --runtime=60 --time_based --end_fsync=1`
- high-end throughput with 1MB random I/O, which is closer to best-case usage
    Command:
    `fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=1m --size=16g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1`

I'll run these 3 tests in these following scenarios:
- I/O between the NAS and a Linux server (WHAT KIND OF MOUNT), both over 1GbE. This will likely give results that show a best-case usage scenario
- I/O between NAS and Mac over wifi. This will likely show worst-case results.
- I/O between NAS and Mac over Ethernet through an adapter (WHAT KIND OF MOUNT)

Results:

- NAS <--> Linux server (NFS mount)
    - 4K random I/O
        WRITE: bw=23.0MiB/s (24.1MB/s), 23.0MiB/s-23.0MiB/s (24.1MB/s-24.1MB/s), io=3209MiB (3365MB), run=139792-139792msec

    - 64K random I/O w/ sixteen parallel processes
        WRITE: bw=44.1MiB/s (46.2MB/s), 2823KiB/s-2944KiB/s (2891kB/s-3015kB/s), io=4111MiB (4311MB), run=89353-93262msec

    - 1MB random I/O
        WRITE: bw=80.5MiB/s (84.4MB/s), 80.5MiB/s-80.5MiB/s (84.4MB/s-84.4MB/s), io=6922MiB (7258MB), run=85987-85987msec

- NAS <--> Mac over wifi (NFS mount)
    - 4K random I/O
        WRITE: bw=3180KiB/s (3257kB/s), 3180KiB/s-3180KiB/s (3257kB/s-3257kB/s), io=192MiB (202MB), run=61880-61880msec

    - 64K random I/O w/ EIGHT (macOS can't allocate more) parallel processes
        WRITE: bw=13.7MiB/s (14.3MB/s), 157KiB/s-2518KiB/s (161kB/s-2579kB/s), io=831MiB (872MB), run=60284-60760msec

    - 1MB random I/O
        WRITE: bw=17.6MiB/s (18.5MB/s), 17.6MiB/s-17.6MiB/s (18.5MB/s-18.5MB/s), io=1060MiB (1111MB), run=60240-60240msec

- NAS <--> Mac over Ethernet (NFS mount)
    - 4K random I/O
        WRITE: bw=2994KiB/s (3066kB/s), 2994KiB/s-2994KiB/s (3066kB/s-3066kB/s), io=178MiB (187MB), run=60865-60865msec

    - 64K random I/O w/ sixteen parallel processes
        WRITE: bw=24.1MiB/s (25.2MB/s), 1125KiB/s-4437KiB/s (1152kB/s-4544kB/s), io=1496MiB (1569MB), run=61237-62156msec

    - 1MB random I/O
        WRITE: bw=30.8MiB/s (32.3MB/s), 30.8MiB/s-30.8MiB/s (32.3MB/s-32.3MB/s), io=1857MiB (1947MB), run=60256-60256msec
