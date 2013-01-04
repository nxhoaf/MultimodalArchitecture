console.log("MC_UIEventObserver.js loaded");
console.log("=====================================================");
 
/*===========================================================================*/
/*================================ COMPONENT INITIALIZATION =================*/
/*===========================================================================*/
var complexMc = MCFactory.createComplexMc(componentName);
var dataComponent = DCFactory.createHtmlDC();
var interactionManager = complexMc.controller.getInteractionManager();
var isRegistered = false;
var isStarted = false;
var infoList = [];
var clockSpec = {
	hourId : "hours", 
	minuteId : "minutes",
	secondId : "seconds"
}
var clock = new Clock(clockSpec);


// Handles the component register and context recovery
init = function() {
	console.log("[MC_UIEventObserver]{init} disable buttons");
	document.getElementById("label").style.visibility = "hidden";
	document.getElementById("clock").style.visibility = "hidden";
	console.log("[MC_UIEventObserver]{init} + "+
						" Creates observer for orchestration events");
	log("Now loading");
	complexMc.controller.load();
}

beforeNewCtxRequestSent = function (msg) {
	console.log("[GUI]{beforeNewCtxRequestSent} - Started");
	
	// For this component, we don't need to use info in msg param.
	log("Prepare Before new context request sent...")
	document.getElementById("label").style.visibility = "visible";
	document.getElementById("clock").style.visibility = "visible";
	// -------------------- Variables declaration  -----------------------------
	var data;
	// check to know if we have data in cookie
	var hasData = dataComponent.readCookie("hasData"); 
	var msg;
	var myFactory = Object.create(factory); 
	var requestNo;
	var returnedState;
	var spec = {};
	 
	// -------------------- Create Prepare Request------------------------------
	
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
	
	interactionManager.processPrepareResponse(msg);
	console.log("[GUI]{beforeNewCtxRequestSent} - Ended");
}

onNewCtxRequestSent = function () {
	log("New context request sent...")
}

// Will be called after initialization complete to activate the UI
onHavingContext = function() {
	console.log("[MC_UIEventObserver]{initDone} change state to registered "); 
	
	log("Context found, application ready!!!");
}

onUIUpdateSent = function () {
	log("Automatic update, sending client info to server...");
}

processStartRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processStartRequest} - Started "); 
	// -------------------- Variables declaration  -----------------------------
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
	
	// -------------------- ¨Process start request  ---------------------------- 
	log("process Start Request");
	clock.start();
	
	// -------------------- Reply to Interaction Managerwith start response ----
	// Create start response		
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
	
	// Send it to interaction Manager 
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processStartResponse(msg);
}

processPauseRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processPauseRequest} - Started "); 
	// -------------------- Variables declaration  -----------------------------
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
	

	// -------------------- ¨Process pause request  ---------------------------- 
	log("process Pause Request");
	clock.pause();
	// -------------------- Reply to Interaction Manager with pause response ---
	// Create start response
	spec = {
		method : operationRegister, // config.js
		source : componentName, // MC_config.js
		token : defaultToken, // config.js
		requestId : msg.getRequestId(), // config.js
		target : serviceRegister, // config.js
		requestAutomaticUpdate : false,
		data : '{"code":"' + dataComponent.readCookie("registerId") + '"}', 
		type : messageType.PAUSE,
		confidential : MC_confidential, // MC_config.js
		context : defaultContext, // config.js
		status : status.SUCCESS
	}
	
	// Send it to interaction Manager 
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processStartResponse(msg);
	console.log("[MC_UIEventObserver]{processPauseRequest} - Ended "); 
}

processResumeRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processResumeRequest} - Started "); 
	// -------------------- Variables declaration  -----------------------------
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
	
	
	
	// -------------------- ¨Process resume request  --------------------------- 
	log("process Resume Request");
	clock.resume();
	
	// -------------------- Reply to Interaction Manager with pause response ---
	// Create start response
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
	
	// Send it to interaction Manager 
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processStartResponse(msg);
	console.log("[MC_UIEventObserver]{processResumeRequest} - Ended "); 
}

processCancelRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processCancelRequest} - Started "); 
	// -------------------- Variables declaration  -----------------------------
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
	
	// -------------------- ¨Process cancel request  ---------------------------
	log("process Cancel Request");
	clock.cancel();
	
	// -------------------- Reply to Interaction Manager with cancel response --
	// Create cancel response
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
	
	// ----------------- Send it to the server ---------------------------------
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processCancelResponse(msg);
	console.log("[MC_UIEventObserver]{processCancelRequest} - Ended "); 
}

processClearCtxRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processClearCtxRequest} - Started "); 
	// -------------------- Variables declaration  -----------------------------
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
	
	
	
	// -------------------- ¨Process clear context request  -------------------- 
	log("Process clear context Request");
	document.getElementById("label").style.visibility = "hidden";
	document.getElementById("clock").style.visibility = "hidden";
	//------------ Reply to Interaction Manager with clear context response ----
	// Create start response
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
	
	// Send it to interaction Manager 
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processClearCtxResponse(msg);
	console.log("[MC_UIEventObserver]{processClearCtxRequest} - Ended "); 
}

log = function(msg) {
	var mostRecentMsg = "";
	var i;
	
	infoList.push(msg + "<br/>");
	
	if (infoList.length == 11)
		infoList.shift(); // max length is 10
		
	 for (i = infoList.length - 1; i >= 0; i--) {
	 	mostRecentMsg += infoList[i];
	 }
	 
	 document.getElementById("log").innerHTML  = mostRecentMsg;
}