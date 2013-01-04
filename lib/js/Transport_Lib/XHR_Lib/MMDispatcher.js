console.log("MMDispatcher.js loaded");

/**
 * Helper Class : MMDispatcher, it's responsible for sending events, notifications.
 */
var MMDispatcher = { };

/**
 * This function will be used to send a asynchronous request to server
 * @param msg contains request as key-value pairs
 * @param method contains the send method to use
 * @param kind contains the kind of message to send
 * @return boolean
 */
MMDispatcher.sendAsynchronous = function(msg, method, kind) {
	console.log("[MMDispatcher]{sendAsynchronous} - Started");
	//Parameter Verification
	var requestMethod = method;
	var requestKind = kind;
	if(!requestMethod)
		requestMethod = "GET";
	if(!requestKind)
		requestKind = "XML";

	requestMethod = requestMethod.toUpperCase();
	requestKind = kind.toUpperCase();

	if(requestKind == "XML") {
		console.log("[MMDispatcher]{sendAsynchronous} - XML/" + requestMethod);
		switch (requestMethod) {
			case "GET":
				//alert("GET/XML REQUEST (json)");
				msg.setApi('json');
				this.sendJsonRequest(msg);
				break;
			case "POST":
				//alert("POST/XML REQUEST (soap)"");
				msg.setApi('soap');
				this.sendSoapRequest(msg, requestKind);
				break;
		}

	}
	if(requestKind == "MMI") {
		console.log("[MMDispatcher]{sendAsynchronous} - MMI/" + requestMethod);
		switch (requestMethod) {
			case "GET":
				msg.setApi('json_mmi');
				this.sendJsonRequest(msg);
				break;
			case "POST":
				msg.setApi('soap');
				this.sendSoapRequest(msg, requestKind);
				break;
		}
	} 
	console.log("[MMDispatcher]{sendAsynchronous} - Ended");
	return true;
}
/**
 * private function : sendJsonRequest to create a RestFul Ajax request
 * @param msg contains request as key-value pairs
 * @return boolean
 */
