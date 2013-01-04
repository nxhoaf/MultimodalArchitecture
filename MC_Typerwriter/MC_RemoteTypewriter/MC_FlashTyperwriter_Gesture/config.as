//*******************************************************************************************
// Data
//*******************************************************************************************
public var  debug:Boolean = true;
//public var  serverRoot:String  = "http://www.berthele.com/soa2m/classes/tests/airTest.php";
public var  serverRoot:String = "http://www.berthele.com/soa2m/";
//public var  serverRoot:String  = "http://localhost:8888/soa2m/";
public var  server:String  = serverRoot+"services/servicesCC/";  
public var  contentType:String  = "text/xml; charset=ISO-8859-1";
public var  serviceRegister:String  = server+"CCs_Register.php";
public var  serviceController:String  = server+"CCs_Orchestrator.php"; 
public var  namespaces:Array = configNamespaces();
public var  messageType:Object = configMessageType();

//*******************************************************************************************
// Namespace
//*******************************************************************************************
public function configNamespaces():Array{
	var namespaces:Array = new Array(15);  
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
	namespaces[10]= new Array('xmlns','ns1',serverRoot);
	namespaces[11]= new Array('xmlns','ser',serverRoot+'ont/service/');
	namespaces[12]= new Array('xmlns','use',serverRoot+'ont/use/');
	namespaces[13]= new Array('xmlns','xs',serverRoot+'xs/Soa2MSchema');
	namespaces[14]= new Array('xmlns','mmi','http://www.w3.org/2008/04/mmi-arch');
	return namespaces;
}

//*******************************************************************************************
// Message types
//*******************************************************************************************
public function configMessageType():Object {
	var messageType:Object = new Object;
	messageType.NEW_CONTEXT=0;
	messageType.CLEAR_CONTEXT=1;
	messageType.PREPARE=2;
	messageType.START=3;
	messageType.CANCEL=4;
	messageType.PAUSE=5;
	messageType.RESUME=6;
	messageType.STATUS=7;
	messageType.EXTENSION_NOTIFICATION=8;
	messageType.DONE_NOTIFICATION=9;
	return messageType;
	
}


