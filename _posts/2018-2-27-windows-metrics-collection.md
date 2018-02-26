---
layout: post
title: Windows OS metrics collection with Telegraf 
categories: windows metrics
---

Ok, getting metrics(CPU, Memory & Network) from Windows OS is completely different from Linux. In Linux, people can easily develop scripts to get system metrics by simply reading [/proc](https://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/proc.html) pesudo files. In fact there are so many open source tools to do this in Linux, like [tcollector](https://github.com/OpenTSDB/tcollector) which is my favourite.

Ok, enough talking about Linux, lets look at this [Telegraf tool](https://www.influxdata.com/time-series-platform/telegraf/) and what it does. I found Telegraf tool is really simple and elegant way to collect Windows OS metrics and light weight also, unlike others which some are paid and crappy. This tools doesn't provide any wizard installation to setup but one has to run a command in Windows powershell to install Windows service. It supports multiple TSDB backend storage like Graphite, OpenTSDB, etc but I have tested only with OpenTSDB.

As they said in [Github repo](https://github.com/influxdata/telegraf) and I quote


>Telegraf is an agent written in Go for collecting, processing, aggregating, and writing metrics.
>
>Design goals are to have a minimal memory footprint with a plugin system so that developers in the community can easily add support for collecting metrics from local or remote services.
>

* Goto influxdata download portal and [download `Telegraf` zip file](https://portal.influxdata.com/downloads)

* Create a folder and name it as “Telegraf” in “C:\Program Files” and extract the .zip content to “Telegraf” folder (C:\Program Files\Telegraf)

* Download telegraf configuration from [here (telegraf.conf)]({{ "/assets/telegraf.conf" | absolute_url }}) and place it in “C:\Program Files\Telegraf”
  * Specify OpenTSDB server IP in `outputs.opentsdb` section in the configuration


![Application Location]({{ "/assets/app-location.JPG" | absolute_url }}){: .center-image }

* Open “Windows PowerShell” with administrator rights(Run as administrator) and paste below command to create “windows service”

  {% highlight shell %}
  C:\"Program Files"\Telegraf\telegraf.exe --config C:\"Program Files"\Telegraf\telegraf.conf –-service install
  {% endhighlight %}


![Command Run]({{ "/assets/cmd-run.JPG" | absolute_url }}){: .center-image }

* In Windows `Services`, you should see `Telegraf` service. Right-click on the Telegraf service, open `“Properties”-> Select “Automatic”` for “Startup Type” and click “Start” button to start the Telegraf service.


![Windows Service]({{ "/assets/service.JPG" | absolute_url }}){: .center-image }


You should able to see [these metrics]({{ "/assets/telegraf_metrics.txt" | absolute_url }}) in your OpenTSDB

* Docs - [https://docs.influxdata.com/telegraf/v1.5/introduction/getting_started/](https://docs.influxdata.com/telegraf/v1.5/introduction/getting_started/) 
 