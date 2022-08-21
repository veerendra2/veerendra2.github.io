---
title: GNU screen commands(Cheat Sheet)
date: 2018-01-08T22:10:22+02:00
slug: "gnu-screen-commands"
author: Veerendra K
categories: linux
---


>GNU Screen is a terminal multiplexer, a software application that can be used to multiplex several virtual consoles, allowing a user to access multiple separate login sessions inside a single terminal window, or detach and reattach sessions from a terminal. It is useful for dealing with multiple programs from a command line interface, and for separating programs from the session of the Unix shell that started the program, particularly so a remote process continues running even when the user is disconnected. [more](https://en.wikipedia.org/wiki/GNU_Screen)
>
>-Wikipedia

* Install `screen`

{% highlight shell %}
$ sudo apt-get install screen
{% endhighlight %}



<table class="tablelines">
<tr>
 <th>Keys/Commands</th><th>Description</th>
</tr>
<tr>
 <td>screen</td><td>Enables Screen</td>
</tr>
<tr>
 <td>Ctrl+a and then c</td><td>Create new screen</td>
</tr>
<tr>
 <td>Ctrl+a and then n</td><td>Go to next screen</td>
</tr>
<tr>
 <td>Ctrl+a and then p</td><td>Go to previous screen</td>
</tr>
<tr>
 <td>Ctrl+a and then Shift+s</td><td>Split screen horizontally</td>
</tr>
<tr>
 <td>Ctrl+a and then Shift+\</td><td>Split screen vertically</td>
</tr>
<tr>
 <td>Ctrl+a and then Tab</td><td>Traverse between splited screens</td>
</tr>
<tr>
 <td>Ctrl+a and then Shift+x</td><td>Unsplit screens</td>
</tr>
<tr>
 <td>Ctrl+a and then Esc (Hit Esc, once you are done)    </td><td>Scroll screen</td>
</tr>
<tr>
 <td>Ctrl+a and then d</td><td>Detach screens</td>
</tr>
<tr>
 <td>screen -r PID</td><td>Reattach screen</td>
</tr>
<tr>
 <td>screen -ls</td><td>List screens</td>
</tr>
<tr>
 <td>screen -S [session] </td><td>Attach screen</td>
</tr>
<tr>
 <td>screen -XS [session] quit</td><td>Kills screen</td>
</tr>
</table>

### Few more in my [Github Gist](https://gist.github.com/veerendra2/2d250c007b49fa213787a465fa1862a6)
<script src="https://gist.github.com/veerendra2/2d250c007b49fa213787a465fa1862a6.js"></script>

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