MMDispatcher.sendJsonRequest = function(msg) {
	console.log("[MMDispatcher]{sendJsonRequest} - Started" );
	isReceive = false;
	var targetUrl = msg.getTarget();
	// if(debug) alert(targetUrl);

	var fullUrl = this.addParamsToUrl(targetUrl, msg);
	console.log("[MMDispatcher]{sendJsonRequest} fullUrl is \n"+fullUrl);
	// if(debug) alert(fullUrl);
	var xmlhttp;

	// For browser: a window object exist
	if( typeof window != "undefined") {
		if(window.XDomainRequest) {
			xmlhttp = new XDomainRequest();
		} else if(window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else {
			alert("Your Browser does not support cross-domain AJAX  !");
		}
	} else {// For non-browser, for e.x: GPAC, which hasn't window object
		xmlhttp = new XMLHttpRequest();
	}

	xmlhttp.onreadystatechange = function() { 
		if(this.readyState == 4 && (this.status == 200 || this.status == 0)) {
			console.log("[MMDispatcher]{sendJsonRequest} Async Data received ...");
			var jsonData = this.responseText;
			dataReceived(jsonData);
		} else {
			//console.log("[MMDispatcher]{sendJsonRequest} \n readyState: "+ this.readyState + "\n status: " + this.status);
		}
	};

	xmlhttp.open("GET", fullUrl);
	xmlhttp.send();
	console.log("[MMDispatcher]{sendJsonRequest} json request sent");
	console.log("[MMDispatcher]{sendJsonRequest} - Ended" );
	return true;
}

/**
 * Add parameters to url, for ex, you have root url : abc.php and spec contains 2 key-value pairs
 * Warning Param order mandatory in URL!
 * @param rootUrl url to which we will add the params, based on function used
 * @param msg contains key-value pairs
 * @returns add-params url.
 */
MMDispatcher.addParamsToUrl = function(rootUrl, msg) {
	console.log("[MMDispatcher]{addParamsToUrl} - Started");
	var token = msg.getToken(); 
	if (!token) token = msg.getRequestId()
	// Parameter Verification
	if(!rootUrl)
		throw "Not a valid url: " + rootUrl;
	if(!msg)
		throw "Interaction Object is missing!";

	var fullUrl = rootUrl + "?";
	fullUrl += "api=" 		+ msg.getApi(); // api
	fullUrl += "&method=" 	+ msg.getMethod(); // method
	fullUrl += "&caller=" 	+ msg.getSource(); // caller
	fullUrl += "&token=" 	+ token; // fake token
	fullUrl += "&id=" 		+ msg.getRequestId(); // id

	if (typeof msg.getMetadata() != "undefined")
		fullUrl += "&type=" + msg.getMetadata();

	if (typeof msg.getType() != "undefined")
		fullUrl += "&type=" + msg.getType();
	
	if (typeof msg.getContext() != "undefined")
		fullUrl += "&context=" + msg.getContext();
	
	if (typeof msg.getStatus() != "undefined")
		fullUrl += "&status=" + msg.getStatus();

	if(typeof msg.getData() != "undefined")
		fullUrl += "&data=" + msg.getData();

	// Normalize
	fullUrl = fullUrl.replace("=undefined", "=");
	 
	console.log("[MMDispatcher]{sendJsonRequest} - Ended" );
	return fullUrl;
}




/**
 * private function : SoapRequest that sends data asynchrounously
 * @param msg contains request as key-value pairs
 * @param requestKind contains the kind of message to send
 * @return boolean
 */
MMDispatcher.sendSoapRequest = function(msg, requestKind) {
	console.log("[MMDispatcher][sendSoapRequest] - Started");
	if(!msg)
		throw "Interaction Object is missing!";
	if(!requestKind)
		throw "Kind of message is missing!";

	var targetUrl = msg.getTarget();
	var xml = this.createSoapRequest(msg, requestKind);
	if(debug)
		alert(xml);
	var xmlhttp;

	if(window.XDomainRequest) {
		xmlhttp = new XDomainRequest();
	} else if(window.XMLHttpRequest) {
		xmlhttp = new XMLHttpRequest();
	} else {
		alert("Your Browser does not support cross-domain AJAX  !");
	}

	xmlhttp.onload = function() {
		var soapData = xmlhttp.responseText;
		if(debug)
			alert("soapData via sendSoapRequest:" + soapData);
		dataReceived(soapData);
	};

	if(debug)
		alert(targetUrl);

	if(msg.getApi() == 'soap') {
		xmlhttp.open("POST", targetUrl);
	} else {
		xmlhttp.open("GET", targetUrl);
	}

	xmlhttp.send(xml);
	console.log("[MMDispatcher][sendSoapRequest] - Ended");
	return true;
}
/**
 * private function : send createSoapRequest that creates the request
 * Warning Param order mandatory in URL!
 * @param msg contains request as key-value pairs
 * @param requestKind contains the kind of message to send
 */
MMDispatcher.createSoapRequest = function(msg, requestKind) {
	console.log("[MMDispatcher][createSoapRequest] - Started");
	if(!msg)
		throw "Interaction Object is missing!";
	if(!requestKind)
		throw "Kind of message is missing!";

	var xml = '<?xml version="1.0" encoding="ISO-8859-1"?>\n';
	xml += '<env:Envelope';
	for( n = 0; n < namespaces.length; n++) {
		xml += ' ' + namespaces[n][0] + ':' + namespaces[n][1] + '=\'' + namespaces[n][2] + '\'\n';
	}
	xml += ' >';
	xml += '\n<env:Body>' + '\n<ns1:MC_register xmlns:ns1="' + server + '">';

	if(requestKind == 'XML') {
		if(debug)
			alert("createXMLMessage");
		xml += this.createXMLMessage(msg);
	} else {

		if(debug)
			alert("createMMIMessage");
		xml += this.createMMIMessage(msg);
	}

	xml += '</ns1:MC_register>\n' + '</env:Body>\n' + '</env:Envelope>\n';

	// Normalize
	xml = xml.replace("undefined", "");
	if(debug)
		alert(xml);
	console.log("[MMDispatcher][createSoapRequest] - Ended");
	return xml;
}
/**
 * private function : send createMMIMessage that creates the body of the message
 * according to MMI Spec Schema
 * Warning Param order mandatory in URL!
 * @param msg contains request as key-value pairs
 */
MMDispatcher.createMMIMessage = function(msg) {
	console.log("[MMDispatcher][createMMIMessage] - Started");
	var mmi = '';
	mmi += "\n<" + namespaces[14][1] + ":" + namespaces[14][1] + " " + namespaces[14][0] + ":" + namespaces[14][1] + "='" + namespaces[14][2] + "' version='1.0'>";
	if(debug)
		alert("createMMIMessage :\n" + mmi);

	var type = msg.getType();

	if(debug)
		alert("Interaction Type is :" + msg.getType());

	// Test of the creation of all events
	//if(debug) for(n=0;n<10;n++) {
	//if(debug) type = n;

	mmi += "\n<" + namespaces[14][1];

	switch (type) {
		case messageType.NEW_CONTEXT:
			//alert('NEW_CONTEXT');
			mmi += ":newContextRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "newContextRequest>\n";
			break;

		case messageType.CLEAR_CONTEXT:
			//alert('CLEAR_CONTEXT');
			mmi += ":clearContextRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "clearContextRequest>\n";
			break;

		case messageType.PREPARE:
			//alert('PREPARE');
			mmi += ":prepareRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "prepareRequest>\n";
			break;

		case messageType.START:
			//alert('START');
			mmi += ":startRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";

			var contentURL = msg.getContentUrl();
			var content = msg.getContent();
			var data = msg.getData();
			if(debug)
				if(!data)
					data = 'None';

			if(contentURL != 'None') {
				mmi += " >";
				mmi += "\n<" + namespaces[14][1] + ':';
				mmi += "contentURL href=\'" + contentURL + "\' />\n";
			}

			if(content != 'None') {
				mmi += "<" + namespaces[14][1] + ':' + "content>";
				mmi += content;
				mmi += "</" + namespaces[14][1] + ':' + "content>\n";
			}

			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			if(data != 'None')
				mmi += data;
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";

			if(data != 'None' && contentURL != 'None' && content != 'None') {
				mmi += "</" + namespaces[14][1] + ':' + "startRequest>\n";
			}
			break;

		case messageType.CANCEL:
			//alert('CANCEL');
			mmi += ":cancelRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			var immediate = msg.getImmediate();
			if(!immediate)
				var immediate = 0;
			mmi += " Immediate=\'" + immediate + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "cancelRequest>\n";
			break;

		case messageType.PAUSE:
			//alert('PAUSE');
			mmi += ":pauseRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";

			var immediate = msg.getImmediate();
			if(!immediate)
				var immediate = 0;
			mmi += " Immediate=\'" + immediate + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "pauseRequest>\n";
			break;

		case messageType.RESUME:
			//alert('RESUME');
			mmi += ":resumeRequest";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "resumeRequest>\n";
			break;

		case messageType.STATUS:
			// alert('STATUS');
			mmi += ":statusRequest";
			mmi += this.getMMIMessageBase(msg);
			var requestAutomaticUpdate = msg.getRequestAutomaticUpdate();
			mmi += " requestAutomaticUpdate=\'" + requestAutomaticUpdate + "\'";
			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			mmi += '     <metadata xsi:type=\'xsd:string\'>' + msg.getMetadata(true) + '</metadata>\n';
			mmi += '     ' + msg.getData() + '\n';
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "statusRequest>\n";

			//alert("**************************** mmi:\n" + mmi);
			break;

		case messageType.EXTENSION_NOTIFICATION:
			//alert('EXTENSION_NOTIFICATION');
			mmi += ":extensionNotification";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			var name = msg.getName();
			var data = msg.getData();
			if(debug)
				if(!data)
					data = 'None';

			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			if(data != 'None')
				mmi += data;
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "extensionNotification>\n";
			break;

		case messageType.DONE_NOTIFICATION:
			//alert('DONE_NOTIFICATION');
			mmi += ":doneNotification";
			mmi += this.getMMIMessageBase(msg);
			mmi += " context=\'" + msg.getContext() + "\'";
			mmi += " status=\'" + msg.getStatus() + "\'";

			var data = msg.getData();
			if(debug)
				if(!data)
					data = 'None';

			mmi += " >\n";
			mmi += "<" + namespaces[14][1] + ':' + "data>";
			mmi += this.addWSData(msg);
			if(data != 'None')
				mmi += data;
			mmi += "</" + namespaces[14][1] + ':' + "data>\n";
			mmi += "</" + namespaces[14][1] + ':' + "doneNotification>\n";
			break;
	}

	//if(debug) }
	//if(debug) alert("================ createMMIMessage :\n"+ mmi);

	mmi += "</" + namespaces[14][1] + ":" + namespaces[14][1] + ">\n";
	console.log("[MMDispatcher][createMMIMessage] - Ended");
	return mmi;
}

MMDispatcher.addWSData = function(msg) {
	console.log("[MMDispatcher][addWSData] - Started");
	wsArgs = '\n     <api xsi:type=\'xsd:string\'>' + msg.getApi() + '</api>\n';
	wsArgs += '     <method xsi:type=\'xsd:string\'>' + msg.getMethod() + '</method>\n';
	var token = msg.getToken(); 
	if (!token) token = msg.getRequestId()
	wsArgs += '     <token xsi:type=\'xsd:string\'>' + token + '</token>\n';
	console.log("[MMDispatcher][addWSData] - Ended");
	return wsArgs;
}

MMDispatcher.getMMIMessageBase = function(msg) {
	console.log("[MMDispatcher][getMMIMessageBase] - Started");
	base = " requestID=\'" + msg.getRequestId() + "\'";
	base += " source=\'" + msg.getSource() + "\'";
	base += " target=\'" + msg.getMethod() + "\'";
	console.log("[MMDispatcher][getMMIMessageBase] - Ended");
	return base;
}
/**
 * private function : send createXMLMessage that creates the body of the message
 * as an xml tree
 * Warning Param order mandatory in URL!
 * @param msg contains request as key-value pairs
 */
MMDispatcher.createXMLMessage = function(msg) {
	console.log("[MMDispatcher][createXMLMessage] - Started");
	var token = msg.getToken(); 
	if (!token) token = msg.getRequestId()
	xml = '\n<api xsi:type=\'xsd:string\'>' + msg.getApi() + '</api>\n' + 
	'<method xsi:type=\'xsd:string\'>' + msg.getMethod() + '</method>\n' + 
	'<caller xsi:type=\'xsd:string\'>' + msg.getSource() + '</caller>\n' + 
	'<token xsi:type=\'xsd:string\'>' + token + '</token>\n' + 
	'<id xsi:type=\'xsd:string\'>' + msg.getRequestId() + '</id>\n';

	var metadata = msg.getMetadata();

	if(!metadata) {
		var metadataString = '<metadata>{\'type\':\'None\',\'url\':\'None\'}</metadata>\n';
		xml = xml + metadataString.replace(/'/g, "&quot;");
	} else {
		var metadataString = '<metadata>{\'type\':' + metadata.type + ',\'url\':' + metadata.url + '}</metadata>\n';
		xml = xml + metadataString.replace(/'/g, "&quot;");
	}

	xml = xml + '<type xsi:type=\'xsd:string\'>' + msg.getType() + '</type>\n' + '<context xsi:type=\'xsd:string\'>' + msg.getContext() + '</context>\n' + '<status xsi:type=\'xsd:string\'>' + msg.getStatus() + '</status>\n';
	console.log("[MMDispatcher][createXMLMessage] - Ended");
	return xml;
}

