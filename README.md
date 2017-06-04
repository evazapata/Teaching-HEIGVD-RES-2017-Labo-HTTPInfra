# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 1 (on the branch *fb-apache-static*)

First, we created a "docker-images" folder which contains an "apache-php-image" folder in which we create a Dockerfile. What we want to do is, better than to do it by ourselves, go on the DockerHub website and look for a *php* image already officially made.
For this step, we have to go on [DockerHub](hub.docker.com) and search for *httpd* which gets us to the page : [httpd](https://hub.docker.com/_/httpd/). As we just want PHP with Apache httpd, we get the next page through a link on the *httpd* library : [php](https://hub.docker.com/_/php/). The last step is to copy the Dockerfile of *php* inside the Dockerfile we created on our own filesystem:

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

- The *-p* option allows us to use port mapping and then be connected to the HTTP server created through the IP address and port of the Docker machine (192.168.99.100 and 9090).

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

**TODO : demo**

## Step 2 (on the branch *fb-express-dynamic*)
### Part A

In this step, we create a new branch. Inside the same folder as before, *docker-images*, we will create a new folder *express-image*. And inside this one, we will have a new Dockerfile, this time working with node.js.
This time again we can use an official image found on DockerHub. We will get the last stable version : `node:6.10`. 

```
FROM node:6.10
COPY src/ /opt/app
CMD ["node", "/opt/app/index.js"]
```

- When a container from this image is launched, the first command that will be executed is `node /opt/app/index.js`.

Again, we will initially use `src` as folder from where to copy local files into the containers. We then have to create the src file and inside it, execute the command line `npm init`. This will allow us to create a `package.json` file. At the moment, we do not have any dependence.
In this step, we will use an npm module which name is *chance*. Then we will execute `npm install --save chance`. This will create a dependence in the file `package.json`. 

We now have to create an `index.js` file. This is the node.js equivalent of the `index.html` of step 1. We will first test it with the following code :

```
var Chance = require('chance');
var chance = new Chance();

console.log("Good morning " + chance.country({ full:true }) + " !");
```

This will allow us to write a different message in the console everytime a container is run.
The tests are conclusive, we get the different messages everytime.

### Part B
In this part, we will first install `express`, the npm module with `npm install --save express`.
We can now use `express` in our `index.js` file.

```
var express = require('express');
var app = express();

app.get('/', function(req, res) {
	res.send("Hello mama!");
});

app.listen(3000, function() {
	console.log('Accepting HTTP requests on port 3000');
});
```

At this point, we can execute this file with the line `node index.js` and it will create a server which accepts connexions on port 3000. If on another terminal, we execute `telnet localhost 3000`, we connect to the server, and when we execute `GET / HTTP/1.0`, we get the message "Hello mama!" and the connection is directly closed.
If, for example, the path in the `get` command is not only '/' but '/first', then we can create a get function for this path in the `index.js` file and it will respond with its message instead of the one of the '/' path. Of course, the command after connecting with telnet will be `GET /first HTTP/1.0`.

For the next step of part b, what we want to do is not only send a basic message but the result of a function. Then the `index.js` file will change a bit :

```
var Chance = require('chance');
var chance = new Chance();

var express = require('express');
var app = express();

app.get('/', function(req, res) {
	res.send( generateCountries() );
});

app.listen(3000, function() {
	console.log('Accepting HTTP requests on port 3000');
});

function generateCountries() {
	var numberOfCountries = chance.integer({
		min: 0,
		max: 10
	});
	
	console.log(numberOfCountries);
	
	var countries = [];

	for (var i = 0; i < numberOfCountries; i++) {
		var population = chance.integer({
			min: 1000,
			max: 35000000
		});
		var president = chance.name();

		countries.push({
			country : chance.country({ full:true }),
			population : population,
			president : president
		});
	};
	console.log(countries);
	return countries;
}
```

This code will generate an array of countries associated with their population and their president. We get this in JSON type and we get the length of the content as well as some other information.

After these tests, we can use the `index.js` file without problem. So we have built the image `res/express_students` and then ran it without any port mapping. How could we join it? 
Using the command line `docker-machine ssh` we get to connect to the virtual machine. As seen before, what we can do is use the command line `docker inspect *name of the container*` and get the IP address of the container. You can then type the following command : `telnet *IP address retrieved* 3000` and this will get you the desired answer after you type `GET / HTTP/1.0`. But this will only be accessible from the "inside" as the IP address is part of your local addresses. How to resolve it?
We have first to kill the current container and then execute it with port mapping with the option `-p 9090:3000` to connect on port 3000. Now, in place of connecting to the container directly, we can connect to the virtual machine through `telnet 192.168.99.100 9090`. This will have the same effect as the previous connections.

## Step 3

In this third step, what we are going to do is create an apache as reverse proxy. It will be used as a unique entrance to both of the containers we created in steps 1 and 2. As the reverse proxy has no html code, the advantage of it will be security. But we will later learn it is not the only advantage.

### Part A - Introduction about AJAX and the reverse proxies
Most of the times a browser will make a request to a static server to get HTML files or a JPEG image or JavaScript files, etc. Everytime the browser makes a GET request, the static server will answer with what the browser asked and the browser will refresh and so on. 

An AJAX request is that everytime we have refreshed a webpage, then a JavaScript file could be running and asking for informations which will be sent in an asynchronous way to the dynamic server. This is most of time seen when parts of the webpage have to be refreshed, for example when you have to fill a form and get an answer for it.
To use AJAX requests we nearly have the obligation to create a reverse proxy. The reason is that thers is a policy named the "Same-origin policy" which specifies that if you are making a request to a certain domain and getting answers, then you can only contact this same domain in the script and not another one. So accessing the static and the dynamic server would be impossible. That is another reason why we have to use a reverse proxy. This is also about security. The reverse proxy will have a domain name and from the point of view of the browser, we will only access this domain and not the two other sub domains who are the static and dynamic servers.

### Part B - Setting a new Docker image for a reverse proxy (on a specific container)
In this part, we will set a new Docker image for a reverse proxy.
First, what we will do is run our two containers : apache_static and express_students. We will give them names so that it is easy to type their names.
Then, we will get their IP addresses :

	- apache_static IP address = 172.17.0.2
	- express_dynamic IP address = 172.17.0.3

For the apache_static container, we can simply connect with `telnet 172.17.0.2 80` and get the HTML code we coded in the first step.
For the express_dynamic container, we can simply connect with `telnet 172.17.03 3000` and get the express code we coded in the second step and which retrieves us an array of countries.

We will now access the filesystem of a container of apache we just launched with `docker run -it -p 8080:80 res/apache_php /bin/bash`. We can go to the following path to see which are the available sites : `/etc/apache2/sites-available`. We will first find a file named `000-default.conf`which is the file in which we can for example find the information about which is the root document (in our case `/var/www/html`). When we see it from the eyes of the reverse proxy, we will actually ask him to go to the `/var/www/html` file to get for example the static server or let's say `/var/www/html/dynamic` for the dynamic server. So the reverse proxy will determine which is the server contacted thanks to the path given.

At this point, we will get the `000-default.conf` file and copy it inside a `001-reverse-proxy.conf` file. Inside it, we will just inform it about the fact that the domain name will be `demo.res.ch`. We will add "ProxyPass" which is the path to where the browser wants to go and "ProxyPassReverse" which is the same content but explains the path back to the browser `"/api/countries/" "http://172.17.0.3:3000/"`. Then we will add what should happen when there is no path, like `/`. In this case, we will add a "ProxyPass" and a "ProxyPassReverse" too, but attention, after what is more specified or else the program would just stop at the first rule.

After what we have done, we should restart the apache server. If we do so with `service apache2 restart`, it will not do anything because we have set a domain name but we did not have made it available. So we can go to `/etc/apache2/sites-enabled` and check that we do not have nothing for the moment. To enable the site, we have to go to `/etc/apache2` and type `a2ensite 001*`. We then have to type `service apache2 reload` and we will get an error because we use "ProxyPass" and it is not a known expression. It says it may be contained in a module which has not already been installed. Then, to make it right, we will have to activate the needed modules : `a2enmod proxy` and `a2enmod proxy_http`. Now we can finally use the `service apache2 reload`!

To test the configuration, we have to `telnet 172.17.0.2 80`. We can not join the service. If we type `telnet 192.168.99.100 8080` we can connect and then we can type : 

```
GET / HTTP/1.0
Host: demo.res.ch
```

This returns us the content of the HTML file. We then obtained what we initially wanted with : `ProxyPass "/" "http://172.17.0.3:80/"`. We can also try :

```
GET /api/countries/ HTTP/1.0
Host: demo.res.ch
```

And this will return the express content. We then obtained what we initially wanted with : `ProxyPass "/api/countries/" "http://172.17.0.3:3000/"`.

### Part C - Setting a new Docker image for a reverse proxy (on every container)
