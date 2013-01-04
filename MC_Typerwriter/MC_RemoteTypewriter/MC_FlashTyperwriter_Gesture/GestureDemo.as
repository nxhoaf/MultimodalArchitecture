/**
*
*
*	GestureDemo
*	
*	@author	Foxy
*	@version	1.0
*
*/

package {
	/*========================================================================*/
	/*=========================== VARIABLES DECLARATION ======================*/
	/*========================================================================*/	
	
	import Architecture.Controller;
	import Architecture.DCFactory; 
	import Architecture.InteractionEvent;
	import Architecture.InteractionManager;
	import Architecture.MCFactory;
	
	import Config.Configuration;
	
	import MMI_Lib.MessageType;
	import MMI_Lib.Spec;
	import MMI_Lib.Status;
	
	import XHR_Lib.MMDispatcher;
	
	import com.foxaweb.ui.gesture.*;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.utils.Timer;
		
	public class GestureDemo extends MovieClip {
		private var complexMc : Object;
		private var dataComponent : Object;
		private var fadeTween:Tween;
		private var mg:MouseGesture;
		private var timer:Timer;
		
		
		public var fiab_mc:MovieClip;
		public var draw_mc:MovieClip;
		public var out_tf:TextField;
		
		
		
		
		//private var fiabTween:Tween;
		/*====================================================================*/
		/*========================== COMPONENT INITIALIZATION =================/
		/*====================================================================*/		
		public function GestureDemo(){
			trace("[GestureDemo][initialization] - Started");
			stage.scaleMode="noScale";
			out_tf.text = "INITIALIZATION";
			complexMc = MCFactory.createComplexMc(MC_config.componentName);
			dataComponent = DCFactory.createDC(MC_config.componentName);
			
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
			
			trace("[MC_AirTyperwriter_Gesture][initialization] - Ended");
			
		}	
		
		public function beforeNewCtxRequestSent(e : InteractionEvent) : void {
			out_tf.text = "BEFORE NEW CTX REQUEST SENT";
		}
		
		public function onNewCtxRequestSent(e : InteractionEvent) : void {
			out_tf.text = "ON NEW CTX REQUEST SENT";
			
		}
		
		public function onHavingContext(e : InteractionEvent) : void {
			out_tf.text = "ON HAVING NEW CXT";
			initMouseGesture(stage);
		}
		
		public function onUIUpdateSent(e : InteractionEvent) : void {
			out_tf.text = "ON UI UPDATE SENT";
			//label.text = "onUIUpdateSent";
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
			// -------------------- ¨Process start request  --------------------
			out_tf.text = "ON PROCESSING START REQUEST";
			
			
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
			// -------------------- ¨Process Pause request  -------------------- 
			out_tf.text = "ON PROCESSING PAUSE REQUEST";
			
			
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
			// -------------------- ¨Process Resume request  ------------------- 
			out_tf.text = "ON PROCESSING RESUME REQUEST";
			
			
			// -------------------- Create Resume Request to send to UI --------
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
			// -------------------- ¨Process Cancel request  ------------------- 
			out_tf.text = "ON PROCESSING CANCEL REQUEST";
			
			// -------------------- Create Cancel Request to send to UI --------
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
			// -------------------- ¨Process start request  -------------------- 
			out_tf.text = "ON PROCESSING CLEAR CXT REQUEST";
			
			
			// -------------------- Create ClearCtx Request to send to UI ------
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
		
		private function initMouseGesture(stage : Stage) : void {
			mg=new MouseGesture(stage);
			mg.addGesture("START","17");
			mg.addGesture("PREPARE","0");			
			mg.addGesture("STOP","163");
			mg.addGesture("PAUSE","3");
			mg.addGesture("RESUME","6");
			
			/*
			_ 03 Prepare
			 V 42 Start
			 X 46 Stop
			  ¡ 05 Pause
			  ! 01 Resume
			*/
			mg.addEventListener(GestureEvent.GESTURE_MATCH,matchHandler);
			mg.addEventListener(GestureEvent.NO_MATCH,noMatchHandler);
			mg.addEventListener(GestureEvent.START_CAPTURE,startHandler);
			mg.addEventListener(GestureEvent.STOP_CAPTURE,stopHandler);
		}
		// ------------------------------------------------
		//
		// ---o private methods
		//
		// ------------------------------------------------
		
		/**
		* match gesture handler
		*/
		protected function matchHandler(e:GestureEvent):void{
			var command : String; 
			switch (e.datas){
				case "BACKSPACE":
					out_tf.text=out_tf.text.substr(0,out_tf.text.length-1);
					break;
				
				case "SPACE":
					out_tf.text+=" ";
					break;
				
				case "DOT":
					out_tf.text+=".";
					break;
				
				default:
					out_tf.text=e.datas;
					command = e.datas;
					break;
			}
			
			switch (command) {
				case "START":
					doStart();
					break;
				
				case "PAUSE":
					doPause();
					break;
				
				case "RESUME":
					doResume();
					break;
				
				case "CANCEL":
					doCancel();
					break;
				
				default:
					break;
			}
			//fiab_mc.barre_mc.x=-6*e.fiability;
			//timer.start();
		}
		
		public function doStart() : void {
			trace("[GestureDemo]{doStart} - Started "); 
			// -------------------- Variables declaration  ---------------------
			var context : String;
			var data : String;
			// check to know if we have data in cookie
			var hasData = dataComponent.readCookie("hasData"); 
			var interactionManager : InteractionManager;
			var requestNo;
			var returnedState;
			var spec : Spec;
			
			// ------------ Call Extension Notif in Interaction Manager --------
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager = complexMc.controller.getInteractionManager();
			interactionManager.start(spec);
			
			trace("[GestureDemo]{doStart} - Ended "); 
		}
		
		public function doPause() : void {
			trace("[GestureDemo]{doPause} - Started "); 
			// -------------------- Variables declaration  ---------------------
			var context : String;
			var data : String;
			// check to know if we have data in cookie
			var hasData = dataComponent.readCookie("hasData"); 
			var interactionManager : InteractionManager;
			var requestNo : Number;
			var returnedState;
			var spec : Spec;
			
			// ------------ Call Extension Notif in Interaction Manager --------
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager = complexMc.controller.getInteractionManager();
			interactionManager.pause(spec);
			trace("[GestureDemo]{doPause} - Ended ");
		}
		
		public function doResume() : void {
			trace("[GestureDemo]{doResume} - Started "); 
			// -------------------- Variables declaration  ---------------------
			var context : String;
			var data : String;
			// check to know if we have data in cookie
			var hasData = dataComponent.readCookie("hasData"); 
			var interactionManager : InteractionManager;
			var requestNo;
			var returnedState;
			var spec : Spec;
			
			// ------------ Call Extension Notif in Interaction Manager --------
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager = complexMc.controller.getInteractionManager();
			interactionManager.resume(spec);
			trace("[GestureDemo]{doResume} - Ended ");
		}
		
		public function doCancel() : void {
			trace("[GestureDemo]{doCancel} - Started "); 
			// -------------------- Variables declaration  ---------------------
			var context : String;
			var data : String;
			// check to know if we have data in cookie
			var hasData = dataComponent.readCookie("hasData"); 
			var interactionManager : InteractionManager;
			var requestNo;
			var returnedState;
			var spec : Spec;
			
			// ------------ Call Extension Notif in Interaction Manager --------
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager = complexMc.controller.getInteractionManager();
			interactionManager.cancel(spec);
			
			trace("[GestureDemo]{doCancel} - Ended ");
		}
		
		/**
		* no match handler 
		*/	
		protected function noMatchHandler(e:GestureEvent):void{
			draw_mc.zone_mc.graphics.clear();
		}
		
		/**
		* start capturing phase handler
		*/
		protected function startHandler(e:GestureEvent):void{
			
			//fiab_mc.alpha=1;
			//fiab_mc.barre_mc.x=-119;
			
			//timer.stop();
			//if (fadeTween)fadeTween.stop();
			//if (fiabTween)fiabTween.stop();
			
			draw_mc.zone_mc.graphics.clear();
			draw_mc.alpha=1;
			draw_mc.zone_mc.graphics.lineStyle(4,0x444444);
			draw_mc.zone_mc.graphics.moveTo(mouseX,mouseY);
			addEventListener(Event.ENTER_FRAME,capturingHandler);
		}
		
		/**
		* fade the drawing zone
		*/
		protected function fadeDrawing(e:TimerEvent):void{
			 //fadeTween = new Tween(draw_mc,"alpha",Regular.easeIn,draw_mc.alpha,0,20);
			 //fiabTween = new Tween(fiab_mc,"alpha",Regular.easeIn,fiab_mc.alpha,0,20);
		}
				
		/**
		* stop capturing phase handler
		*/
		protected function stopHandler(e:GestureEvent):void{
			removeEventListener(Event.ENTER_FRAME,capturingHandler);
		}
		
		/**
		* capturing handler
		*/
		protected function capturingHandler(e:Event):void{
			draw_mc.zone_mc.graphics.lineTo(mouseX,mouseY);
		}
		
	}	
}

