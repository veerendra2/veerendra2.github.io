---
layout: post
title: Encrypt your DNS queries, stay anonymous
categories: linux security
---
We think if we connect to a website over HTTPS is secure which is true(not true sometimes!), but what about DNS queries that you(browser) sent?

![HTTPS Example]({{ "/assets/https_example.jpg" | absolute_url }}){: .center-image }

Sure if we use HTTPS, all your ([POST](https://en.wikipedia.org/wiki/POST_(HTTP)) or GET) data is encrypted end-to-end which prevents eavesdropping, [MITM attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) and have [Confidentiality](https://en.wikipedia.org/wiki/Confidentiality), but again what about DNS queries?

I got this question back in a while, so after a quick Internet search, I found [DNSCrypt](https://en.wikipedia.org/wiki/DNSCrypt) protocol which is really cool that I can encrypt DNS queries.

First of all what the heck is [DNS](https://en.wikipedia.org/wiki/Domain_Name_System)? in simple, DNS or Domain Name System is a service that resolves/translates domain "name" to "IP" or vice versa. So once you hit google.com in your browser, a [DNS query](https://serverfault.com/questions/173187/what-does-a-dns-request-look-like) fired to DNS host(for example 8.8.8.8) like asking "what is the IP of google.com" and gets DNS responses which contains IP of google.com. Now we got the IP of google.com, browser initiates connection and establish HTTPS.

So, you see these DNS queries are not part of "HTTPS". So let's encrypt DNS queries with DNCrypt.

>Why should we care about "DNS queries encryption"? well, sometimes the eavesdroppers are interested in meta data of communication rather than actual communication.

## What is [DNSCrypt](https://dnscrypt.org/)?

*DNSCrypt is a protocol that authenticates communications between a DNS client and a DNS resolver. It prevents DNS spoofing. It uses cryptographic signatures to verify that responses originate from the chosen DNS resolver and haven't been tampered with.*

*It is an open specification, with free and opensource reference implementations, and it is not affiliated with any company nor organization.*

There are some points to be noted

* In order to use this protocol, we should install a package called [dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy)
* Normal name servers(like 8.8.8.8) won't support this protocol. We should use [these](https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv) DNS resolvers
* `dnscrypt-proxy` by default binds on loopback interface (127.0.0.1) 53 port. So, have to do tittle configuration change.

### 1. Install dnscrypt-proxy

From Ubuntu 16/ Linux Mint 18.x, dnscrypt-proxy is available in the offical repo.
{% highlight shell %}
sudo apt-get install dnscrypt-proxy
{% endhighlight %}
I found a PPA for Ubuntu 14.04 and Linux Mint 17.x
{% highlight shell %}
sudo add-apt-repository ppa:anton+/dnscrypt
sudo apt-get update
sudo apt-get install dnscrypt-proxy
{% endhighlight %}

### 2. Start `dnscrypt-proxy`

After installation, with `--help` argument get options and run accordingly. But luckily I created a python script which will do it for you.
{% highlight shell %}
wget -qO dnscrypt.py https://goo.gl/zjZYVR
sudo python dnscrypt.py
{% endhighlight %}
After you run the script, it will lists the DNS reslovers details like below.(The script downloads [reslovers csv](https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv) and passes this file as argument to `dnscrypt-proxy``)

![Run the script]({{ "/assets/command_run.jpg" | absolute_url }}){: .center-image }

Select one name sever. You can see these name servers have options [`DNSSec`](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) & `No Loggging` which provider can logs your queries, choose one accordingly (These options/table header you cant see in above screeshot. You have to scroll up)

Next, configure your network settings like below

![Network Config]({{ "/assets/network_config.jpeg" | absolute_url }}){: .center-image }

Restart network (disconnect and connect wifi) and your done! 

To verify run `tcpdump -i any -n port 2053` (Why `2053` port? because in above screenshot I selected `66` option which has `178.216.201.222:2053`)

##### What's happening?

![Diagram]({{ "/assets/diagram.png" | absolute_url }}){: .center-image }


## Go beyond this script!
I create `init` script which runs at system boot. So that no need to run above script again and again.

* Download [reslovers csv](https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv) file with --> `python dsncrypt.py -d`
* Specify `resolver_name`(By default it has `soltysiak` which has `No Logging` policy and `DNSSec`) in the script.

{% highlight shell %}
sudo wget -O /etc/init.d/encryptdns https://goo.gl/opZ78J
sudo chmod +x /etc/init.d/encryptdns
sudo update-rc.d encryptdns defaults
sudo service encryptdns start
{% endhighlight %}

> Github Repository Link
> 
> https://github.com/veerendra2/useless-scripts

## DNSCrypt in Windows
* [Simple DNSCrypt](* https://simplednscrypt.org/)


![Simple DNSCrypt]({{ "/assets/DNSCrypt-Windows.JPG" | absolute_url }}){: .center-image }

Other resources you can try
* [https://github.com/jedisct1/dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy)
