console.log("DCFactory.js loaded");

var DCFactory = function() {};

DCFactory.createHtmlDC = function() {
	var dataComponent = {};

	/**
	 * Create cookie 
	 * @param {Object} name
	 * @param {Object} value
	 * @param {Object} days
	 */
	dataComponent.createCookie = function(name, value, days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
			var expires = "; expires=" + date.toGMTString();
		} else
			var expires = "";
		document.cookie = name + "=" + value + expires + "; path=/";
	}

	/**
	 * Read cookie
   	 * @param {Object} name
	 */
	dataComponent.readCookie = function(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for (var i = 0; i < ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0) == ' ')
			c = c.substring(1, c.length);
			if (c.indexOf(nameEQ) == 0)
				return c.substring(nameEQ.length, c.length);
		}
		
		return null;
	}
	
	/**
	 * EraseCookie 
 	 * @param {Object} name
	 */ 
	dataComponent.eraseCookie = function(name) {
		dataComponent.createCookie(name,"",-1);
	}
	
	/**
	 * save register info to local memory. 
 	 * @param {Object} serviceResponse
	 */
	dataComponent.saveRegisterInfo = function(serviceResponse) {
		console.log("[DcComponent]{saveRegisterInfo} - Started");
		
		// -------------------- 1. Variables declaration  ----------------------
		var begin;
		var currentState; 
		var end;
		var interval;
		var lifeTime;
		var now; 
		var registerId;
		var serviceResponse; 
		var sleep;
		var timerData;
		var validationResult; 
		
		// -------------------- 2. Save info -----------------------------------				
		if (serviceResponse.status == status.ALIVE) {
			now = (new Date()).getTime();
			end = dataComponent.readCookie("end");
			
			if (!end || end < now ) {
				timerData = serviceResponse.timeout; // Get timer data
				
				// Check if we have timerData.
				if(timerData == null || serviceResponse.deliveryContent == null) {
					console.log("[DataComponent][processRegister] - "+
								"Error, don't have timerData! ");
					currentState = InteractionState.FAILURE;
					console.log("[DataComponent][load] - Ended. "+
								"State will be changed to: " + currentState);
					return currentState;
				}
				
				console.log("[DataComponent][processRegister] - "+
							"Saving received info into cookie: " + componentName);
				registerId = serviceResponse.deliveryContent;
				
				begin = Parser.parseTimerData(timerData)[0];
				end = Parser.parseTimerData(timerData)[1];					
				interval = Parser.parseTimerData(timerData)[2];
				
				dataComponent.createCookie("hasData", true);
				dataComponent.createCookie("registerId", registerId);
				dataComponent.createCookie("begin", begin);
				dataComponent.createCookie("end", end);
				dataComponent.createCookie("interval", interval);
				
				currentState = InteractionState.HAS_SESSION;
			} else {
				console.log("[DataComponent][processRegister] - "+
							"Timer data found in cache!");
				// If we've already had session and it still be valid
				currentState = InteractionState.HAS_SESSION; 
			}
		} else {
			// delete data (logically turn off the flag);
			createCookie("hasData", false); 
			currentState = InteractionState.FAILURE;
			console.log("[DataComponent][load] - Ended. "+
						"State will be changed to: " + currentState);
			return currentState;
		}
		
		
		console.log("[DcComponent]{saveRegisterInfo} - Ended. "+
					" State will be changed to: " + currentState);
		return currentState;
	}
	
	
	dataComponent.processInformResponse = function (data, requestId, previousState) {
		console.log("[DataComponent][processListeningResponse] - Started ");
		// -------------------- 1. Variables declaration  -----------------------
		var currentState; 
		var serviceResponse; 
		var validationResult; 
		var registerId;
		// Time-related variable
		var now; 
		var sleep; 
		var begin;
		var end;
		var lifeTime; 
		var interval;
		var timerData;
		// -------------------- 2. Process data  -------------------------------
		serviceResponse = Parser.parseReceivedData(data);
		timerData = serviceResponse.timeout;
		
		// Modify data based on data in timer field.
		if (timerData != null) {
			now = Date.parse(new Date());
			
			begin = Parser.parseTimerData(timerData)[0];
			end = Parser.parseTimerData(timerData)[1];					
			interval = Parser.parseTimerData(timerData)[2];
			
			if (now >= end) {
				currentState = InteractionState.DEAD;
				console.log("[DataComponent][processListeningResponse] - "+
							" Invalid data:");
				console.log("		now: " + (new Date(now)).toString());
				console.log("		end: " + (new Date(end)).toString());
				return currentState;
			}
			
			dataComponent.createCookie("begin", begin);
			dataComponent.createCookie("end", end);
			dataComponent.createCookie("interval", interval);
			
			console.log("[DataComponent][processListeningResponse] - "+
						"Update timer data");
			console.log("		begin: " + (new Date(begin)).toString());
			console.log("		end: " + (new Date(end)).toString());
			console.log("		interval: " + (new Date(interval)).toString());
			
			switch (previousState) 
			{
				case InteractionState.HAS_SESSION:
					currentState = InteractionState.NEW_CONTEXT_REQUEST_SHEDULED;
					break;
				
				default : 
					currentState = InteractionState.DEAD;
					break;
			}
			
		}
		
		console.log("[DataComponent][processInformResponse] - Ended. "+
					"State will be changed to: " + currentState);
		return currentState;
	}
	
	
	return dataComponent;
}

DCFactory.createGpacDC = function() {

}
