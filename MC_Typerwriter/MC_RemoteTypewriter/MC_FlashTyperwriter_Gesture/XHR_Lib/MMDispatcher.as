package XHR_Lib
{
	import Config.Configuration;
	
	import MMI_Lib.*;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.*;
	import flash.text.ReturnKeyLabel;
	
	import mx.messaging.channels.StreamingAMFChannel;
 
	public class MMDispatcher
	{
		private var urlLoader : URLLoader;
		public static const TEXT : String = URLLoaderDataFormat.TEXT;
		public static const BINARY : String = URLLoaderDataFormat.BINARY;
		
//*************************************************************************************************
// Public methods  
//*************************************************************************************************		
		public function MMDispatcher() { 
			urlLoader = new URLLoader();
			urlLoader.dataFormat = TEXT; // default
		}
		public function addEventListener(urlLoaderEvent : String, listener: Function) : void {
			urlLoader.addEventListener(urlLoaderEvent, listener);
		};
		public function removeEventListener(urlLoaderEvent: String, listener: Function) : void {
			urlLoader.removeEventListener(urlLoaderEvent, listener);
		};
		public function reset() : void {
			urlLoader = new URLLoader(); // In fact, we create a new object
			urlLoader.dataFormat = TEXT; // default
		}
		public function setReturnedDataFormat(returnedDataFormat : String) : void {
			urlLoader.dataFormat = returnedDataFormat;
		}
		public function getReturnedDataFormat(returnedDataFormat : String) : String {
			return returnedDataFormat;
		}
		/**
		 * This function will be used to send a asynchronous request to server
		 * @param msg :Speccontains request as key-value pairs 
		 * @param method contains the send method to use
		 * @param kind contains the kind of message to send
		 * @return boolean
		 */
		public function sendAsynchronous ( msg :Spec, method : String, kind: String ):URLLoader { 
			trace("[MMDispatcher][sendAsynchronous] - Started");
			//Parameter Verification 
			var requestMethod:String = method;
			var requestKind:String = kind;
			if (!requestMethod) requestMethod = "GET";
			if (!requestKind) requestKind = "XML";
			
			requestMethod = requestMethod.toUpperCase();
			requestKind = kind.toUpperCase();
			
			if (requestKind == "XML") { 
				switch (requestMethod) {
					case "GET": 
						msg.setApi('json'); 
						if(Configuration.debug) trace("[MMDispatcher.class]{sendAsynchronous} api is "+msg.getApi());
						this.sendJsonRequest( msg);
						break;
					case "POST":
						msg.setApi('soap');
						if(Configuration.debug) trace("[MMDispatcher.class]{sendAsynchronous} api is "+msg.getApi());
						this.sendSoapRequest( msg, requestKind );
						break;
				} 
				import MMI_Lib.Spec;
				
			} else if (requestKind == "MMI") { 
				switch (requestMethod) {
					case "GET": 
						msg.setApi('json_mmi');
						if(Configuration.debug)  trace("[MMDispatcher.class]{sendAsynchronous} api is "+msg.getApi());
						this.sendJsonRequest( msg );
						break;
					case "POST":
						msg.setApi('soap');
						if(Configuration.debug) trace("[MMDispatcher.class]{sendAsynchronous} api is "+msg.getApi());
						this.sendSoapRequest( msg, requestKind );
						break;
				}
			}
			trace("[MMDispatcher][sendAsynchronous] - Ended");
			return urlLoader;  
		}//END sendAsynchronous
//*************************************************************************************************
// Private methods  
//*************************************************************************************************
		/**
		 * private function : sendJsonRequest to create a RestFul Ajax request
		 * @param msg :Speccontains request as key-value pairs 
		 * @return boolean
		 */
		private function sendJsonRequest  ( msg:Spec ) : void { 
			trace("[MMDispatcher][sendJsonRequest] - Started");
			var targetUrl:String  = msg.getTarget(); 
			//create URLRequest instance
			var request:URLRequest = new URLRequest();
			//Choose a method as GET
			request.method = URLRequestMethod.GET; 
			request.url = targetUrl;
			request = this.addParamsToUrl ( request , msg ); 
 
			//send the request 
			trace("[MMDispatcher][sendJsonRequest] - RequestUrl: " + request.url + "?" + request.data);
			try { urlLoader.load(request); } 
			catch (error:Error) {
				trace("Error catched: " + error);
			} 
			trace("[MMDispatcher][sendJsonRequest] - Ended");
		} //END sendJsonRequest
 
		/**
		 * Add parameters to url, for ex, you have root url : abc.php and spec contains 2 key-value pairs
		 * Warning Param order mandatory in URL!
		 * @param rootUrl url to which we will add the params, based on function used 
		 * @param msg :Speccontains key-value pairs
		 * @returns add-params url.
		 */
		private function addParamsToUrl  ( request:URLRequest , msg :Spec) :URLRequest { 
			trace("[MMDispatcher][addParamsToUrl] - Started");
			var fullUrl:URLVariables = new URLVariables(); 
			
			// api
			if (msg.getApi() != null)
				fullUrl.api = msg.getApi(); 
			
			// method
			if (msg.getMethod() != null)
				fullUrl.method = msg.getMethod(); 
			
			// caller (source)
			if (msg.getMethod() != null)
				fullUrl.caller = msg.getSource(); 
			
			// token
			if (msg.getToken() != null)
				fullUrl.token = msg.getToken();
			
			// requestId
			if (msg.getRequestId() != null)
				fullUrl.id = msg.getRequestId();
					
			// metadata
			if (msg.getMetadata() != null)
				fullUrl.metadata = msg.getMetadata();
			
			// type
			if (msg.getType() != null)
				fullUrl.type= msg.getType(); // type
			
			// context
			if (msg.getContext()!= null)
				fullUrl.context = msg.getContext(); 
			
			// status
			if (msg.getStatus() != null)
				fullUrl.status=msg.getStatus(); 
 			
			// requestAutomaticUpdate
			if(msg.getAutomaticUpdate())
				fullUrl.requestAutomaticUpdate = 1;
			
			// data
			if(msg.getData() != null)
				fullUrl.data = msg.getData();
			
			request.data = fullUrl;
			trace("[MMDispatcher][addParamsToUrl] - Ended");
			
			return request; 	
		}//END addParamsToUrl
		
		/**
		 * private function : SoapRequest that sends data asynchrounously
		 * @param msg :Speccontains request as key-value pairs  
		 * @param requestKind contains the kind of message to send
		 * @return boolean
		 */
		private function sendSoapRequest  ( msg:Spec , requestKind:String ): void {
			trace("[MMDispatcher][sendSoapRequest] - Started");
			var targetUrl:String  = msg.getTarget(); 
			//create URLRequest instance
			var request:URLRequest = new URLRequest();
			request.url = targetUrl; 
			request = this.createSoapRequest( request, msg, requestKind);
			
			
			
			if(Configuration.debug) trace("[MMDispatcher.class]{sendSoapRequest} service request is : \n"+request.data);  
			
			if( msg.getApi() == 'soap' ){ 
				//Choose a method as POST
				request.method = URLRequestMethod.POST; 
				
				request.contentType = "text/xml; charset=ISO-8859-1"; 
				var soapAction:URLRequestHeader = new URLRequestHeader("SOAPAction",targetUrl);
				request.requestHeaders.push(soapAction);
				
			} else { 
				//Choose a method as GET
				request.method = URLRequestMethod.GET;  
			}		
			
			if(Configuration.debug) trace("[MMDispatcher.class]{sendSoapRequest} Sending...."); 
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT; 
			//send the request 
			try { urlLoader.load(request); } 
			catch (error:Error) {
				trace("Error catched: " + error);
			}  
			 
			trace("[MMDispatcher][sendSoapRequest] - Ended");	
		}//END 	sendSoapRequest
		
		/**
		 * private function : createSoapRequest that creates the request
		 * Warning Param order mandatory in URL! 
		 * @param msg :Speccontains request as key-value pairs  
		 * @param requestKind contains the kind of message to send
		 */
		private function createSoapRequest  (  request:URLRequest , msg :Spec, requestKind:String  ):URLRequest {
			trace("[MMDispatcher][createSoapRequest] - Started");
			var xml:String;
			xml = 	'<?xml version="1.0" encoding="ISO-8859-1"?>\n'; 
			xml += '<env:Envelope'; 
			var n:Number;
			for(n=0; n<Configuration.namespaces.length; n++ ) {	
				xml += ' ' + Configuration.namespaces[n][0] + ':' + Configuration.namespaces[n][1] + '=\'' + Configuration.namespaces[n][2]+'\'\n';
			}
			 
			xml += ' >'; 
			xml += '\n<env:Body>'+
			'\n<ns1:MC_register xmlns:ns1="'+Configuration.server+'">';
			
			if(requestKind == 'XML'){
				if(Configuration.debug) trace("[MMDispatcher.class]{sendSoapRequest} createXMLMessage");
				xml += this.createXMLMessage(msg);	
				
			} else {
				if(Configuration.debug) trace("[MMDispatcher.class]{sendSoapRequest} createMMIMessage");
				xml += this.createMMIMessage( msg);
				
			} 
			
			xml += '</ns1:MC_register>\n' +
			
			'</env:Body>\n' +
			'</env:Envelope>\n' ; 
			
			//var test : XML = new XML(xml);
			//Alert.show("**************var test : XML = new XML(xml); \n" +test.toString());
			
			//request.data =  new XML(xml); 
			request.data = xml;
			trace("[MMDispatcher][createSoapRequest] - Ended");
			return request;
		}//END createSoapRequest
		
		/**
		 * private function : send createXMLMessage that creates the body of the message 
		 * as an xml tree
		 * Warning Param order mandatory in URL! 
		 * @param msg :Speccontains request as key-value pairs   
		 */
		private function createXMLMessage  ( msg:Spec) :String {
			trace("[MMDispatcher][createXMLMessage] - Started");
			var xml:String; 

			xml = 	'\n<api xsi:type=\'xsd:string\'>' + msg.getApi() + '</api>\n' +
			'<method xsi:type=\'xsd:string\'>' + msg.getMethod() + '</method>\n' +
			'<caller xsi:type=\'xsd:string\'>' + msg.getSource() + '</caller>\n' +
			'<token xsi:type=\'xsd:string\'>' + msg.getRequestId() + '</token>\n' +
			'<id xsi:type=\'xsd:string\'>' + msg.getRequestId() + '</id>\n';
			// type conversion
			var metadata:Metadata = Metadata (msg.getMetadata()); 
			var metadataString:String;
			if (!metadata){
			metadataString = '{\'type\':\'None\',\'url\':\'None\'}';
			metadataString = metadataString.replace(/'/g, "&quot;");	
			metadataString = '<metadata xsi:type=\'xsd:string\'>'+metadataString+'</metadata>\n';
			xml = xml +  metadataString;
			} else{		
			metadataString = '{\'type\':'+ metadata.getType() + ',\'url\':' + metadata.getUrl() + '}';
			metadataString = metadataString.replace(/'/g, "&quot;");	
			metadataString = '<metadata xsi:type=\'xsd:string\'>'+metadataString+'</metadata>\n';
			xml = xml +  metadataString;
			}
			
			xml = xml + 
			'<type xsi:type=\'xsd:string\'>' + msg.getType() + '</type>\n' +
			'<context xsi:type=\'xsd:string\'>' + msg.getContext() + '</context>\n' +
			'<status xsi:type=\'xsd:string\'>' + msg.getStatus() + '</status>\n';
			'<data xsi:type=\'xsd:string\'>' + msg.getData() + '</data>\n';
			
			
			trace("[MMDispatcher][createXMLMessage] - Ended");
			return xml; 
		}//END createXMLMessage

		/**
		 * private function : createMMIMessage that creates the body of the MMI message 
		 * according to MMI Spec Schema
		 * Warning Param order mandatory in URL! 
		 * @param msg :Speccontains request as key-value pairs   
		 */
		private function createMMIMessage  ( msg:Spec ) :String { 
			trace("[MMDispatcher][createMMIMessage] - Started");
			var mmi:String='';
			mmi += "\n<" + Configuration.namespaces[14][1] + ":" + Configuration.namespaces[14][1] + " " + Configuration.namespaces[14][0] + ":" + Configuration.namespaces[14][1] + "='" + Configuration.namespaces[14][2] + "' version='1.0'>";
			
			
			var type:String = msg.getType();
			
			if(Configuration.debug) trace("Interaction Type is :"+msg.getType());
			
			// Test of the creation of all events
			//if(debug) for(n=0;n<10;n++) {
			//if(debug) type = n;  
			
			mmi += "\n<" + Configuration.namespaces[14][1];
			var data:String = msg.getData();
			var immediate:Boolean;
			var requestAutomaticUpdate:String;
			var name :String;
			
			if(!data) data='None';
			switch (type) {
				//***********************************************************
				// case MessageType.NEW_CONTEXT: 
				//***********************************************************
				case MessageType.NEW_CONTEXT: 
				trace("[MMDispatcher][createMMIMessage] - Creating NEW_CONTEXT");
				mmi += ":newContextRequest";
				mmi +=  this.getMMIMessageBase(msg); 
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg); 
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"newContextRequest>\n";
				break;
				
				
				//***********************************************************
				// case MessageType.CLEAR_CONTEXT:
				//***********************************************************
				case MessageType.CLEAR_CONTEXT: 
				trace("[MMDispatcher][createMMIMessage] - Creating CLEAR_CONTEXT");
				mmi += ":clearContextRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"clearContextRequest>\n";
				break;
				
				
				//***********************************************************
				// case MessageType.CLEAR_CONTEXT:
				//***********************************************************
				case MessageType.PREPARE: 
				trace("[MMDispatcher][createMMIMessage] - Creating PREPARE");
				mmi += ":prepareRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"prepareRequest>\n";
				break;		
				
				
				//***********************************************************
				// case MessageType.CLEAR_CONTEXT:
				//***********************************************************
				case MessageType.START:
				trace("[MMDispatcher][createMMIMessage] - Creating START");	
				mmi += ":startRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'";
				
				var contentURL:String = msg.getContentUrl();  
				var content:String = msg.getContent();  
	 
				if(contentURL !='None') {
				mmi += " >";
				mmi += "\n<" + Configuration.namespaces[14][1]+':';
				mmi += "contentURL href=\'"+ contentURL+"\' />\n"; 
				} 
				
				if(content !='None') { 
				mmi += "<" + Configuration.namespaces[14][1]+':'+"content>";
				mmi += content;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"content>\n";
				}
				
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
					mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				
				if(data !='None' && contentURL !='None' && content !='None' ) {
					mmi += "</" + Configuration.namespaces[14][1]+':'+"startRequest>\n"; 
				}    
				break; 
				
				
				//***********************************************************
				// case MessageType.CANCEL: 
				//***********************************************************
				case MessageType.CANCEL: 
				trace("[MMDispatcher][createMMIMessage] - Creating CANCEL");
				mmi += ":cancelRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'";  
				immediate = msg.getImmediate();
				if(!immediate) immediate =false;
				mmi += " Immediate=\'"+ immediate +"\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"cancelRequest>\n";
				break;
				 
				
				//***********************************************************
				// case MessageType.PAUSE:
				//***********************************************************
				case MessageType.PAUSE: 
				trace("[MMDispatcher][createMMIMessage] - Creating PAUSE");
				mmi += ":pauseRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'"; 
				immediate = msg.getImmediate();
				if(!immediate) immediate =false;
				mmi += " Immediate=\'"+ immediate +"\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);				
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"pauseRequest>\n";
				
				break;
				
				
				//***********************************************************
				// case MessageType.RESUME: 
				//***********************************************************
				case MessageType.RESUME: 
				trace("[MMDispatcher][createMMIMessage] - Creating RESUME");
				mmi += ":resumeRequest";
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'"; 
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"resumeRequest>\n";
				break;
				
				
				//***********************************************************
				// case MessageType.STATUS:
				//***********************************************************
				case MessageType.STATUS: 
				trace("[MMDispatcher][createMMIMessage] - Creating STATUS");
				mmi += ":statusRequest"; 
				mmi +=  this.getMMIMessageBase( msg); 
				if (msg.getRequestAutomaticUpdate())
					requestAutomaticUpdate = "1";
				else 
					requestAutomaticUpdate = "0";
				mmi += " requestAutomaticUpdate=\'"+ requestAutomaticUpdate + "\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				
				mmi += '     <metadata xsi:type=\'xsd:string\'>' + msg.getMetadata() + '</metadata>\n';
				
				if(data !='None') mmi += '     ' + data + "\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"statusRequest>\n"; 
				break;
				
				
				//***********************************************************
				// case MessageType.EXTENSION_NOTIFICATION:
				//***********************************************************
				case MessageType.EXTENSION_NOTIFICATION: 
				trace("[MMDispatcher][createMMIMessage] - Creating EXTENSION_NOTIFICATION");
				trace('EXTENSION_NOTIFICATION');
				mmi += ":extensionNotification";  
				mmi +=  this.getMMIMessageBase( msg); 
				mmi += " context=\'"+ msg.getContext() + "\'"; 
				name = msg.getName(); 
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"extensionNotification>\n"; 	
				break;			
			 
				
				//***********************************************************
				// case MessageType.DONE_NOTIFICATION: 
				//***********************************************************
				case MessageType.DONE_NOTIFICATION: 
					trace("[MMDispatcher][createMMIMessage] - Creating DONE_NOTIFICATION");
				mmi += ":doneNotification";
				mmi +=  this.getMMIMessageBase( msg);
				mmi += " context=\'"+ msg.getContext() + "\'";  
				mmi += " status=\'"+ msg.getStatus() + "\'";
				mmi += " >\n";
				mmi += "<" + Configuration.namespaces[14][1]+':'+"data>";
				mmi += this.addWSData( msg);
				if(data !='None') mmi += data;
				mmi += "</" + Configuration.namespaces[14][1]+':'+"data>\n";
				mmi += "</" + Configuration.namespaces[14][1]+':'+"doneNotification>\n";
				break; 
			 
			} 
			
			//if(debug) }
			if(Configuration.debug) trace("================ createMMIMessage :\n"+ mmi);
			
			mmi += "</" + Configuration.namespaces[14][1] + ":" + Configuration.namespaces[14][1] + ">\n";
			trace("[MMDispatcher][createMMIMessage] - Ended");
			return mmi;
			
	}//END createMMIMessage

	private function getMMIMessageBase  ( msg:Spec):String {
		var base:String; 
		 
		base = " requestID=\'"+ msg.getRequestId() +"\'";
		base += " source=\'"+ msg.getSource() +"\'";
		base += " target=\'"+ msg.getMethod() +"\'"; 
		 
		return base; 
	}//END getMMIMessageBase
	
	private function addWSData  ( msg:Spec ):String { 
		var wsArgs:String;
		wsArgs = '\n     <api xsi:type=\'xsd:string\'>' + msg.getApi() + '</api>\n'; 
		wsArgs += '     <method xsi:type=\'xsd:string\'>' + msg.getMethod() + '</method>\n'; 
		wsArgs += '     <token xsi:type=\'xsd:string\'>' + msg.getRequestId() + '</token>\n'; 
		 
		return wsArgs;
		
	}//END addWSData
		
	}//END CLASS
}//END PACKAGE