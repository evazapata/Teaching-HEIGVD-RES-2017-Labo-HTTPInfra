# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 5 : Dynamic reverse proxy configuration

### Part B

The first thing we did is kill all the remaining containers and create a new branch *fb-dynamic-configuration*. Now, in the `docker-images/apache-reverse-proxy` folder, we want to modify the Dockerfile as to use environment variables in a script.

There are two things to know :

- First, when we will use this kind of command : `docker run -e HELLO=world -e RES=heigvd -it res/apache_rp /bin/bash`, if we type the command `export`, then we will see that these environment variables have been saved.
- Second, because we want to have a script able to interact with the start of the container, we will have to understand how the image (*Apache 7.0*) has been built. If we look at the Dockerfile of the base image, we can see they use a command `CMD ["apache2-foreground"]` : they start the Apache 2 server and they do so in foreground because they do not want the server to be shut down immediately. What we will then do is replace this command, call our own script and from it call the command they wrote.

Back to the Dockerfile. We will copy the organization of the *Apache 7.0* filesystem and we will create an apache2-foreground script at the same level as the Dockerfile `apache2-foreground` :

```
#!/bin/bash
set -e

# Add setup for RES lab
echo "Setup for the RES lab"
echo "Static app URL: $STATIC_APP"
echo "Dynamic app URL: $DYNAMIC_APP"


# Note: we don't just use "apache2ctl" here because it itself is just a shell-script wrapper around apache2 which provides extra functionality like "apache2ctl start" for launching apache2 in the background.
# (also, when run as "apache2ctl <apache args>", it does not use "exec", which leaves an undesirable resident shell process)

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
	. "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_RUN_DIR:=/var/run/apache2}"
: "${APACHE_PID_FILE:=$APACHE_RUN_DIR/apache2.pid}"
rm -f "$APACHE_PID_FILE"

# create missing directories
# (especially APACHE_RUN_DIR, APACHE_LOCK_DIR, and APACHE_LOG_DIR)
for e in "${!APACHE_@}"; do
	if [[ "$e" == *_DIR ]] && [[ "${!e}" == /* ]]; then
		# handle "/var/lock" being a symlink to "/run/lock", but "/run/lock" not existing beforehand, so "/var/lock/something" fails to mkdir
		#   mkdir: cannot create directory '/var/lock': File exists
		dir="${!e}"
		while [ "$dir" != "$(dirname "$dir")" ]; do
			dir="$(dirname "$dir")"
			if [ -d "$dir" ]; then
				break
			fi
			absDir="$(readlink -f "$dir" 2>/dev/null || :)"
			if [ -n "$absDir" ]; then
				mkdir -p "$absDir"
			fi
		done

		mkdir -p "${!e}"
	fi
done

exec apache2 -DFOREGROUND "$@"
```

Be careful! If you are on Windows, you have to use for example Notepad++ to change the end of lines in Unix end of lines.

What we did is only copy the content of the file found in the PHP Apache 7.0 repository and add some lines representing the environment variables *STATIC_APP* and *DYNAMIC_APP*.
As we used the same name for the script, we will be able to keep the command as specified before in our Dockerfile.
First we have to add the line `COPY apache2-foreground /usr/local/bin/` to get the script inside the container. The result is what follows :

```
FROM php:7.0-apache

RUN apt-get update && \
apt-get install -y vim

COPY apache2-foreground /usr/local/bin/

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

If we now build and run the image with an envrionment variable, we can see that the variables are actually retrieved. 


### Part C
In this part, we will create a PHP file for the reverse proxy configuration file. If we look at the PHP documentation, then we can see that there are ways to retrieve an environment variable with, for example : `$ip = getenv('REMOTE_ADDR');`.

Now that we know how it works, we can go get the configuration file hardcoded we created in the reverse proxy step inside the `conf` file and copy it inside the PHP file :

```
<?php 
	$STATIC_APP = getenv('STATIC_APP');
	$DYNAMIC_APP = getenv('DYNAMIC_APP');
?>

<VirtualHost *:80>
	ServerName demo.res.ch

	ProxyPass '/api/students/' 'http://<?php print "$DYNAMIC_APP"?>/'
	ProxyPassReverse '/api/students/' 'http://<?php print "$DYNAMIC_APP"?>/'

	ProxyPass '/' 'http://<?php print "$STATIC_APP"?>/'
	ProxyPassReverse '/' 'http://<?php print "$STATIC_APP"?>/'
</VirtualHost>
```

If we type the following commands : `export STATIC_APP=172.17.0.x:80` and `export STATIC_APP=172.17.0.y:3000`. After having typed the command `php config-template.php`, we get the environment variables replaced by the values set in the previous commands.

We are now capable, if we invoke the PHP interpreter, to generate the configuration file.

### Part D
The file created in the previous step will be copied inside the containers. We will then modifiy the Dockerfile once again and place the *template* file inside `/var/apache2/` : 

```
FROM php:7.0-apache

RUN apt-get update && \
apt-get install -y vim

COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

We will also modify the *apache2-foreground* script adding the line `php /var/apache2/templates/config-template.php > /etc/apache2/sites-available/001-reverse-proxy.conf` after what we had added at the beginning of the file.

And now we can build and test if this worked with the following commands : `docker build -t res/apache_rp .` and `docker run -e STATIC_APP=172 -e DYNAMIC_APP=172 res/apache_rp`. The environment variables have been retrieved. We can now *exec* the container and verify the filesystem. In the folder *templates* we actually find the *config-template.php* file. And in the folder *sites-available*, if we look at the file *001-reverse-proxy.conf*, the IP addresses have been set with *172* and in the folder *sites-enabled*, it is well too. It is all for this part.

### Part E
At this point, it is all ready to work. We have :

- We modified the starting script *apache2-foreground* to invoke the PHP interpreter
- We created a PHP interpreter which retrieves the environment variables

With this, we dynamically configure the Apache server. We will give the IP addresses from the outside so it will avoid the step in which we have to hardcode the IP addresses inside the configuration file.

To test our configuration, we will lauch four static servers and three dynamic servers. This will allow us to have different IP addresses.
For the two servers we will have chosen, we will inspect the containers and retrieve their IP addresses.

- Static server IP address : 172.17.0.5
- Dynamic server IP address : 172.17.0.8

We can now run the reverse proxy image giving it the environment variables with the IP addresses retrieved previously : `docker run -d -e STATIC_APP=172.17.0.5:80 -e DYNAMIC_APP=172.17.0.8:3000 --name apache_rp -p 8080:80 res/apache_rp`.

On a browser, we type `demo.res.ch:8080` and we get the webpage with the update of the text every two seconds and if we type `demo.res.ch:8080/api/students/` we get a list of countries every time we refresh it.

And here we finish the basic laboratory! Thanks for reading ;)


### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker`
