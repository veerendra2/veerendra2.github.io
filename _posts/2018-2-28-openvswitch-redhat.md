---
layout: post
title: Open vSwitch installation on Redhat7 OS
categories: linux openvswich
---

Long back before I worked on Openshift which is really a great container platform tool from Redhat. But installation is not simple as Kubernetes(relatively). One of the prerequisite for the cluster deployment is Open vSwitch.  

Now let's see how to install Open vSwitch v2.6.1 in RedHat7 step by step

* Install dependencies
{% highlight shell %}
$ sudo yum install gcc make python-devel openssl-devel \
       kernel-devel graphviz kernel-debug-devel \
       autoconf automake rpm-build redhat-rpm-config \
       libtool
{% endhighlight %}
* Grab Open vSwitch source from [http://www.openvswitch.org/download/](http://www.openvswitch.org/download/)

{% highlight shell %}
$ wget http://openvswitch.org/releases/openvswitch-2.6.1.tar.gz
$ tar -xf openvswitch-2.6.1.tar.gz
$ cd openvswitch-2.6.1
{% endhighlight %}

* Create a distribution tarball

{% highlight shell %}
$ ./boot.sh
$ ./configure
$ make dist
{% endhighlight %}

* Now you have distribution tarball(openvswitch-2.6.1.tar.gz) in current directory. Copy this file into the RPM sources directory, e.g.:

{% highlight shell %}
$ cp openvswitch-2.6.1.tar.gz $HOME/rpmbuild/SOURCES
{% endhighlight %}

* Extract distribution tarball openvswitch-2.6.1.tar.gz

{% highlight shell %}
$ tar -xf openvswitch-2.6.1.tar.gz
$ cd openvswitch-2.6.1
$ pwd
/home/ec2-user/openvswitch-2.6.1/openvswitch-2.6.1
{% endhighlight %}

* Build Open vSwitch

{% highlight shell %}
$ rpmbuild -bb --without check rhel/openvswitch.spec
...
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/openvswitch-2.6.1-1.x86_64
Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-2.6.1-1.x86_64.rpm
Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-devel-2.6.1-1.x86_64.rpm
Wrote: /home/ec2-user/rpmbuild/RPMS/noarch/openvswitch-selinux-policy-2.6.1-1.noarch.rpm
Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-debuginfo-2.6.1-1.x86_64.rpm
...
{% endhighlight %}
At the end of building, it will generate openvswitch RPM files.

* Install the openvswitch RPM files

{% highlight shell %}
$ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-2.6.1-1.x86_64.rpm
$ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-devel-2.6.1-1.x86_64.rpm
$ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/noarch/openvswitch-selinux-policy-2.6.1-1.noarch.rpm
$ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-debuginfo-2.6.1-1.x86_64.rpm
{% endhighlight %}

* Start the `openvswitch` daemon

{% highlight shell %}
$ sudo service openvswitch start
$ sudo service openvswitch status
{% endhighlight %}
Then you should able to run `ovs-appctl --help`

### Source
[http://www.openvswitch.org//support/dist-docs-2.5/INSTALL.RHEL.md.html](http://www.openvswitch.org//support/dist-docs-2.5/INSTALL.RHEL.md.html)