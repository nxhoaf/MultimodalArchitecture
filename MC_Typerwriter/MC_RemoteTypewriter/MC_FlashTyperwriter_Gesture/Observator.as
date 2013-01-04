package 
{
	import MMI_Lib.MessageType;
	import MMI_Lib.Spec;
	import MMI_Lib.Status;
	
	import MmiObservator_Lib.CommandController;
	import MmiObservator_Lib.ContextController;
	import MmiObservator_Lib.ObservatorEvent;
	import MmiObservator_Lib.ObservatorState;
	import MmiObservator_Lib.RegisterController;
	import MmiObservator_Lib.Timer;
	
	import XHR_Lib.MMDispatcher;
	
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.URLVariables;
	


	public class Observator extends EventDispatcher
	{
		include "config.as";
		private static var requestNo : int;
		private var registerController : RegisterController;
		private var contextController : ContextController;
		private var commandController : CommandController;
		private var timer : Timer;
	
		private var state : ObservatorState;
		public function Observator() {
			requestNo = 0;
			registerController = new RegisterController();
			contextController = new ContextController();
			commandController = new CommandController();
			
			registerController.addEventListener(Event.COMPLETE, onload);
			contextController.addEventListener(Event.COMPLETE, onEventReceived);
			commandController.addEventListener(Event.COMPLETE, onEventReceived);
			
			timer = null;
	
			state = new ObservatorState();
		}
		public function test() : void {
			dispatchEvent(new ObservatorEvent(ObservatorEvent.OBSERVATION_COMPLETED))
		}
		public function start() : void {
			trace("[Observator][sendRegister] - Started ");
			// Create register Request
			var spec:Spec= new Spec();
			spec.setMethod("MC_register");
			spec.setSource("MC_Recorder");
			spec.setToken("MC_1234"); // RegisterId
			requestNo += 1;
			spec.setRequestId("r" + requestNo);
			//spec.setTarget(serverRoot); // @TODO change to real values
			spec.setTarget(serviceRegister); 
			spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
			spec.setType(MessageType.STATUS);
			spec.setConfidential(false);  
			spec.setContext("Unknown");
			spec.setStatus(Status.LOAD);
			
			// Send register request
			
			var returnedState : String = registerController.sendRegister(spec);	
			state.setCurrentState(returnedState);
			trace("[Observator][sendRegister] - " + state.getStatus());
			trace("[Observator][sendRegister] - Ended ");
		}	
		
		public function onTimerElapsed(event: TimerEvent) : void {
			trace("[Observator][onTimerElapsed] - State: " + state.getCurrentState());
			var spec : Spec; 
			var sharedObj : SharedObject; 
			var context : String; 
			var returnedState : String; 
			switch (state.getCurrentState()) {
				case ObservatorState.NEW_CONTEXT_REQUEST_SHEDULED : 
					// ******************** Create a NewContextRequest ********************
					// Create register Request
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234"); // RegisterId
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					spec.setType(MessageType.NEW_CONTEXT);
					spec.setConfidential(false);  
					spec.setContext("Unknown");
					spec.setStatus(Status.LOAD);
				
					returnedState = contextController.sendNewContextRequest(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.PREPARE_REQUEST_SCHEDULED :
//					// ******************** Create a Prepare Request ********************
				 	spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.PREPARE);
					spec.setConfidential(false);  
					spec.setContext("Unknown");
					spec.setStatus(Status.LOAD);
					
					returnedState= contextController.sendPrepareRequest(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.START_REQUEST_SCHEDULED :
					// ******************** Create a Start Request ********************
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.PREPARE);
					spec.setConfidential(false);  
					spec.setContext("Unknown");
					spec.setStatus(Status.LOAD);
					
					returnedState = contextController.sendStartRequest(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
			
				case ObservatorState.HAS_CONTEXT :
//					// ******************** Create a Poll Status ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.STATUS);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);

					returnedState = commandController.pollStatus(spec);		
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.AUTOMATIC_UPDATE_SCHEDULED : 
					// @TODO : Not implemented yet
					break;
				
				case ObservatorState.POLL_PREPARE_SCHEDULED : 
					// ******************** Create a Poll Prepare ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.PREPARE);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollPrepare(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.POLL_START_SCHEDULED: 
					// ******************** Create a Poll Start ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.PREPARE);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollStart(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.RECORDING : 
				case ObservatorState.POLL_PAUSE_SCHEDULED : 
					// ******************** Create a Poll Pause ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.PAUSE);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollPause(spec);			
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;

				
				case ObservatorState.PAUSED: 
					// ******************** Create a Poll Pause ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.RESUME);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollResume(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.POLL_CANCEL_SCHEDULED : 
					// ******************** Create a Poll Pause ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.CANCEL);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollCancel(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					
					break;
				
				case ObservatorState.POLL_CLEAR_CONTEXT_SCHEDULED: 
//					// ******************** Create a Poll Pause ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.CANCEL);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollClearContext(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				case ObservatorState.DONE : 
					// ******************** Create a Done Notification ********************
					sharedObj = SharedObject.getLocal("MC_Register");
					context  = sharedObj.data.context;
					spec = new Spec();
					spec.setMethod("MC_command");
					spec.setSource("MC_Recorder");
					spec.setToken("MC_1234");
					requestNo += 1;
					spec.setRequestId("r" + requestNo);
					//spec.setMetadata("{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}");
					//spec.setTarget(serverRoot); // @TODO change to real values
					spec.setTarget(serviceController); 
					spec.setType(MessageType.DONE_NOTIFICATION);
					spec.setConfidential(false);  
					spec.setContext(context);
					spec.setStatus(Status.LOAD);
					
					returnedState = commandController.pollClearContext(spec);
					state.setCurrentState(returnedState);
					trace("[Observator][onTimerElapsed] - " + state.getStatus());
					break;
				
				default : 
					trace("[Observator][onTimerElapsed] - State: " + state + " *** DO NOTHING ***");
					trace("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ requestNo: " + requestNo);
					return;
					break;
				
			}
		}
		
		public function onload(event:Event) :void {  
			trace("[Observator][onload] - Started ");
			processEvent(state, event);
			trace("[Observator][onload] - Ended ");
		}
		
		public function onEventReceived(event:Event) : void {
			trace("[Observator][onReceivingResponse] - Started ");		
			processEvent(state, event);
			trace("[Observator][onReceivingResponse] - Ended ");
		}
		
		private function processEvent (state : ObservatorState, event : Event) : void {
			trace("[Observator][processEvent] - Started ");
			var returnedState : String; 
			switch(state.getCurrentState()) 
			{
				case ObservatorState.MC_REGISTER_SENT :
					// ******************** Mark as received and them process it ********************		
					state.setCurrentState(ObservatorState.MC_REGISTER_RECEIVED);
					trace("[Observator][processEvent] - " + state.getStatus());
					returnedState = registerController.processRegister(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					// ******************** Activate the timer ********************					
					var sharedObj : SharedObject = SharedObject.getLocal("MC_Recorder");
					var now : Number = Date.parse(new Date());
					var sleep : Number = sharedObj.data.begin - now;
					if (sleep < 1000) sleep = 0; // less than one second
					var lifeTime : Number = sharedObj.data.end - now;
					if (lifeTime < 0) lifeTime = 0;				
					var interval : Number = sharedObj.data.interval;				
					timer = new Timer(sleep, lifeTime, 5000);
					timer.addEventListener(TimerEvent.TIMER, onTimerElapsed);
					trace("[RegisterController][processEvent] - Creating timer at: " + new Date(now));
					timer.start();
						
					break;
				
				
				case ObservatorState.NEW_CONTEXT_REQUEST_SENT : // if we're now waiting for context response					
					// mark as received then process it
					state.setCurrentState(ObservatorState.NEW_CONTEXT_REQUEST_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = contextController.processNewCtxResponse(event,requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					break;
				
				
				case ObservatorState.PREPARE_REQUEST_SENT : // if we're now waiting for prepare response
					// mark as received then process it
					state.setCurrentState(ObservatorState.PREPARE_REQUEST_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = contextController.processPrepareResponse(event,requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					break;
				
				
				
				
				case ObservatorState.START_REQUEST_SENT : // if we're now waiting for context response					
					// mark as received then process it
					state.setCurrentState(ObservatorState.START_REQUEST_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = contextController.processStartResponse(event,requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					break;
				
				
				case ObservatorState.POLL_STATUS_SENT : 					
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_STATUS_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollStatusResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					break; 
				
				
				case ObservatorState.POLL_PREPARE_SENT : 
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_PREPARE_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollPrepareResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					break;
				
				case ObservatorState.POLL_START_SENT : 
					
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_START_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollStartResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					if (state.getCurrentState() == ObservatorState.RECORD_SCHEDULED) {
//						soundRecorder.startRecord();
						state.setCurrentState(ObservatorState.RECORDING);
						trace("[Observator][processEvent] - "+ state.getStatus() );
					}						
					break;
				
				case ObservatorState.POLL_PAUSE_SENT: 
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_PAUSE_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollPauseResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					if (state.getCurrentState() == ObservatorState.PAUSE_SCHEDULED) {
//						soundRecorder.stopRecord();
						state.setCurrentState(ObservatorState.PAUSED);
						trace("[Observator][processEvent] - "+ state.getStatus() );
					}
					break;
				
				case ObservatorState.POLL_RESUME_SENT: 					
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_RESUME_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollResumeResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					if (state.getCurrentState() == ObservatorState.RECORD_SCHEDULED) {
						//soundRecorder.startRecord();
						state.setCurrentState(ObservatorState.PAUSED);
						trace("[Observator][processEvent] - "+ state.getStatus() );
					}
					break;
				
				case ObservatorState.POLL_CANCEL_SENT: 
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_CANCEL_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState = commandController.processPollCancelResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					if (state.getCurrentState() == ObservatorState.DONE_SCHEDULED) {
						timer.removeEventListener(Event.COMPLETE, onEventReceived);
						timer.stop();
//						soundRecorder.playback();
						state.setCurrentState(ObservatorState.DONE);
						trace("[Observator][processEvent] - "+ state.getStatus() );
					}
					break;
				
				case ObservatorState.POLL_CLEAR_CONTEXT_SENT: 
					// mark as received then process it
					state.setCurrentState(ObservatorState.POLL_CLEAR_CONTEXT_RECEIVED);
					trace("[Observator][processEvent] - "+ state.getStatus() );
					
					returnedState =  commandController.processPollClearContextResponse(event, requestNo);
					state.setCurrentState(returnedState);
					trace("[Observator][processEvent] - "+ state.getStatus() );
				
				default:
					break;
			}
			trace("[Observator][processEvent] - Ended ");
		}
		
	}
}		