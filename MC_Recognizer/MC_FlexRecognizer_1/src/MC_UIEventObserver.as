import Architecture.Controller;
import Architecture.DCFactory;
import Architecture.InteractionEvent;
import Architecture.InteractionManager;
import Architecture.MCFactory;

import Config.Configuration;

import MMI_Lib.MessageType;
import MMI_Lib.Spec;
import MMI_Lib.Status;

import sound.Recognizer;




private var complexMc : Object = 
	MCFactory.createComplexMc(MC_config.componentName);
private var dataComponent : Object = 
	DCFactory.createDC(MC_config.componentName);
private var recognizer : Recognizer = new Recognizer();
public function init() : void {
	trace("[MC_UIEventObserver][init] - Started");
	label.text = "Now loading";
	
	var controller : Controller = complexMc.controller;
	controller.addEventListener(InteractionEvent.BEFORE_NEW_CTX_REQUEST_SENT, 
		beforeNewCtxRequestSent);
	controller.addEventListener(InteractionEvent.ON_NEW_CTX_REQUEST_SENT, 
		onNewCtxRequestSent);
	controller.addEventListener(InteractionEvent.ON_HAVING_CONTEXT, 
		onHavingContext);
	controller.addEventListener(InteractionEvent.ON_UI_UPDATE_SENT, 
		onUIUpdateSent);
	
	controller.addEventListener(InteractionEvent.ON_PROCESS_START_REQUEST, 
		onProcessStartRequest);
	
	controller.addEventListener(InteractionEvent.ON_PROCESS_PAUSE_REQUEST, 
		onProcessPauseRequest);
	
	controller.addEventListener(InteractionEvent.ON_PROCESS_RESUME_REQUEST, 
		onProcessResumeRequest);
	
	controller.addEventListener(InteractionEvent.ON_PROCESS_CANCEL_REQUEST, 
		onProcessCancelRequest);
	
	controller.addEventListener(InteractionEvent.ON_PROCESS_CLEAR_CTX_REQUEST, 
		onProcessClearCtxRequest);
	controller.load();
	trace("[MC_UIEventObserver][init] - Ended");
}

public function beforeNewCtxRequestSent(e : InteractionEvent) : void {
	label.text = "Before New Context Request Sent";
}

public function onNewCtxRequestSent(e : InteractionEvent) : void {
	label.text = "onNewCtxRequestSent";
}

public function onHavingContext(e : InteractionEvent) : void {
	label.text = "onHavingContext";
}

public function onUIUpdateSent(e : InteractionEvent) : void {
	label.text = "onUIUpdateSent";
}

public function onProcessStartRequest(e : InteractionEvent) : void {
	trace("[MC_UIEventObserver]{onProcessStartRequest} - Started "); 
	// -------------------- Variables declaration  ---------------------
	var interactionManager : InteractionManager;
	var data : String;
	// check to know if we have data in cookie
	var spec : Spec;
	var event : InteractionEvent;
	var requestId : String = e.getMessage().getRequestId();
	// -------------------- ¨Process start request  ---------------------------- 
	label.text = "onProcessStartRequest";
	recognizer.convertSpeechToText();
	
	// -------------------- Create Start Request to send to UI ---------
	// Create Start Requset 
	spec = new Spec();
	// Method, source, token
	spec.setMethod(Configuration.operationOrchestrate); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken); 
	
	// RequestId
	spec.setRequestId(requestId);
	
	// Target, RequestAutomaticUpdate
	spec.setTarget(Configuration.serviceController);
	spec.setRequestAutomaticUpdate(false);
	
	// Data
	data = "{\"code\":\"" + 
		dataComponent.readCookie("registerId") + "\"}";
	spec.setData(data);
	
	// Type, confidential, context, status
	spec.setType(MessageType.START);
	spec.setConfidential(MC_config.mc_confidential);
	spec.setContent(dataComponent.readCookie("context"));
	spec.setStatus(Status.SUCCESS);
	
	interactionManager = complexMc.controller.getInteractionManager();
	interactionManager.processStartResponse(spec);
	trace("[MC_UIEventObserver]{onProcessStartRequest} - Ended ");
}

public function onProcessPauseRequest(e : InteractionEvent) : void {
	trace("[MC_UIEventObserver]{onProcessPauseRequest} - Started "); 
	// -------------------- Variables declaration  ---------------------
	var interactionManager : InteractionManager;
	var controller : Controller; 
	var data : String;
	// check to know if we have data in cookie
	var spec : Spec;
	var event : InteractionEvent;
	var requestId : String = e.getMessage().getRequestId();
	// -------------------- ¨Process Pause request  ---------------------------- 
	label.text = "onProcessPauseRequest";
	
	
	// -------------------- Create Pause Request to send to UI ---------
	// Create Pause Requset 
	spec = new Spec();
	// Method, source, token
	spec.setMethod(Configuration.operationOrchestrate); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken); 
	
	// RequestId
	spec.setRequestId(requestId);
	
	// Target, RequestAutomaticUpdate
	spec.setTarget(Configuration.serviceController);
	spec.setRequestAutomaticUpdate(false);
	
	// Data
	data = "{\"code\":\"" + 
		dataComponent.readCookie("registerId") + "\"}";
	spec.setData(data);
	
	// Type, confidential, context, status
	spec.setType(MessageType.PAUSE);
	spec.setConfidential(MC_config.mc_confidential);
	spec.setContent(dataComponent.readCookie("context"));
	spec.setStatus(Status.SUCCESS);
	
	interactionManager = complexMc.controller.getInteractionManager();
	interactionManager.processPauseResponse(spec);
	trace("[MC_UIEventObserver]{onProcessPauseRequest} - Ended ");
}

