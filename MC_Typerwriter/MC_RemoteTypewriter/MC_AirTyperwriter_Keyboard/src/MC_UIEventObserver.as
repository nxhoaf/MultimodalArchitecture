/*===============================================================================================*/
/*=========================== VARIABLES DECLARATION =============================================*/
/*===============================================================================================*/

import Config.Configuration;

import Controller_Lib.Controller;

import MMI_Lib.MessageType;
import MMI_Lib.Spec;
import MMI_Lib.Status;

import Observer_Lib.InteractionEvent;
import Observer_Lib.InteractionManager;
import Observer_Lib.InteractionState;

import XHR_Lib.MMDispatcher;

import flash.events.KeyboardEvent;
import flash.net.SharedObject;

private var controller : Controller = new Controller();
public var interactionManager : InteractionManager = new InteractionManager();

/*===============================================================================================*/
/*========================== COMPONENT INITIALIZATION ===========================================*/
/*===============================================================================================*/
public function initialization () : void {
	trace("[MC_AirTyperwriter_1][initialization] - Started");
	this.label.text = "Initializing, waiting..."
	this.txtArea.enabled = false;
	controller.addEventListener(InteractionEvent.HAS_CONTEXT, onHavingContext);
	controller.load();
	trace("[MC_AirTyperwriter_1][initialization] - Ended");
}


/*===============================================================================================*/
/*========================== ORCHESTRATION UPDATES HANDLING =====================================*/
/*===============================================================================================*/
public function onHavingContext(event : InteractionEvent) : void {
	trace("[MC_AirTyperwriter_1][onHavingContext] - Started");
	this.label.text = "Registered, waiting for start...";
	var state : InteractionState = event.getObservationState();
	state.setCurrentState(InteractionState.POLL_START_SCHEDULED);
	
	var spec : Spec; 
	var returnedState : String; 
	var sharedObj : SharedObject = SharedObject.getLocal(MC_config.componentName);
	
	var context : String = sharedObj.data.context;				
	var requestNo : int;
	
	if(sharedObj.data.requestNo == null) {
		requestNo = 1;
		sharedObj.data.requestNo = requestNo;
	} else {
		requestNo = int(sharedObj.data.requestNo);		
	}
	
	// Poll Start
	spec = new Spec();
	spec.setMethod(Configuration.operationRegister); // Configuration.as
	spec.setSource(MC_config.componentName); // MC_config.as
	spec.setToken(Configuration.defaultToken); // config.as
	
	spec.setRequestId(MC_config.getRequestId(requestNo)); // config.as
	trace("[Observator][observe] - RequestId: " + MC_config.getRequestId(requestNo));
	sharedObj.data.requestNo = requestNo + 1;
	sharedObj.flush(); // Explicitly write data to a disk
	
	//spec.setTarget(serverRoot); // @TODO change to real values
	spec.setTarget(Configuration.serviceRegister);  // config.as
	spec.setMetadata(MC_config.mc_metadata);
	spec.setType(MessageType.START);
	spec.setConfidential(MC_config.mc_confidential);  
	spec.setContext(Configuration.defaultContext);
	spec.setStatus(Status.LOAD);
	
	interactionManager.addEventListener(InteractionEvent.START_SCHEDULED, doStart);
	interactionManager.addEventListener(InteractionEvent.PAUSE_SCHEDULED, doPause);
	interactionManager.addEventListener(InteractionEvent.RESUME_SCHEDULED, doResume);
	interactionManager.addEventListener(InteractionEvent.CANCEL_SCHEDULED, doCancel);
	
	interactionManager.pollStart(spec);
	
	trace("[MC_AirTyperwriter_1][onHavingContext] - Ended");
}

public function doStart(e: InteractionEvent) : void {
	trace("[MC_AirTyperwriter_1][onStartScheduled] - Started");
	this.label.text = "Application started, please type here:";
	this.txtArea.enabled = true;
	
	// Response Start
	var spec : Spec; 
	var returnedState : String; 
	var sharedObj : SharedObject = SharedObject.getLocal(MC_config.componentName);
	
	var context : String = sharedObj.data.context;				
	var requestNo : int;
	
	if(sharedObj.data.requestNo == null) {
		requestNo = 1;
		sharedObj.data.requestNo = requestNo;
	} else {
		requestNo = int(sharedObj.data.requestNo);		
	}
	spec = new Spec();
	spec.setMethod(Configuration.operationRegister); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken);
	
	spec.setRequestId(MC_config.getRequestId(requestNo)); 
	trace("[Observator][observe] - RequestId: " + MC_config.getRequestId(requestNo));
	sharedObj.data.requestNo = requestNo + 1;
	sharedObj.flush(); // Explicitly write data to a disk
	
	spec.setTarget(Configuration.serviceRegister);  // config.as
	spec.setMetadata(MC_config.mc_metadata);
	spec.setType(MessageType.START);
	spec.setConfidential(MC_config.mc_confidential);  
	spec.setContext(Configuration.defaultContext);
	spec.setStatus(Status.SUCCESS);
	
	var mmiDispatcher : MMDispatcher = new MMDispatcher();
	mmiDispatcher.sendAsynchronous(spec,"GET","MMI");
	trace("[MC_AirTyperwriter_1][onStartScheduled] - Ended");
}

