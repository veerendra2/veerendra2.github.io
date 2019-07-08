---
layout: post
title: Publish Python Package with PyPI
categories: python pip
comments: true
---
PyPI or Python Package Indexing is great place to publish Python packages, recently I have published a Python package called `funmotd` to PyPI. Unlike other tutorials, I have published real working python app and refered many docs to make it work for specific requirement which we will see in a moment. 

First, let's see what is this [`funmotd`](https://github.com/veerendra2/funmotd) package, it's functionality and build the package according to it.

## `funmotd` Package
The idea is to display famous Movies and TV Shows quotes on Terminal as [motd](https://en.wikipedia.org/wiki/Motd_(Unix)) when you open. I want to make the app simple, have local quotes db, should configurable via CLI and easy to install; which boil down below points.
* The app has local db files (python files)
* The app has configuration text file
* The app has CLI that user can interact 
* Easy to install

{% highlight shell %}
.
├── funmotd
│   ├── config.json
│   ├── __init__.py
│   └── quotes_db.py
├── LICENSE
├── MANIFEST.in
├── README.md
└── setup.py

{% endhighlight %}
Above is my project tree structure which typical file structure for python package.


<table class="tablelines">
 <tr>
  <td>"funmotd" directory </td><td>Contains actual code, "__init__.py" in "funmotd" directory indicates that it is package. According to python standards, the `__init__.py` file should be present in the directory that you want define as package, weather it can be empty file</td>
 </tr>
 <tr>
  <td>setup.py</td><td>Packages information</td>
 </tr>
 <tr>
  <td>MANIFEST.in</td><td> Used to specify include/exclude files</td>
 </tr>

</table>


## Packing with `setuptools`
`setuptools` is another python package or module designed to facilitate packaging Python projects. Let's see step-by-step process, how to pack and publish

### 0. Prerequisites    
Install required packages and create account on [https://pypi.org/](https://pypi.org/)
{% highlight shell %}

{% endhighlight %}


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