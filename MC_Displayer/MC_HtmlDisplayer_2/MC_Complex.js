console.log("MC_UIEventObserver.js loaded");
console.log("=====================================================");

/*==========================================================================================================================*/
/*================================ COMPONENT INITIALIZATION ================================================================*/
/*==========================================================================================================================*/
controller = new Controller();
var isRegistered = false;
var isStarted = false;
var timer = {}; 
var ccFactory = Object.create(CC_Factory);
var dcFactory = Object.create(DC_Factory);
var mcFactory =

// Handles the component register and context recovery
init = function() {
	console.log("[MC_UIEventObserver]{init} disable buttons");
	log("Initialization, please wait...");
	document.getElementById("txt").innerHTML = "Initialization...";
	console.log("[MC_UIEventObserver]{init} creates observer for orchestration events");
	controller.load(); 
}

// Will be called after initialization complete to activate the UI
initDone = function() {
	console.log("[MC_UIEventObserver]{initDone} change state to registered "); 
	log("Initialization done, waiting for start...");
	document.getElementById("txt").innerHTML = "Waiting for start...";
}
/*==========================================================================================================================*/
/*================================ ORCHESTRATION UPDATES HANDLING ==========================================================*/
/*==========================================================================================================================*/
// override base function in comet.js (couleur rouge) 
comet.onDataReceived = function(data) {
	var validationResult; 
	console.log("[MC_UIEventObserver]{onDataReceived} validates registering info ");
	
	// if(!isRegistered) {
		// console.log("[MC_UIEventObserver]{onDataReceived} " + componentName + " is not registered."); 
		// return;
	// }

	// Parse data
	data = decodeURIComponent(data);
	// decode received data
	
	var args = Parser.parseUrlArgs(data)
	// Just a request, so we use its id for verifying
	// validationResult = Validator.validate(args, args.id); 
	// if (validationResult.toUpperCase() != "OK")
			// throw new Error(validationResult);

	/////////////////////////////////////////////////////////////////////////
	// If already registered and started

	switch(parseInt(args.type)) {
		case messageType.STATUS:
			doStatus(args);
			break;
		
		case messageType.PREPARE:
		
			doPrepare(args);
			break;
		
		case messageType.START:
			doStart(args);
			break;

		case messageType.PAUSE:
			doPause(args);
			break;

		case messageType.CANCEL:
			doCancel(args);
			break;

		case messageType.RESUME:
			doResume(args);
			break;

		default:
			break;
	} 
}

doPrepare = function (args) {
	console.log("[MC_UIEventObserver]{doPrepare} started");
	log("Prepare Request received, now preparing data...");
	// In one hand, let the GUI does its job
	var msg = args.data;
	document.getElementById("txt").innerHTML = msg;
	
	// In other hand,  send the PrepareResponse to server
	spec = {
		method : "MC_command",
		source : componentName, // In config.js
		token : readCookie("token"),
		requestId : createRequestId(),
		target : serviceController,
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.PREPARE,
		confidential : "false",
		context : "Unknown",
		status : status.SUCCESS
	}
	// Create message and send it
	var mmiDispatcher = Object.create(MMDispatcher);
	var myFactory = Object.create(factory);
	var msg;
	try {
		msg = myFactory.createResponse(spec);
	} catch (err) {
		alert("Exception: " + err);
	}

	mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	console.log("[MC_UIEventObserver]{doPrepare} ended ");
}

doStart = function(args) {
	console.log("[htmlDisplayer][doStart] - Started ");
	log("Start Request received..");
	// In one hand, let the GUI does its job
	var msg = args.data;
	document.getElementById("txt").innerHTML += " --> " + msg;
	
	
	// In other hand,  send the PrepareResponse to server
	spec = {
		method : "MC_command",
		source : componentName, // In config.js
		token : readCookie("token"),
		requestId : createRequestId(),
		target : serviceController,
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.START,
		confidential : "false",
		context : "Unknown",
		status : status.SUCCESS
	}
	// Create message and send it
	var mmiDispatcher = Object.create(MMDispatcher);
	var myFactory = Object.create(factory);
	var msg;
	try {
		msg = myFactory.createResponse(spec);
	} catch (err) {
		alert("Exception: " + err);
	}

	mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	console.log("[htmlDisplayer][doStart] - Ended ");
}

doPause = function(args) {
	console.log("[htmlDisplayer][doPause] - Started ");
	log("PauseRequest received..");
	// In one hand, let the GUI does its job
	var msg = args.data;
	document.getElementById("txt").innerHTML += " --> " + msg;
	
	
	// In other hand,  send the PrepareResponse to server
	spec = {
		method : "MC_command",
		source : componentName, // In config.js
		token : readCookie("token"),
		requestId : createRequestId(),
		target : serviceController,
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.PAUSE,
		confidential : "false",
		context : "Unknown",
		status : status.SUCCESS, 
		immediate : true
	}
	// Create message and send it
	var mmiDispatcher = Object.create(MMDispatcher);
	var myFactory = Object.create(factory);
	var msg;
	try {
		msg = myFactory.createResponse(spec);
	} catch (err) {
		console.log("[htmlDisplayer][doPause] - Exception " + err);
	}

	mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	console.log("[htmlDisplayer][doPause] - Ended ");
}

