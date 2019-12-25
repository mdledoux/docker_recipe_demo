# docker_recipe_demo
## A simple demo of how to use a Docker recipe and some commands - following up on a conversation with Malcolm

### Commands:
OPTIONAL: \
docker pull httpd \
Your recipe (Dockerfile) says "FROM http" on the first line, which will automatically pull this if not done already


docker image  build -t  olp_image  . \
The "." tells it to build from a local recipse stored HERE. \
I tend to have a prod recipe in "." and a dev recipe in "./dev" (e.g., ./dev/Dockerfile) \
in which case I would use.

```docker image  build -t  olp_image  ./dev/``` \
and it will look for a recipe (a Dockerfile) in that locaiton. \
Or perhaps you want to use a different filename: \
```docker image  build -t  olp_image  ./Dockerfile.dev``` \
which works great, but you might lose your IDE's syntax highlighting.



THIS WILL PROBABLY FAIL, IF PORT 80 is not available:\
```docker run             --name olp_container -d olp_image```\
TRY THIS INSTEAD:\
```docker run -p 8080:80  --name olp_container -d olp_image```\
> 4154aa22a08f19d8cf7ec1aead62eae43c8eeeccd42929d87af0674f5f6f65be

OR  (addition of "--rm" exaplained a bit further down)\
```docker run --rm              --name olp_container -d olp_image```\
```docker run --rm  -p 8080:80  --name olp_container -d olp_image```


```docker container ls```
```
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                NAMES
4154aa22a08f        olp_image             "httpd-foreground"       2 minutes ago       Up 2 minutes        80/tcp               olp_container
```
#### NOTE the hash of the container ID 

IF YOU USE "--rm" it will automatically remove the container as soon as you stop it with:

```docker stop olp_container```

If you didn't use "--rm" then you have to use the 'rm' command if you want to re-run/rebuild it.\
```docker rm olp_container```

OR you can start it back up again\
```docker start olp_container```\
this is the same instance

NOTE if you aren't removing it, you can use   docker start, docker stop, docker start over and over again as long as you want with the same container instance (of the image).\
You ideally wan to remove it every time and rebuild it with docker-run



Launch a bash terminal INTO the container: \
```docker exec -it olp_container bash```\
YOU WILL GET SOMETHING LIKE:
```root@a5b84073a54a:/usr/local/apache2#```\
TRY:\
```root@a5b84073a54a:/usr/local/apache2# composer``` \
THIS IS THE PACKAGE MANAGER FOR INSTALLING PHP MODULES - it requires php-cli, which was installed with "php" in the recipe


NOTE you can run many linux commands, but many seemingly basic commands are missing.\
DO NOT fight this!  It's supposed to be that way!  Don't fight it like I did!!  This is NOT a VM!\
If you do fight it, you're missing both THE POINT and the GLORY of how Docker is meant to be used

For TEMPORAY (non-persistant) purposes, feel free to install tools and run them at the BASH prompt, but only for testing purposes, with the intention of putting those commands into your Dockerfile recipe.\
This is the intended and PROPER usage of Docker.

The goal is to rebuild the container any time a change is made with the latest customizations to ensure that the new settings are seamlessly / smoothly reproducible.  In cases that you want data to persist (e.g., media files, database files, and maybe even source code), you can take advantage of volume mounting



### NOTE - I'm not super fond of where this httpd image puts the files:
/usr/local/apache2/htdocs\
This is a bit suprising considering it is based on Debian.  In the debian-based Drupal image that I use, it puts things into /var/www/html, which is also where the bash brings you when you "terminal in" to the container.

You can set your recipe to do various tasks in certain directories by adjusting the CWD (as many times as necessary)\
```WORKDIR /var/www/html/```\
Whatever the last WORKDIR is, that is where bash/the terminal will bring you.
