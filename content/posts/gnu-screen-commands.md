---
title: GNU screen commands(Cheat Sheet)
date: 2018-01-08T22:10:22+02:00
slug: "gnu-screen-commands"
author: Veerendra K
tags:
  - linux
  - screen
---


>GNU Screen is a terminal multiplexer, a software application that can be used to multiplex several virtual consoles, allowing a user to access multiple separate login sessions inside a single terminal window, or detach and reattach sessions from a terminal. It is useful for dealing with multiple programs from a command line interface, and for separating programs from the session of the Unix shell that started the program, particularly so a remote process continues running even when the user is disconnected. [more](https://en.wikipedia.org/wiki/GNU_Screen)
>
>-Wikipedia

* Install `screen`

```
$ sudo apt-get install screen
```



| Keys/Commands                                            | Description                      |
| -------------------------------------------------------- | -------------------------------- |
| screen                                                   | Enables Screen                   |
| `Ctrl`+`a` and then `c`                                  | Create new screen                |
| `Ctrl`+`a` and then `n`                                  | Go to next screen                |
| `Ctrl`+`a` and then `p`                                  | Go to previous screen            |
| `Ctrl`+`a` and then `Shift`+`s`                          | Split screen horizontally        |
| `Ctrl`+`a` and then `Shift`+`\`                          | Split screen vertically          |
| `Ctrl`+`a` and then `Tab`                                | Traverse between splited screens |
| `Ctrl`+`a` and then `Shift`+`x`                          | Unsplit screens                  |
| `Ctrl`+`a` and then `Esc` (Hit `Esc`, once you are done) | Scroll screen                    |
| `Ctrl`+`a` and then `d`                                  | Detach screens                   |
| `screen -r <PID>`                                        | Reattach screen                  |
| `screen -ls`                                             | List screens                     |
| `screen -S <session>`                                    | Attach screen                    |
| `screen -XS <session> quit`                              | Kills screen                     |


### Few more in my [Github Gist](https://gist.github.com/veerendra2/2d250c007b49fa213787a465fa1862a6)
<script src="https://gist.github.com/veerendra2/2d250c007b49fa213787a465fa1862a6.js"></script>