doResume = function(args) {
	console.log("[htmlDisplayer][doResume] - Started ");
	log("ResumeRequest received..");
	// In one hand, let the GUI does its job
	var msg = args.data;
	document.getElementById("txt").innerHTML += " --> " + msg;
	
	
	// In other hand,  send the PrepareResponse to server
	spec = {
		method : "MC_command",
		source : componentName, // In config.js
		token : readCookie("token"),
		requestId : createRequestId(),
		target : serviceController,
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.RESUME,
		confidential : "false",
		context : "Unknown",
		status : status.SUCCESS, 
		immediate : true
	}
	// Create message and send it
	var mmiDispatcher = Object.create(MMDispatcher);
	var myFactory = Object.create(factory);
	var msg;
	try {
		msg = myFactory.createResponse(spec);
	} catch (err) {
		console.log("[htmlDisplayer][doPause] - Exception " + err);
	}

	mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	console.log("[htmlDisplayer][doResume] - Ended ");
}

doCancel = function(args) {
	console.log("[htmlDisplayer][doCancel] - Started ");
	log("CancelRequest received..");
	// In one hand, let the GUI does its job
	var msg = args.data;
	document.getElementById("txt").innerHTML += " --> " + msg;
	
	
	// In other hand,  send the PrepareResponse to server
	spec = {
		method : "MC_command",
		source : componentName, // In config.js
		token : readCookie("token"),
		requestId : createRequestId(),
		target : serviceController,
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.RESUME,
		confidential : "false",
		context : "Unknown",
		status : status.SUCCESS, 
		immediate : true
	}
	// Create message and send it
	var mmiDispatcher = Object.create(MMDispatcher);
	var myFactory = Object.create(factory);
	var msg;
	try {
		msg = myFactory.createResponse(spec);
	} catch (err) {
		console.log("[htmlDisplayer][doPause] - Exception " + err);
	}

	mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	console.log("[htmlDisplayer][doCancel] - Ended ");
}

doExit = function() {
	log("ExitRequest received..");
}

doStatus = function (args) {
	var automaticUpdate = args.automaticUpdate;
	// If the RequestAutomaticUpdate field is false, the recipient should 
	// send one and only one StatusResponse message in response to this request
	if (!automaticUpdate) {
		var spec = {
				method : operationRegister,  // config.js
				source : componentName, // MC_config.js
				token : args.token,
				requestId : args.id,
				target : serviceController,  // config.js
				metadata : MC_metadata, // MC_config.js
				type : messageType.STATUS,
				confidential : MC_confidential,// MC_config.js
				context : defaultContext, // config.js
				status : status.SUCCESS
			}
			
			console.log("[MC_UIEventObserver]{doStatus} spec created! ");
			// Create message and send it
			var mmiDispatcher = Object.create(MMDispatcher);
			var myFactory = Object.create(factory);
			var msg;
			try {
				msg = myFactory.createResponse(spec);
			} catch (err) {
				alert("Exception: " + err);
			}
			
			mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	} else {
		// If the RequestAutomaticUpdate field is true, the recipient should 
		// send periodic StatusResponse message in response to this request
		// without waiting for an additional StatusRequest messages
		var begin = readCookie("begin");
		var end = readCookie("end");
		var expiredDay = (end - begin) / (60*60*24*1000);
		var interval = readCookie("interval");
		sendPeriodicStatus(interval, args);	
	} 
}

sendPeriodicStatus = function (interval, args) {
	var t = setInterval(function () {
		var spec = {
				method : operationRegister,  // config.js
				source : componentName, // MC_config.js
				token : args.token,
				requestId : args.id,
				target : serviceController,
				metadata : MC_metadata, // MC_config.js
				type : messageType.STATUS,
				confidential : MC_confidential,// MC_config.js
				context : defaultContext, // config.js
				status : status.SUCCESS
		}
			
		console.log("[MC_UIEventObserver]{sendPeriodicStatus} spec created! ");
		// Create message and send it
		var mmiDispatcher = Object.create(MMDispatcher);
		var myFactory = Object.create(factory);
		var msg;
		try {
			msg = myFactory.createResponse(spec);
		} catch (err) {
			alert("Exception: " + err);
		}
		
		mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
	}, interval)
}

log = function(msg) {
	document.getElementById("log").innerHTML = msg;
}
/*==========================================================================================================================*/
/*================================ USER EVENTS HANDLING ===================================================================*/
/*==========================================================================================================================*/

// This component don't have user event handling