public function onProcessResumeRequest(e : InteractionEvent) : void {
	trace("[MC_UIEventObserver]{onProcessResumeRequest} - Started "); 
	// -------------------- Variables declaration  ---------------------
	var interactionManager : InteractionManager;
	var controller : Controller; 
	var data : String;
	// check to know if we have data in cookie
	var spec : Spec;
	var event : InteractionEvent;
	var requestId : String = e.getMessage().getRequestId();
	// -------------------- ¨Process Resume request  ---------------------------- 
	label.text = "onProcessResumeRequest";
	
	
	// -------------------- Create Resume Request to send to UI ---------
	// Create Resume Requset 
	spec = new Spec();
	// Method, source, token
	spec.setMethod(Configuration.operationOrchestrate); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken); 
	
	// RequestId
	spec.setRequestId(requestId);
	
	// Target, RequestAutomaticUpdate
	spec.setTarget(Configuration.serviceController);
	spec.setRequestAutomaticUpdate(false);
	
	// Data
	data = "{\"code\":\"" + 
		dataComponent.readCookie("registerId") + "\"}";
	spec.setData(data);
	
	// Type, confidential, context, status
	spec.setType(MessageType.RESUME);
	spec.setConfidential(MC_config.mc_confidential);
	spec.setContent(dataComponent.readCookie("context"));
	spec.setStatus(Status.SUCCESS);
	
	interactionManager = complexMc.controller.getInteractionManager();
	interactionManager.processResumeResponse(spec);
	trace("[MC_UIEventObserver]{onProcessResumeRequest} - Ended ");
}

public function onProcessCancelRequest(e : InteractionEvent) : void {
	trace("[MC_UIEventObserver]{onProcessCancelRequest} - Started "); 
	// -------------------- Variables declaration  ---------------------
	var interactionManager : InteractionManager;
	var data : String;
	// check to know if we have data in cookie
	var spec : Spec;
	var event : InteractionEvent;
	var requestId : String = e.getMessage().getRequestId();
	// -------------------- ¨Process Cancel request  ---------------------------- 
	label.text = "onProcessCancelRequest";
	
	// -------------------- Create Cancel Request to send to UI ---------
	// Create Cancel Requset 
	spec = new Spec();
	// Method, source, token
	spec.setMethod(Configuration.operationOrchestrate); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken); 
	
	// RequestId
	spec.setRequestId(requestId);
	
	// Target, RequestAutomaticUpdate
	spec.setTarget(Configuration.serviceController);
	spec.setRequestAutomaticUpdate(false);
	
	// Data
	data = "{\"code\":\"" + 
		dataComponent.readCookie("registerId") + "\"}";
	spec.setData(data);
	
	// Type, confidential, context, status
	spec.setType(MessageType.CANCEL);
	spec.setConfidential(MC_config.mc_confidential);
	spec.setContent(dataComponent.readCookie("context"));
	spec.setStatus(Status.SUCCESS);
	
	interactionManager = complexMc.controller.getInteractionManager();
	interactionManager.processCancelResponse(spec);
	trace("[MC_UIEventObserver]{onProcessCancelRequest} - Ended ");
}

public function onProcessClearCtxRequest(e : InteractionEvent) : void {
	trace("[MC_UIEventObserver]{onProcessClearCtxRequest} - Started "); 
	// -------------------- Variables declaration  ---------------------
	var interactionManager : InteractionManager;
	var data : String;
	// check to know if we have data in cookie
	var spec : Spec;
	var event : InteractionEvent;
	var requestId : String = e.getMessage().getRequestId();
	// -------------------- ¨Process start request  ---------------------------- 
	label.text = "onProcessClearCtxRequest";
	
	
	// -------------------- Create ClearCtx Request to send to UI ---------
	// Create ClearCtx Requset 
	spec = new Spec();
	// Method, source, token
	spec.setMethod(Configuration.operationOrchestrate); 
	spec.setSource(MC_config.componentName); 
	spec.setToken(Configuration.defaultToken); 
	
	// RequestId
	spec.setRequestId(requestId);
	
	// Target, RequestAutomaticUpdate
	spec.setTarget(Configuration.serviceController);
	spec.setRequestAutomaticUpdate(false);
	
	// Data
	data = "{\"code\":\"" + 
		dataComponent.readCookie("registerId") + "\"}";
	spec.setData(data);
	
	// Type, confidential, context, status
	spec.setType(MessageType.CLEAR_CONTEXT);
	spec.setConfidential(MC_config.mc_confidential);
	spec.setContent(dataComponent.readCookie("context"));
	spec.setStatus(Status.SUCCESS);
	
	interactionManager = complexMc.controller.getInteractionManager();
	interactionManager.processClearCxtResponse(spec);
	trace("[MC_UIEventObserver]{onProcessClearCtxRequest} - Ended ");
}

public function sendIsClicked() : void {
	complexMc.controller.send(txtIn.text);
}

