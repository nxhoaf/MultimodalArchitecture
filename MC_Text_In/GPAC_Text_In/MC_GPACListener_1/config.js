var debug = true;
var applicationType = "GpacApp";
var applicationName = "MC_GpacListener_1";
var root = "http://www.berthele.com/soa2m/";
//var root = "http://localhost:8888/soa2m/";
var server = root+"services/servicesCC/";  
var contentType = "text/xml; charset=ISO-8859-1";
var serviceRegister = server+"CCs_Register.php";
var serviceController = server+"CCs_Orchestrator.php";  
//var serviceRegister = server+"ajax_test.php"; 

var namespaces = new Array();
namespaces[0]= new Array('env','encodingStyle','http://www.w3.org/2003/05/soap-encoding');
namespaces[1]= new Array('xmlns','soap','http://www.w3.org/2003/05/soap-envelope');
namespaces[2]= new Array('xmlns','env','http://www.w3.org/2003/05/soap-envelope');
namespaces[3]= new Array('xmlns','wsdl','http://www.w3.org/2007/06/wsdl/wsdl20.xsd');
namespaces[4]= new Array('xmlns','whttp','http://www.w3.org/ns/wsdl/http');
namespaces[5]= new Array('xmlns','wsdlx','http://www.w3.org/ns/wsdl-extensions');
namespaces[6]= new Array('xmlns','wsoap','http://www.w3.org/ns/wsdl/soap');
namespaces[7]= new Array('xmlns','xsi','http://www.w3.org/1999/XMLSchema-instance');
namespaces[8]= new Array('xmlns','xsd','http://www.w3.org/2001/XMLSchema');
namespaces[9]= new Array('xmlns','sawsdl','http://www.w3.org/ns/sawsdl');
namespaces[10]= new Array('xmlns','ns1',root);
namespaces[11]= new Array('xmlns','ser',root+'ont/service/');
namespaces[12]= new Array('xmlns','use',root+'ont/use/');
namespaces[13]= new Array('xmlns','xs',root+'xs/Soa2MSchema');
namespaces[14]= new Array('xmlns','mmi','http://www.w3.org/2008/04/mmi-arch');

var messageType = {
	NEW_CONTEXT : 0,
	CLEAR_CONTEXT : 1,
	PREPARE : 2,
	START : 3,
	CANCEL : 4,
	PAUSE : 5,
	RESUME : 6,
	STATUS : 7,
	EXTENSION_NOTIFICATION : 8,
	DONE_NOTIFICATION : 9
};

var spec = { };

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	var timeData = name+"="+value+expires+"; path=/";
	gpac.setOption(applicationName, name,timeData);
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = gpac.getOption(applicationName,name).split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}



var requestId = 0;
var createRequestId = function () {
	requestId ++;
	return "r" + requestId;
}
var getRequestId = function () {
	return "r" + requestId;
}


// Override console.log function, which isn't supported by GPAC
var console = {};
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

