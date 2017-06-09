# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
#### Ludovic Delafontaine & Denise Gemesio, HEIG-VD June 2017

## Step 1: Static HTTP server with apache httpd

First, we created a "docker-images" folder which contains an "apache-php-image" folder in which we create a Dockerfile. What we want to do, better than to do it by ourselves, is to go on the DockerHub website and look for an official image that provide us a Web server with *Apache* and *PHP*.
For this step, we have to go on [DockerHub](hub.docker.com) and search for *httpd* which gets us to the page : [httpd](https://hub.docker.com/_/httpd/). As we just want PHP with Apache, we get the next page through a link on the *httpd* library : [php](https://hub.docker.com/_/php/). The last step is to copy the Dockerfile of *php* inside the Dockerfile we created on our own filesystem:

```
FROM php:7.0-apache
COPY src/ /var/www/html/
```

- `FROM php:7.0-apache` describes the version of the php image we want to get.
- `COPY src/ /var/www/html/` gives us the option to copy files inside every container we create from the image. This will be used later.

Thanks to the docker command we launched from the same point as the Dockerfile, the image we built is named *res/apache-php*.

```
docker build -t res/apache-php .
```

To create a container, the last thing to do is launch the following command :

```
docker run -p 9090:80 res/apache-php
```

- The `-p` option allows us to use port mapping and then be connected to the HTTP server created through the IP address and port of the Docker machine (192.168.99.100 and 9090).

At this point, everything is set to have a bit of fun creating an HTML page. In fact, with the command *docker exec*, we can easily realize that the filesystem of the image is only a filesystem which will contain the HTML files. We created the file *index.html* and we wrote `Hello world` in it. When looking for the page `192.168.99.100:9090` in a browser, we can see the `Hello world` being displayed.

The problem now is that if we kill the container which is currently displaying the web page and run it again, then we wouldn't have the `Hello world` displaying anymore. The solution rests in the Dockerfile. In fact, the second line : `COPY src/ /var/www/html/` is used to copy files from the local machine to the Docker image. We then changed the Dockerfile and created the files needed to display an HTML page.

- Changes in the Dockerfile :

```
FROM php:7.0-apache
COPY content/ /var/www/html/
```

- Changes in the filesystem :

  - The *content* folder contains the index.html and if wanted, other files allowing to get a more beautiful HTML page.
  - To have an astonishing beautiful page, we allowed ourselves to select a one page theme on the site [Start Bootstrap](https://startbootstrap.com/template-categories/one-page/) and modify it as the professor did.

**Careful** : if you want to launch another container, you will have to map it on another port, for example 9091

Plus, the IP address of the container can be found by running the `docker inspect *name of the container*` line. In our case, it is 172.17.0.2.

If you want to access the configuration files, you will have to launch the following command :

```
docker exec -it *the name of the container* /bin/bash
```

It will give access to the filesystem of the Docker container in which you can find the configuration files by going to the following folder : `/etc/apache2`.

### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker` and may need to run the script as `root`