public function doPause(e: InteractionEvent) : void {
	trace("[MC_AirTyperwriter_1][onPauseScheduled] - Started");
	this.label.text = "Application paused, text will be sent to server";
	this.txtArea.enabled = false;
	var returnedData : String = this.txtArea.text;
	
	// Response pause
	var spec : Spec; 
	var returnedState : String; 
	var sharedObj : SharedObject = SharedObject.getLocal(MC_config.componentName);
	
	var context : String = sharedObj.data.context;				
	var requestNo : int;
	
	if(sharedObj.data.requestNo == null) {
		requestNo = 1;
		sharedObj.data.requestNo = requestNo;
	} else {
		requestNo = int(sharedObj.data.requestNo);		
	}
	spec = new Spec();
	spec.setMethod(Configuration.operationRegister); // Configuration.as
	spec.setSource(MC_config.componentName); // MC_config.as
	spec.setToken(Configuration.defaultToken); // config.as
	
	spec.setRequestId(MC_config.getRequestId(requestNo)); // config.as
	trace("[Observator][observe] - RequestId: " + MC_config.getRequestId(requestNo));
	sharedObj.data.requestNo = requestNo + 1;
	sharedObj.flush(); // Explicitly write data to a disk
	
	spec.setTarget(Configuration.serviceRegister);  // config.as
	spec.setMetadata(MC_config.mc_metadata);
	spec.setType(MessageType.PAUSE);
	spec.setConfidential(MC_config.mc_confidential);  
	spec.setContext(Configuration.defaultContext);
	spec.setStatus(Status.SUCCESS);
	spec.setData(returnedData);
	var mmiDispatcher : MMDispatcher = new MMDispatcher(); 
	mmiDispatcher.sendAsynchronous(spec,"GET","MMI");
	
	trace("[MC_AirTyperwriter_1][onPauseScheduled] - Ended");
}

public function doResume(e: InteractionEvent) : void {
	trace("[MC_AirTyperwriter_1][onResumeScheduled] - Started");
	this.label.text = "Application resumed";
	this.txtArea.enabled = true;
	
	// Response Resume
	var spec : Spec; 
	var returnedState : String; 
	var sharedObj : SharedObject = SharedObject.getLocal(MC_config.componentName);
	
	var context : String = sharedObj.data.context;				
	var requestNo : int;
	
	if(sharedObj.data.requestNo == null) {
		requestNo = 1;
		sharedObj.data.requestNo = requestNo;
	} else {
		requestNo = int(sharedObj.data.requestNo);		
	}
	spec = new Spec();
	spec.setMethod(Configuration.operationRegister); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken);
	
	spec.setRequestId(MC_config.getRequestId(requestNo)); 
	trace("[Observator][observe] - RequestId: " + MC_config.getRequestId(requestNo));
	sharedObj.data.requestNo = requestNo + 1;
	sharedObj.flush(); // Explicitly write data to a disk
	
	spec.setTarget(Configuration.serviceRegister);  // config.as
	spec.setMetadata(MC_config.mc_metadata);
	spec.setType(MessageType.RESUME);
	spec.setConfidential(MC_config.mc_confidential);  
	spec.setContext(Configuration.defaultContext);
	spec.setStatus(Status.SUCCESS);
	
	var mmiDispatcher : MMDispatcher = new MMDispatcher();
	mmiDispatcher.sendAsynchronous(spec,"GET","MMI");
	trace("[MC_AirTyperwriter_1][onResumeScheduled] - Ended");
}

public function doCancel(e: InteractionEvent) : void {
	trace("[MC_AirTyperwriter_1][onCancelScheduled] - Started");
	this.label.text = "Application will be closed...";
	this.txtArea.enabled = true;
	
	// Response Cancel
	var spec : Spec; 
	var returnedState : String; 
	var sharedObj : SharedObject = SharedObject.getLocal(MC_config.componentName);
	
	var context : String = sharedObj.data.context;				
	var requestNo : int;
	
	if(sharedObj.data.requestNo == null) {
		requestNo = 1;
		sharedObj.data.requestNo = requestNo;
	} else {
		requestNo = int(sharedObj.data.requestNo);		
	}
	spec = new Spec();
	spec.setMethod(Configuration.operationRegister); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken);
	
	spec.setRequestId(MC_config.getRequestId(requestNo)); 
	trace("[Observator][observe] - RequestId: " + MC_config.getRequestId(requestNo));
	sharedObj.data.requestNo = requestNo + 1;
	sharedObj.flush(); // Explicitly write data to a disk
	
	spec.setTarget(Configuration.serviceRegister);  // config.as
	spec.setMetadata(MC_config.mc_metadata);
	spec.setType(MessageType.CANCEL);
	spec.setConfidential(MC_config.mc_confidential);  
	spec.setContext(Configuration.defaultContext);
	spec.setStatus(Status.SUCCESS);
	
	var mmiDispatcher : MMDispatcher = new MMDispatcher();
	mmiDispatcher.sendAsynchronous(spec,"GET","MMI");
	
	this.exit();
	trace("[MC_AirTyperwriter_1][onCancelScheduled] - Ended");
}

/*===============================================================================================*/
/*========================== USER EVENTS HANDLING ===============================================*/
/*===============================================================================================*/
public function onKeyDown (event: KeyboardEvent) : void {
	trace('CharCode: ' + event.charCode + ' Cmd: ' + event.commandKey + ' Ctrl: ' + event.ctrlKey + ' KeyCode: ' + event.keyCode);
}
