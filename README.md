# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 3: Reverse proxy with apache (static configuration)

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
For the express_dynamic container, we can simply connect with `telnet 172.17.0.3 3000` and get the express code we coded in the second step and which retrieves us an array of countries.

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
##### (At this point, Docker having had a complete reset, I had to build and run the containers again. Then we have 172.17.0.3 as the IP address of apache_static and 172.17.0.2 as the IP address of express_dynamic)

First, we have to go inside the *apache_reverse_proxy* folder we had created. In it, we will create a *conf* folder in which we will create two files : *000-default.conf* and *001-reverse-proxy.conf*. These are the same files that we created in part B.

Then, we will go to the Dockerfile and modify it as follows :

```
FROM php:7.0-apache

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

This will tell the containers that they will be based on the Apache 7.0 image. Then, it will copy the files from the *conf/* folder to the */etc/apache2* folder of the containers and finally, it will run the commands `a2enmod proxy proxy_http` to enable its modules and `a2ensite 000-* 001-*` to enable its virtual hosts.

Then, inside the file *001-reverse-proxy.conf*, we will write the following code :

```
<VirtualHost *:80>
	ServerName demo.res.ch

	#ErrorLog ${APACHE_LOG_DIR}/error.log
	#CustomLog ${APACHE_LOG_DIR}/access.log combined

	ProxyPass "/api/students/" "http://172.17.0.2:3000/"
	ProxyPassReverse "/api/students/" "http://172.17.0.2:3000/"

	ProxyPass "/" "http://172.17.0.3:80/"
	ProxyPassReverse "/" "http://172.17.0.3:80/"
</VirtualHost>
```


And inside the file *000-default.conf*, we will write the following code :

```
<VirtualHost *:80>
</VirtualHost>
```

Be careful! If you are on Windows, then you will have to use Notepad++, for example, to change the end of lines as the UNIX ones.

Why did we created this file with this code? If we only had the virtual host of *001-reverse-proxy.conf*, then it would also be the default virtual host. If the client did not send the host `demo.res.ch` or the IP address of the reverse proxy, then he would end int the *001-reverse-proxy.conf*, but we don't want that. We want that if a user connects to the IP address of the Docker machine or localhost or any other way, then there would be an error message.

Now that everything is ready we can build an image of the reverse proxy from the Dockerfile with `docker build -t res/apache-rp .`. And we can now run it with `docker run -p 8080:80 res/apache-rp`. What we get is the error message specified before, because we got on the configuration of the virtual host 000.

Last thing to do: what are we going to do to make it work on a browser? We will have to modify our DNS configuration. We will have to go in the `/etc/hosts` file which is the same for all systems and define the DNS names or IP addresses of machines. With administrator rights, we will then modify the file and add `192.168.99.100   demo.res.ch`. We will then test it with a `ping demo.res.ch` and we will actually receive replies from 192.168.99.100.

If we now try to get to `demo.res.ch:8080` on a browser, we will get our webpage! And if we try to get to `demo.res.ch:8080/api/students/`, we get a list of countries!

### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker`
