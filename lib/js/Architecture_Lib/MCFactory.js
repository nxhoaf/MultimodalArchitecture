console.log("MCFactory.js loaded");

var MCFactory = function() {};

MCFactory.createSimpleMc = function(name) {
	var o = {};
	return o;
}

MCFactory.createComplexMc = function(name) {
	var o = {};
	o.controller = new Controller(name);
	return o;
}
