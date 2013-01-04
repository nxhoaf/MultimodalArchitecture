package Architecture
{
	
	import Config.Configuration;
	
	import MMI_Lib.MessageType;
	import MMI_Lib.Spec;
	import MMI_Lib.Status;
	
	import XHR_Lib.MMDispatcher;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	public class Controller
	{
		
		// Name of this component
		private var componentName : String; 
		private var dataComponent : DataComponent;
		private var interactionManager : InteractionManager;
		// Mark if new ctx is prepared or not.
		private var isNewCtxPrepared : Boolean;
		private var mmiDispatcher : MMDispatcher;
		private var socketManager : SocketManager;
		private var state : InteractionState;
		private var stateManager : StateManager;
		private var timer : Architecture.Timer
		
		public function Controller(name : String)
		{
			componentName = name;
			dataComponent = DCFactory.createDC(componentName);
			interactionManager = CCFactory.createInteractionManager(name, this);
			isNewCtxPrepared = false;
			
			mmiDispatcher = new MMDispatcher();
			mmiDispatcher.addEventListener(Event.COMPLETE, onEventReceived);
			
			socketManager = new SocketManager();
			socketManager.addEventListener(Event.CONNECT, connectHandler);
			socketManager.addEventListener(DataEvent.DATA, dataHandler);
			socketManager.addEventListener(Event.CLOSE, closeHandler);
			
			state = new InteractionState();
			stateManager = CCFactory.createStateManager(name);
			
			timer = new Architecture.Timer();
			timer.addEventListener(TimerEvent.TIMER, onTimerElapsed);
		}
		
		public function getInteractionManager() : InteractionManager {
			return interactionManager;
		}
		
		public function addEventListener(type : String, 
										 callback : Function) : void {
			interactionManager.addEventListener(type,callback);
		}
		
		public function onEventReceived(event:Event) : void {
			trace("[Controller][onEventReceived] - Started ");		
			processEvent(state, event);
			trace("[Controller][onEventReceived] - Ended ");
		}
		
		private function processEvent(state : InteractionState, 
									  event : Event) : void {
			trace("[Controller][processEvent] - Started ");
			var returnedState : String; 
			switch(state.getCurrentState()) 
			{
				
				// if we're waiting for register response
				case InteractionState.MC_REGISTER_SENT :
					processRegisterResponse(state, event);
					break;
				
				// if we're waiting for listening response
				case InteractionState.INFORM_SENT :
					processInformResponse(state, event);
					break;
				
				
				// if we're waiting for context response
				case InteractionState.NEW_CONTEXT_REQUEST_SENT : 					
					processNewCtxResponse(state, event);
					break;
//				
//				// if we're waiting for prepare response
//				case InteractionState.PREPARE_REQUEST_SENT : 
//					processPrepareResponse(state, event);
//					break;
//				
//				// if we're waiting for context response
//				case InteractionState.START_REQUEST_SENT : 					
//					processStartResponse(state, event);
//					break;
				
				default:
					trace("[Controller][processEvent] - "+
									"Default: " + state.getCurrentState());
					break;
			}
		}
		
		private function processRegisterResponse(state : InteractionState, 
												 event : Event) : void {
			trace("[Controller][processRegisterResponse] - Started ");
			// -------------------- 1. Variables declaration  ------------------
			var end : Number;
			var interval : Number;
			var lifeTime : Number;
			var now : Number;
			var requestNo : int; // requestNo of the previous registerRequest
			var returnedState : String; 
			var serviceResponse : URLVariables;
			var sleep : Number;
			var validationResult : String;
			
			// -------------------- 2. Mark as received  and process it --------
			state.setCurrentState(InteractionState.MC_REGISTER_RECEIVED);
			trace("[Controller][processRegisterResponse] - " 
							+ state.getStatus());
			
			
			
			// -------------------- 3. Check received data ---------------------
			// 3.1 Check data
			requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
			var loader:URLLoader = URLLoader(event.target);
			loader.dataFormat = URLLoaderDataFormat.TEXT; 
			serviceResponse = Parser.parseReceivedData(loader.data);
			validationResult = Validator.validate(serviceResponse, 
													"r" + requestNo);
			if (validationResult.toUpperCase() != "OK")
				throw new Error(validationResult);
			
			// 3.2 Process data
			returnedState = dataComponent.saveRegisterInfo(serviceResponse);
			state.setCurrentState(returnedState);
			trace("[Controller][processRegisterResponse] - " + 
							state.getStatus());
			
			// 3.3 Go to next step
			inform();
			trace("[Controller][processRegisterResponse] - Ended ");
		}
		
		private function processInformResponse(state : InteractionState, 
											   event : Event) : void {
			trace("[Controller][processInformResponse] - Started ");
			// -------------------- 1. Variables declaration  ------------------
			var returnedState : String;
			var requestNo : Number;
			
			// -------------------- 2. Process it ------------------------------
			// 2.1 Get the most recent requestNo to check
			requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
			// 2.2 Process inform request
			returnedState = 
				dataComponent.processInformResponse(event, 
													"r" + requestNo, 
													state.getOldState());
			state.setCurrentState(returnedState);
			trace("[Controller][processRegisterResponse] - " + 
								state.getStatus());
			
			// 3. Update the timer data based on received data
			updateTimer();
			
			trace("[Controller][processInformResponse] - Ended ");
		}
		
		private function updateTimer() : void {
			trace("[Controller][updateTimer] - Started ");
			// Time-related variable
			var now : Number; 
			var sleep : Number;
			var end : Number;
			var lifeTime : Number;
			var interval : Number;
			// -------------------- Update the timer ---------------------------
			// a. set params
			now = Date.parse(new Date());
			
			sleep  = Number(dataComponent.readCookie("begin")) - now;
			if (sleep < 1000) sleep = 0; // less than one second
			
			lifeTime = Number(dataComponent.readCookie("end")) - now;
			if (lifeTime < 0) lifeTime = 0;				
			
			interval = Number(dataComponent.readCookie("interval"));				
			if (interval <= 0) interval = 0;
			
			
			sleep = 0;
			interval = 3000;
			// b. Update timer
			timer.update(sleep, lifeTime, interval);
			trace("[Controller][updateTimer] - Ended ");
		}
			
		private function processNewCtxResponse(state : 
											   InteractionState, 
											   event : Event) : void {
			trace("[Controller][processNewCtxResponse] - Started ");
			
			// -------------------- 1. Variables declaration  ------------------
			var context : String;
			var returnedState : String;
			var requestNo : Number;
			var serviceResponse : URLVariables;
			var validationResult : String;
			
			// -------------------- 2. Mark as received  and process it --------
			state.setCurrentState(InteractionState.
											NEW_CONTEXT_REQUEST_RECEIVED);
			trace("[Controller]{processNewCtxResponse} "+
							"before processing : " + state.getStatus());
			
			// 2.1 Check data
			requestNo = Number(dataComponent.readCookie("requestNo")) - 1;
			var loader:URLLoader = URLLoader(event.target);
			loader.dataFormat = URLLoaderDataFormat.TEXT; 
			serviceResponse = Parser.parseReceivedData(loader.data);
			validationResult = Validator.validate(serviceResponse, 
												  "r" + requestNo);
			if (validationResult.toUpperCase() != "OK")
				throw new Error(validationResult);
			
			// 2.2 Process it
			returnedState = stateManager.processNewCtxResponse(serviceResponse);
			state.setCurrentState(returnedState);
			trace("[Controller]{processNewCtxResponse}  "+
								"===============  : " + state.getStatus());
			trace("[Controller][processNewCtxResponse] - Ended ");
		}
		
		public function load() : void {
			trace("[Controller][load] - Started");
			// -------------------- 1. Variables declaration  ------------------
			var currentState : String = InteractionState.UNKNOWN;
			var loadedSleep : int;
			var sleepTimer : flash.utils.Timer;
			// --------------------2. Load informations in cache  --------------
			currentState = stateManager.load();
			state.setCurrentState(currentState);
			trace("[Controller]{load} - " + state.getStatus());
			// --------------------3. Process the system  ----------------------
			// Based on the returned status, we will process the system: sleep,
			// dead, alive...
			if (currentState == InteractionState.SLEEP) {
				loadedSleep = stateManager.getSleepTime();
				sleepTimer = new flash.utils.Timer(loadedSleep, 1);
				sleepTimer.addEventListener(TimerEvent.TIMER, onSleepElapsed);
				sleepTimer.start();
			} else {
				sendRegister(currentState);
			}
			
			function onSleepElapsed() : void {
				sendRegister(currentState);
			}
			trace("[Controller][load] - Ended");
		}
		
		public function sendRegister(currentState : String) : void {
			trace("[MC_UIEventObserver][sendRegister] - Started");
			// -------------------- 1. Variables declaration  ------------------
			var stateToSend : String; 
			var typeToSend : String; 
			var urlToSend : String;
			var data : String; // Session local
			var requestNo : int;
			var spec:Spec= new Spec();
			
			// -------------------- 2. Create Register Request------------------
			// Method, source, token
			spec.setMethod(Configuration.operationRegister);
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
			spec.setTarget(Configuration.serviceRegister);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			stateToSend = currentState;
			typeToSend = MessageType.STATUS;
			urlToSend = "toto";
			data = "{'state':'" + stateToSend + "',"+
							" 'metadata': '{"+
								"'type':'" + typeToSend + "',"+
								"'url':'" + urlToSend + "'}'}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.STATUS);
			spec.setConfidential(MC_config.mc_confidential);  
			spec.setContext(Configuration.defaultContext);
			spec.setStatus(Status.LOAD);
			// ----------------- 3. Send register request to the server --------
			// 3.1 Send the message
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// 3.2 Mark as sent
			state.setCurrentState(InteractionState.MC_REGISTER_SENT);
			trace("[Controller]{sendRegister} - " + state.getStatus());
			
			trace("[Controller][sendRegister] - Ended");
		}
	
		public function inform() : void {
			trace("[Controller][inform] - Started ");
			// -------------------- 1. Variables declaration  ------------------
			var spec : Spec = new Spec();
			var requestNo : Number;
			
			// -------------------- 2. Create Inform Request--------------------
			// Method, source, token
			spec.setMethod(Configuration.operationRegister);
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
			spec.setTarget(Configuration.serviceRegister);
			spec.setRequestAutomaticUpdate(false);
			
			// Type, confidential, context, status
			spec.setType(MessageType.STATUS);
			spec.setConfidential(MC_config.mc_confidential);  
			spec.setContext(Configuration.defaultContext);
			spec.setStatus(Status.LOAD);
			
			// -------------------- 3. Send Inform request ---------------------
			// 3.1 Send
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// 3.2 Mark the change
			state.setCurrentState(InteractionState.INFORM_SENT);
			trace("[Controller]{inform} - " + state.getStatus());
			
			trace("[Controller][inform] - Ended ");
		}
				
		public function onTimerElapsed(event: TimerEvent) : void {
			trace("[Controller][onTimerElapsed] - "+
							"State: " + state.getCurrentState());
			var spec : Spec; 
			var context : String; 
			var returnedState : String; 
			switch (state.getCurrentState()) 
			{
				case InteractionState.HAS_LISTENER_FOR_NEW_CTX:
				case InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED : 
					trace("[Controller]{onTimerElapsed} - " + 
											" Create New Context Request");		
					if (!isNewCtxPrepared) {
						interactionManager.beforeNewCtxRequestSent();
						isNewCtxPrepared = true;
					}
					
					sendNewCtxRequest();
					
					interactionManager.onNewCtxRequestSent();
					break;
			
				case InteractionState.HAS_CONTEXT :
					trace("[Controller]{onTimerElapsed} "+
						"Context found: " + dataComponent.readCookie("context"));
					//***** Found context!!! ******
					
					// -------------- Make socket connection available ---------
					socketManager.connect(Configuration.hostName, 
										  Configuration.port);
					
					// -------------- Update current state ---------------------
					state.setCurrentState(InteractionState.UI_UPDATE_SCHEDULED);
					interactionManager.onHavingContext();
					trace("[Controller][onTimerElapsed] - " + 
												state.getStatus());
					break;
				
				case InteractionState.UI_UPDATE_SCHEDULED:
					trace("[Controller]{onTimerElapsed} - "+
									"UI update scheduled...");
					sendNotification();
					interactionManager.onUIUpdateSent();
					break;
				
				default : 
					trace("[Controller][onTimerElapsed] - default. "+
									"State: " + state.getCurrentState() + 
									" *** DO NOTHING ***");
					break;		
			}		
		}
		
		private function sendNewCtxRequest() : void {
			trace("[Controller][sendNewCtxRequest] - Started ");
			// -------------------- Variables declaration  ---------------------
			var spec : Spec; 
			var context : String; 
			var returnedState : String; 
			var requestNo : int;
			var data : String;
			spec = new Spec();
			
			// -------------------- Create NewCtxRequest -----------------------
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
			spec.setRequestId("r" + requestNo);
			
			dataComponent.createCookie("requestNo", requestNo + 1);
			dataComponent.commit(); // Explicitly write data to a disk
			
			// Target, RequestAutomaticUpdate
			spec.setTarget(Configuration.serviceController);
			spec.setRequestAutomaticUpdate(false);
			
			// Data
			data = "{\"code\":\"" + 
							dataComponent.readCookie("registerId") + "\"}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.NEW_CONTEXT);
			spec.setConfidential(MC_config.mc_confidential);  
			
			// ----------------- 3. Send register request to the server --------
			// 3.1 Send the message
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// 3.2 Mark as sent
			state.setCurrentState(InteractionState.NEW_CONTEXT_REQUEST_SENT);
			trace("[Controller]{sendRegister} - " + state.getStatus());
			
			trace("[Controller][sendNewCtxRequest] - Ended ");
		}
	
		private function sendNotification() : void {
			trace("[Controller]{sendNotification} - Started");
			// -------------------- 1. Variables declaration  ------------------
			var data : String;
			var requestNo : Number;
			var returnedState : String;
			var spec : Spec = new Spec();
			
			// -------------------- 2. Create Start Request---------------------
			// Method, source, token
			spec.setMethod(Configuration.operationRegister);
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
			
			data = "{state:" + InteractionState.HAS_INPUT + 
								", type:" + MessageType.START + "}";
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.STATUS);
			spec.setConfidential(MC_config.mc_confidential);  
			spec.setContext(Configuration.defaultContext);
			spec.setStatus(Status.LOAD);
			
			// ----------------- 3. Send notification to the server ------------
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			trace("[Controller]{sendNotification} - Ended");
		}
		
		
		//**********************************************************************
		// Socket Manager
		//**********************************************************************
		public function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
		}
		
		public function connectHandler(event:Event):void {
			trace("connectHandler: " + event);
		}
		
		public function dataHandler(event:DataEvent):void {
			trace("[Controller]{dataHandler} - Started. Raw data: " + event);
			
			// -------------------- 1. Variables declaration  ------------------
			var requestId : String;
			var serviceResponse : URLVariables;
			var type : String;
			var validationResult : String;
			
			// -------------------- Check received data ------------------------
			serviceResponse = Parser.parseReceivedData(event.data);
			// just a request, don't need to check requestId
			requestId = serviceResponse.id;
			validationResult = Validator.validate(serviceResponse, requestId);
			if (validationResult.toUpperCase() != "OK")
				throw new Error(validationResult);
			
			type = serviceResponse.type;
			
			switch (type) {
				case MessageType.START:
					trace("[Controller]{dataHandler} - SOCKET START");
					processStartRequest(requestId);
					break;
				
				case MessageType.PAUSE:
					trace("[Controller]{dataHandler} - SOCKET PAUSE");
					processPauseRequest(requestId);
					break;
				
				case MessageType.RESUME:
					trace("[Controller]{dataHandler} - SOCKET RESUME");
					processResumeRequest(requestId);
					break;
				
				case MessageType.CANCEL:
					trace("[Controller]{dataHandler} - SOCKET CANCEL");
					processCancelRequest(requestId);
					break;
				
				case MessageType.CLEAR_CONTEXT:
					trace("[Controller]{dataHandler} - SOCKET CLEAR_CONTEXT");
					processClearCtxRequest(requestId);
					break;
				
				default: 
					trace("[Controller]{dataHandler} - DEFAULT" + type);
					break;
			}
			trace("[Controller]{dataHandler} - Ended");
		}
		
		public function send(data:Object):void {
			trace("[Controller][send] - Started. Data is: " + data);
			socketManager.send(data);
		}
		
		public function processStartRequest(requestId : String) : void {
			trace("[Controller]{processStartRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			
			// ------------- Create Start Response and send it to the server ---
			// Create Start Response 
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
			
			// Send start response to the server
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// --------- Create Extension Notif, send to interactionManager-----
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager.processStartRequest(spec);
			
			trace("[Controller]{processStartRequest} - Ended");
		}
					
		public function processStartResponse(msg : Spec) : void {
			trace("[Controller]{processStartResponse} - " + 
				"Started, raw data: " + msg);
			// Place-holder.
			trace("[Controller]{processStartResponse} - Ended");
		}
	
		public function processPauseRequest(requestId : String) : void {
			trace("[Controller]{processPauseRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			
			// ------------- Create Pause Response and send it to the server ---
			// Create Pause Response 
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
			
			// Send start response to the server
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// --------- Create Extension Notif, send to interactionManager-----
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager.processPauseRequest(spec);
			
			trace("[Controller]{processPauseRequest} - Ended");
		}
	
		public function processPauseResponse(msg : Spec) : void {
			trace("[Controller]{processPauseResponse} - " + 
				"Started, raw data: " + msg);
			// Place-holder.
			trace("[Controller]{processPauseResponse} - Ended");
		}
	
		public function processResumeRequest(requestId : String) : void {
			trace("[Controller]{processResumeRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			
			// ------------ Create Resume Response and send it to the server ---
			// Create Resume Response 
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
			
			// Send start response to the server
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// --------- Create Extension Notif, send to interactionManager-----
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager.processResumeRequest(spec);
			
			trace("[Controller]{processResumeRequest} - Ended");
		}
	
		public function processResumeResponse(msg : Spec) : void {
			trace("[Controller]{processResumeResponse} - " + 
				"Started, raw data: " + msg);
			// Place-holder.
			trace("[Controller]{processResumeResponse} - Ended");
		}
		
		public function processCancelRequest(requestId : String) : void {
			trace("[Controller]{processCancelRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			
			// ------------ Create Cancel Response and send it to the server ---
			// Create Cancel Response 
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
			
			// Send start response to the server
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// --------- Create Extension Notif, send to interactionManager-----
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager.processCancelRequest(spec);
			
			trace("[Controller]{processCancelRequest} - Ended");
		}

		public function processCancelResponse(msg : Spec) : void {
			trace("[Controller]{processCancelResponse} - " + 
				"Started, raw data: " + msg);
			// Place-holder.
			trace("[Controller]{processCancelResponse} - Ended");
		}
	
		public function processClearCtxRequest(requestId : String) : void {
			trace("[Controller]{processClearCtxRequest} - Started");
			// -------------------- Variables declaration  ---------------------
			var data : String;
			// check to know if we have data in cookie
			var spec : Spec;
			
			// --------- Create Clear Ctx Response and send it to the server ---
			// Create Clear Ctx Response 
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
			
			// Send start response to the server
			mmiDispatcher.sendAsynchronous(spec, "GET", "MMI");
			
			// --------- Create Extension Notif, send to interactionManager-----
			// Create Extension Notif
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
			data = '{"state":"MUST_UPDATE"}';
			spec.setData(data);
			
			// Type, confidential, context, status
			spec.setType(MessageType.EXTENSION_NOTIFICATION);
			spec.setConfidential(MC_config.mc_confidential);
			spec.setContent(dataComponent.readCookie("context"));
			spec.setStatus(Status.SUCCESS);
			
			// Send it to the Interaction Manager
			interactionManager.processClearCtxRequest(spec);
			
			trace("[Controller]{processClearCtxRequest} - Ended");
		}
	
		public function processClearCtxResponse(msg : Spec) : void {
			trace("[Controller]{processClearCtxResponse} - " + 
				"Started, raw data: " + msg);
			// Place-holder.
			trace("[Controller]{processClearCtxResponse} - Ended");
		}
	
		public function sendStart(msg : Spec) : void {
			trace("[Controller]{sendStart} - Started");
			mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
			trace("[Controller]{sendStart} - Ended");
		}
		
		public function sendPause(msg : Spec) : void {
			trace("[Controller]{sendPause} - Started");
			mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
			trace("[Controller]{sendPause} - Ended");
		}
		
		public function sendResume(msg : Spec) : void {
			trace("[Controller]{sendResume} - Started");
			mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
			trace("[Controller]{sendResume} - Ended");
		}
		
		public function sendCancel(msg : Spec) : void {
			trace("[Controller]{sendCancel} - Started");
			mmiDispatcher.sendAsynchronous(msg, "GET", "MMI");
			trace("[Controller]{sendCancel} - Ended");
		}
	}
}


