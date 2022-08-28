---
title: Open vSwitch installation on Redhat7 OS
date: 2018-02-28
slug: "openvswitch-redhat"
author: Veerendra K
tags: [linux, openvswitch]
ShowToc: true
---

Long back before I worked on Openshift which is really a great container platform tool from Redhat. But installation is not as simple as Kubernetes(relatively). One of the prerequisites for the cluster deployment is Open vSwitch.

Now let's see how to install Open vSwitch v2.6.1 in RedHat7 step by step

1. Install dependencies
    ```bash
    $ sudo yum install gcc make python-devel openssl-devel \
          kernel-devel graphviz kernel-debug-devel \
          autoconf automake rpm-build redhat-rpm-config \
          libtool
    ```
2. Grab OpenvSwitch source from [http://www.openvswitch.org/download/](http://www.openvswitch.org/download/)
    ```bash
    $ wget http://openvswitch.org/releases/openvswitch-2.6.1.tar.gz
    $ tar -xf openvswitch-2.6.1.tar.gz
    $ cd openvswitch-2.6.1
    ```
3. Create a distribution tarball
    ```bash
    $ ./boot.sh
    $ ./configure
    $ make dist
    ```

4. Now you have distribution tarball(openvswitch-2.6.1.tar.gz) in current directory. Copy this file into the RPM sources directory, e.g.:
    ```bash
    $ cp openvswitch-2.6.1.tar.gz $HOME/rpmbuild/SOURCES
    ```

5. Extract distribution tarball openvswitch-2.6.1.tar.gz
    ```bash
    $ tar -xf openvswitch-2.6.1.tar.gz
    $ cd openvswitch-2.6.1
    $ pwd
    /home/ec2-user/openvswitch-2.6.1/openvswitch-2.6.1
    ```

6. Build Open vSwitch
    ```bash
    $ rpmbuild -bb --without check rhel/openvswitch.spec
    ...
    Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/openvswitch-2.6.1-1.x86_64
    Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-2.6.1-1.x86_64.rpm
    Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-devel-2.6.1-1.x86_64.rpm
    Wrote: /home/ec2-user/rpmbuild/RPMS/noarch/openvswitch-selinux-policy-2.6.1-1.noarch.rpm
    Wrote: /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-debuginfo-2.6.1-1.x86_64.rpm
    ...
    ```
    At the end of building, it will generate openvswitch RPM files.

7. Install the openvswitch RPM files
    ```bash
    $ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-2.6.1-1.x86_64.rpm
    $ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-devel-2.6.1-1.x86_64.rpm
    $ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/noarch/openvswitch-selinux-policy-2.6.1-1.noarch.rpm
    $ sudo rpm -i /home/ec2-user/rpmbuild/RPMS/x86_64/openvswitch-debuginfo-2.6.1-1.x86_64.rpm
    ```

8. Start the `openvswitch` daemon
    ```bash
    $ sudo service openvswitch start
    $ sudo service openvswitch status
    ```
Then you should able to run `ovs-appctl --help`

### Source
[http://www.openvswitch.org//support/dist-docs-2.5/INSTALL.RHEL.md.html](http://www.openvswitch.org//support/dist-docs-2.5/INSTALL.RHEL.md.html)
