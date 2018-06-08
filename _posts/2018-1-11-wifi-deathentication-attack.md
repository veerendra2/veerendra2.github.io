---
layout: post
title: Wifi De-authentication attack
categories: linux python wifi security
---
>A Wi-Fi deauthentication attack is a type of denial-of-service attack that targets communication between a user and a Wi-Fi wireless access point.
>
> -Wikipedia

As you can see, this type of attack is pretty powerful and difficult  to detect who is attacking. There are some tools(like “aircrack-ng”) for this attack(You can check the commands [here](https://www.aircrack-ng.org/doku.php?id=deauthentication)).

So, basically the concept is the attacker broadcasts a wifi management “De-authentication” frame to victim’s to tell deauthenticate. It is like, “Hey client! Can you please deauthenticate and authenticate”. Then the client will reconnect to the AP (Access Point). These types of frames are supposed to send by valid “AP” to its clients, but the attacker can mimic these frames and broadcasts in the network.

Interestingly, the victim’s laptop/device could not differentiate between attacker and valid AP. Here, the attacker creates “De-authentication” packet/frame with source MAC address from valid AP’s MAC address. So, every device thinks, the management frame came from valid AP.

The attacker not just send the frame once, but sends continuously. Things get pretty bad, now the clients continuously trying to reconnect. In this way, the clients never connect to its valid AP until the attacker stops sending the “deauth” frames.

I automated these steps with Python. I used “scapy” module to send “deauth” frames.

Want to try this script? run bellow commands.

##### Dependencies
wireless
Install `aircrack-ng` and `scapy`
{% highlight shell %}
sudo apt-get install aircrack-ng -y
sudo apt-get install python-scapy -y
{% endhighlight %}

##### Download and run the script

{% highlight shell %}
sudo wget -O deauth.py https://goo.gl/5gGHbE
sudo python deauth.py
{% endhighlight %}

When you run the command, you should see like bellow.

![Help]({{ "/assets/blog-image1.jpg" | absolute_url }}){: .center-image }

![Command Run]({{ "/assets/blog-image2.jpg" | absolute_url }}){: .center-image }

When you start the script, it will create “mon0” interface(A monitoring virtual interface used to send our deauth frames) and observes wifi signals. After few seconds, it will display near APs and its MAC addresses. Choose one to broadcasts the “deauth” frames to that network which results network outage for connected clients to that AP.

> NOTE: Inorder to work deauthentication attack successful, you should near to the target network. The deauth packets should reach the connected devices of the target network

## So, how to avoid this attack?

Simple, use “802.1w” supported routers. Know more about [802.1w](https://en.wikipedia.org/wiki/IEEE_802.11w-2009) and read [cisco document](http://www.cisco.com/c/en/us/td/docs/wireless/controller/technotes/5700/software/release/ios_xe_33/11rkw_DeploymentGuide/b_802point11rkw_deployment_guide_cisco_ios_xe_release33/b_802point11rkw_deployment_guide_cisco_ios_xe_release33_chapter_0100.pdf) here

Check out my repo below for more info. Use my [docker image](https://github.com/veerendra2/wifi-sniffer) to kick the environment quickly.

> Github Repository Link
>
> https://github.com/veerendra2/wifi-deauth-attack


