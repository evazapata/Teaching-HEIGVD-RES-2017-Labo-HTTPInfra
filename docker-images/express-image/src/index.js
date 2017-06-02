var Chance = require('chance');
var chance = new Chance();

console.log("Good morning " + chance.country({ full:true }) + " !");