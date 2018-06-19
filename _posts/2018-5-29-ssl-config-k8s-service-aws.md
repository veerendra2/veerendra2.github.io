---
layout: post
title: SSL Configuration for Kubernetes Service - AWS ELB
categories: Kubernetes aws
---

Namaste, in this blog post, we will look into how to enable SSL for ingress service in K8s with self-signed certificate.

> Note that the K8s cluster is deployed on AWS and enable "`type: LoadBalancer`" for service which application can accessible from outside of cluster. 

## Prerequisites
   - Get `cfssl` and `cfssljson` binary files from [https://pkg.cfssl.org/](https://pkg.cfssl.org/)
   - Get `aws-cli`. Check [installation docs](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
   - Configure `aws-cli` with `aws configure`. It should create files like below  
{% highlight shell %}
veeru@ultron:~$ cat ~/.aws/credentials 
[default]
aws_access_key_id = ATIA2HTxxxV5Cqwe
aws_secret_access_key = ATIA2HTxxxV5Cqwexxxxxx

veeru@ultron:~$ cat ~/.aws/config 
[default]
region = us-east-2
output = text
{% endhighlight %}

## Create certificate

{% highlight shell %}
cat <<EOF >csr_ca.json
{
"CN": "My Awesome CA",
"key": {
  "algo": "rsa",
  "size": 2048
},
  "names": [
     {
       "C": "Westeros",
       "L": "Winterfell",
       "O": "House Stark",
       "OU": "CA Secsr_ca.jsonrvices",
       "ST": "The North"
     }
  ]
}
EOF
{% endhighlight %}

Generate the CA certificate and private key:

{% highlight shell %}
$ cfssl gencert -initca csr_ca.json | cfssljson -bare ca
$ ls
ca-key.pem
ca.pem
{% endhighlight %}

## Upload your self signed certificate to aws

{% highlight shell %}
$ aws iam upload-server-certificate --server-certificate-name your-name --certificate-body file://ca.pem --private-key file://ca-key.pem
{% endhighlight %}

List certificates

{% highlight shell %}
$ aws iam list-server-certificates
SERVERCERTIFICATEMETADATALIST	arn:aws:iam::xxxxx:server-certificate/your-name	2023-04-30T07:52:00Z	/	ASCAIxxxxxCHES3FxxIQO	cf	2018-05-01T08:17:30Z
{% endhighlight %}

## Specify annotation in Kuberenetes service

Edit service with "`kubectl edit svc {svc-name}`" or you can also edit with the help of K8s dashboard like me. 

{% highlight shell %}
"service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "arn:aws:iam::xxxxx:server-certificate/your-name"
{% endhighlight %}

![_config.yml]({{ site.baseurl }}/assets/k8s-service.jpg)

Now you should able to access endpoint on `https`. 
* For example: `https://xxxx-xxxx.us-east-2.elb.amazonaws.com:9090/graph`

[Check out other AWS service annotations](https://gist.github.com/mgoodness/1a2926f3b02d8e8149c224d25cc57dc1) 