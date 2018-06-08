---
layout: post
title: Why my container is getting permission denied on Openshift but not on Kubernetes?
categories: Openshift Kubernetes
---

Welcome back people, this time we will look at Openshift permissions. Recently I have been working on Openshift and I found it is dealing users in container differently unlink kubernetes, I'm able launch my application/container on Kubernetes but not on Openshift. In container logs I see permission denied error which is strange(it is not!). After I did some research, it is Openshift default behaviour to "prevent process inside container run as root user".

Let's start from docker and then Openshift.  

## The Docker Containers
First of all, I want to talk about Docker containers briefly. If you take a closer look at the docker container, it is nothing but a "process" having [cgroups](https://en.wikipedia.org/wiki/Cgroups) constraints and linux [namesapces](https://en.wikipedia.org/wiki/Linux_namespaces). So, when an process running in a container is no difference from normal process running in host i.e containers are trusted boundaries. Generally we knew it is not recommended to run a process as root, same rule does apply here too i.e If process running in container as root is equal to process running as root in host.  

To understand this, I have create a file `/opt/secret.txt` which `root` can only edit it and normal user `veeru` can't. Now we will try to edit `secert.txt` from docker container and see that is possible or not.

* Launch a docker container
{% highlight shell %}
$ docker run -it -d -v /opt/:/opt/ ubuntu:latest
{% endhighlight %}

* Now let's go inside the docker(which means `exec` the `/bin/bash`) and edit the `/opt/secert.txt`. 
{% highlight shell %}
$ docker exec -it ad143a661dcbd16 /bin/bash
root@ad143a661dcb:/# echo "Are you sure about that?" >> /opt/secret.txt
{% endhighlight %}

![DockerDemo]({{ "/assets/docker.gif" | absolute_url }}){: .center-image } 



You can see something happened when I run `docker exec` command, I went inside the docker container as "root". I didn't specify any user while launching container, but I'm root. This is because docker's default behaviour, if we don't specify ["UID"](http://www.linfo.org/uid.html) while launching docker, it will be `root` i.e UID is 0. Same happens if you don't specify `USER` in Dockerfile while create Docker image, your application or process run as root user.

## Openshift
Now lets do some observation in Openshift and Kubernetes.

For sake of this blog I have create a simple and dummy application run that runs in tomcat servlet container.

The `Dockerfile`
{% highlight shell %}
FROM ubuntu:14.04
MAINTAINER Veerendra Kakumanu
RUN apt-get update && apt-get install --no-install-recommends software-properties-common -y && add-apt-repository ppa:openjdk-r/ppa -y
RUN apt-get update && apt-get install openjdk-8-jdk -y
ADD http://www-eu.apache.org/dist/tomcat/tomcat-7/v7.0.86/bin/apache-tomcat-7.0.86.tar.gz /opt/apache-tomcat-7.0.86.tar.gz
COPY run.sh /bin/run.sh
RUN tar -xf /opt/apache-tomcat-7.0.86.tar.gz -C /opt && chmod +x /bin/run.sh
ADD https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war /opt/apache-tomcat-7.0.86/webapps/sample.war
CMD ["run.sh"]
{% endhighlight %}

`run.sh`
{% highlight shell %}
#!/bin/bash
sed -i -e 's/8080/8161/g' /opt/apache-tomcat-7.0.86/conf/server.xml
sh /opt/apache-tomcat-7.0.86/bin/startup.sh
while :;
do
  sleep 100
done
{% endhighlight %}

The Dockerfile is nothing but a Ubuntu 14.04 base image, java installation and a tomcat with sample app. `run.sh` runs while starting of container. 

>I've see some docker image are like this i.e. modifying config files or create directories while starting of container 

##### Reference Links
* Docker
  * [https://opensource.com/business/14/7/docker-security-selinux](https://opensource.com/business/14/7/docker-security-selinux)
  * [https://medium.com/@mccode/understanding-how-uid-and-gid-work-in-docker-containers-c37a01d01cf](]https://medium.com/@mccode/understanding-how-uid-and-gid-work-in-docker-containers-c37a01d01cf)
  * [https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b](]https://medium.com/@mccode/understanding-how-uid-and-gid-work-in-docker-containers-c37a01d01cf)
* Openshift 
  * [http://lists.openshift.redhat.com/openshift-archives/users/2017-May/msg00060.html](http://lists.openshift.redhat.com/openshift-archives/users/2017-May/msg00060.html)
  * [https://docs.openshift.org/latest/admin_guide/manage_scc.html](https://docs.openshift.org/latest/admin_guide/manage_scc.html)
  * [https://docs.openshift.org/latest/architecture/additional_concepts/authorization.html](https://docs.openshift.org/latest/architecture/additional_concepts/authorization.html)
  * [https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities)