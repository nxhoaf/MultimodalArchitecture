package Architecture
{
	import flash.events.Event;
	import flash.net.URLVariables;

	public class StateManager
	{
		private var componentName : String;
		private var dataComponent : DataComponent;
		private var sleepTime : int;
		
		public function StateManager(name : String) {
			componentName = name;
			dataComponent = DCFactory.createDC(name);
		}
		
		public function getSleepTime() : int {
			return sleepTime;
		}
		
		public function setSleepTime(sleepTime : int) : void {
			this.sleepTime = sleepTime;
		}
		
		public function load() : String {
			trace("[StateManager][load] - Started");
			// -------------------- 1. Variables declaration  ------------------
			var currentState : String;
			var hasData : Boolean;
			var dataComponent : DataComponent = 
						DCFactory.createDC(componentName);
			var loadedLife : int;
			var loadedInterval : int;
			var loadedSleep : int; 
			var now : Number = Date.parse(new Date());
			
			// -------------------- 2. Algorithme Load -------------------------
			currentState = InteractionState.DEAD;
			hasData = dataComponent.hasData();
			
			if(hasData) {
				loadedSleep = Number(dataComponent.readCookie("begin")) - now;
				trace("[AdvertiseManager][load] - loadedSleep: " + loadedSleep);
				
				loadedInterval = Number(dataComponent.readCookie("interval"));
				trace("[AdvertiseManager][load] - "+
								"loadedInterval: " + loadedInterval);
				
				loadedLife = Number(dataComponent.readCookie("end"));
				trace("[AdvertiseManager][load] - now       : " + now);
				trace("[AdvertiseManager][load] - loadedLife: " + loadedLife);
				
				if (now < loadedLife) {
					currentState = InteractionState.ALIVE;
					if (loadedSleep > 0) {
						currentState = InteractionState.SLEEP;
						sleepTime = loadedSleep;
					}
				} else {
					currentState = InteractionState.DEAD;
				}
				
			}
			trace("[StateManager][load] - Ended." + 
							"State will be changed to: " + currentState);
			return currentState;
		}
		
		public function processNewCtxResponse(serviceResponse 
											  		: URLVariables) : String {
			trace("[StateManager][processNewCtxResponse] - Started");
			
			// -------------------- 1. Variables declaration  ------------------
			var context : String;
			var currentState : String;
			var begin : Number; 
			var end : Number; 
			var expiredDay : Number;
			
			// -------------------- 2. Process response  -----------------------
			context = serviceResponse.context;
			// Not ready: wait until timeout to send a new context Request
			if (context.toUpperCase() == "ALIVE") { 						
				currentState = InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED;
			} else {					
				currentState = InteractionState.HAS_CONTEXT;
				begin = Number(dataComponent.readCookie("begin"));
				end = Number(dataComponent.readCookie("end"));
				expiredDay = (end - begin) / (60*60*24*1000);
				expiredDay = Math.floor(expiredDay);
				dataComponent.createCookie("context", 
										   serviceResponse.context);
				if (serviceResponse.token) // If have token, save it.
					dataComponent.createCookie("token",
											   serviceResponse.token);				
			}
			trace("[StateManager][processNewCtxResponse] - Ended");
			return currentState;
		}
	}
}











