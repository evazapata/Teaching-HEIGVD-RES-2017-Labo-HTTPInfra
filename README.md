# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 2: Dynamic HTTP server with express.js
### Part A

Inside the same folder as before, *docker-images*, we will create a new folder *express-image*. And inside this one, we will have a new Dockerfile, this time working with node.js.
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

## Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker` and `npm`
