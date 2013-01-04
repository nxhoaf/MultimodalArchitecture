package Architecture
{
	import Config.Configuration;
	
	import MMI_Lib.MessageType;
	import MMI_Lib.Spec;
	import MMI_Lib.Status;
	
	import flash.events.EventDispatcher;

	public class InteractionManager extends EventDispatcher
	{
		private var componentName : String;
		private var controller : Controller;
		private var dataComponent : DataComponent;
		public function InteractionManager(name : String, 
										   controller : Controller) {
			this.componentName = name;
			this.controller = controller;
			dataComponent = DCFactory.createDC(name);
		}
		
		public function beforeNewCtxRequestSent() : void {
			trace("[InteractionManager]{beforeNewCtxRequestSent} - Started");
			// -------------------- 1. Variables declaration  ------------------ 
			var data : String;
			var event : InteractionEvent;
			var requestNo : Number;
			var returnedState : String;
			var spec : Spec = new Spec();
			
			// -------------------- 2. Send Prepare Request to GUI -------------
			// 2.1 Create prepare requeset
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceRegister);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{\"code\":\"" + 
				dataComponent.readCookie("registerId") + "\"}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.STATUS);
			spec.setConfidential(MC_config.mc_confidential);  
			spec.setContext(Configuration.defaultContext);
			spec.setStatus(Status.LOAD);
			
			// 2.2 Send it to GUI
			event = new InteractionEvent(InteractionEvent
											.BEFORE_NEW_CTX_REQUEST_SENT);
			event.setMessage(spec);					
			dispatchEvent(event);
			trace("[InteractionManager]{beforeNewCtxRequestSent} - Ended");
		}
		
		public function onNewCtxRequestSent() : void {
			trace("[InteractionManager]{onNewCtxRequestSent} - Started");
			var event : InteractionEvent = 
				new InteractionEvent(InteractionEvent.ON_NEW_CTX_REQUEST_SENT);			
			dispatchEvent(event);
			trace("[InteractionManager]{onNewCtxRequestSent} - Ended");
		}
		
		public function onHavingContext() : void {
			trace("[InteractionManager]{onHavingContext} - Started");
			var event : InteractionEvent = 
				new InteractionEvent(InteractionEvent.ON_HAVING_CONTEXT);			
			dispatchEvent(event);
			trace("[InteractionManager]{onHavingContext} - Ended");
		}
		
		public function onUIUpdateSent() : void {
			trace("[InteractionManager]{onUIUpdateSent} - Started");
			var event : InteractionEvent = 
				new InteractionEvent(InteractionEvent.ON_UI_UPDATE_SENT);			
			dispatchEvent(event);
			trace("[InteractionManager]{onUIUpdateSent} - Ended");
		}
		
		public function processStartRequest(msg : Spec) : void {
			trace("[InteractionManager]{processStartRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			
			
			// -------------------- Create Start Request to send to UI ---------
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			spec.setRequestId(msg.getRequestId());
			
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
			
			// Notify the UI
			event = new InteractionEvent(InteractionEvent
												.ON_PROCESS_START_REQUEST);
			event.setMessage(spec);
			dispatchEvent(event);
			
			trace("[InteractionManager]{processStartRequest} - Ended");
		}
		
		public function processStartResponse(msg : Spec) : void {
			trace("[InteractionManager]{processStartResponse} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.START + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.processStartResponse(spec);
			trace("[InteractionManager]{processStartResponse} - Ended");
		}
	
		public function processPauseRequest(msg : Spec) : void {
			trace("[InteractionManager]{processPauseRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			
			
			// -------------------- Create Pause Request to send to UI ---------
			// Create Pause Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			spec.setRequestId(msg.getRequestId());
			
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
			
			// Notify the UI
			event = new InteractionEvent(InteractionEvent
				.ON_PROCESS_PAUSE_REQUEST);
			event.setMessage(spec);
			dispatchEvent(event);
			
			trace("[InteractionManager]{processPauseRequest} - Ended");
		}
	
		public function processPauseResponse(msg : Spec) : void {
			trace("[InteractionManager]{processPauseResponse} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.PAUSE + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.START);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.processPauseResponse(spec);
			trace("[InteractionManager]{processPauseResponse} - Ended");
		}
	
		public function processResumeRequest(msg : Spec) : void {
			trace("[InteractionManager]{processResumeRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			
			
			// -------------------- Create Resume Request to send to UI ---------
			// Create Resume Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			spec.setRequestId(msg.getRequestId());
			
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
			
			// Notify the UI
			event = new InteractionEvent(InteractionEvent
				.ON_PROCESS_RESUME_REQUEST);
			event.setMessage(spec);
			dispatchEvent(event);
			
			trace("[InteractionManager]{processResumeRequest} - Ended");
		}
	
		public function processResumeResponse(msg : Spec) : void {
			trace("[InteractionManager]{processResumeResponse} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.RESUME + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.processResumeResponse(spec);
			trace("[InteractionManager]{processResumeResponse} - Ended");
		}
	
		public function processCancelRequest(msg : Spec) : void {
			trace("[InteractionManager]{processCancelRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			
			
			// -------------------- Create Start Request to send to UI ---------
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			spec.setRequestId(msg.getRequestId());
			
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
			
			// Notify the UI
			event = new InteractionEvent(InteractionEvent
				.ON_PROCESS_CANCEL_REQUEST);
			event.setMessage(spec);
			dispatchEvent(event);
			
			trace("[InteractionManager]{processCancelRequest} - Ended");
		}
	
		public function processCancelResponse(msg : Spec) : void {
			trace("[InteractionManager]{processCancelResponse} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.CANCEL + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.processCancelResponse(spec);
			trace("[InteractionManager]{processCancelResponse} - Ended");
		}
	
		public function processClearCtxRequest(msg : Spec) : void {
			trace("[InteractionManager]{processClearCtxRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			
			
			// -------------------- Create Start Request to send to UI ---------
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			spec.setRequestId(msg.getRequestId());
			
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
			
			// Notify the UI
			event = new InteractionEvent(InteractionEvent
				.ON_PROCESS_CLEAR_CTX_REQUEST);
			event.setMessage(spec);
			dispatchEvent(event);
			
			trace("[InteractionManager]{processClearCtxRequest} - Ended");
		}
	
		public function processClearCxtResponse(msg : Spec) : void {
			trace("[InteractionManager]{processClearCxtResponse} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.CLEAR_CONTEXT + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.processClearCtxResponse(spec);
			trace("[InteractionManager]{processClearCxtResponse} - Ended");
		}
	
		public function start(msg : Spec) : void {
			trace("[InteractionManager]{start} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.START + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.sendStart(spec);
			trace("[InteractionManager]{start} - Ended");
		}
	
		public function pause(msg : Spec) : void {
			trace("[InteractionManager]{stop} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.PAUSE + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.sendPause(spec);
			trace("[InteractionManager]{stop} - Ended");
		}
	
		public function resume(msg : Spec) : void {
			trace("[InteractionManager]{resume} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.RESUME + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.sendResume(spec);
			trace("[InteractionManager]{resume} - Ended");
		}
	
		public function cancel(msg : Spec) : void {
			trace("[InteractionManager]{cancel} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			var event : InteractionEvent;
			var requestNo : Number;
			
			// ------- Create UI Update Notification and send to controller-----
			// Create Start Requset 
			spec = new Spec();
			// Method, source, token
			spec.setMethod(Configuration.operationOrchestrate); 
			spec.setSource(MC_config.componentName); 
			spec.setToken(Configuration.defaultToken); 
			
			// RequestId
			if(!dataComponent.hasData()) {
				requestNo = 1;
			} else {
				requestNo = Number(dataComponent.readCookie("requestNo"));	
			}
			spec.setRequestId(MC_config.getRequestId(requestNo));
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{state:" + InteractionState.HAS_INPUT + ", "+
				"type:" + MessageType.CANCEL + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.UI_UPDATE);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to controller
			controller.sendCancel(spec);
			trace("[InteractionManager]{cancel} - Ended");
		}
	}
}