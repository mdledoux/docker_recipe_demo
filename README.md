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
```docker run -p 8080:80  --name olp_container -d olp_image```
> 4154aa22a08f19d8cf7ec1aead62eae43c8eeeccd42929d87af0674f5f6f65be

OR  (addition of "--rm" exaplained a bit further down)\
```docker run --rm              --name olp_container -d olp_image```\
```docker run --rm  -p 8080:80  --name olp_container -d olp_image```


```docker container ls```
```
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                NAMES
4154aa22a08f        olp_image             "httpd-foreground"       2 minutes ago       Up 2 minutes        80/tcp               olp_container
```
***NOTE the hash of the container ID***

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


### NOTE you can run many linux commands, but many seemingly basic commands are missing.
DO NOT fight this!  It's supposed to be that way!  Don't fight it like I did!!  This is NOT a VM!\
If you do fight it, you're missing both THE POINT and the GLORY of how Docker is meant to be used

For TEMPORAY (non-persistant) purposes, feel free to install tools and run them at the BASH prompt, but only for testing purposes, with the intention of putting those commands into your Dockerfile recipe.\
This is the intended and PROPER usage of Docker.

The goal is to rebuild the container any time a change is made with the latest customizations to ensure that the new settings are seamlessly / smoothly reproducible.  In cases that you want data to persist (e.g., media files, database files, and maybe even source code), you can take advantage of volume mounting

Additionally, the base OS of the image(s) you may be using are not necessarily important.  They may be, but the point of containerization is to get the service you are looking for available to you quickly.  For example, you may want a databse and a webserver, so you would look for an apache or nginx image, and you would look for a PostGreSQL image - in each case you are interested in the service that the image provides when run as a container, and not concerned about the underlying OS (in fact, the idea is that you should be able to get it up and running - maybe passing some environment variables - without the need to know about the OS and how to get the particular service up and running.  Someone else has done that for you - you focus on building your application which uses these services, and let others worry about how to get them up and running.

This is a common case for using docker-compose (probably installed separately) whereby you create an application from a set of services - a database and a web server and a map tiling engine (e.g., postgres, apache, and mapserver) are all composed together, and communicate with eachother via their own private network.  Containers on the hosting system that are not part of this composition cannot talk to any of those containers.

You might respond "What if a particular OS doesn't have a certain tool that I need".  Well, theoretically that tool would be on your development system, OR if it needs to be in a certain container, and only one Linux distro offers a certain application, then you would choose that as your base image (if making your own image, but most likely someone else already made an image and it is already using the distro that provides it).  Other tools that you might need should be pretty standard to all distros (curl, wget, git, gnupg, unzip, sqlite3,...and languages like perl, python, ruby, etc...)

I'm mostly avoid putting vim into an image unless I'm actively trying to tweak with files to get a configuration working - but once I do, I take those customizations and integrate them into my recipe.  I might use ```RUN echo "asdf" >> file.conf"``` to append a line to a conf file, or I might use sed to modify a configuraiton in a file, or a value in a databse:\
```RUN sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /var/lib/postgresql/data/postgresql.conf```


### Persisting files across rebuilds / Volume mounting:
This might be useful for persisting the postgres datafiles for a database container - when changing a config, you might still want the same popualted database.  (though in other cases you may want that wiped out every time and always import SQL backup files to always revert to a precise known state, such as after running a bunch of tests that might populate your DB with garbage data - the DB should be reverted before the next test run).

ANOTHER USECASE migth be accessing log files - you might want to save the log files, or be able to acess them from your desktop, rather than having to bash-terminal into the container to view them.
```
docker run --rm 
  -p 8080:80  --name olp_container -d olp_image 
  -v $PWD/logs:/var/logs/apache2
```

Or, even mount two locations:
```
docker run --rm 
  -p 8080:80  --name olp_container -d olp_image 
  -v $PWD/logs:/var/logs/apache2
  -v $PWD/web/htdocs:/var/www/html/ 
```
The latter volume-mount mounts the htdocs folder in your local repo's "web" folder (repo/web/htdocs), and maps it to the standard debian web root location.  (this was just to have a parent folder for all web resources, including CGIs or scripts relative to the web aspect, as opposed to the database asepct)



### Docker in Production (vs development)
In our conversation we discussed using Docker in prod, but also that using Docker in dev made more sense to you.  I commented that it has historically been the reverse, and it seems to me that Docker in dev is more recent thing as more people are getting familiar and comfortable with Docker.  The 2nd volume mounting example above provides a way to keep your web source files local, and you are able to view the site without a redeploy (rebuilding the container wtih the new code).

In production you might
1. copy the source code to the container image (while building the image, before running a container
2. or even pull the repo via git in the image.  It makes a case for either https checkouts or having a set of SSH keys for the build system to access git repo while building the image.

but in dev you can mount those files onto the system to not have to trigger your build process for code changes.

One of the concerns you raised with with regard to overhead/resources on devlopment.  Certainly, running containers in Docker adds some overhead, but it is doubtfully a heavy hit - the benefits would tend to out-weigh the extra resource overhead.  The key benefit to consider is that your application is entirely containerized, and that is the reason for using Docker in production (as opposed to the newer use-case of using it for dev).  It's great for devs to get "on-boared" to a project when hired to a project that is in progress, but that's a newer use-case.

The real value of Docker is the complete isolation it gives your application in production, and the platform independence.\
When running various "dockerized" applications on a server, they are all completely independent of eachother - a configuration change to one app can't mess up the configuration of another.  With containerization, no longer are the days of adjusting an Apache setting for one vhost, and accidentally taking down other/all of the vhosts because of a bad setting.  Also, if a site is hacked, only that site is hacked, and not the other containerized apps on that server.\
In the case of using Docker for both dev and prod, discrepencies between dev and prod systems are almost entirely eliminated.  There's no more "it works on my machine".  You may develop on Windows, I may develop on Mac, and we may deploy to a Linux server, but all of the containers will run exactly the same in any system with Docker, because of the containers built on standard images.


### NOTE - I'm not super fond of where this httpd image puts the files:
/usr/local/apache2/htdocs\
This is a bit suprising considering it is based on Debian.  In the debian-based Drupal image that I use, it puts things into /var/www/html, which is also where the bash brings you when you "terminal in" to the container.

You can set your recipe to do various tasks in certain directories by adjusting the CWD (as many times as necessary)\
```WORKDIR /var/www/html/```\
Whatever the last WORKDIR is, that is where bash/the terminal will bring you.


### Examples with NodeJS and PostGreSQL, brought together with docker-compose
Here is a couple of tutorials that helped me a lot:
1. https://www.linode.com/docs/applications/containers/docker-container-communication/
2. https://www.linode.com/docs/applications/containers/how-to-use-docker-compose/

The first one is a nice simple, gradual, and progressive example.  It starts off by setting up Docker, installing PostGres locally on your hosting system, and making a recipe for an image tha would use NodeJS to run a simple web server.  The source code run via Node simply connects to the PG databse on the hosting machine.  Then a Postgres container is downloaded and lauched and the app is reconfigured to access that container by linking the web server to the database server.  Finally the entire process of running these different containers at the commandline and setting up their network is all automated by a simple docker-compose file which runs an integrated set or system of containers together - potentially starting and stopping them together in the order of their dependencies (database first, then web server, etc...).

The second URL dives more into docker-compose, which should provide more insites after that initial example.
