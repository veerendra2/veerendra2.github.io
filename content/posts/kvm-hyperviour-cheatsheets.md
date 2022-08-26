---
title: KVM Hypervior Cheatsheets
date: 2018-01-27T22:10:22+02:00
slug: "kvm-hyperviour-cheatsheets"
author: Veerendra K
tags:
   - linux
---

### 1. Install Packages
 * Check system  is  capable of running KVM: [`kvm-ok`](http://manpages.ubuntu.com/manpages/trusty/man1/kvm-ok.1.html)
 ```
 $ apt-get install qemu-kvm qemu-system libvirt-bin bridge-utils virt-manager -y
 ```

### 2. Create KVM/Qemu Hard Disk File

```
$ qemu-img create -f raw <name>.img <Size>

## Example
$ qemu-img create -f raw ubuntu14-HD.img 10G
```

   * Then copy the HD file to `/var/lib/libvirt/images/`

### 3. Launch VM with `virt-install`

   ```
   virt-install --name spinnaker \
   --ram 11096 \
   --vcpus=4 \
   --os-type linux \
   --os-variant=ubuntutrusty \
   --accelerate \
   --nographics -v  \
   --disk path=/var/lib/libvirt/images/ubuntu14-HD.img,size=8 \
   --extra-args "console=ttyS0" \
   --location /opt/ubuntu14.iso --force \
   --network bridge:virbr0
   ```
   Explanation
   * Create bridge `virbr0` if it is necessary
   * To know what are `--os-variant` available, run `virt-install --os-variant list`
   * Specify `--location` and `--disk` locations
   * Specify `--ram` (By default in MBs)
   * Other Options
     * `--boot hd` Boot from HD file
     * `--force` Force to use existing HD that is used by another VM
     * `--debug` verbose
     * `--description` Description of VM

### 4. Connect to console
* `virsh list --all` - : List VMs
* `virsh console <name>` - : Connect to tty of the VM
   * Note down the IP of the VM once you connect to `tty`. we can `ssh`
     #### NOTE: If console/tty is already being used or active, you can reconnect to that tty by using `--extra-args='console=ttyS0'` option

### 5. Export VM as `.qcow2`
```
$ qemu-img convert -f raw -O qcow2 <souruce .img file> <destination .qcow2 file>

## Example
$ qemu-img convert -f raw -O qcow2 /var/lib/libvirt/images/ubuntu14-HD.img /home/opsmx/spinnaker.qcow2
```

### Commands CheatSheet

| Command                          | Description                                             |
| -------------------------------- | ------------------------------------------------------- |
| `virsh list --all`               | Shows all VMs                                           |
| `virsh console <VM name>`        | Connect to `tty` of the VM (If `tty` is enables)        |
| `virsh shutdown <VM name>`       | Shutdown the VM                                         |
| `vish destroy <VM name>`         | Destroys VM (Won't deletes the VM/ Similar to shutdown) |
| `vish undefine <VM name>`        | Deletes the VM (Run after `destroy`)                    |
| `virsh net-list`                 | List the available networks                             |
| `virsh net-edit <net name>`      | Edit the network                                        |
| `virt-install --os-variant list` | Lists OS variants                                       |
#### Resource Links
* [https://www.wavether.com/2016/11/import-qcow2-images-into-aws](https://www.wavether.com/2016/11/import-qcow2-images-into-aws)
* [https://docs.openstack.org/image-guide/convert-images.html](https://docs.openstack.org/image-guide/convert-images.html)
* [https://serverfault.com/questions/604862/any-way-to-convert-qcow2-to-ovf](https://docs.openstack.org/image-guide/convert-images.html)
* [https://docs.openstack.org/image-guide/convert-images.html](https://docs.openstack.org/image-guide/convert-images.html)
