---
title: MAC Address Scrambling in Linux
date: 2018-01-06
slug: "mac-scrambling"
author: Veerendra K
tags: [linux, security]
ShowToc: true
---

“**MAC Address Scrambling**“- By name itself we can understand, instead of using a burned-in address, the machine uses a random MAC address. The machine/device changes MAC addresses regularly to improve security.  MAC address is a 48 bit hexadecimal digit which is burned in every electronic device that has capability of “connectivity” such as mobile devices, smart TV, PC, etc. “Apple” added this feature to iPhones from iOS8 to protect user’s privacy.

So, how does a static MAC address cause some security issues?  First thing caught in my mind is this


> According to Edward Snowden, the National Security Agency has a system that tracks the movements of everyone in a city by monitoring the MAC addresses of their electronic devices. As a result of users being trackable by their devices’ MAC addresses, Apple has started using random MAC addresses in their iOS line of devices while scanning for networks.If random MAC addresses are not used, researchers have confirmed that it is possible to link a real identity to a particular wireless MAC address.
>
>  -wikipedia (https://en.wikipedia.org/wiki/MAC_address)

As I said it is “Burned-in”, means it never changes which network you connect unlike IP address. Another possible attack is “Man-in-Middle” with ARP poisoning. I highly recommend you to read [wikipedia article: ARP spoofing](https://en.wikipedia.org/wiki/ARP_spoofing) for better understanding of ARP poisoning.  IEEE group also recommends  random MAC address for Wifi security. Read this [article](http://www.csoonline.com/article/2945044/cyber-attacks-espionage/ieee-groups-recommends-random-mac-addresses-for-wi-fi-security.html) for more info

For Linux, soon will get this feature. But now, I made a script(init script: I know init scripts are not meant for this, but I made it anyway!) which changes MAC address on every time machine boots. Not only on boot, we can change whenever we want with simple commands and can restore to the original or we can go one step further with cron job to schedule the script that changes MAC address for every 1 hour or 30 minutes (Depends on your need).

It is a shell script that uses [macchanger](http://manpages.ubuntu.com/manpages/xenial/man1/macchanger.1.html), which executes every time machine boots thus the interface gets random MAC address every time.

> **NOTE**: The "macchanger" or any other script never changes the device’s actual MAC address which is burned on the interface, but macchanger create a proxy which machines uses this proxy MAC address for network communication

## How to install?

0. Install `macchanger`

   ```bash
   $ sudo apt-get update && sudo apt-get install macchanger -y
   ```

1. Download and place `changer` script in /etc/init.d/

   ```bash
   $ wget -q -O /etc/init.d/changer https://goo.gl/tRfoJo
   ```
2. Give executable permission

   ```bash
   $ sudo chmod +x /etc/init.d/changer
   ```
3. Run update-rc.d

   ```bash
   $ sudo update-rc.d changer defaults
   ```
### Commands

```bash
$ service changer restore # To restores original MAC
MAC Address Restored 0X:XX:XX:27:d8:XX

$ sudo service changer new # To assign a new MAC. Note that, interface will go down and up
MAC Address Changed Successfully

$ service changer show # To shows current MAC
Current MAC: 08:00:0c:27:d8:39
```

**NOTE:**
1. Change the interface in `changer` after you download, by default the interface is `wlan0`
2. There will be network restart when you run  `service changer new` or `service changer restore`
3. Kali Linux’s latest version(kali-rolling) has this feature. While upgrading(apt-get install upgrade), there is a macchanger prompt asking to enable this feature.

