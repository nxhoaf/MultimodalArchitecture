package Architecture
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.xml.XMLDocument;

	public class Parser
	{
		private static var debug : Boolean = false;
		public function Parser()
		{
		}
		
		public static function setDebug(debug : Boolean) : void {
			Parser.debug = debug;
		}
		public static function getDebug() : Boolean {
			return Parser.debug;
		}
		
		public static function decodeHtmlEntities(str:String):String {
			return new XMLDocument(str).firstChild.nodeValue;
		}
		
		/**
		 * Parse Timer Data
		 * @return an array containing {begin, end, interval} of our timer
		 */ 
		public static function parseTimerData(timerData: String) : Array {
			trace("[Parser][parseTimerData] - Started ");
			var parsedData : Array = new Array();			
			// Get data, exclude { and }
			timerData = timerData.substr(1, timerData.length - 2); 
			parsedData = timerData.split("-");
			
			var now : Number = Date.parse(new Date());
			var sleepTime : Number = new Number(parsedData[0]) 
			var duration : Number = new Number(parsedData[1]);
			var interval : Number = new Number(parsedData[2]);
			
			parsedData[0] = now + sleepTime;  // begin
			trace("[Parser][parseTimerData] - begin: " + parsedData[0]);
			
			parsedData[1] = now + sleepTime + duration; // end
			trace("[Parser][parseTimerData] - end: " + parsedData[1]);
			
			parsedData[2] = interval; // interval
			trace("[Parser][parseTimerData] - interval: " + parsedData[2]);
			
			trace("[Parser][parseTimerData] - Ended ");
			return parsedData;
		}
		
		/**
		 * Parser received data
		 * @return an object of type URLVariables containing all parsed 
		 * information
		 */ 
		public static function parseReceivedData(responseData : 
												 String) : URLVariables {
			trace("[Parser][parseReceivedData] - Started ");
			var myPattern:RegExp = /\'/g;
			responseData = responseData.replace(myPattern, "\"");
			trace("[Parser][parseReceivedData] - raw data : " + responseData);
			var serviceResponse:URLVariables;
			
			var serviceXMLResponse:XML = new XML(responseData);
			var soapNS:Namespace = serviceXMLResponse.namespace("soap");
			if(soapNS==null) { 
				var jsonStructure:Object = 
					com.adobe.serialization.json.JSON.decode(responseData); 
				var response:Object = jsonStructure.response; 
				var data:Object = jsonStructure.response.data;
				delete(jsonStructure.response.data);
				delete(jsonStructure.jsonrpc);
				delete(jsonStructure.response);
				
				serviceResponse = new URLVariables();
				for (var p:String in response) {  
					serviceResponse[p]  = response[p]; 
				}
				for (var d:String in data) {   
					serviceResponse[d]  = data[d]; 
				}
				for (var o:String in jsonStructure) { 
					serviceResponse[o]  = jsonStructure[o]; 
				}
				
			} else {
				var envelopeNS:Namespace = serviceXMLResponse.namespace("env"); 
				var body:XMLList = serviceXMLResponse.envelopeNS::Body;
 
				
				
				var bodyContent:XML =body[0].children()[0];
				var operation:String = bodyContent.name(); 
				operation=operation.replace(envelopeNS+"::", "");
				operation=operation.replace("Response", ""); 
				
				

				var output:XML =bodyContent[0].children()[0];

				
				
				// process SOAP/MMI response
				if(output.*.length() == 1) {
					var isMMI:Boolean=true;
					output = output[0].children()[0];
					var responseTag:XML = output.children()[0];
					var dataTag:XML = responseTag.children()[0];
					output=dataTag;
				}

				
				
				serviceResponse = new URLVariables();
				for (var i:int = 0; i < output.*.length(); i++) {
					var child:XML = output[0].children()[i];
					var parameterName:String = child.name();
					var parameterValue:String =  
						output[0].children()[i].toString();

					if(!isMMI) {
						serviceResponse[parameterName] = 
							decodeHtmlEntities(parameterValue);
					} else {
						serviceResponse[parameterName] = 
							parameterValue;
					}
				} 
			}
			trace("[Mc_AirRecorder_1][parseReceivedData] - Ended ");
			return serviceResponse;
		}
	}
}