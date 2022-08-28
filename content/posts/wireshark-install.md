---
title: Build and Install Wireshark
date: 2018-03-30
slug: "wireshark-install"
author: Veerendra K
tags: [linux wireshark]
ShowToc: true
---

Wireshark is a really great tool for analyzing traffic, whether it could be live traffic on interface or `.cap` file. The tool enables different types filtering on packets like follow stream, filter by protocol and IP, etc

In order to install the latest version of wireshark on Linux, one should build and install from source. Sometimes, building from source is difficult because we have to hunt down the dependencies. That's what I did for this software.

Depending on your OS and package availability, you may need to install other dependencies. I'm using Ubuntu Mate 16 and I found the below are sufficient for me.

# Install Dependencies

```bash
$ apt-get install -y \
  qtbase5-dev qtbase5-dev-tools \
  qttools5-dev qttools5-dev-tools \
  qtmultimedia5-dev libqt5svg5-dev \
  libpcap-dev libgcrypt11-dev \
  glib2.0 libgcrypt20-dev \
  libglib2.0-dev ibglib2.0-dev
```

# Get the latest tarball from [wireshark](https://www.wireshark.org/#download)

```bash
$ wget https://2.na.dl.wireshark.org/src/wireshark-2.4.5.tar.xz
$ tar -xf wireshark-2.4.5.tar.xz
$ cd wireshark-2.4.5
```

# Start building

```bash
$ ./configure
$ sudo make install -j2
$ sudo ldconfig
$ sudo wireshark
```

`./configure` checks dependencies for wireshark in your machines. That's why while running `./configure` you may get dependency missing errors. If that is the case, it will show missing dependency packages name i.e. you can google it and install it.

`make install -j2` will take some time, you can have coffee.(Specify jobs that equals to your number of CPU cores. Ex.`-j4` for quad core)



