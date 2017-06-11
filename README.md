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


### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker`
