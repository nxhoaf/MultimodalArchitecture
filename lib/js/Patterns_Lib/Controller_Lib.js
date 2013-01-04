console.log("Controller_Lib.js loaded");

var Controller = function () {
	var Controller = {};
	var requestNo = 0;
	var advertiseManager = new AdvertiseManager();
	var stateManager = new StateManager();
	var interactionManager = new InteractionManager();
	var state = new InteractionState();
	var timer = {};
	// overrided
	var self = this;
 
	dataReceived = function (data) {
		console.log("[Controller_Lib]{dataReceived} data received, now process Event");
		Controller.processEvent(state, data);  
	}
	
	Controller.observe = function () {
		console.log("[Controller_Lib]{observe} Controller object created");
		console.log("[Controller_Lib]{observe} prepare register Request");
		
		requestNo += 1;
		var spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : createRequestId(), // config.js
			target : serviceRegister, // config.js
			metadata : MC_metadata, // MC_config.js
			type : messageType.STATUS,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.LOAD
		}
		
		var returnedState = advertiseManager.sendRegister(spec);
		state.setCurrentState(returnedState);
			
		if(isEmpty(timer)) {
			var now = (new Date()).getTime();
			var sleep = readCookie("begin") - now;
			if (sleep < 1000 ) sleep = 0;
			if(debug) sleep = sleepDebug;
			var lifeTime = readCookie("end") - now; 
			if(debug) lifeTime = lifeTimeDebug;
			var interval = readCookie("interval");
			if(debug) interval = intervalDebug;
			
			timer = new Timer(sleep, lifeTime, interval);
			timer.start();
			console.log("[Controller_Lib]{observe} TIMER LAUNCHED ");
			
			// Redefined onTimerElapsed
			timer.onTimerElapsed = function () {
				Controller.onTimerElapsed();
			}
		}
		
		console.log("[Controller_Lib]{observe} Current state: " + state.getCurrentState());
	}
	
	Controller.startRegister = function () {
		console.log("[Controller_Lib]{startRegister} Create Start Request");
				requestNo += 1;
				spec = {
					method : operationOrchestrate, // config.js
					source : componentName, // MC_config.js
					token : defaultToken, // config.js 
					requestId : createRequestId(), // config.js
					target : serviceController, // config.js
					metadata : MC_metadata, // MC_config.js
					type : messageType.START,
					confidential : MC_confidential, // MC_config.js
					context : defaultContext, // config.js
					status : status.LOAD
				}
				
				returnedState = interactionManager.pollStart(spec);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{startRegister} ============================ " + state.getStatus());
	}
	
	Controller.onTimerElapsed = function () {
		console.log("[Controller_Lib]{onTimerElapsed} Loop to observe state changes ");
		var spec = {};
		var context;
		var returnedState;
		switch (state.getCurrentState()) 
		{
			case InteractionState.NEW_CONTEXT_REQUEST_SHEDULED : 
				console.log("[Controller_Lib]{onTimerElapsed} Create New Context Request");
				requestNo += 1;
				spec = {
					method : operationOrchestrate, // config.js
					source : componentName, // MC_config.js
					token : defaultToken,  // config.js
					requestId : createRequestId(), // config.js
					target : serviceController, // config.js
					metadata : MC_metadata, // MC_config.js
					type : messageType.NEW_CONTEXT,
					confidential : MC_confidential, // MC_config.js
					context : defaultContext, // config.js
					status : status.LOAD
				}
				
				returnedState = stateManager.sendNewContextRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{onTimerElapsed} " + state.getStatus());
				break;
			
			case InteractionState.PREPARE_REQUEST_SCHEDULED:
				console.log("[Controller_Lib]{onTimerElapsed} Create Prepare Request");
				requestNo += 1;
				spec = {
					method : operationOrchestrate, // config.js
					source : componentName, // MC_config.js
					token : defaultToken, // config.js
					requestId : createRequestId(), // config.js
					target : serviceController, // config.js
					metadata : MC_metadata, // MC_config.js
					type : messageType.PREPARE,
					confidential : MC_confidential, // MC_config.js
					context : defaultContext, // config.js
					status : status.LOAD
				}
				
				returnedState = stateManager.sendPrepareRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{onTimerElapsed} " + state.getStatus());
				break;
			 
			case InteractionState.START_REQUEST_SCHEDULED:
				// Create Start Request	
				requestNo += 1;
				spec = {
					method : operationOrchestrate, // config.js
					source : componentName, // MC_config.js
					token : defaultToken, // config.js
					requestId :createRequestId(), // config.js
					target : serviceController, // config.js
					metadata : MC_metadata, // MC_config.js
					type : messageType.START,
					confidential : MC_confidential, // MC_config.js
					context : defaultContext, // config.js
					status : status.LOAD
				}
				
				returnedState = stateManager.sendStartRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{onTimerElapsed} " + state.getStatus());
				break;
			
			case InteractionState.HAS_CONTEXT:
				console.log("[Controller_Lib]{onTimerElapsed} Context found: " + readCookie("context"));
				timer.stop();
				initDone();
				// Activate button
				break;
			
			case InteractionState.POLL_START_SCHEDULED:  
				break;
			
			default: 
				console.log("[Controller_Lib]{onTimerElapsed} Default, state: " + state.getCurrentState());	
				break;
		}
	}
	
	Controller.onload = function (event) {
		console.log("[Controller_Lib]{onload} process event now");
		processEvent(state, event); 
	}

	Controller.processEvent = function (state, data) {
		console.log("[Controller_Lib]{processEvent} event processing based on state changes");
		var returnedState;
		switch(state.getCurrentState()) 
		{
			case InteractionState.MC_REGISTER_SENT : 
				console.log("[Controller_Lib]{processEvent} Marks as RegisterResponse received and then process it");
				state.setCurrentState(InteractionState.MC_REGISTER_RECEIVED);
				console.log("[Controller_Lib]{processEvent} " + state.getStatus());
				console.log("[Controller_Lib]{processEvent} data received \n"+ data);
				returnedState = advertiseManager.processRegister(data, getRequestId);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{processEvent}  ============================ "+ state.getStatus() );
				break;
			
			
			case InteractionState.NEW_CONTEXT_REQUEST_SENT:
				console.log("[Controller_Lib]{processEvent} Marks as NewContextResponse received and then process it");
				state.setCurrentState(InteractionState.NEW_CONTEXT_REQUEST_RECEIVED);
				console.log("[Controller_Lib]{processEvent} before processing : "+ state.getStatus() );
				console.log("[Controller_Lib]{processEvent} data received \n"+ data);
				returnedState = stateManager.processNewCtxResponse(data,getRequestId);
				state.setCurrentState(returnedState);				
				console.log("[Controller_Lib]{processEvent}  ============================  : "+ state.getStatus() );
				break;
				
			case InteractionState.PREPARE_REQUEST_SENT :
				// mark as received then process it
				console.log("[Controller_Lib]{processEvent} Marks as prepareResponse received and then process it");
				state.setCurrentState(InteractionState.PREPARE_REQUEST_RECEIVED);
				console.log("[Controller_Lib]{processEvent} before processing : "+ state.getStatus() );
				console.log("[Controller_Lib]{processEvent} data received \n"+ data);
				returnedState = stateManager.processPrepareResponse(data,getRequestId);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{processEvent} ============================  : "+ state.getStatus() );
				break;
				
			case InteractionState.START_REQUEST_SENT :
				// mark as received then process it
				state.setCurrentState(InteractionState.START_REQUEST_RECEIVED);
				console.log("[Controller_Lib]{processEvent} before processing : "+ state.getStatus() );
				console.log("[Controller_Lib]{processEvent} data received \n"+ data);
				returnedState = stateManager.processStartResponse(data,getRequestId);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{processEvent}  ============================  : "+ state.getStatus() );
			break;
			
			case InteractionState.POLL_START_SENT :
				// mark as received then process it
				state.setCurrentState(InteractionState.POLL_START_RECEIVED);
				console.log("[Controller_Lib]{processEvent} before processing : "+ state.getStatus() );
				console.log("[Controller_Lib]{processEvent} data received \n"+ data);
				returnedState = interactionManager.processPollStartResponse(data, getRequestId);
				state.setCurrentState(returnedState);
				console.log("[Controller_Lib]{processEvent}  ============================  "+ state.getStatus() );
				break;
			
			
			case 1 :
				break;
				 
			default: 
				break;
		}
		 
	}
	
	Controller.done = function () {
		console.log("[Controller_Lib][done] - Started ");
		timer.stop(); 
	}
		
	return Controller;
}