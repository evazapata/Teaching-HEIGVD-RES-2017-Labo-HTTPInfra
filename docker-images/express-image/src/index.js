// PART A

var Chance = require('chance');
var chance = new Chance();

//console.log("Good morning " + chance.country({ full:true }) + " !");


// PART B

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
		var mayor = chance.name();

		countries.push({
			country : chance.country({ full:true }),
			population : population,
			mayor : mayor
		});
	};
	console.log(countries);
	return countries;
}