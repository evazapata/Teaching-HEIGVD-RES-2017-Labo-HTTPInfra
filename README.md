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

It will give access to the filesystem of the Docker container in which you can find the configuration files.

**TODO : demo**

## Step 2 on the branch *fb-express-dynamic*
### Step 2
#### Part A
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

#### Part B
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

