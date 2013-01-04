var InteractionState = function () {
	var state = {};

	var oldState = InteractionState.UNKNOWN;
	var currentState = InteractionState.UNKNOWN;
	var self = this;
	
	state.getOldState = function () {
		return oldState;
	}
	state.setCurrentState = function (aState) {
		oldState = currentState;
		currentState = aState;
	}
	state.getCurrentState = function () {
		return currentState;
	}
	state.getStatus = function () {
		return "State changed: " + state.getOldState() + " --> " + state.getCurrentState();
	}
	return state;
}
// General purpose related states
	InteractionState.UNKNOWN = "UNKNOWN";
	InteractionState.DEAD = "DEAD";
	InteractionState.ALIVE = "ALIVE";
	InteractionState.FAILURE = "FAILURE";
	InteractionState.SLEEP = "SLEEP";
	InteractionState.HAS_SESSION = "HAS_SESSION";
	InteractionState.HAS_CONTEXT = "HAS_CONTEXT";
	InteractionState.HAS_INPUT = "HAS_INPUT";
	InteractionState.IS_UPDATED = "IS_UPDATED";
	InteractionState.PULL_SCHEDULED = "PULL_SCHEDULED";
	InteractionState.LISTEN_SENT = "LISTEN_SENT";
	InteractionState.CHECK_UPDATE_SENT = "CHECK_UPDATE_SENT";
	
	InteractionState.RECORD_SCHEDULED = "RECORD_SCHEDULED";
	InteractionState.RECORDING = "RECORDING";
	InteractionState.PAUSE_SCHEDULED = "PAUSE_SCHEDULED";
	InteractionState.PAUSED = "PAUSED";
	InteractionState.DONE_SCHEDULED = "DONE_SCHEDULED";
	InteractionState.DONE = "DONE";
	InteractionState.DONE_NOTIFICATION_SENT = "DONE_NOTIFICATION_SENT";
	
	
	InteractionState.HAS_LISTENER_FOR_NEW_CTX = "HAS_LISTENER_FOR_NEW_CTX";
	
	// Handshaking related states
	InteractionState.INFORM_SENT= "INFORM_SENT";
	InteractionState.MC_REGISTER_SENT = "MC_REGISTER_SENT";
	InteractionState.NEW_CONTEXT_REQUEST_SENT = "NEW_CONTEXT_REQUEST_SENT";
	InteractionState.PREPARE_REQUEST_SENT = "PREPARE_REQUEST_SENT";
	InteractionState.START_REQUEST_SENT = "START_REQUEST_SENT";						
	
	InteractionState.MC_REGISTER_RECEIVED = "MC_REGISTER_RECEIVED";
	InteractionState.NEW_CONTEXT_REQUEST_RECEIVED = "NEW_CONTEXT_REQUEST_RECEIVED";				
	InteractionState.PREPARE_REQUEST_RECEIVED = "PREPARE_REQUEST_RECEIVED";
	InteractionState.START_REQUEST_RECEIVED = "START_REQUEST_RECEIVED";			
	
	InteractionState.NEW_CONTEXT_REQUEST_SHEDULED = "NEW_CONTEXT_REQUEST_SHEDULED";
	InteractionState.START_REQUEST_SCHEDULED = "START_REQUEST_SCHEDULED";
	InteractionState.PREPARE_REQUEST_SCHEDULED = "PREPARE_REQUEST_SCHEDULED";					
	
	// Polling related states
	InteractionState.POLL_STATUS_SENT = "POLL_STATUS_SENT"; 
	InteractionState.POLL_PREPARE_SENT = "POLL_PREPARE_SENT"; 
	InteractionState.POLL_START_SENT = "POLL_START_SENT";
	InteractionState.POLL_PAUSE_SENT = "POLL_PAUSE_SENT";
	InteractionState.POLL_RESUME_SENT = "POLL_RESUME_SENT";
	InteractionState.POLL_CANCEL_SENT = "POLL_CANCEL_SENT";
	InteractionState.POLL_CLEAR_CONTEXT_SENT = "POLL_CLEAR_CONTEXT_SENT";
	
	InteractionState.POLL_STATUS_RECEIVED = "POLL_STATUS_RECEIVED";
	InteractionState.POLL_PREPARE_RECEIVED = "POLL_PREPARE_RECEIVED";
	InteractionState.POLL_START_RECEIVED = "POLL_START_RECEIVED";
	InteractionState.POLL_PAUSE_RECEIVED = "POLL_PAUSE_RECEIVED";
	InteractionState.POLL_RESUME_RECEIVED = "POLL_RESUME_RECEIVED";
	InteractionState.POLL_CANCEL_RECEIVED = "POLL_CANCEL_RECEIVED";
	InteractionState.POLL_CLEAR_CONTEXT_RECEIVED = "POLL_CLEAR_CONTEXT_RECEIVED";
	
	InteractionState.UI_UPDATE_SCHEDULED = "UI_UPDATE_SCHEDULED";
	InteractionState.AUTOMATIC_UPDATE_SCHEDULED = "AUTOMATIC_UPDATE_SCHEDULED";
	InteractionState.POLL_STATUS_SCHEDULED = "POLL_STATUS_SCHEDULED";
	InteractionState.POLL_PREPARE_SCHEDULED = "POLL_PREPARE_SCHEDULED"; 
	InteractionState.POLL_START_SCHEDULED = "POLL_START_SCHEDULED"; 
	InteractionState.POLL_PAUSE_SCHEDULED = "POLL_PAUSE_SCHEDULED"; 
	InteractionState.POLL_RESUME_SCHEDULED = "POLL_RESUME_SCHEDULED";
	InteractionState.POLL_CANCEL_SCHEDULED = "POLL_CANCEL_SCHEDULED";
	InteractionState.POLL_CLEAR_CONTEXT_SCHEDULED = "POLL_CLEAR_CONTEXT_SCHEDULED";