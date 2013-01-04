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
var timer = {};


/**
 * This function is called whenever the application started.
 * It handles the component register and context recovery
 */
init = function() {
	console.log("[MC_UIEventObserver]{init} - Started");
	
	// -------------------- 1. Prepare the GUI ---------------------------------
	// It fact, we make the GUI invisible as it hasn't been loaded yet.
	document.getElementById("start").style.visibility = "hidden";
	document.getElementById("pause").style.visibility = "hidden";
	document.getElementById("resume").style.visibility = "hidden";
	document.getElementById("cancel").style.visibility = "hidden";
	log("Now loading");
	
	// -------------------- 2. Call the load function to register the app ------
	complexMc.controller.load();
	console.log("[MC_UIEventObserver]{init} Ended");
}

beforeNewCtxRequestSent = function (msg) {
	console.log("[MC_UIEventObserver]{beforeNewCtxRequestSent} - Started");
	// -------------------- 1. Variables declaration  --------------------------
	var data;
	// check to know if we have data in cookie
	var hasData = dataComponent.readCookie("hasData"); 
	var msg;
	var myFactory = Object.create(factory); 
	var requestNo;
	var returnedState;
	var spec = {};
	
	// -------------------- 2. Update GUI --------------------------------------
	log("Prepare Before new context request sent...")
	
	document.getElementById("start").style.visibility = "visible";
	document.getElementById("pause").style.visibility = "visible";
	document.getElementById("resume").style.visibility = "visible";
	document.getElementById("cancel").style.visibility = "visible";
	
	document.getElementById("start").disabled = true;
	document.getElementById("pause").disabled = true;
	document.getElementById("resume").disabled = true;
	document.getElementById("cancel").disabled = true;
	 
	// -------------------- 3. Create Prepare Request---------------------------
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
	console.log("[MC_UIEventObserver]{beforeNewCtxRequestSent} - Ended");
}

/**
 * This function is called when a new context request sent 
 */
onNewCtxRequestSent = function () {
	log("New context request sent...")
}

/**
 * Will be called after initialization complete to activate the UI 
 */
