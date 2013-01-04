console.log("StateManager.js loaded");

var StateManager = function () {
	var stateManager = {};
	
	var dataComponent = DCFactory.createHtmlDC();
	var sleepTime;
	
	stateManager.getSleepTime = function () {
		return sleepTime;
	}
	
	stateManager.load = function () {
		console.log("[AdvertiseManager][load] - Started ");
		// -------------------- 1. Variables declaration  ----------------------
		var currentState;
		var hasData;
		var htmlDc = DCFactory.createHtmlDC();
		var loadedLife;
		var loadedInterval;
		var loadedSleep; 
		var now = (new Date()).getTime();
		 
		// -------------------- 2. Algorithme Load -----------------------------
		currentState = InteractionState.DEAD;
		hasData = htmlDc.readCookie("hasData");

		if(hasData != null && hasData) {
			loadedSleep = htmlDc.readCookie("begin") - now;
			console.log("[StateManager][load] - "+
								"loadedSleep: " + loadedSleep);
			
			loadedInterval = htmlDc.readCookie("interval");
			console.log("[StateManager][load] - "+
								"loadedInterval: " + loadedInterval);
			
			loadedLife = htmlDc.readCookie("end");
			console.log("[StateManager][load] - now       : " + now);
			console.log("[StateManager][load] - "+
								"loadedLife: " + loadedLife);
			
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
		console.log("[StateManager][load] - Ended." + 
					"State will be changed to: " + currentState);
		return currentState;
	}
	
	stateManager.processNewCtxResponse = function(serviceResponse) {
		console.log("[StateManager]{processNewCtxResponse} - Started");
		// -------------------- 1. Variables declaration  ----------------------
		var context;
		var currentState;
		
		// -------------------- 2. Process response  ---------------------------
		context = serviceResponse.context;
		// Not ready: wait until timeout to send a new context Request
		if (context.toUpperCase() == "ALIVE") { 						
				currentState = InteractionState.NEW_CONTEXT_REQUEST_SHEDULED;
			} else {					
				currentState = InteractionState.HAS_CONTEXT;
				var begin = dataComponent.readCookie("begin");
				var end = dataComponent.readCookie("end");
				var expiredDay = (end - begin) / (60*60*24*1000);
				expiredDay = Math.floor(expiredDay);
				dataComponent.createCookie("context", 
											serviceResponse.context, 
											expiredDay);
				if (serviceResponse.token) // If have token, save it.
					dataComponent.createCookie("token", 
												serviceResponse.token, 
												expiredDay);				
			}

		console.log("[AdvertiseManager][processNewCtxResponse] - Ended." + 
					"State will be changed to: " + currentState);
					
		return currentState;
	}
	
	return stateManager;
};
