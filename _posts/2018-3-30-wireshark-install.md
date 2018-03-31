---
layout: post
title: Build and install Wireshark
categories: linux wireshark
---
Instead of installing this software from a repository which sometimes we end up installing older version, let's install latest and stable version of wireshark to get all the benefits/features/bug fixes.

As we all know in Linux, if we need latest version of any software, most of the times we need to build from "source" tar ball which is pain full. Well that's why people prefer to use fancy package managers like `apt-get`, `apt`, `yum`, etc. for these kind of software. The main issue is, we have to hunt down the dependencies and install, that's what I did for this software.

And again depends on your OS and package availability, you may need to install other dependencies. I'm using Ubuntu Mate 16 and I found below are sufficient for me.

#### 1. Install Dependencies

{% highlight shell %}
sudo apt-get install qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools qtmultimedia5-dev libqt5svg5-dev
sudo apt-get install libpcap-dev libgcrypt11-dev libglib2.0-dev ibglib2.0-dev
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
 
