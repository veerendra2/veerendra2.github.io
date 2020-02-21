---
layout: post
title: Install jekyll in Ubuntu 14.04
categories: jekyll
---
I was very excited to try [`Jekyll`](https://jekyllrb.com/) and [Github Pages](https://pages.github.com/) when I heard about it. When I try to install `jekyll`, I got below error 
{% highlight shell %}
root@veeru:/home/veeru# gem install jekyll bundler
Fetching: public_suffix-3.0.1.gem (100%)
ERROR:  Error installing jekyll:
	public_suffix requires Ruby version >= 2.1.
Fetching: bundler-1.16.1.gem (100%)
Successfully installed bundler-1.16.1
1 gem installed
Installing ri documentation for bundler-1.16.1...
Installing RDoc documentation for bundler-1.16.1...
{% endhighlight %}

I din't even know what that means(I'm not a Ruby guy, so..). Clearly `jekyll` needs more then Ruby version 2.1, but in Ubuntu 14.04 if you type `apt-get install ruby -y` you will end up having Ruby 1.9. So lets install Ruby2.4 like below

{% highlight shell %}
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install ruby2.4 ruby2.4-dev make g++ -y
{% endhighlight %}

Then install `jekyll`

{% highlight shell %}
gem install jekyll bundler
{% endhighlight %}

### What's next?
I found a blog which exactly I was look for to deploy website on Github Pages. As Drew Silcock said in the blog, it better to maintain website source code and compiled website on same repository. Just head over to his [blog](https://drewsilcock.co.uk/custom-jekyll-plugins) and check the stuff