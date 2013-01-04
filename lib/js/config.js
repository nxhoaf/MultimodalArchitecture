console.log("================================================================");
console.log("config.js loaded");

var debug = true;
var intervalDebug = 2000; 
var lifeTimeDebug = 120000; 
var sleepDebug = 0; 

var root = "http://www.berthele.com/soa2m/";
//var root = "http://localhost:8888/soa2m/";
var server = root+"services/servicesCC/";  
var cometIFramePath = server+"CC_EventObserver.php"; 
var contentType = "text/xml; charset=ISO-8859-1";
var serviceRegister = server+"CCs_Register.php";
var operationRegister = "MC_register";
var serviceController = server+"CCs_Orchestrator.php"; 
var operationOrchestrate = "MC_orchestrate";  
var defaultToken = "MC_1234";
var defaultContext = "Unknown";
var defaultImmediate = "true";

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



var getEventType = function (type) {
for(var name in messageType) { 
    var value = messageType[name]; 
	 if(type==value) return name;
}
return "UNKNOWN";
}

var hasOwnProperty = Object.prototype.hasOwnProperty;
var isEmpty = function (obj) {
    if (obj.length && obj.length > 0)    return false;
    for (var key in obj) {
        if (hasOwnProperty.call(obj, key))    return false;
    }
    return true;
}