onHavingContext = function() {
	console.log("[MC_UIEventObserver]{onHavingContext} "+
						"change state to registered "); 
	
	document.getElementById("start").disabled = false;
	document.getElementById("pause").disabled = false;
	document.getElementById("resume").disabled = false;
	document.getElementById("cancel").disabled = false;
	log("Context found, application ready!onHavingContext!");
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
	console.log("[MC_UIEventObserver]{processStartRequest} - Ended "); 
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
	document.getElementById("start").disabled = true;
	document.getElementById("pause").disabled = true;
	document.getElementById("resume").disabled = true;
	document.getElementById("cancel").disabled = true;
	// -------------------- Reply to Interaction Manager with pause response ----
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
	document.getElementById("start").disabled = false;
	document.getElementById("pause").disabled = false;
	document.getElementById("resume").disabled = false;
	document.getElementById("cancel").disabled = false;
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
	
	// -------------------- ¨Process cancel request  ---------------------------- 
	log("process Cancel Request");
	document.getElementById("start").disabled = true;
	document.getElementById("pause").disabled = true;
	document.getElementById("resume").disabled = true;
	document.getElementById("cancel").disabled = true;
	
	// -------------------- Reply to Interaction Manager with cancel response ----
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
	
	// ----------------- Send it to the server ------------------------
	try { 
		msg = myFactory.createResponse(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	
	interactionManager.processCancelResponse(msg);
	console.log("[MC_UIEventObserver]{processCancelRequest} - Ended "); 
}

processClearCtxRequest = function (msg) {
	console.log("[MC_UIEventObserver]{processCancelRequest} - Started "); 
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
	
	// -------------------- ¨Process Clear context request  -------------------- 
	log("process Clear context Request");
	document.getElementById("start").style.visibility = "hidden";
	document.getElementById("pause").style.visibility = "hidden";
	document.getElementById("resume").style.visibility = "hidden";
	document.getElementById("cancel").style.visibility = "hidden";
	
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

startIsClicked = function () {
	console.log("[MC_UIEventObserver]{startIsClicked} - Started "); 
	// -------------------- Variables declaration  -----------------------------
	var context;
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
	
	// -------------------- Show start event to GUI ---------------------------- 
	log("Start Button is clicked!");
	
	// -------------------- Call Extension Notif to Interaction Manager --------
	// Create Extension notification
	if(hasData == null || !hasData) {
		requestNo = 1;
	} else {
		requestNo = dataComponent.readCookie("requestNo");
	}
	dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		
	// context
	context = dataComponent.readCookie("context");
	data = "{type:" + messageType.START + "}";
	
	spec = {
		method : operationRegister, // config.js
		source : componentName, // MC_config.js
		token : defaultToken, // config.js
		requestId : "r" + requestNo, // config.js
		target : serviceController, // config.js
		requestAutomaticUpdate : false,
		data : data, // MC_config.js
		type : messageType.EXTENSION_NOTIFICATION,
		confidential : MC_confidential, // MC_config.js
		context : context, // config.js
		status : status.LOAD
	}
	
	// Send it to Interaction Manager
	try { 
		msg = myFactory.createNotification(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	interactionManager.start(msg); 
	console.log("[MC_UIEventObserver]{startIsClicked} - Ended "); 
}

pauseIsClicked = function () {
	console.log("[MC_UIEventObserver]{pauseIsClicked} - Started "); 
	// -------------------- Variables declaration  -----------------------------
	var context;
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
	
	// -------------------- Show pause event to GUI ---------------------------- 
	log("Pause Button is clicked!");
	
	// -------------------- Call Extension Notif to Interaction Manager --------
	// Create Extension notification
	if(hasData == null || !hasData) {
		requestNo = 1;
	} else {
		requestNo = dataComponent.readCookie("requestNo");
	}
	dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		
	// context
	context = dataComponent.readCookie("context");
	data = "{type:" + messageType.PAUSE + "}";
	
	spec = {
		method : operationRegister, // config.js
		source : componentName, // MC_config.js
		token : defaultToken, // config.js
		requestId : "r" + requestNo, // config.js
		target : serviceController, // config.js
		requestAutomaticUpdate : false,
		data : data, // MC_config.js
		type : messageType.EXTENSION_NOTIFICATION,
		confidential : MC_confidential, // MC_config.js
		context : context, // config.js
		status : status.LOAD
	}
	
	// Send it to Interaction Manager
	try { 
		msg = myFactory.createNotification(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	interactionManager.pause(msg); 
	console.log("[MC_UIEventObserver]{pauseIsClicked} - Ended "); 
}

resumeIsClicked = function () {
	console.log("[MC_UIEventObserver]{resumeIsClicked} - Started "); 
	// -------------------- Variables declaration  -----------------------------
	var context;
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
	
	// -------------------- Show resume event to GUI --------------------------- 
	log("Resume Button is clicked!");
	
	// -------------------- Call Extension Notif to Interaction Manager --------
	// Create Extension notification
	if(hasData == null || !hasData) {
		requestNo = 1;
	} else {
		requestNo = dataComponent.readCookie("requestNo");
	}
	dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		
	// context
	context = dataComponent.readCookie("context");
	data = "{type:" + messageType.RESUME + "}";
	
	spec = {
		method : operationRegister, // config.js
		source : componentName, // MC_config.js
		token : defaultToken, // config.js
		requestId : "r" + requestNo, // config.js
		target : serviceController, // config.js
		requestAutomaticUpdate : false,
		data : data, // MC_config.js
		type : messageType.EXTENSION_NOTIFICATION,
		confidential : MC_confidential, // MC_config.js
		context : context, // config.js
		status : status.LOAD
	}
	
	// Send it to Interaction Manager
	try { 
		msg = myFactory.createNotification(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	interactionManager.resume(msg); 
	console.log("[MC_UIEventObserver]{resumeIsClicked} - Ended "); 
}

cancelIsClicked = function () {
	log("Cancel is clicked.");
	
	// -------------------- Variables declaration  -----------------------------
	var context;
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
	
	// -------------------- Show start event to GUI ---------------------------- 
	log("Cancel Button is clicked!");
	
	// -------------------- Call Extension Notif to Interaction Manager --------
	// Create Extension notification
	if(hasData == null || !hasData) {
		requestNo = 1;
	} else {
		requestNo = dataComponent.readCookie("requestNo");
	}
	dataComponent.createCookie("requestNo", Number(requestNo) + 1);
		
	// context
	context = dataComponent.readCookie("context");
	data = "{type:" + messageType.CANCEL + "}";
	
	spec = {
		method : operationRegister, // config.js
		source : componentName, // MC_config.js
		token : defaultToken, // config.js
		requestId : "r" + requestNo, // config.js
		target : serviceController, // config.js
		requestAutomaticUpdate : false,
		data : data, // MC_config.js
		type : messageType.EXTENSION_NOTIFICATION,
		confidential : MC_confidential, // MC_config.js
		context : context, // config.js
		status : status.LOAD
	}
	
	// Send it to Interaction Manager
	try { 
		msg = myFactory.createNotification(spec); 
	} catch (err) { 
		alert("Exception: " + err); 
	}
	interactionManager.cancel(msg); 
}

log = function(msg) {
	var mostRecentMsg = "";
	var i;
	
	infoList.push(msg + "<br/>");
	
	if (infoList.length == 11)
		infoList.shift(); // max length is 11
		
	 for (i = infoList.length - 1; i >= 0; i--) {
	 	mostRecentMsg += infoList[i];
	 }
	 
	 document.getElementById("log").innerHTML  = mostRecentMsg;
}