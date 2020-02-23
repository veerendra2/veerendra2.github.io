---
layout: post
title: CI/CD for GitHub Pages with GitHub Actions
categories: jekyll
comments: true
---
Looks like my blog posts are like Sherlock TV Show episodes, posting once in a while..anyways I'm back now. As you might aware GitHub recently launched [GitHub Actions](https://github.com/features/actions) which people can automate workflows like build, test, deploy code from GitHub.

I have started reading docs little bit, I got to admit, setting up workflows on GitHub Actions is not that hard. I can directly start creating workflow from available workflow templates in "Actions" tab. Then I saw workflow template for "Jekyll Site CI/CD", builds Jekyll site. I got some feeling that I automate my workflow of building and deploying my blog (which currently you are reading) on [GitHub Pages](https://pages.github.com/). So, Let's see how did I setup CI/CD

But first let me explain how my blog site works and then manual steps every time I do to publish a blog.
## GitHub Pages
This blog site is powered by GitHub Pages which you can publish static html site right from GitHub repository (For example my repo [here](https://github.com/veerendra2/veerendra2.github.io)). All you have to do is to create a repo name like `<YourGitHubUsername>.github.io` and drop static html pages in `master` branch. That's it, GitHub do the magic, serves your website.

For this, I'm maintaining 2 branches, one for my markup source files in [`source` branch](https://github.com/veerendra2/veerendra2.github.io/tree/source) and another for static html site in [`master` branch](https://github.com/veerendra2/veerendra2.github.io)

![Branch Image]({{ "/assets/branch_image1.jpg" | absolute_url }}){: .center-image }

## Jekyll
Everything's good so far, but we know that we are too lazy to write html pages. So, that's where this tool ["Jekyll"](https://jekyllrb.com/) comes into picture, converts markup files to static html website. Once you `jekyll build`, it will build static website in `_site` directory. For local testing you can run `jekyll serve` to see how site looks.(Checkout my other [post to know how to install jekyll](https://veerendra2.github.io/jeklly-website/))

## My Manual Workflow
1. Write blog post in markup files which I keep in `source` branch (Obviously I can not automate this step :-P)
2. Run `jekyll build` to build static website
3. Copy static website content from `_site` to `master` branch
4. Push `master` branch changes to repo to publish website
5. Push `source` branch changes to repo to store/version tracking

## GitHub Actions
Below is the `jekyll.yml` to automate my workflow

<script src="https://gist.GitHub.com/veerendra2/e049bbf03637413e94a2632ad3f20781.js"></script>

Let's go thought the `jekyll.yml` line by line very briefly

<table class="tablelines">
 <tr>
  <th>Line No.</th>
  <th>Description</th>
 </tr>
 <tr>
  <td>3</td>
  <td>Event subscription; I want to trigger the workflow only when there is any push in "source" branch</td>
 </tr>
  <tr>
  <td>11</td>
  <td>I want to run this build procedure on ubuntu box(GitHub action supports other box as well like windows, mac, etc)</td>
 </tr>
 <tr>
  <td>16</td>
  <td>In order to build, first I have to clone the repo, for this, there is ready made action called "actions/checkout@v2" which checkouts my repo with "source" branch</td>
 </tr>
  <tr>
  <td>21</td>
  <td>Since I can't expect GitHub servers has "jekyll" installed, so I built my own docker image for jekyll with dependency gems to build website. (You can find other jekyll docker image, I'm using older version of jekyll, that's why I built my own)</td>
 </tr>
 <tr>
  <td>28</td>
  <td>I want to push static website to "master" branch, so I have to checkout "master" branch as well</td>
 </tr>
  <tr>
  <td>33</td>
  <td>Copy "_site" content to master branch</td>
 </tr>
  <tr>
  <td>37</td>
  <td>Normal shell commands, git add and git commit</td>
 </tr>
   <tr>
  <td>44</td>
  <td>Finally push changes to "master" to publish website with help of using ready made action "ad-m/GitHub-push-action@master"</td>
 </tr>
</table>

Now, all I have to do is drop `jekyll.yml` in `.github/workflows/` directory to GitHub pickup my workflow. Below is the picture shows pipeline for my website deployment.

![Pipeline Image]({{ "/assets/pipeline.png" | absolute_url }}){: .center-image }



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
