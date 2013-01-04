package architecture;

import utilities.Loggable;

public class InteractionState implements Loggable {
	// General purpose related states
	public static final String UNKNOWN = "UNKNOWN";
	public static final String HAS_CONTEXT = "HAS_CONTEXT";
	public static final String RECORD_SCHEDULED = "RECORD_SCHEDULED";
	public static final String RECORDING = "RECORDING";
	public static final String	PAUSE_SCHEDULED = "PAUSE_SCHEDULED";
	public static final String PAUSED = "PAUSED";
	public static final String DONE_SCHEDULED = "DONE_SCHEDULED";
	public static final String DONE = "DONE";
	public static final String DONE_NOTIFICATION_SENT = "DONE_NOTIFICATION_SENT";
	public static final String DEAD = "DEAD";
	public static final String ALIVE = "ALIVE";
	public static final String SLEEP = "SLEEP";
	public static final String FAILURE = "FAILURE";
	public static final String HAS_SESSION = "HAS_SESSION";
	public static final String INFORM_SENT = "INFORM_SENT";
	public static final String PULL_MODE = "PULL_MODE";
	public static final String HAS_INPUT = "HAS_INPUT";
	public static final String CHECK_UPDATE_SENT = "CHECK_UPDATE_SENT";
	
	// Hanshaking related states
	public static final String MC_REGISTER_SENT = "MC_REGISTER_SENT";
	public static final String NEW_CONTEXT_REQUEST_SENT = "NEW_CONTEXT_REQUEST_SENT";
	public static final String PREPARE_REQUEST_SENT = "PREPARE_REQUEST_SENT";
	public static final String START_REQUEST_SENT = "START_REQUEST_SENT";						
	
	public static final String MC_REGISTER_RECEIVED = "MC_REGISTER_RECEIVED";
	public static final String NEW_CONTEXT_REQUEST_RECEIVED = "NEW_CONTEXT_REQUEST_RECEIVED";				
	public static final String PREPARE_REQUEST_RECEIVED = "PREPARE_REQUEST_RECEIVED";
	public static final String START_REQUEST_RECEIVED = "START_REQUEST_RECEIVED";			
	
	public static final String NEW_CONTEXT_REQUEST_SCHEDULED = "NEW_CONTEXT_REQUEST_SCHEDULED";
	public static final String START_REQUEST_SCHEDULED = "START_REQUEST_SCHEDULED";
	public static final String PREPARE_REQUEST_SCHEDULED = "PREPARE_REQUEST_SCHEDULED";					
	
	// Polling related states
	public static final String POLL_STATUS_SENT = "POLL_STATUS_SENT"; 
	public static final String POLL_PREPARE_SENT = "POLL_PREPARE_SENT"; 
	public static final String POLL_START_SENT = "POLL_START_SENT";
	public static final String POLL_PAUSE_SENT = "POLL_PAUSE_SENT";
	public static final String POLL_RESUME_SENT = "POLL_RESUME_SENT";
	public static final String POLL_CANCEL_SENT = "POLL_CANCEL_SENT";
	public static final String POLL_CLEAR_CONTEXT_SENT = "POLL_CLEAR_CONTEXT_SENT";
	
	public static final String POLL_STATUS_RECEIVED = "POLL_STATUS_RECEIVED";
	public static final String POLL_PREPARE_RECEIVED = "POLL_PREPARE_RECEIVED";
	public static final String POLL_START_RECEIVED = "POLL_START_RECEIVED";
	public static final String POLL_PAUSE_RECEIVED = "POLL_PAUSE_RECEIVED";
	public static final String POLL_RESUME_RECEIVED = "POLL_RESUME_RECEIVED";
	public static final String POLL_CANCEL_RECEIVED = "POLL_CANCEL_RECEIVED";
	public static final String POLL_CLEAR_CONTEXT_RECEIVED = "POLL_CLEAR_CONTEXT_RECEIVED";
	
	public static final String  UI_UPDATE_SCHEDULED = "UI_UPDATE_SCHEDULED";
	public static final String AUTOMATIC_UPDATE_SCHEDULED = "AUTOMATIC_UPDATE_SCHEDULED";
	public static final String POLL_STATUS_SCHEDULED = "POLL_STATUS_SCHEDULED";
	public static final String POLL_PREPARE_SCHEDULED = "POLL_PREPARE_SCHEDULED"; 
	public static final String POLL_START_SCHEDULED = "POLL_START_SCHEDULED"; 
	public static final String POLL_PAUSE_SCHEDULED = "POLL_PAUSE_SCHEDULED"; 
	public static final String POLL_RESUME_SCHEDULED = "POLL_RESUME_SCHEDULED";
	public static final String POLL_CANCEL_SCHEDULED = "POLL_CANCEL_SCHEDULED";
	public static final String POLL_CLEAR_CONTEXT_SCHEDULED = "POLL_CLEAR_CONTEXT_SCHEDULED";
	
	private String oldState;
	private String currentState;
	
	public InteractionState() {
		oldState  = InteractionState.UNKNOWN;
		currentState = InteractionState.UNKNOWN;
	}

	public synchronized String getStatus() {
		return "State changed: " + this.getOldState() + " --> " + this.getCurrentState();
	}
	
	public synchronized String getOldState() {
		return oldState;
	}

	public synchronized String getCurrentState() {
		return currentState;
	}

	public synchronized Boolean currentStateEquals(String anotherState) {
		if (currentState.equalsIgnoreCase(anotherState))
			return true;
		else 
			return false;
	}
	
	public synchronized void setCurrentState(String currentState) {
		this.oldState = this.currentState;
		this.currentState = currentState;
	}

	@Override
	public void log(String message) {
		System.out.println(message);
	}
	
	
}
