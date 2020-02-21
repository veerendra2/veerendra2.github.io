#!/bin/bash

sudo docker run \
-v ${PWD}:/srv/jekyll -v ${PWD}/_site:/srv/jekyll/_site \
veerendrav2/my-jekyll:latest /bin/bash -c "chmod 777 /srv/jekyll && jekyll build --future"

