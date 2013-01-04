// Override console.log function, which isn't supported by GPAC
console = {};
console.log = function(msg) {
	alert(msg);
}
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

console.log("MC_GpacListener_1");
var componentName = "MC_GpacListener_1";
var MC_metadata = "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}";
var MC_confidential = "false";
var isGPacComponent = true; // GPac component will be treated differently

function createGpacCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	var timeData = name+"="+value+expires+"; path=/";
	gpac.setOption(componentName, name,timeData);
}

function readGpacCookie(name) {
	var nameEQ = name + "=";
	var ca = gpac.getOption(componentName,name).split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseGpacCookie(name) {
	createCookie(name,"",-1);
}





