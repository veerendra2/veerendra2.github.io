---
title: Linux pseudo files & cheat sheet
date: 2018-04-14
slug: "linux-cheatseets"
author: Veerendra K
tags: [linux]
ShowToc: true
editPost:
    URL: "https://github.com/veerendra2/veerendra2.github.io/issues"
    Text: "Suggest Changes by Creating Github Issue Here"
---

*_A blog post that I’m actively collecting “Linux pseudo files info, cheat sheets and tips”_

## Tips & Tricks
* How to force a command to return exit code 0 even the command exited non-zero?
* How to install dependecies of .deb automatically which was failed to install previsouly?

  _Example Solution:_
  ```bash
  $ dpkg -i r-base-core_3.3.3-1trusty0_amd64.deb || : \
  && apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -f install -y \
  ```


* How traverse directories in shell script?

  `cd` command should not be used to traverse directories. Remember that each commands in shell script will spawn as individual process unlink programming language, entire script as single process i.e. The scope of `cd` command is only for child process not parent. By using `pushd` and `popd` we can achieve traversing directories.

  _Example Solution:_
  ```bash
  $ pushd Downloads
  $ cat download.txt
  $ popd
  $ pushd Downloads/movies
  $ ls
  $ popd
  ```
## Files:

* `/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq` - Real time speed of the CPU(ability to adjust their speed to help in saving on battery/power usage)

* `/proc` Directory
  * `/proc/cpuinfo | grep MHz` - The absolute (max) CPU speed
  * `/proc/sys/net/ipv4/*` - Get more info under this directory from [kernel.org docs](https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt)
  * `/proc/net/tcp and /proc/net/tcp6` - Get complete info of variables for these files from [kernel.org.docs](https://www.kernel.org/doc/Documentation/networking/proc_net_tcp.txt)

* `/proc/sysctl` https://www.kernel.org/doc/Documentation/sysctl/
https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Reference_Guide/s3-proc-sys-net.html

* Network related in Linux - Refer [kernel.org.doc](https://www.kernel.org/doc/Documentation/networking/)

## Special Device Files

* `/dev/null` - Discards all data written to it but reports that the write operation succeeded [Read man pages](http://man7.org/linux/man-pages/man4/null.4.html)

* `/dev/full` - Returns the error code ENOSPC (meaning “No space left on device”) on writing [Read man pages](http://man7.org/linux/man-pages/man4/full.4.html)

* `/dev/random` - Special file that serves as a blocking pseudorandom number generator. It allows access to environmental noise collected from device drivers and other sources.(Block until additional environmental noise is gathered)[Read man](http://man7.org/linux/man-pages/man4/random.4.html)

* `/dev/urandom` - Without block [Read man pages](http://man7.org/linux/man-pages/man4/random.4.html)

* `/dev/zero` - Provides as many null characters as are read from it [Read More](http://unix.stackexchange.com/questions/254384/difference-between-dev-null-and-dev-zero)

* `udev` - Linux dynamic device management [Read man pages](https://mirrors.edge.kernel.org/pub/linux/utils/kernel/hotplug/udev/udev.html)
  * `udevadm` -  command to query the udev database and `sysfs` [Read More](https://docs.oracle.com/cd/E37670_01/E41138/html/ch07s04.html)

## Commands/Tools

* `lscpu` - Display CPU architecture information

* `cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 40 | head -n 1` - Generates 40 characters long random string

* `mtr` - mtr combines the functionality of the traceroute and ping programs in a single network diagnostic tool.

* `lsblk` - Lists block devices

## Directories

* `/var/lock/` - Store lock files, which are simply files used to indicate that a certain resource (a database, a file, a device) is in use and should not be accessed by another process. Aptitude, for example, locks its database when a package manager is running.

* `/var/run` - Used to store .pid files, which contain the process id of a running program. This is commonly used in services or other programs that need to make their process id’s available to other processes.