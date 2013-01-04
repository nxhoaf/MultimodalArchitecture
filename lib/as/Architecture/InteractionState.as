package Architecture
{
	public class InteractionState
	{
		// General purpose related states
		public static const UNKNOWN : String = "UNKNOWN";
		public static const DEAD : String = "DEAD";
		public static const ALIVE : String = "ALIVE";
		public static const FAILURE : String = "FAILURE";
		public static const SLEEP : String = "SLEEP";
		public static const HAS_SESSION : String = "HAS_SESSION";
		public static const HAS_CONTEXT : String = "HAS_CONTEXT";
		public static const HAS_INPUT : String = "HAS_INPUT";
		public static const PULL_MODE : String = "PULL_MODE";
		public static const CHECK_UPDATE_SENT : String = "CHECK_UPDATE_SENT";
		
		
		public static const RECORD_SCHEDULED : String = "RECORD_SCHEDULED";
		public static const RECORDING : String = "RECORDING";
		public static const	PAUSE_SCHEDULED : String = "PAUSE_SCHEDULED";
		public static const PAUSED : String = "PAUSED";
		public static const DONE_SCHEDULED : String = "DONE_SCHEDULED";
		public static const DONE : String = "DONE";
		public static const DONE_NOTIFICATION_SENT : String = "DONE_NOTIFICATION_SENT";
		
		
		public static const HAS_LISTENER_FOR_NEW_CTX : String = "HAS_LISTENER_FOR_NEW_CTX";
		public static const HAS_LISTENER_FOR_UNAVAILABLE : String = "HAS_LISTENER_FOR_UNAVAILABLE";
		public static const UNAVAILVABLE_HAS_LISTENER : String = "UNAVAILVABLE_HAS_LISTENER";
		public static const AVAILVABLE_HAS_LISTENER : String = "AVAILVABLE_HAS_LISTENER";
		
		
		// Hanshaking related states
		public static const INFORM_SENT : String = "INFORM_SENT";
		public static const LISTENING_SENT : String = "LISTENING_SENT";
		public static const MC_REGISTER_SENT : String = "MC_REGISTER_SENT";
		public static const NEW_CONTEXT_REQUEST_SENT : String = "NEW_CONTEXT_REQUEST_SENT";
		public static const PREPARE_REQUEST_SENT : String = "PREPARE_REQUEST_SENT";
		public static const START_REQUEST_SENT : String = "START_REQUEST_SENT";						
		
		public static const LISTENING_RECEIVED : String = "LISTENING_RECEIVED";
		public static const MC_REGISTER_RECEIVED : String = "MC_REGISTER_RECEIVED";
		public static const NEW_CONTEXT_REQUEST_RECEIVED : String = "NEW_CONTEXT_REQUEST_RECEIVED";				
		public static const PREPARE_REQUEST_RECEIVED : String = "PREPARE_REQUEST_RECEIVED";
		public static const START_REQUEST_RECEIVED : String = "START_REQUEST_RECEIVED";			
		
		public static const LISTENING_SCHEDULED : String = "LISTENING_SCHEDULED";
		public static const MC_REGISTER_SCHEDULED : String = "MC_REGISTER_SCHEDULED";
		public static const NEW_CONTEXT_REQUEST_SCHEDULED : String = "NEW_CONTEXT_REQUEST_SCHEDULED";
		public static const START_REQUEST_SCHEDULED : String = "START_REQUEST_SCHEDULED";
		public static const PREPARE_REQUEST_SCHEDULED : String = "PREPARE_REQUEST_SCHEDULED";					
		
		// Polling related states
		public static const POLL_STATUS_SENT : String = "POLL_STATUS_SENT"; 
		public static const POLL_PREPARE_SENT : String = "POLL_PREPARE_SENT"; 
		public static const POLL_START_SENT : String = "POLL_START_SENT";
		public static const POLL_PAUSE_SENT : String = "POLL_PAUSE_SENT";
		public static const POLL_RESUME_SENT : String = "POLL_RESUME_SENT";
		public static const POLL_CANCEL_SENT : String = "POLL_CANCEL_SENT";
		public static const POLL_CLEAR_CONTEXT_SENT : String = "POLL_CLEAR_CONTEXT_SENT";
		
		public static const POLL_STATUS_RECEIVED : String = "POLL_STATUS_RECEIVED";
		public static const POLL_PREPARE_RECEIVED : String = "POLL_PREPARE_RECEIVED";
		public static const POLL_START_RECEIVED : String = "POLL_START_RECEIVED";
		public static const POLL_PAUSE_RECEIVED : String = "POLL_PAUSE_RECEIVED";
		public static const POLL_RESUME_RECEIVED : String = "POLL_RESUME_RECEIVED";
		public static const POLL_CANCEL_RECEIVED : String = "POLL_CANCEL_RECEIVED";
		public static const POLL_CLEAR_CONTEXT_RECEIVED : String = "POLL_CLEAR_CONTEXT_RECEIVED";
		
		public static const UI_UPDATE_SCHEDULED : String = "UI_UPDATE_SCHEDULED";
		public static const AUTOMATIC_UPDATE_SCHEDULED : String = "AUTOMATIC_UPDATE_SCHEDULED";
		public static const POLL_STATUS_SCHEDULED : String = "POLL_STATUS_SCHEDULED";
		public static const POLL_PREPARE_SCHEDULED : String = "POLL_PREPARE_SCHEDULED"; 
		public static const POLL_START_SCHEDULED : String = "POLL_START_SCHEDULED"; 
		public static const POLL_PAUSE_SCHEDULED : String = "POLL_PAUSE_SCHEDULED"; 
		public static const POLL_RESUME_SCHEDULED : String = "POLL_RESUME_SCHEDULED";
		public static const POLL_CANCEL_SCHEDULED : String = "POLL_CANCEL_SCHEDULED";
		public static const POLL_CLEAR_CONTEXT_SCHEDULED : String = "POLL_CLEAR_CONTEXT_SCHEDULED";
		
		// Polling related states
		private static var oldState : String = InteractionState.UNKNOWN;
		private static var currentState : String = InteractionState.UNKNOWN
			
		public function InteractionState(aCurrentState : String = UNKNOWN, 
										 anOldState : String = UNKNOWN)
		{
			oldState = anOldState;
			currentState = aCurrentState;
		}
		
		
		// public functions
		public function getOldState() : String {
			return InteractionState.oldState;
		}
		
		public function getCurrentState() : String {
			return InteractionState.currentState;
		}
		public function setCurrentState(state : String) : void {
			oldState = currentState;
			currentState = state;
		}
		public function getStatus() : String {
			return "State changed: " + this.getOldState() + " --> " + this.getCurrentState();
		}
	}
}