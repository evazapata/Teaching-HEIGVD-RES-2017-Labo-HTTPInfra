# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution
##### Ludovic Delafontaine & Denise Gemesio
##### June 2017

## Step 4 : AJAX requests with JQuery
In this step, we will use the JQuery library to implement an Ajax request.

Requests from the browser will automatically be sent to the dynamic server and we will get replies which will display a message on our website.

First, we will kill the three remaining containers from last step. Then, in all the Dockerfiles (for the three images we have), we will write the following lines to install automatically Vim at launch for every container :

```
RUN apt-get update && \
apt-get install -y vim
```

After this, we can build all three images, whitout forgetting to port map on 8080:80 the reverse proxy one. 

Finally, we will launch every container and verify that the IP addresses correspond to the ones in the reverse proxy configuration file, as they are hardcoded. We can now verify that we have access to `demo.res.ch:8080` and `demo.res.ch:8080/api/students/`.

The main part is to connect to the static container. We will launch a `bash` on it and modify `index.html`. In the first test, we will only add a *!* somewhere. We can see that it will directly change on the webpage.

At the end of `index.html`, we can see that there are some scripts launched. This can also be seen on the browser if we inspect the page with a right click and we go in the `Sources` menu. We will then add our own script to update some parts of the display everytime we want. To do so, we will need to first add the two following lines to the `index.html`, at the end :

```
<!-- Custom script to load countries -->
<script src="js/countries.js"></script>
```

We will then go inside the folder `js` in which we will find the existing scripts. We will create `countries.js` in it and modify it. What we will do is create the script allowing us to change a text inside the webpage every two seconds :

```
$(function() {
        console.log("Loading countries");

        function loadCountries() {
                $.getJSON( "/api/students/", function( countries ) {
                        console.log(countries);
                        var message = "Nobody is here";
                        if ( countries.length > 0 ) {
                                message = countries[0].country + " of " + countries[0].population + " citizen loves him!";
                        }
                $(".section-heading").text(message);
                });
        };
	
	loadCountries();

    setInterval( loadCountries, 2000);
});
```

The `$(".section-heading")` expression will allow us to access the variable representing a certain text thanks to a class, in this case the class is `section-heading`.
The `setInterval( loadCountries, 2000);` line will define that every 2000 milliseconds we will call the function `loadCountries();`.

When we save it, if we test it on a browser, we will see that the webpage actually changes every two seconds.

When we are done with the modifications and the tests, we can copy everything we have done inside the files in our own system. Finally, we will just kill the static server container and remove the image of the static server and build it again with the new configurations. We will run a container and this should work as well as the tests done before.


### Demo
For a complete demo, you can run the bash script `demo.sh`.

```
chmod +x demo.sh
./demo.sh
```

For the demo, you need the following packages to be installed: `docker`
