package Architecture
{
	import MMI_Lib.Status;
	
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	public final class DataComponent
	{
		private var dataStoreName : String;
		private var sharedObject : SharedObject;
		public function DataComponent(name : String)
		{
			this.dataStoreName = name;
			sharedObject = SharedObject.getLocal(name);
		}
		
		public function hasData() : Boolean {
			if (sharedObject.data.hasData == null) 
				return false;
			else
				return sharedObject.data.hasData;
		}
		
		public function readCookie(name : String) : String {
			if (sharedObject.data.hasData == null 
				|| sharedObject.data.hasData == false)
				return null;
			return sharedObject.data[name];
		}
		
		public function createCookie(name : String, value : Object) : void {
			sharedObject.data[name] = value;
			sharedObject.data.hasData = true;
		}
		
		public function eraseCookie() : void {
			sharedObject.data.hasData = false;
		}
		
		public function commit() : void {
			sharedObject.flush();
		}
		
		public function saveRegisterInfo(serviceResponse 
										 		: URLVariables) : String {
			trace("[DataComponent][saveRegisterInfo] - Started ");
			
			// -------------------- 1. Variables declaration  ------------------
			var begin : Number;
			var currentState : String; 
			var end : Number;
			var interval : Number;
			var lifeTime : Number;
			var now : Number; 
			var registerId : String;
			var serviceResponse : URLVariables; 
			var sleep : Number;
			var timerData : String;
			var validationResult : String;
			
			// -------------------- 2. Save info -------------------------------
			if (serviceResponse.status == Status.ALIVE) {
				now = Date.parse(new Date());
				end = Number(readCookie("end"));
				
				if (!end || end < now ) {
					timerData = serviceResponse.timeout; // Get timer data
					// Check if we have timerData.
					if(timerData == null 
								|| serviceResponse.deliveryContent == null) {
						trace("[DataComponent][saveRegisterInfo] - "+
											"Error, don't have timerData! ");
						currentState = InteractionState.FAILURE;
						trace("[DataComponent][saveRegisterInfo] - Ended. "+
								   "State will be changed to: " + currentState);
						return currentState;
					}
					
					trace("[DataComponent][saveRegisterInfo] - "+
						  "Saving received info into cookie: " + dataStoreName);
					
					registerId = serviceResponse.deliveryContent;
					begin = Parser.parseTimerData(timerData)[0];
					end = Parser.parseTimerData(timerData)[1];					
					interval = Parser.parseTimerData(timerData)[2];
					createCookie("hasData", true);
					createCookie("registerId", registerId);
					createCookie("begin", begin);
					createCookie("end", end);
					createCookie("interval", interval);
					commit();
					
					currentState = InteractionState.HAS_SESSION;
				} else {
					trace("[DataComponent][processRegister] - "+
								"Timer data found in cache!");
					// If we've already had session and it still be valid
					currentState = InteractionState.HAS_SESSION; 
				}
			} else {
				// delete data (logically turn off the flag);
				eraseCookie();
				commit();
				
				currentState = InteractionState.FAILURE;
				trace("[DataComponent][load] - Ended. "+
								"State will be changed to: " + currentState);
				return currentState;
			}
			
			trace("[DataComponent][saveRegisterInfo] - Ended " +
							"State will be changed to: " + currentState);
			return currentState;
		}
		
		public function processInformResponse(event : Event, 
											  requestId : String, 
											  previousState : String) : String {
			trace("[DataComponent][processInformResponse] - Started ");
			// -------------------- 1. Variables declaration  ------------------
			var begin : Number;
			var end : Number;
			var interval : Number;
			var currentState : String; 
			var lifeTime : Number;
			var now : Number;
			var registerId : String;
			var serviceResponse : URLVariables; 
			var sleep : Number;
			var timerData : String;
			var validationResult : String; 
			
			// -------------------- 2. Process data  ---------------------------
			var loader:URLLoader = URLLoader(event.target);
			loader.dataFormat = URLLoaderDataFormat.TEXT; 
			serviceResponse = Parser.parseReceivedData(loader.data);
			timerData = serviceResponse.timeout;
			
			// Modify data based on data in timer field.
			if (timerData != null) {
				now = Date.parse(new Date());
				
				begin = Parser.parseTimerData(timerData)[0];
				end = Parser.parseTimerData(timerData)[1];					
				interval = Parser.parseTimerData(timerData)[2];
				
				if (now >= end) {
					currentState = InteractionState.DEAD;
					trace("[DataComponent][processListeningResponse] - "+
						" Invalid data:");
					trace("		now: " + (new Date(now)).toString());
					trace("		end: " + (new Date(end)).toString());
					return currentState;
				}
				
				createCookie("begin", begin);
				createCookie("end", end);
				createCookie("interval", interval);
				commit();
				
				trace("[DataComponent][processListeningResponse] - "+
					"Update timer data");
				trace("		begin: " + (new Date(begin)).toString());
				trace("		end: " + (new Date(end)).toString());
				trace("		interval: " + (new Date(interval)).toString());
				
				switch (previousState) 
				{
					case InteractionState.HAS_SESSION:
						currentState = 
								InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED;
						break;
					
					default : 
						currentState = InteractionState.DEAD;
						break;
				}
				
			}
			
			trace("[DataComponent][processInformResponse] - Ended. "+
							"State will be changed to: " + currentState);
			return currentState;
		}
		public function getDataStoreName() : String {
			return dataStoreName;
		}
	}
}