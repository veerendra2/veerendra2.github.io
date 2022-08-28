---
title: Moving to Hugo and other updates!
date: 2022-08-27
slug: "moving-to-hugo"
author: Veerendra K
tags: [hugo]
ShowToc: true
---

It has been 2 year since I wrote a new post. Due to busy work and moving to a new city, new jobs and getting married, I wasn’t able to keep up posts. Finally I’m back now, I have been thinking of changing blog themes for a long time. I spent some time on Jekyll themes and tried to modify them according to my requirements. As you can see [here](https://github.com/veerendra2/veerendra2.github.io/tree/6-New-theme-and-remove-disqus) my feature branch.

# Hugo
![Hugo Image](/hugo.svg)
But a month ago I discovered [Hugo](https://gohugo.io/), a static website builder like Jekyll, so I decided to take a look at it. And thus I decided to move to Hugo, because of its speed, simple and single binary

Just like Hugo, I discovered Jekyll a few years back, as you can see from [my old blog post]({{< ref "jeklly-website" >}} "my old blog post"). After using Jekyll for a while I see below annoying things while building and installing Jekyll everytime I change the OS in my laptop. [#7](https://github.com/veerendra2/veerendra2.github.io/issues/7)

1. Jekyll is relatively slow
2. I get confuse with gems versions and its dependencies while picking new themes
3. Screw up my system ruby packages with other packages like Vagrant etc. because of that I had to use docker containers and these some permissions issues, etc.

So, when I see Hugo, it solved my above problems
1. It is faster like they say in their website
2. To install new theme, I can use git module or simply drop the theme in themes directly and configure
3. Single binary! No BS!
4. Simple directory structure

Now my blog is powered by Hugo :tada:

# Other updates
* I removed [disqus](https://disqus.com/) tool for commenting, moved to Github discussion with tool [https://giscus.app](https://giscus.app/)
* From now onwards I will try to keep up the blogs regularly. I’m planning some “nugget” blogs like small posts contains info from book I’m reading or may be some my troubleshooting on tools, etc. :crossed_fingers:

