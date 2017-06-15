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