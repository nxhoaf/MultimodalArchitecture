// var dataReceived = function (data) {
// Parser.parseReceivedData(data);
// }

var Observator = function() {

	var observator = {};
	var requestNo = 0;
	var registerController = new RegisterController();
	var contextController = new ContextController();
	var commandController = new CommandController();
	var state = new ObservatorState();

	var timer = {};
	// overrided

	var self = this;

	observator.observe = function() {
		console.log("[Observator][observe] - Started ");
		// Create register Request
		requestNo += 1;
		var spec = {
			method : "MC_register",
			source : "MC_Recorder",
			token : "MC_1234",
			requestId : createRequestId(),
			target : serviceRegister,
			metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
			type : messageType.STATUS,
			confidential : "false",
			context : "Unknown",
			status : status.LOAD
		}
		var returnedState = registerController.sendRegister(spec);
		state.setCurrentState(returnedState);
		console.log("[Observator][observe] - Ended. Current state: " + state.getCurrentState());
	}

	observator.startRegister = function() {
		// Create Start Request
		requestNo += 1;
		spec = {
			method : "MC_command",
			source : "MC_Recorder",
			token : "MC_1234",
			requestId : createRequestId(),
			target : serviceController,
			metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
			type : messageType.START,
			confidential : "false",
			context : "Unknown",
			status : status.LOAD
		}

		returnedState = commandController.pollStart(spec);
		state.setCurrentState(returnedState);
		console.log("[Observator][onTimerElapsed] - " + state.getStatus());
	}

	observator.onTimerElapsed = function() {
		console.log("[Observator][onTimerElapsed] - Started ");
		var spec = {};
		var context;
		var returnedState;
		switch (state.getCurrentState()) {
			case ObservatorState.NEW_CONTEXT_REQUEST_SHEDULED :

				// Create New Context Request
				requestNo += 1;
				spec = {
					method : "MC_command",
					source : "MC_Recorder",
					token : "MC_1234",
					requestId : createRequestId(),
					target : serviceController,
					metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
					type : messageType.NEW_CONTEXT,
					confidential : "false",
					context : "Unknown",
					status : status.LOAD
				}

				returnedState = contextController.sendNewContextRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Observator][onTimerElapsed] - " + state.getStatus());
				break;

			case ObservatorState.PREPARE_REQUEST_SCHEDULED:
				// Create Prepare Request
				requestNo += 1;
				spec = {
					method : "MC_command",
					source : "MC_Recorder",
					token : "MC_1234",
					requestId : createRequestId(),
					target : serviceController,
					metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
					type : messageType.PREPARE,
					confidential : "false",
					context : "Unknown",
					status : status.LOAD
				}

				returnedState = contextController.sendPrepareRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Observator][onTimerElapsed] - " + state.getStatus());
				break;

			case ObservatorState.START_REQUEST_SCHEDULED:
				// Create Start Request
				requestNo += 1;
				spec = {
					method : "MC_command",
					source : "MC_Recorder",
					token : "MC_1234",
					requestId : createRequestId(),
					target : serviceController,
					metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
					type : messageType.START,
					confidential : "false",
					context : "Unknown",
					status : status.LOAD
				}

				returnedState = contextController.sendStartRequest(spec);
				state.setCurrentState(returnedState);
				console.log("[Observator][onTimerElapsed] - " + state.getStatus());
				break;

			case ObservatorState.HAS_CONTEXT:
				console.log("[Observator][sendRegister] - Context found: " + readCookie("context"));
				timer.stop();
				initDone();
				// Activate button
				break;

			case ObservatorState.POLL_START_SCHEDULED:
				alert("******************************");
				break;

			default:
				console.log("[Observator][onTimerElapsed] - Default, state: " + state.getCurrentState() + " *** DO NOTHING ***");

				break;
		}
		console.log("[Observator][onTimerElapsed] - Ended ");
	}

	observator.onload = function(event) {
		console.log("[Observator][onload] - Started ");
		processEvent(state, event);
		console.log("[Observator][onload] - Ended ");
	}
	// onEventReceived - equivalent function
	dataReceived = function(data) {
		console.log("[Observator][dataReceived] - Started ");
		observator.processEvent(state, data);
		console.log("[Observator][dataReceived] - Ended ");

	}

	observator.processEvent = function(state, data) {
		console.log("[Observator][processEvent] - Started ");
		var returnedState;
		switch(state.getCurrentState()) {
			case ObservatorState.MC_REGISTER_SENT :
				// ******************** Mark as received and them process it ********************
				state.setCurrentState(ObservatorState.MC_REGISTER_RECEIVED);
				console.log("[Observator][processEvent] - " + state.getStatus());
				returnedState = registerController.processRegister(data, requestNo);
				state.setCurrentState(returnedState);
				console.log("[Observator][processEvent] - " + state.getStatus());

				// ******************** Activate the timer ********************

				var now = (new Date()).getTime();
				var sleep = readCookie("begin") - now;
				var sleepTimer;
				if(sleep < 1000)
					sleep = 0;
				
				sleep = Math.floor(sleep / 1000); // time in GPAC is in second, not mili-second
				
				var lifeTime = readCookie("end") - now;			
				var interval = readCookie("interval");
				alert("$$$$$$$$$$$$$$$$$$$$$$$$$$" + interval);
				interval = 5000;
				var tick = Math.floor(lifeTime / interval);
				lifeTime = Math.floor(lifeTime / 1000);
				
				timer = createTimer('myTimer');
				timer.set(lifeTime, tick);
				// Redifined on_end
				timer.on_fraction = function() {
					observator.onTimerElapsed();
				}
				
				console.log("[Timer][start] - Sleep: "+ sleep + " (ms) before starting");
				if(sleep > 0) {
					sleepTimer = createTimer('sleepTimer');
					sleepTimer.set(sleep);
					sleepTimer.on_end = function() {
						console.log("[Observator][processEvent][Timer][start] - Timer launched...");
						console.log("[Observator][processEvent][Timer][start] - LifeTime: " + lifeTime + " (s)");			
						console.log("[Observator][processEvent][Timer][start] - Inverval: " + interval + " (ms)");
						console.log("[Observator][processEvent][Timer][start] - Counter: " + tick + " (times)");	
						timer.start();
					}
					sleepTimer.start();
				} else {
					console.log("[Observator][processEvent][Timer][start] - Timer launched...");
					console.log("[Observator][processEvent][Timer][start] - LifeTime: " + lifeTime + " (s)");			
					console.log("[Observator][processEvent][Timer][start] - Inverval: " + interval + " (s)");
					console.log("[Observator][processEvent][Timer][start] - Counter: " + tick + " (times)");	
					timer.start();
				}

				

				break;

			case ObservatorState.NEW_CONTEXT_REQUEST_SENT:
				// mark as received then process it
				state.setCurrentState(ObservatorState.NEW_CONTEXT_REQUEST_RECEIVED);
				console.log("[Observator][processEvent] - " + state.getStatus());
				//alert("******************" + data);
				returnedState = contextController.processNewCtxResponse(data, requestNo);
				state.setCurrentState(returnedState);
				console.log("[Observator][processEvent] - " + state.getStatus());
				break;

			case ObservatorState.PREPARE_REQUEST_SENT :
				// mark as received then process it
				state.setCurrentState(ObservatorState.PREPARE_REQUEST_RECEIVED);
				console.log("[Observator][processEvent] - " + state.getStatus());

				returnedState = contextController.processPrepareResponse(data, requestNo);
				state.setCurrentState(returnedState);
				console.log("[Observator][processEvent] - " + state.getStatus());
				break;

			case ObservatorState.START_REQUEST_SENT :
				// mark as received then process it
				state.setCurrentState(ObservatorState.START_REQUEST_RECEIVED);
				console.log("[Observator][processEvent] - " + state.getStatus());

				returnedState = contextController.processStartResponse(data, requestNo);
				state.setCurrentState(returnedState);
				console.log("[Observator][processEvent] - " + state.getStatus());
				break;

			case ObservatorState.POLL_START_SENT :
				// mark as received then process it
				state.setCurrentState(ObservatorState.POLL_START_RECEIVED);
				console.log("[Observator][processEvent] - " + state.getStatus());

				returnedState = commandController.processPollStartResponse(data, requestNo);
				state.setCurrentState(returnedState);
				console.log("[Observator][processEvent] - " + state.getStatus());
				break;

			case 1 :
				break;

			default:
				break;
		}

		console.log("[Observator][processEvent] - Ended ");
	}

	observator.done = function() {
		console.log("[Observator][done] - Started ");
		timer.stop();
		console.log("[Observator][done] - Ended ");
	}

	return observator;
}