---
layout: post
title: Publish Python Package with PyPI
categories: python pip
comments: true
---
PyPI or Python Package Indexing is a great place to publish Python packages, recently I have published a Python package called `funmotd` to PyPI. Unlike other tutorials, this post is about my experience that I published real working python app and refered many docs to make it work for specific requirement which we will see in a moment. 

First, let's see what is this [`funmotd`](https://github.com/veerendra2/funmotd) package, it's functionality and build the package according to it.

## `funmotd` Package
The idea is to display famous Movies and TV Shows quotes on Terminal as [motd](https://en.wikipedia.org/wiki/Motd_(Unix)) when you open. I want to make the app simple, have local quotes db, should configurable via CLI and easy to install; which boil down below points.
* The app has local db files (python files)
* The app has configuration text file
* The app should accessible via CLI that user can interact 
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

* `funmotd` Directory - Contains actual code (`__init__.py` in `funmotd` directory indicates that `funmotd` is package. More info [here](https://stackoverflow.com/questions/448271/what-is-init-py-for))
* `setup.py` - Packages information
* `MANIFEST.in` - Used to specify include/exclude files


## Packing with `setuptools`
`setuptools` is another python package or module designed to facilitate packaging Python projects. Let's see step-by-step process, how to pack and publish

### 0. Prerequisites    
Install required packages and create account on [https://pypi.org/](https://pypi.org/)
{% highlight shell %}
$ sudo pip install setuptools twine
{% endhighlight %}

### 1. Create `setup.py` which is build script like below
{% highlight shell %}
#!/usr/bin/python3
import setuptools
from setuptools.command.install import install

setuptools.setup(
      name='funmotd',
      version='0.3',
      description='TV Show and Movie Quotes MOTD for Terminal',
      url='https://github.com/veerendra2/funmotd',
      author='Veerendra Kakumanu',
      author_email='veerendra@example.com',
      license='Apache 2.0',
      packages=setuptools.find_packages(),
      entry_points={'console_scripts': ['funmotd = funmotd:main']},
      package_dir={'funmotd': 'funmotd/'},
      package_data={'funmotd': ['config.json'], },
      include_package_data=True,
      python_requires=">=3.4",
      classifiers=[
              "Programming Language :: Python :: 3.4",
              "License :: OSI Approved :: Apache Software License",
              "Development Status :: 4 - Beta"
          ],
      zip_safe=False)
{% endhighlight %}
Most of the arguments are self-explainatory, let's go through some interesting arguments.
#### `name`
Name of the distribution which should be unique on pypi.org

#### `packages` 
List of packages/sub-packages or simply use `setuptools.find_packages()` finds all pacakges automatically

#### `entry_points` as `console_scripts`
As I said, we want to install package as CLI, with the help `console_scripts` type `entry_points`, we can call our function which contains CLI code(`argparse`). The syntax would be 
{% highlight shell %}
entry_points={'console_scripts': ['<your_package_name> = <path_to_module>:<function_name>']}
{% endhighlight %}

For example, if you have project structure like below and you want to call a function `cli_function` in `cli.py` which in `sub_pkg` directory, the syntax should like below
{% highlight shell %}
.
└── my_pkg1
    ├── __init__.py
    └── sub_pkg
        ├── cli.py
        └── __init__.py


entry_points={'console_scripts': ['my_pkg1 = my_pkg1.sub_pkg.cli:cli_function']}
{% endhighlight %}
If the function that want to call is in `__init__.py`, then you just have to specify `<pkg_name>:<function_name>` like below
{% highlight shell %}
entry_points={'console_scripts': ['my_pkg1 = my_pkg1.sub_pkg:cli_function']}
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