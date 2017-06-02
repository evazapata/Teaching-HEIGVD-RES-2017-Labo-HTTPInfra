# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 1 on the branch *fb-apache-static*
### Step 1
First, we created a "docker-images" folder which contains an "apache-php-image" folder in which we create a Dockerfile. What we want to do is, better than to do it by ourselves, go on the DockerHub website and look for a *php* image already officially made.
For this step, we have to go on [DockerHub](hub.docker.com) and search for *httpd* which gets us to the page : [httpd](https://hub.docker.com/_/httpd/). As we just want PHP with Apache httpd, we get the next page through a link on the *httpd* library : [php](https://hub.docker.com/_/php/). The last step is to copy the Dockerfile of *php* inside the Dockerfile we created on our own filesystem:

```
FROM php:7.0-apache
COPY src/ /var/www/html/
```

From this point, we have all the tools to build the image and run the container of the *Apache server*. The runnning of the container has been set with a port mapping `9090:80` allowing us to connect to the IP address of the docker machine (192.168.99.100) and the port of the machine (9090) which is directly connected to the 80 port.

At this point, everything is set to have a bit of fun creating an HTML page. In fact, with the command *docker exec*, we can easily realize that the filesystem of the image is only a filesystem which will contain the HTML files. We created the file *index.html* and we wrote `Hello world` in it. When looking for the page `192.168.99.100:9090` in a browser, we can see the `Hello world` being displayed.
The problem now is that if we kill the container which is currently displaying the web page and run it again, then we wouldn't have the `Hello world` displaying anymore. The solution rests in the Dockerfile. In fact, the second line : `COPY src/ /var/www/html/` is used to copy files from the local machine to the Docker image. We then changed the Dockerfile and created the files needed to display an HTML page.

- Changes in the Dockerfile :

```
FROM php:7.0-apache
COPY content/ /var/www/html/
```

- Changes in the filesystem :

  - The *content* folder contains the index.html and if wanted, other files allowing to get a more beautiful HTML page.
  - To have an astonishing beautiful page, we allowed ourselves to select a one page theme on the site [Start Bootstrap](https://startbootstrap.com/template-categories/one-page/) as the professor did. 

**Careful** : if you want to launch another container, you will have to map it on another port, for example 9091

Plus, the IP address of the container can be found by running the `docker inspect *name of the container*` line. In our case, it is 172.17.0.2.


## Step 2 on the branch *fb-express-dynamic*
### Step 2

