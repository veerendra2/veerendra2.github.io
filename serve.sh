#!/bin/bash


sudo docker rm -f jekyll > /dev/null 2>&1
sudo docker run -d --name=jekyll \
-v ${PWD}:/srv/jekyll -v ${PWD}/_site:/srv/jekyll/_site \
veerendrav2/my-jekyll:latest /bin/bash -c "chmod 777 /srv/jekyll && jekyll serve"

IP=`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jekyll`

echo "http://$IP:4000"

