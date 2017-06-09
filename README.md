# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
#### Ludovic Delafontaine & Denise Gemesio, HEIG-VD June 2017

## Step 3: Reverse proxy with apache (static configuration)

In this third step, what we are going to do is to configure an Apache server as a reverse proxy. It will be used as a unique entrance to both of the containers we created in steps 1 and 2. The reverse proxy will not deliver anything to the clients but will provide us security. But we will later learn it is not the only advantage.

### Part A - Introduction to AJAX and the reverse proxies
Most of the times a browser will make a request to a static server to get HTML files or a JPEG image or JavaScript files, etc. Everytime the browser makes a GET request, the static server will answer with what the browser asked and the browser will refresh and so on.

Instead of refreshing the browser's page on every GET request, we could use a JavaScript script on client side that can interacts with the Web server in an asynchronous way. This way, we could send/receive information to/from the server without having to refresh the page. This is most of time seen when parts of a webpage change without refreshing the page, such as Facebook's Wall feed. This is possible with, for example, AJAX, a JavaScript library for asynchronous requests.

In our implementation, we nearly have the obligation to create a reverse proxy to use both of the static (HTML) and dynamic (JSON) servers. The reason is that there is a policy named the "Same-origin policy" which specifies that if you are making a request to a certain domain and getting answers, then you can only contact this same domain in the script and not another one. So accessing the static and the dynamic server would be impossible. That is another reason why we have to use a reverse proxy. This is also about security. The reverse proxy will have a domain name and from the point of view of the browser, we will only access this domain and not the two other sub domains who are the static and dynamic servers. By this way of implementing our Web infrastructure, we only show to the "real" world one and one only server that can be reached. The other servers are hidden by the reverse proxy. We could have 50 servers or only two that do many differents things, from the user side, we only one server with its unique address.

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

### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker` and may need to run the script as root
