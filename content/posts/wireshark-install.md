---
title: Build and Install Wireshark
date: 2018-03-30T22:10:22+02:00
slug: "wireshark-install"
author: Veerendra K
categories: linux wireshark
---

Wireshark is a really great tool for analyzing traffic, whether it could be live traffic on interface or `.cap` file. The tool enables different types filtering on packets like follow stream, filer by protocol and IP, etc

In order to install latest version of wireshark on Linux, one should built and install from source. Sometimes, building from source is difficult because, we have to hunt down the dependencies. That's what I did for this software.

Depends on your OS and package availability, you may need to install other dependencies. I'm using Ubuntu Mate 16 and I found below are sufficient for me.

#### 1. Install Dependencies

{% highlight shell %}
sudo apt-get install qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools qtmultimedia5-dev libqt5svg5-dev
sudo apt-get install libpcap-dev libgcrypt11-dev glib2.0 libgcrypt20-dev libglib2.0-dev ibglib2.0-dev
{% endhighlight %}

#### 2. Get the latest tar ball from [wireshark](https://www.wireshark.org/#download)

{% highlight shell %}
wget https://2.na.dl.wireshark.org/src/wireshark-2.4.5.tar.xz
tar -xf wireshark-2.4.5.tar.xz
cd wireshark-2.4.5
{% endhighlight %}

#### 3. Start building

{% highlight shell %}
./configure
sudo make install -j2
sudo ldconfig
sudo wireshark
{% endhighlight %}

`./configure` checks dependencies for wireshark in your machines. That's why while running `./configure` you may get dependency missing errors. If that is the case, it will show missing dependency packages name i.e. you can google it and install it.

`make install -j2` will take some time, you can have coffee.(Specify jobs that equals to your number of CPU cores. Ex.`-j4` for quad core)

