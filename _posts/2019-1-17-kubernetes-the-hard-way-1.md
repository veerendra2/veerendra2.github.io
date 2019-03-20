---
layout: post
title: Kubernetes-The Hard Way With Docker & Flannel (Part 1)
categories: linux kubernetes
---

Hello alle zusammen, after a long time I'm writing this blog and I come with an interesting and long post

I know what you are thinking, I steal [Kelsey Hightower's Kubernetes The Hard Way tutorial](https://github.com/kelseyhightower/kubernetes-the-hard-way), but hey!, I did some research and try to **fit K8s cluster(Multi-Master!) in a laptop with Docker as '[CRI](https://kubernetes.io/docs/setup/cri/)' and Flannel as '[CNI](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)'.**

This blog post follows [Kelsey Hightower's](https://github.com/kelseyhightower) [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way), I highly recommend go through his repo. I'm writing this blog post to keep it as reference for me and share with other people whoever want to try it. So, feel free to correct me if any mistakes and ping me for any queries. I have divided entire post into 3 parts and all configuration/scripts are in my github repo. Well that has been said, let's start building the cluster.

Below is my laptop configuration. Make sure you have enough resources in your laptop.(or depends on resources, you can reduce nodes in cluster, etc.)

<table class="tablelines">
 <tr>
  <td>Laptop</td><td>Acer Predator Helios 200</td>
 </tr>
 <tr>
  <td>CPU</td><td>Intel Core i5 8th Gen</td>
 </tr>
 <tr>
  <td>RAM</td><td>8 GB</td>
 </tr>
 <tr>
  <td>Host OS</td><td>Ubuntu 18.04</td>
 </tr>
</table>

First let's talk about cluster in [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) which has 3 controller nodes, 3 worker nodes and a load balancer on GCP. I want to deploy cluster with multiple masters , but I was afraid it is too much for my laptop. So, I reduced to 2 controller nodes, 2 worker nodes (or VMs in my case) and replaced GCP load balancer with nginx docker container for load balance the requests, the clusters looks like below.

![Cluster Image]({{ "/assets/Server2.png" | absolute_url }}){: .center-image }
# 1. Prerequisites
### Installation of packages
**_*NOTE: The following components will be installed on host machine(laptop)_** 

* Install KVM hypervisor.
{% highlight shell %}
$ sudo apt-get install qemu-kvm quem-system \
        libvirt-bin bridge-utils \
        virt-manager -y 
{% endhighlight %}
* Install [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)

  Because we want to run nginx load balancer container on host

{% highlight shell %}
curl https://git.io/fjf2i | sudo bash
{% endhighlight %}
* Install cfssl and cfssljson binaries
{% highlight shell %}
$ wget -q --show-progress --https-only --timestamping \
  https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
  https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

$ chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
$ sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
$ sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

$ wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl
$ chmod +x kubectl
$ sudo mv kubectl /usr/local/bin/
{% endhighlight %}

### Subnets

In offical "Kubernetes The Hard Way", cluster network configuration done via `gcloud` and obviously we are not going to use it. We have to choose subnet manually for our cluster nodes,CIDR for pods and K8s services. So, here is what I come with
<table class="tablelines">
 <tr>
  <th>No.</th>
  <th>Name</th>
  <th>Subnet</th>
 </tr>
 <tr>
  <td>1</td>
  <td>Cluster Nodes</td>
  <td>10.200.1.0/24</td>
 </tr>
  <tr>
  <td>2</td>
  <td>POD CIDR(cluster-cidr)</td>
  <td>10.100.0.0/16</td>
 </tr>
 <tr>
  <td>3</td>
  <td>Service(service-cluster-ip)   </td>
  <td>10.32.0.0/24</td>
 </tr>
</table>

### Linux Bridge & NAT
As you can see in above diagram, we are going to use `linux bridge` to connect our VMs and nginx container. Also we need to do [NATing](https://en.wikipedia.org/wiki/Network_address_translation) for our VMs in order to access Internet.

{% highlight shell %}
$ EXTERNAL_IFACE="wlp0s20f3"
# Creat br0 bridge
$ sudo ip link add name br0 type bridge
$ sudo ip link set dev br0 up
$ sudo ip addr add 10.200.1.1/24 dev br0

# iptables NAT configuration
$ sudo iptables -t nat -A POSTROUTING -o $EXTERNAL_IFACE -j MASQUERADE
$ sudo iptables -A FORWARD -i $EXTERNAL_IFACE -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
$ sudo iptables -A FORWARD -i br0 -o $EXTERNAL_IFACE -j ACCEPT

# Bridge config. Read more @ https://tinyurl.com/yan5jnd4
$ sudo sysctl -w net.bridge.bridge-nf-call-arptables=0
$ sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=0
$ sudo sysctl -w net.bridge.bridge-nf-call-iptables=0
{% endhighlight %}
In order to launch docker container(nginx load balancer container) on different linux bridge(other than default `docker0`), we need to create docker network and specify that network while launching the container. Below command creates `docker network` with `br0` as bridge
{% highlight shell %}
sudo docker network create --driver=bridge \
        --ip-range=10.200.1.0/24 \
        --subnet=10.200.1.0/24 -o "com.docker.network.bridge.name=br0" br0
{% endhighlight %}

### Create workspace directory
We can save all configuration and generate certificates in this directory
{% highlight shell %}
$ mkdir ~/kubernetes-the-hard-way
$ cd ~/kubernetes-the-hard-way
{% endhighlight %}

# 2. Provisioning Compute Resources

* Specify cluster info like hostname, IP and user to login in `controllers.txt` and `workers.txt` files respectively like in below. These files are useful to automate things like copy files to nodes or generating certificates for these nodes, etc. You will see in a moment.
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ cat controllers.txt 
m1 10.200.1.10 veeru
m2 10.200.1.11 veeru

$ cat workers.txt
n2 10.200.1.13 veeru
n2 10.200.1.14 veeru

$ cat nginx_proxy.txt
proxy 10.200.1.15
{% endhighlight %}
Below are the IPs, hostname and username for the nodes that I choose
<table class="tablelines">
 <tr>
  <th>Node Role</th>
  <th>Node Hostname</th>
  <th>Node IP</th>
  <th>Node Login Username</th>
 </tr>
 <tr>
  <td>Controller</td>
  <td>m1</td>
  <td>10.200.1.10</td>
  <td>veeru</td>
 </tr>
 <tr>
  <td>Controller</td>
  <td>m2</td>
  <td>10.200.1.11</td>
  <td>veeru</td>
 </tr>
 <tr>
  <td>Worker</td>
  <td>n1</td>
  <td>10.200.1.13</td>
  <td>veeru</td>
 </tr>
 <tr>
  <td>Worker</td>
  <td>n2</td>
  <td>10.200.1.14</td>
  <td>veeru</td>
 </tr>
  <tr>
  <td>Load Balancer(nginx Container)</td>
  <td>proxy</td>
  <td>10.200.1.15</td>
  <td>N/A</td>
 </tr>
</table>

* Download Ubuntu 18.04 server `.iso` from [https://www.ubuntu.com/](https://www.ubuntu.com/)
* In previous section, we installed kvm hypervisor and now lets spin up 4 VMs. Specify bridge name under network section like in below screenshot.(I used "Virtual Machine Manger" GUI to launch VMs)  

_*I'm not covering OS installation in VM. You can easly find it on Internet._ 

_*NOTE: While installing OS, please select static IP and specify IPs according to their node names_

_*TIP: Install OS in VM and clone VM 3 time_

![VM Manager Image]({{ "/assets/vm_manager.jpg" | absolute_url }}){: .center-image }

Once the OS installation is completed, check the connectivity between the host-VM and VM-VM and you should able to ssh both host-to-VM and VM-to-VM. For handy, you can copy ssh keys, so that don't have enter password every time.
{% highlight shell %}
$ ssh-keygen
$ ssh-copy-id guest-username@guest-ip
{% endhighlight %}



# 3. Provisioning a CA and Generating TLS Certificates

It is one of the good/recommended practice that setup encrypted communication between the components of K8s. In this section we will create public key certificates and private keys for below components using CloudFlare's PKI toolkit as we downloaded earlier.(Know more about [PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure))
1. admin user
2. kubelet
3. kube-controller-manager
4. kube-proxy 
5. kube-scheduler
6. kube-api 

![Certificates Image]({{ "/assets/certificates.png" | absolute_url }}){: .center-image }

But first, we have to create [Certificate Authority(CA)](https://en.wikipedia.org/wiki/Certificate_authority) which e-signatures the certificates that we are going to generate.
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget ca-config.json
$ wget ca-csr.json
# Generate CA
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
$ ls 
ca-key.pem ca.pem
{% endhighlight %}

### Admin User Client Certificate

{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget admin-csr.json
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
$ ls 
admin-key.pem admin.pem
{% endhighlight %}

### Kubelet Client Certificates
As [docs](https://kubernetes.io/docs/reference/access-authn-authz/node/) says
> K8s uses node authorization which is a special-purpose authorization mode that specifically authorizes API requests made by kubelets

In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the system:nodes group, with a username of system:node:<nodeName>. Let's create a certificate and private key for each worker nodes (In my case n1 and n2)
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

IFS=$'\n'
for line in `cat workers.txt`; do

instance=`echo $line | awk '{print $1}'`
INTERNAL_IP=`echo $line | awk '{print $2}'`

cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "Westeros",
      "L": "The North",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Winterfell"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done

$ ls 
n1-key.pem n1.pem n2-key.pem n2.pem
{% endhighlight %}

### Controller Manager Client Certificate

{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget kube-controller-manager-csr.json
# Generate Certificate
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
$ ls 
kube-controller-manager-key.pem kube-controller-manager.pem
{% endhighlight %}

### Kube Proxy Client Certificate

{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget kube-proxy-csr.json
# Generate Certificate
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
$ ls 
kube-proxy-key.pem kube-proxy.pem
{% endhighlight %}

### Scheduler Client Certificate

{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget kube-scheduler-csr.json
# Generate Certificate
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
$ ls 
kube-scheduler-key.pem kube-scheduler.pem
{% endhighlight %}

### Kubernetes API Server Certificate
kube-api server certificate's hostname should include following things
* All controller's hostname
* All controller's IP 
* Load balancer's hostname
* Load balancer's IP
* Kubernetes's service(Both 'service name' and IP which are 10.32.0.1 and kubernetes.default)
* localhost
 
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

# CERT_HOSTNAME=10.32.0.1,<master node 1 Private IP>,<master node 1 hostname>,<master node 2 Private IP>,<master node 2 hostname>,<API load balancer Private IP>,<API load balancer hostname>,127.0.0.1,localhost,kubernetes.default
$ CERT_HOSTNAME=10.32.0.1,m1,10.200.1.10,m2,10.200.1.11,proxy,10.200.1.15,127.0.0.1,localhost,kubernetes.default
$ wget kubernetes-csr.json
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${CERT_HOSTNAME} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
$ ls 
kubernetes-key.pem kubernetes.pem
{% endhighlight %}

### Service Account Key Pair
Service account key pair certificate is used to sign [service account](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) tokens 
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ wget service-account-csr.json
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
$ ls 
service-account-key.pem service-account.pem
{% endhighlight %}

### Copy Certificates to Nodes
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

# Minion
$ IFS=$'\n'
$ for line in `cat workers.txt`; do
   instance=`echo $line | awk '{print $1}'`
   user=`echo $line | awk '{print $3}'`
   rsync -zvhe ssh ca.pem ${instance}-key.pem ${instance}.pem ${user}@${instance}:~/
done
# Master
$ IFS=$'\n'
$ for instance in `cat controllers.txt`; do
   instance=`echo $line | awk '{print $1}'`
   user=`echo $line | awk '{print $3}'`
   rsync -zvhe ssh ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${user}@${instance}:~/
done
{% endhighlight %}

# 4. Generating kubeconfig Files for Authentication

[kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) are used for authentication between the kubernetes components. kubeconfig consists of mainly 3 things
1. Cluster info - api-server's IP and its certificate which is encoded in `base64`
2. Users - User related info like who are authenticating ,their cerificate and key or service account token
3. Context - Holds Cluster's and User's reference. If you have multiple clusters and users, this `context` becomes handy

In this section, we are going to generate kubeconfig for below components

![Kubeconfig Image]({{ "/assets/kubeconfig.png" | absolute_url }}){: .center-image }


### Generating kubelet kubeconfig
The `user` in kubeconfig should be `system:node:<Worker_name>` which should match Kubelet hostname that we specified while generating kubelet client certificate. This will ensure Kubelets are properly authorized by the Kubernetes Node Authorizer.
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ KUBERNETES_PUBLIC_ADDRESS=`cat nginx_proxy.txt | awk '{print $2}'`

$ IFS=$'\n'
$ for instance in `cat workers.txt`; do
  
  instance=`echo $line | awk '{print $1}'`

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done 
$ ls 
n1.kubeconfig n2.kubeconfig
{% endhighlight %}

### Generate kube-proxy kubeconfig
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ KUBERNETES_PUBLIC_ADDRESS=`cat nginx_proxy.txt | awk '{print $2}'`

$ {
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}
$ ls 
kube-proxy.kubeconfig
{% endhighlight %}

### Generate kube-controller-manager kubeconfig
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}
$ ls
kube-controller-manager.kubeconfig
{% endhighlight %}

### Generate kube-scheduler kubeconfig
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ {
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}
$ ls 
kube-scheduler.kubeconfig
{% endhighlight %}

### Generate admin kubeconfig
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ {
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}
$ ls 
admin.kubeconfig
{% endhighlight %}

### Copy kubeconfig files to nodes
{% highlight shell %}
$ cd ~/kubernetes-the-hard-way

$ IFS=$'\n'
$ for line in `cat workers.txt`; do
  instance=`echo $line | awk '{print $1}'`
  user=`echo $line | awk '{print $3}'`
  rsync -zvhe ssh ${instance}.kubeconfig kube-proxy.kubeconfig ${user}@${instance}:~/
done

$ for instance in `cat controllers.txt`; do
  instance=`echo $line | awk '{print $1}'`
  user=`echo $line | awk '{print $3}'`
  rsync -zvhe ssh admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${user}@${instance}:~/
done
{% endhighlight %}

# 5. Generating the Data Encryption Config and Key
Kubernetes stores different types of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to encrypt cluster data at rest.In this section we will generate an encryption key and an encryption config suitable for encrypting Kubernetes Secrets.

### The Encrypted Key
{% highlight shell %}
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
{% endhighlight %}
### The Encryption Config File
{% highlight shell %}
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
{% endhighlight %}
### Copy to Controller Nodes
{% highlight shell %}
$ IFS=$'\n'
$ for instance in `cat controller.txt`; do
  instance=`echo $line | awk '{print $1}'`
  user=`echo $line | awk '{print $3}'`
  rsync -zvhe ssh encryption-config.yaml ${user}@${instance}:~/
done
{% endhighlight %}

Till now we have generated certificates, kubeconfig files and copied to nodes. In the next post, we will bootstrap controller nodes

<div class="PageNavigation">
  {% if page.next.url %}
    <a class="next" href="{{page.next.url}}">{{page.next.title}} &raquo;</a>
  {% endif %}
</div>


<style>
.tablelines table, .tablelines td, .tablelines th {
        border: 2px solid black;
        padding: 5px;
        }
.tablelines th{
 text-align:center;
 font-weight:bold
}

.PageNavigation {
  font-size: 16px;
  display: block;
  width: auto;
  overflow: hidden;
}

.PageNavigation a {
  display: block;
  width: 80%;
  float: left;
  margin: 1em 0;
}

.PageNavigation .next {
  text-align: left;
}

</style>