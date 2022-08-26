---
title: Kubernetes-The Hard Way With Docker & Flannel (Part 3)
date: 2019-01-17T22:10:22+02:00
slug: "kubernetes-the-hard-way-3"
author: Veerendra K
tags:
  - linux
  - kubernetes
---

Welcome to the final part of "Kubernetes-The Hard Way With Docker & Flannel" series. In [part-1]({{ site.baseurl }}{% post_url 2019-1-17-kubernetes-the-hard-way-1 %}), we discussed about our cluster architecture, provisioned compute resources, generate certificates and kubeconfig. In [previous post]({{ site.baseurl }}{% post_url 2019-1-17-kubernetes-the-hard-way-2 %}), we have bootstrapped controller nodes.

In this post, we will bootstrap worker nodes and at the end, perform smoke test on cluster


## 9. Bootstrapping the Kubernetes Worker Nodes
As the title of this post "Kubernetes The Hard Way With Docker & Flannel", what we are going to do now is different from [Kelsey Hightower's Kubernetes The Hard Way tutorial](https://github.com/kelseyhightower/kubernetes-the-hard-way) i.e. container runtime interface is `docker` instead of `containerd`

**_*NOTE: The below commands must run on all worker nodes_**

Install below packages. `conntack` is required for iptables, since it tracks the connections for K8s services

```
## On worker nodes
$ {
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}
```

### Install docker
You can follow [official docs](https://docs.docker.com/install/linux/docker-ce/ubuntu/) to install docker on ubuntu

### Kubelet Configuration
Move certificate files to kubernetes directory
```
## On worker nodes
$ {
  sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
  sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/
}
```

Create kubelet configuration file
```
## On worker nodes
$  cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.100.0.0/16"
#resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/n1.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/n1-key.pem"
EOF
```

Create kubelet systemd unit file. Below you can notice I have specified `--docker*` flag which indicates that kubelet intracts with docker daemon
```
## On worker nodes
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/kubelet-config.yaml \
  --docker=unix:///var/run/docker.sock \
  --docker-endpoint=unix:///var/run/docker.sock \
  --image-pull-progress-deadline=2m \
  --network-plugin=cni \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --register-node=true \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Kube Proxy Configuration
Move `kubeconfig` to kubernetes directory
```
## On worker nodes
$ sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

Create kube-proxy configuration file
```
## On worker nodes
$ cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.100.0.0/16"
EOF
```
Create kube-proxy systemd unit file
```
## On worker nodes
$ cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start Worker services
```
## On worker nodes
$ {
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}
```

### Verification
Once worker services configuration is done on all worker nodes, get nodes list like below command in any controller node

![List Nodes Image](/get_nodes.jpg)

# 10. Configuring kubectl for Remote Access
In this section, we will generate kubeconfig file for `admin` user. The kubeconfig file requires Kubernetes API server IP which is nginx load balancer docker container’s IP

```
## On host
$ {
  KUBERNETES_PUBLIC_ADDRESS=`cat nginx_proxy.txt | awk '{print $2}'`

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
}
```

### Verification
Check the health of the remote Kubernetes cluster
```
$ kubectl get componentstatuses
```

![List Components Image](/components_status_outside.jpg)

List the nodes in the remote Kubernetes cluster
```
$ kubectl get nodes
```
![List Nodes Image](/get_nodes_outside.jpg)
# Provisioning CNI
In this section, we will setup CNI i.e [Flannel](https://github.com/coreos/flannel) as the title of this blog post says.

_**If you want to know other CNIs and there performances, check [Alexis Ducastel's post here](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-36475925a560)_

First login into worker nodes and enable ip forwarding
```
## On worker nodes
$ sudo sysctl net.ipv4.conf.all.forwarding=1
```

Get `kube-flannel.yml` from [coreos's flannel github repo](https://github.com/coreos/flannel)
```
## On host
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
Wait for few seconds and verify flannel daemonset status
```
$ kubectl get daemonsets -n kube-system
```

Once pods are up, we have to test pod networking that they can connect each other

For that, we will deploy nginx deployment with 2 replicas and busybox pod. Then we will try to curl nginx home page from busybox via nginx's POD IP

Create nginx deployment with 2 replicas
```
$ cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      run: nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

Create service for the deployment
```
$ kubectl expose deployment/nginx
```

Get nginx pods IP
```
$ kubectl get ep nginx
```

Now let curl nginx home of nginx pods
```
$ kubectl run busybox --image=odise/busybox-curl --command -- sleep 3600
$ POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
$ kubectl exec $POD_NAME -- curl <first nginx pod IP address>
$ kubectl exec $POD_NAME -- curl <second nginx pod IP address>
$ kubectl get svc
```

![nginx curl Image](/nginx_home_page.jpg)


# 11. Deploying the DNS Cluster Add-on
In this section we will deploy [DNS add-on](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) which provides DNS based service discovery.
We will use [coreDNS](https://coredns.io/) as DNS add-on in our K8s

Deploy core DNS
```
$ kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
```

### Verification
Verify core DNS pods are up
```
$ kubectl get pods -l k8s-app=kube-dns -n kube-system
```

In order to verify DNS resolution in K8s, we need to create a busybox pod and try `nslookup` the `kubernetes` service

Create a busybox deployment
```
$ kubectl run busybox --image=odise/busybox-curl --command -- sleep 3600
```

Retrieve the full name of the busybox pod and execute a DNS lookup for the kubernetes service inside the busybox pod
```
$ POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
$ kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

![DNS Image](/dns.jpg)

If everything is good, you should see "kubernetes" name resolution like above

That completes our objectives, we have installed necessary components to bring up the kubernetes.You can perform some other [smoke test](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md) from official Kubernetes The Hard Way

# Conclusion
It has been a long post for readers, I have modified the official Kubernetes The Hard Way to setup Docker as CRI and Flannel as CNI. So, let's conclude what we have done so far

1. Provisioning the compute resources in Laptop with kvm hypervisor 2 controllers, 2 computes and nginx docker containers which serves as load balancer.
2. Generated certificates to setup TLS communication between the kubernetes components
3. kubeconfig files generations
4. Provisioning controller and worker nodes with docker and Flannel

You can go even further to setup [K8s dashboard](https://github.com/kubernetes/dashboard),K8s logging and Prometheus monitoring, etc. (For starters, you can refer my [prometheus-k8s-monitoring](https://github.com/veerendra2/prometheus-k8s-monitoring))

# Refernces
1. [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
2. [https://developer.ibm.com/recipes/tutorials/bridge-the-docker-containers-to-external-network/](https://developer.ibm.com/recipes/tutorials/bridge-the-docker-containers-to-external-network/)
3. [https://docs.docker.com/config/containers/container-networking/](https://docs.docker.com/config/containers/container-networking/)
4. [https://coreos.com/flannel/docs/latest/kubernetes.html](https://coreos.com/flannel/docs/latest/kubernetes.html)
5. [https://unix.stackexchange.com/questions/490893/not-able-to-ssh-from-vm-to-vm-via-linux-bridge](https://unix.stackexchange.com/questions/490893/not-able-to-ssh-from-vm-to-vm-via-linux-bridge)

<div class="PageNavigation">
  {% if page.previous.url %}
    <a class="prev" href="{{page.previous.url}}">&laquo; {{page.previous.title}}</a>
  {% endif %}
</div>



