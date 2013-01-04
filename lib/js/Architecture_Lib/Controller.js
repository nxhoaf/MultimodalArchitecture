console.log("Controller.js loaded");

/**
 * Controller object, it will handle the initialization process (the process for
 * 	 an app to register, to obtain context from server)
 */
var Controller = function(name) {
	var controller = {};

	// -------------------- Private fields declaration  ------------------------
	var advertiseManager;
	var componentName;
	var dataComponent;
	var interactionManager;
	var canReceiveComet;
	// See if we can receive comet or not.
	var isNewCtxPrepared;
	// Mark if new ctx is prepared or not.
	var mmiDispatcher;
	var requestNo;
	var self;
	var state;
	var stateManager;
	var timer;
	var isPullMode = false;

	// -------------------- Initialization -------------------------------------
	advertiseManager = CCFactory.createAdvertiseManager(name);
	componentName = name;
	dataComponent = DCFactory.createHtmlDC();
	interactionManager = CCFactory.createInteractionManager(name, controller);
	isNewCtxPrepared = false;
	canReceiveComet = false;
	mmiDispatcher = Object.create(MMDispatcher);
	requestNo = 0
	self = this;
	// overrided
	state = new InteractionState();
	stateManager = CCFactory.createStateManager(name);
	timer = new Timer(0, 0, 0);

	controller.getInteractionManager = function() {
		return interactionManager;
	}
	
	//**************************************************************************
 	// Register functions 
	//**************************************************************************
	
	/**
	 * Load function, it will be called when the application want to register
	 * itself with the server. This function should be call as soon as we start
	 * the application.
	 */
	controller.load = function() {
		console.log("[Controller]{load} - Started");

		// -------------------- 1. Variables declaration  ----------------------
		var currentState = InteractionState.UNKNOWN;
		var loadedSleep;

		// --------------------2. Load informations in cache  ------------------
		currentState = stateManager.load();
		state.setCurrentState(currentState);
		console.log("[Controller]{load} - " + state.getStatus());

		// --------------------3. Process the system  --------------------------
		// Based on the returned status, we will process the system: sleep,
		// dead, alive...
		if (currentState == InteractionState.SLEEP) {
			loadedSleep = stateManager.getSleepTime();
			setTimeout(function() {
				controller.sendRegister(InteractionState.SLEEP);
			}, loadedSleep);
		} else {
			controller.sendRegister(currentState);
		}

		console.log("[Controller]{load} - Ended");
	}
	
	/**
	 * Send register request to the server.
	 */
	controller.sendRegister = function(currentState) {
		console.log("[Controller]{sendRegister} - Started");

		// -------------------- 1. Variables declaration  ----------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;

		// -------------------- 2. Create Register Request----------------------
		// RequestId
		if (hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);

		// Data
		stateToSend = currentState;
		typeToSend = messageType.STATUS;
		urlToSend = "toto";
		data = "{'state':'" + stateToSend + "'," + 
					"'metadata': '{'type':'" + typeToSend + 
					"','url':'" + urlToSend + "'}'}";

		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : data,
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : "r" + requestNo,
			source : componentName,
			status : status.LOAD,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.STATUS
			
		}

		// ----------------- 3. Send register request to the server ------------
		// 3.1 Send the message
		try {
			msg = myFactory.createRequest(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// 3.2 Mark as sent
		state.setCurrentState(InteractionState.MC_REGISTER_SENT);
		console.log("[Controller]{sendRegister} - " + state.getStatus());

		console.log("[Controller]{sendRegister} - Ended");
	}
	
	controller.inform = function() {
		console.log("[Controller]{inform} - Started");

		// -------------------- 1. Variables declaration  ----------------------
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var spec;

		// -------------------- 2. Create Inform Request------------------------
		// 2.1 Create inform request
		if (hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);

		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			method : operationRegister,
			requestAutomaticUpdate : true,
			requestId : "r" + requestNo,
			source : componentName,
			status : status.LOAD,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.STATUS,
		}

		// -------------------- 3. Send Inform request -------------------------
		// 3.1 Send
		try {
			msg = myFactory.createRequest(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// 3.2 Mark the change
		state.setCurrentState(InteractionState.INFORM_SENT);
		console.log("[Controller]{inform} - " + state.getStatus());

		console.log("[Controller]{inform} - Ended");
	}
	
	controller.sendNewCtxRequest = function() {
		console.log("[Controller]{sendNewCtxRequest} - Started");

		// -------------------- 1. Variables declaration  ----------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};

		// -------------------- 2. Create New Context Request-------------------
		// RequestId
		if (hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);

		spec = {
			confidential : MC_confidential,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			method : operationOrchestrate,
			requestId : "r" + requestNo,
			source : dataComponent.readCookie("registerId"),
			target : serviceController,
			token : defaultToken,
			type : messageType.NEW_CONTEXT
		}

		// ----------------- 3. Send NewCtxRequest to the server ---------------
		// 3.1 Send
		try {
			msg = myFactory.createRequest(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// 3.2 Mark as sent and return
		state.setCurrentState(InteractionState.NEW_CONTEXT_REQUEST_SENT);
		console.log("[Controller]{sendNewCtxRequest} " + state.getStatus());

		console.log("[Controller]{sendNewCtxRequest} - Ended");
	}
	//**************************************************************************
 	// Comet functions 
	//**************************************************************************
	/**
	 * Call back function, it will be called whenever an event from sever is
	 * received.
	 */
	comet.onDataReceived = function(data) {
		//canReceiveComet = true;
		// testing purpose

		console.log("[Controller]{comet.onDataReceived} - Started");
		if (!canReceiveComet) {
			console.log("[Controller]{comet.onDataReceived} - " + 
								" Cannot receive comet request now");
			return;
		}

		console.log("[Controller]{processRegisterResponse} - " + 
							"Started, raw data: " + data.toString());

		// -------------------- Variables declaration  -------------------------
		var end;
		var interval;
		var lifeTime;
		var now;
		var returnedState;
		var requestId;
		var serviceResponse;
		var sleep;
		var type;
		var validationResult;

		// -------------------- Check received data ----------------------------

		serviceResponse = Parser.parseReceivedData(data);
		// just a request, don't need to check requestId
		requestId = serviceResponse.id;
		validationResult = Validator.validate(serviceResponse, requestId);
		if (validationResult.toUpperCase() != "OK")
			throw new Error(validationResult);

		type = Number(serviceResponse.type);

		switch (type) {
			case messageType.START:
				console.log("[Controller]{comet.onDataReceived} - COMET START");
				controller.processStartRequest(requestId);
				break;

			case messageType.PAUSE:
				console.log("[Controller]{comet.onDataReceived} - COMET STOP");
				controller.processPauseRequest(requestId);
				break;

			case messageType.RESUME:
				console.log("[Controller]{comet.onDataReceived} - COMET RESUME");
				controller.processResumeRequest(requestId);
				break;
			
			case messageType.CANCEL:
				console.log("[Controller]{comet.onDataReceived} - COMET CANCEL");
				controller.processCancelRequest(requestId);
				break;
				
			case messageType.CLEAR_CONTEXT:
				console.log("[Controller]{comet.onDataReceived} - COMET CLEAR_CONTEXT");
				controller.processClearCtxRequest(requestId);
				break;

			
			default:
			 	console.log("[Controller]{comet.onDataReceived} - " + 
								" Unknown request type...");
				break;	
		}
	}

	controller.processStartRequest = function(requestId) {
		console.log("[Controller]{processStartRequest} - Started");
		// -------------------- Variables declaration  --------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;
		
		// ----------------- Create Start Response and send it to the server --- 
		// Create start response
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.START
		}

		// Send start response to the server
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create extension Notif
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"state":"MUST_UPDATE"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.EXTENSION_NOTIFICATION
		}
		// Send it to the Interaction Manager
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		interactionManager.processStartRequest(msg);
		console.log("[Controller]{processStartRequest} - Ended");
	}

	controller.processPauseRequest = function(requestId) {
		console.log("[Controller]{processCancelRequest} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;
		
		// ----------------- Create Pause Response and send it to the server --- 
		// Create pause response
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken, 
			type : messageType.PAUSE
		}

		// Send pause response to the server
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		
		// --------- Create Extension Notif, send to interactionManager---------
		// Create extension Notif
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"state":"MUST_UPDATE"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.EXTENSION_NOTIFICATION
		}
		
		// Send it to the Interaction Manager
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		interactionManager.processPauseRequest(msg);

		console.log("[Controller]{processCancelRequest} - Ended");
	}

	controller.processResumeRequest = function(requestId) {
		console.log("[Controller]{processResumeRequest} - Started");
		
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;
		
		// ----------------- Create Resume Response and send it to the server --
		// Create resume response
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			immediate : true,
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.RESUME
		}

		// Send resume response to the server
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("[Controller]{processResumeRequest} - Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		
		// --------- Create Extension Notif, send to interactionManager---------
		// Create extension Notif
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"state":"MUST_UPDATE"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.START
		}
		
		// Send it to the Interaction Manager
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: *" + err);
		}
		interactionManager.processResumeRequest(msg);

		console.log("[Controller]{processResumeRequest} - Ended");
	}
	
	controller.processCancelRequest = function(requestId) {
		console.log("[Controller]{processCancelRequest} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;
		
		// ----------------- Create Start Response and send it to the server --- 
		// Create start response
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			immediate : true,
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.CANCEL
		}

		// Send start response to the server
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("[Controller]{processCancelRequest} - Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create extension Notif
		spec = {			
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"state":"MUST_UPDATE"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken, 
			type : messageType.START
		}
		
		// Send it to the Interaction Manager
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: *" + err);
		}

		interactionManager.processCancelRequest(msg);

		console.log("[Controller]{processCancelRequest} - Ended");
	}
	
	controller.processClearCtxRequest = function(requestId) {
		console.log("[Controller]{processClearCtxRequest} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		var stateToSend;
		var typeToSend;
		var urlToSend;
		
		// --------- Create Clear Context Response and send it to the server --- 
		// Create Clear Context response
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken,
			type : messageType.CLEAR_CONTEXT
		}

		// Send Clear Context response to the server
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		// ------ Create Extension Notif, send to interactionManager---------
		// Create extension Notif
		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : '{"state":"MUST_UPDATE"}',
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : requestId,
			source : componentName,
			status : status.SUCCESS,
			target : serviceRegister,
			token : defaultToken, 
			type : messageType.EXTENSION_NOTIFICATION
		}
		// Send it to the Interaction Manager
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		interactionManager.processClearCtxRequest(msg);
		console.log("[Controller]{processClearCtxRequest} - Ended");
	}
	
	/**
	 * This function is actually defined in XHR_Lib/MMDispatcher.js. It will
	 *  be invoked whenever we receive response from server
	 * @param {Object} data: data, which contain response from server side
	 */
	dataReceived = function(data) {
		console.log("[Controller]{dataReceived} "+
							" data received, now process Event");
		console.log("[Controller]{dataReceived} data received \n" + data);
		controller.processEvent(state, data);
	}
	
	

	//**************************************************************************
 	// Command functions 
	//**************************************************************************
	/**
	 * Send start command to to server
	 */
	controller.sendStart = function(msg) {
		console.log("[Controller]{sendStart} - Started");
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
		console.log("[Controller]{sendStart} - Ended");
	}
	
	/**
	 * Send pause command to to server
	 */
	controller.sendPause = function(msg) {
		console.log("[Controller]{sendPause} - Started");
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
		console.log("[Controller]{sendPause} - Ended");
	}
	
	/**
	 * Send resume command to to server
	 */
	controller.sendResume = function(msg) {
		console.log("[Controller]{sendResume} - Started");
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
		console.log("[Controller]{sendResume} - Ended");
	}

	/**
	 * Send cancel command to to server
	 */
	controller.sendCancel = function(msg) {
		console.log("[Controller]{sendCancel} - Started");
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
		console.log("[Controller]{sendCancel} - Ended");
	}
	
	/**
	 * This function is used to process the start response comes from 
	 * intaraction.
	 */
	controller.processStartResponse = function(msg) {
		console.log("[Controller]{processStartResponse} - " + 
							"Started, raw data: " + msg);
		// Place-holder.
		console.log("[Controller]{processStartResponse} - Ended");
	}

	/**
	 * This function is used to process the cancel response comes from 
	 * intaraction.
	 */
	controller.processCancelResponse = function(msg) {
		console.log("[Controller]{processCancelResponse} - " + 
							"Started, raw data: " + msg);
		// Place-holder.
		console.log("[Controller]{processCancelResponse} - Ended");
	}

	/**
	 * This function is used to process the pause response comes from 
	 * intaraction.
	 */
	controller.processPauseResponse = function(msg) {
		console.log("[Controller]{processPauseResponse} - " + 
							"Started, raw data: " + msg);
		// Place-holder.
		console.log("[Controller]{processPauseResponse} - Ended");
	}

	/**
	 * This function is used to process the resume response comes from 
	 * intaraction.
	 */
	controller.processResumeResponse = function(msg) {
		console.log("[Controller]{processResumeResponse} - " + 
							"Started, raw data: " + msg);
		// Place-holder.
		console.log("[Controller]{processResumeResponse} - Ended");
	}
	
	/**
	 * This function is used to process the resume response comes from 
	 * intaraction.
	 */
	controller.processClearCtxResponse = function(msg) {
		console.log("[Controller]{processResumeResponse} - " + 
							"Started, raw data: " + msg);
		// Place-holder.
		console.log("[Controller]{processResumeResponse} - Ended");
	}
	
	
	// *********** CORRIGÉ CHECK *********
	//**************************************************************************
 	// Data processing functions
	//**************************************************************************
	/**
	 * This function is used to process response from the server.
	 * It will handle the response, and then dispatch it to suitable functions
	 * @param {Object} state State at time of receiving server response
	 * @param {Object} data Data receiving from server
	 */
	controller.processEvent = function(state, data) {
		console.log("[Controller]{processEvent} - " + 
							"Started, state: " + state.getCurrentState());
		var returnedState;
		var currentState = state.getCurrentState();
		switch(currentState) {
			case InteractionState.MC_REGISTER_SENT :
				controller.processRegisterResponse(state, data);
				break;

			// if we're waiting for listening response
			case InteractionState.INFORM_SENT :
				controller.processInformResponse(state, data);
				break;

			case InteractionState.NEW_CONTEXT_REQUEST_SENT:
				controller.processNewCtxResponse(state, data);
				break;

			case InteractionState.PREPARE_REQUEST_SENT :
				controller.processPrepareResponse(state, data);
				break;
				
			case InteractionState.LISTEN_SENT :
				controller.processListenResponse(state, data);
				break;

			/*
			case InteractionState.POLL_START_SENT :
							// mark as received then process it
							state.setCurrentState(InteractionState.POLL_START_RECEIVED);
							console.log("[Controller]{processEvent} " + 
												"before processing : " + state.getStatus());
							console.log("[Controller]{processEvent} " + 
												"data received \n" + data);
							returnedState = 
								interactionManager.processPollStartResponse(data, getRequestId);
							state.setCurrentState(returnedState);
							console.log("[Controller]{processEvent} " + 
												" =====================  " + state.getStatus());
							break;*/
			

			default:
				break;
		}

	}

	/**
	 * This function is used to process the register response comes from server
	 */
	controller.processRegisterResponse = function(state, data) {
		console.log("[Controller]{processRegisterResponse} - " + 
							"Started, raw data: " + data);

		// -------------------- 1. Variables declaration  ----------------------
		var end;
		var interval;
		var lifeTime;
		var now;
		var returnedState;
		var requestNo;
		var serviceResponse;
		var sleep;
		var validationResult;

		// -------------------- 2. Mark as received  and process it -----------
		state.setCurrentState(InteractionState.MC_REGISTER_RECEIVED);
		console.log("[Controller]{processRegisterResponse} " + 
							state.getStatus());

		// -------------------- 3. Check received data -------------------------
		// 3.1 Check data
		requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
		serviceResponse = Parser.parseReceivedData(data);
		validationResult = Validator.validate(serviceResponse, "r" + requestNo);
		if (validationResult.toUpperCase() != "OK")
			throw new Error(validationResult);

		// 3.2 Process data
		returnedState = dataComponent.saveRegisterInfo(serviceResponse);
		state.setCurrentState(returnedState);
		console.log("[Controller][processRegisterResponse] - " + 
							state.getStatus());

		// 3.3 Go to next step
		controller.inform();
		console.log("[Controller][processRegisterResponse] - Ended");
	}

	/**
	 * This function is used to process the inform response comes from server.
	 */
	controller.processInformResponse = function(state, data) {
		console.log("[Controller]{processInformResponse} - Started");

		// -------------------- 1. Variables declaration  ----------------------
		var returnedState;
		var requestNo;

		// -------------------- 2. Process it ----------------------------------
		// 2.1 Get the most recent requestNo to check
		requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
		// 2.2 Process inform request
		returnedState = 
			dataComponent.processInformResponse(data, "r" + requestNo, 
												state.getOldState());
		state.setCurrentState(returnedState);

		console.log("[Controller][processInformResponse] - " + 
							state.getStatus());

		// 3. Update the timer data based on received data
		controller.updateTimer();
		console.log("[Controller]{processInformResponse} - Ended");
	}
	
	/**
	 * Process the new context response
	 */
	controller.processNewCtxResponse = function(state, data) {
		console.log("[Controller]{processNewCtxResponse} - " + 
							"Started, raw data: " + data);

		// -------------------- 1. Variables declaration  ----------------------
		var context;
		var returnedState;
		var requestNo;
		var serviceResponse;
		var validationResult;

		// -------------------- 2. Mark as received  and process it ------------
		state.setCurrentState(InteractionState.NEW_CONTEXT_REQUEST_RECEIVED);
		console.log("[Controller]{processNewCtxResponse} before processing : " + 
							state.getStatus());

		// 2.1 Check data
		requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
		serviceResponse = Parser.parseReceivedData(data);
		validationResult = Validator.validate(serviceResponse, "r" + requestNo);
		if (validationResult.toUpperCase() != "OK")
			throw new Error(validationResult);

		// 2.2 Process it
		returnedState = stateManager.processNewCtxResponse(serviceResponse);
		state.setCurrentState(returnedState);
		console.log("[Controller]{processNewCtxResponse}  ===============  : " + 
							state.getStatus());
	}
	
	// *********** CORRIGÉ CHECK *********
	controller.processListenResponse = function (state, data) {
		console.log("[Controller]{processListenResponse} - " + 
							"Started, raw data: " + data);
		// -------------------- Variables declaration  -------------------------
		var end;
		var interval;
		var lifeTime;
		var now;
		var returnedState;
		var requestId;
		var serviceResponse;
		var sleep;
		var type;
		var validationResult;					
		
		// -------------------- Check received data ----------------------------

		serviceResponse = Parser.parseReceivedData(data);
		// just a request, don't need to check requestId
		requestId = serviceResponse.id;
		validationResult = Validator.validate(serviceResponse, requestId);
		if (validationResult.toUpperCase() != "OK")
			throw new Error(validationResult);

		type = Number(serviceResponse.type);
		//type = messageType.START;
		switch (type) {
			case messageType.START:
				console.log("[Controller]{processListenResponse} - "+
									"PULL START");
				controller.processStartRequest(requestId);
				break;

			case messageType.PAUSE:
				console.log("[Controller]{processListenResponse} - "+
									"PULL STOP");
				controller.processPauseRequest(requestId);
				break;

			case messageType.RESUME:
				console.log("[Controller]{processListenResponse} - "+
									"PULL RESUME");
				controller.processResumeRequest(requestId);
				break;
			
			case messageType.CANCEL:
				console.log("[Controller]{processListenResponse} - "+
									"PULL CANCEL");
				controller.processCancelRequest(requestId);
				break;
				
			case messageType.CLEAR_CONTEXT:
				console.log("[Controller]{processListenResponse} - "+
									"PULL CLEAR_CONTEXT");
				controller.processClearCtxRequest(requestId);
				break;

			
			default:
			 	console.log("[Controller]{processListenResponse} - " + 
								" Type: " + type);
				break;	
		}
		
		// *********** CORRIGÉ CHECK *********
		state.setCurrentState(InteractionState.PULL_SCHEDULED);
		console.log("[Controller]{processListenResponse} - " + 
															state.getStatus());
							
		console.log("[Controller][processListenResponse] - Ended.");					
	}
	
	
	//**************************************************************************
 	// Timer-related functions
	//**************************************************************************
	/**
	 * This function used to update timer data based on timer information
	 * in cache.
	 */
	controller.updateTimer = function() {
		console.log("[Controller]{updateTimer} - Started");
		// -------------------- 1. Variables declaration  ----------------------
		var now;
		var sleep;
		var end;
		var lifeTime;
		var interval;

		// -------------------- 2. Update the timer ----------------------------
		// 2.1 Set params
		now = Date.parse(new Date());

		sleep = dataComponent.readCookie("begin") - now;
		if (sleep < 1000)
			sleep = 0;

		lifeTime = dataComponent.readCookie("end") - now;
		if (lifeTime < 0)
			lifeTime = 0;

		interval = dataComponent.readCookie("interval");
		if (interval < 0)
			interval = 0;

		// Added for testing purpose, should be deleted during production...
		sleep = 0;
		interval = 2000;

		// 2.2 Update timer
		timer.update(sleep, lifeTime, interval);
		// Redefined onTimerElapsed
		timer.onTimerElapsed = function() {
			controller.onTimerElapsed();
		}

		console.log("[Controller]{updateTimer} - Ended");
	}

	controller.stopTimer = function () {
		console.log("[Controller][stopTimer] - Started ");
		timer.stop();
		console.log("[Controller][stopTimer] - Ended ");
	}

	/**
	 * This function is called whenever an interval is elapsed. At that moment,
	 * based on state of the system. A suitable action will be taken
	 */
	controller.onTimerElapsed = function() {
		console.log("[Controller]{onTimerElapsed} " + 
							"Loop to observe state changes ");
		var spec = {};
		var context;
		var returnedState;
		switch (state.getCurrentState()) {
			case InteractionState.NEW_CONTEXT_REQUEST_SHEDULED :
				console.log("[Controller]{onTimerElapsed} - " + 
									" Create New Context Request");

				if (!isNewCtxPrepared) {
					interactionManager.beforeNewCtxRequestSent();
					isNewCtxPrepared = true;
				}

				controller.sendNewCtxRequest();
				interactionManager.onNewCtxRequestSent();
				break;

			case InteractionState.HAS_CONTEXT:
				console.log("[Controller]{onTimerElapsed} Context found: " + 
									dataComponent.readCookie("context"));
				state.setCurrentState(InteractionState.UI_UPDATE_SCHEDULED);
				interactionManager.onHavingContext();
				canReceiveComet = true;
				console.log("[Controller][processRegisterResponse] - " + 
									state.getStatus());
				break;

			case InteractionState.UI_UPDATE_SCHEDULED:
				console.log("UI update scheduled...");
				controller.sendNotification();
				interactionManager.onUIUpdateSent();
				break;
				
			case InteractionState.PULL_SCHEDULED:
				console.log("Pull mode scheduled...");
				controller.sendNotification();
				interactionManager.onUIUpdateSent();
				controller.listen();
				//interactionManager.onUIUpdateSent();
				break;
				

			default:
				console.log("[Controller]{onTimerElapsed} Default, state: " + 
									state.getCurrentState());
				break;
		}
	}


	// *********** CORRIGÉ CHECK *********
	controller.listen = function () {
		console.log("[Controller]{listen} - Started");
		// -------------------- 1. Variables declaration  ----------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};
		
		// -------------------- 3. Listen to the server ------------------------
		console.log("[Controller]{listen} - Create UI_Update Event");
		// Create listen message
		if (hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + 
						", type:" + messageType.START + "}";

		spec = {
			
			confidential : MC_confidential,
			context : defaultContext,
			data : data,
			method : operationRegister,
			requestAautomaticUpdate : false,
			requestId : "r" + requestNo,
			source : componentName,
			state : "state",
			status : status.LOAD, 
			target : serviceRegister,
			timeOut : "timeout",
			token : defaultToken,
			type : messageType.CHECK_UPDATE,
			updateType : "update type"
		}
		
		// Send listen message to the server
		try {
			msg = myFactory.createUpdateEvent(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
		
		// Mark as sent
		state.setCurrentState(InteractionState.LISTEN_SENT);
		console.log("[Controller]{listen} - " + state.getStatus());
		
		console.log("[Controller]{listen} - Ended");
	}


	/**
	 * This function is sent by the client to notify its change to server.
	 */
	controller.sendNotification = function() {
		console.log("[Controller]{sendNotification} - Started");
		// -------------------- 1. Variables declaration  ----------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData");
		var msg;
		var myFactory = Object.create(factory);
		var requestNo;
		var returnedState;
		var spec = {};

		// -------------------- 2. Create Notif Request-------------------------

		// RequestId
		if (hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + 
						", type:" + messageType.START + "}";

		spec = {
			confidential : MC_confidential,
			context : defaultContext,
			data : data,
			method : operationRegister,
			requestAutomaticUpdate : false,
			requestId : "r" + requestNo,
			source : componentName,
			status : status.LOAD,
			target : serviceController,
			token : defaultToken,
			type : messageType.STATUS
		}

		// ----------------- 3. Send notification to the server ----------------
		try {
			msg = myFactory.createNotification(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");

		console.log("[Controller]{sendNotification} - Ended");
	}
	
	
	
	
	//**************************************************************************
 	// State-based functions
	//**************************************************************************

	controller.switchToPullMode = function() {
		console.log("[Controller][switchToPullMode] - Started ");
		var currentState = state.getCurrentState();
		if (currentState == InteractionState.PULL_SCHEDULED) {
			console.log("[Controller][switchToPullMode] - The system is " + 
						"already in PULL_MODE");
		} else {
			state.setCurrentState(InteractionState.PULL_SCHEDULED);
			console.log("[Controller][switchToPullMode] - System changed " + 
						"to  PULL_MODE");
		}
		console.log("[Controller][switchToPullMode] - Ended ");

	}

	controller.switchToCometMode = function() {
		console.log("[Controller][switchToCometMode] - Started ");
		var currentState = state.getCurrentState();
		if (currentState == InteractionState.UI_UPDATE_SCHEDULED) {
			console.log("[Controller][switchToCometMode] - The system is " + 
						"already in COMET_MODE ");
		} else {
			state.setCurrentState(InteractionState.UI_UPDATE_SCHEDULED);
			console.log("[Controller][switchToCometMode] - System changed " + 
						"to  COMET_MODE");
		}

		console.log("[Controller][switchToCometMode] - Ended ");
	}

	
	/**
	 * This function is invoked when the observation process is done..
	 */
	controller.done = function() {
		console.log("[Controller][done] - Started ");
		timer.stop();
	}
	
	return controller;
}
