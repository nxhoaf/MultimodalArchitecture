console.log("InteractionManager.js loaded");

var InteractionManager = function(aName, aController) {
	var interactionManager = {};
	
	// Private fields declaration
	var componentName = aName;
	var controller = aController;
	
	
	interactionManager.changeAppearance = function (name, isDisabled) {
		document.getElementById(name).disabled = isDisabled;
	}
	
	interactionManager.beforeNewCtxRequestSent = function () {
		console.log("[InteractionManager]{beforeNewCtxRequestSent} - Started");
		
		// -------------------- 1. Variables declaration  ----------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};
		 
		// -------------------- 2. Send Prepare Request to GUI -----------------
		// 2.1 Create prepare requeset
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		
		spec = {
			method : operationOrchestrate, // config.js
			source : dataComponent.readCookie("registerId"), // MC_config.js
			token : defaultToken,  // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			type : messageType.PREPARE,
			confidential : MC_confidential, // MC_config.js
		}
			
		// 2.2 Send it to GUI
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		beforeNewCtxRequestSent(msg);
		
		console.log("[InteractionManager]{beforeNewCtxRequestSent} - Ended");
	}
	
	interactionManager.processPrepareResponse = function (msg) {
		console.log("[InteractionManager]{processPrepareResponse} - Started");
		// Place holder, don't need to implement in this component.
		console.log("[InteractionManager]{processPrepareResponse} - Ended");
	}
	
	interactionManager.onNewCtxRequestSent = function () {
		console.log("[InteractionManager]{onNewCtxRequestSent} - Started");	
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		onNewCtxRequestSent(); 
		
		console.log("[InteractionManager]{onNewCtxRequestSent} - Ended");
	}
	
	interactionManager.onHavingContext = function() {
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		onHavingContext(); 
	}
	
	interactionManager.onUIUpdateSent = function() {
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		onUIUpdateSent(); 
	}
	
	/**
	 * Process start request comes from the server  
	 */
	interactionManager.processStartRequest = function (msg) {
		console.log("[InteractionManager]{processStartRequest} - Started");
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
		
		// -------------------- Create Start Request to send to UI -------------
		// Create Start Request		
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : msg.getRequestId(), // config.js
			target : serviceRegister, // config.js
			requestAutomaticUpdate : false,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}', 
			type : messageType.START,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to the user interface
		try { 
			msg = myFactory.createRequest(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		processStartRequest(msg); 
		console.log("[InteractionManager]{processStartRequest} - Ended");
	}
	
	/**
	 * Process start response come from the UI  
 	 * @param {Object} msg
	 */
	interactionManager.processStartResponse = function (msg) {
		console.log("[InteractionManager]{processStartResponse} - Started");
		
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller---------
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ", "+
						"type:" + messageType.START + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.processStartResponse(msg);
		
		console.log("[InteractionManager]{processStartResponse} - Ended");
	} 
		
	/**
	 * Process pause request comes from the server  
	 */
	interactionManager.processPauseRequest = function (msg) {
		console.log("[InteractionManager]{processPauseRequest} - Started");
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
		
		// -------------------- Create Start Request to send to UI -------------
		// Create Start Request	
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : msg.getRequestId(), // config.js
			target : serviceRegister, // config.js
			requestAutomaticUpdate : false,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}',
			type : messageType.CANCEL,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to the user interface
		try { 
			msg = myFactory.createRequest(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		processPauseRequest(msg); 
		console.log("[InteractionManager]{processPauseRequest} - Ended");
	}
	
	/**
	 * Process pause response come from the UI  
 	 * @param {Object} msg
	 */
	interactionManager.processPauseResponse = function (msg) {
		console.log("[InteractionManager]{processPauseResponse} - Started");
		
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller---------
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + 
						", type:" + messageType.START + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.processPauseResponse(msg);
		
		console.log("[InteractionManager]{processPauseResponse} - Ended");
	} 
	
	/**
	 * Process pause request comes from the server  
	 */
	interactionManager.processResumeRequest = function (msg) {
		console.log("[InteractionManager]{processCancelRequest} - Started");
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
		
		// -------------------- Create Start Request to send to UI -------------
		// Create Start Request	
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : msg.getRequestId(), // config.js
			target : serviceRegister, // config.js
			requestAutomaticUpdate : false,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}', // MC_config.js
			type : messageType.RESUME,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to the user interface
		try { 
			msg = myFactory.createRequest(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		processResumeRequest(msg); 
		console.log("[InteractionManager]{processCancelRequest} - Ended");
	}
	
	/**
	 * Process resume response come from the UI  
 	 * @param {Object} msg
	 */
	interactionManager.processResumeResponse = function (msg) {
		console.log("[InteractionManager]{processResumeResponse} - Started");
		
		// -------------------- Variables declaration  --------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller---------
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ","+
						" type:" + messageType.START + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.processResumeResponse(msg);
		
		console.log("[InteractionManager]{processResumeResponse} - Ended");
	} 
	
	/**
	 * Process pause request comes from the server  
	 */
	interactionManager.processCancelRequest = function (msg) {
		console.log("[InteractionManager]{processCancelRequest} - Started");
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
		
		// -------------------- Create Start Request to send to UI -------------
		// Create Start Request	
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : msg.getRequestId(), // config.js
			target : serviceRegister, // config.js
			requestAutomaticUpdate : false,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}', 
			type : messageType.CANCEL,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to the user interface
		try { 
			msg = myFactory.createRequest(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		processCancelRequest(msg); 
		console.log("[InteractionManager]{processCancelRequest} - Ended");
	}
	
	/**
	 * Process cancel response come from the UI  
 	 * @param {Object} msg
	 */
	interactionManager.processCancelResponse = function (msg) {
		console.log("[InteractionManager]{processCancelResponse} - Started");
		
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller---------
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ", "+
						"type:" + messageType.START + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.processCancelResponse(msg);
		
		console.log("[InteractionManager]{processCancelResponse} - Ended");
	} 
	
	interactionManager.processClearCtxRequest = function (msg) {
		console.log("[InteractionManager]{processStartRequest} - Started");
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
		
		// ------- Create processClearCtxRequestRequest to send to UI ----------
		// Create processClearCtxRequest Request		
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : msg.getRequestId(), // config.js
			target : serviceRegister, // config.js
			requestAutomaticUpdate : false,
			data : '{"code":"' + dataComponent.readCookie("registerId") + '"}', 
			type : messageType.CLEAR_CONTEXT,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to the user interface
		try { 
			msg = myFactory.createRequest(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		
		// Used as a callback function, 
		// should be implemented by application itself in order to response 
		// to event produced by the system.
		processClearCtxRequest(msg); 
		console.log("[InteractionManager]{processStartRequest} - Ended");
	}
	
	interactionManager.processClearCtxResponse = function (msg) {
		console.log("[InteractionManager]{processClearCtxResponse} - Started");
		
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller---------
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ", "+
						"type:" + messageType.CLEAR_CONTEXT + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.SUCCESS
		}
		
		// Send it to controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.processClearCtxResponse(msg);
		
		console.log("[InteractionManager]{processClearCtxResponse} - Ended");
	} 
	
	/**
	 * Process start event comes from the server  
 	 * @param {Object} msg
	 */
	interactionManager.start = function (msg) {
		console.log("[InteractionManager]{start} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller --------	
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ","+
						" type:" + messageType.START + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.LOAD
		}
		
		
		// Send it to the controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.sendStart(msg);
		
		console.log("[InteractionManager]{start} - Ended");
	}
	
	interactionManager.pause = function (msg) {
		console.log("[InteractionManager]{pause} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller --------	
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ","+
						" type:" + messageType.PAUSE + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.LOAD
		}
		
		
		// Send it to the controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.sendPause(msg);
		
		console.log("[InteractionManager]{pause} - Ended");
	}
	
	interactionManager.resume = function (msg) {
		console.log("[InteractionManager]{resume} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// ------- Create UI Update Notification and send to controller --------	
		// Create UI Update Notification
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ","+
						" type:" + messageType.RESUME + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.LOAD
		}
		
		
		// Send it to the controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.sendResume(msg);
		
		console.log("[InteractionManager]{resume} - Ended");
	}
	
	interactionManager.cancel = function () {
		console.log("[InteractionManager]{cancel} - Started");
		// -------------------- Variables declaration  -------------------------
		var data;
		// check to know if we have data in cookie
		var hasData = dataComponent.readCookie("hasData"); 
		var msg;
		var myFactory = Object.create(factory); 
		var requestNo;
		var returnedState;
		var spec = {};

		// -------------------- Create Start Request----------------------------
		
		// RequestId
		if(hasData == null || !hasData) {
			requestNo = 1;
		} else {
			requestNo = dataComponent.readCookie("requestNo");
		}
		dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		data = "{state:" + InteractionState.HAS_INPUT + ", "+
						"type:" + messageType.CANCEL + "}";
				
		spec = {
			method : operationRegister, // config.js
			source : componentName, // MC_config.js
			token : defaultToken, // config.js
			requestId : "r" + requestNo, // config.js
			target : serviceController, // config.js
			requestAutomaticUpdate : false,
			data : data, // MC_config.js
			type : messageType.UI_UPDATE,
			confidential : MC_confidential, // MC_config.js
			context : defaultContext, // config.js
			status : status.LOAD
		}
		
		// Send it to the controller
		try { 
			msg = myFactory.createNotification(spec); 
		} catch (err) { 
			alert("Exception: " + err); 
		}
		controller.sendCancel(msg);
		
		console.log("[InteractionManager]{cancel} - Ended");
	}
	
	return interactionManager;
}
