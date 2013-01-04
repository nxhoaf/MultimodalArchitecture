package architecture;

import java.util.Date;
import java.util.Map;
import mmiLib.Status;

import utilities.ConfigurationReader;
import utilities.Loggable;
import xhrLib.MMDispatcherEvent;

public class DataComponent implements Loggable {
	private ConfigurationReader cf;
	
	public DataComponent() {
		cf = new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
	}
	
	public Boolean hasData() {
		Boolean hasData = cf.getBoolean("hasData", false);
		return hasData;
	}
	
	
	public String saveRegisterInfo(Map<String, String> serviceResponse) {
		log("[DataComponent][saveRegisterInfo] - Started ");
		String currentState = "";
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		
		// Algorithme for saving register info
		if (serviceResponse.get("status").equals(Status.ALIVE.status())) {
			log("[DataComponent][saveRegisterInfo] - ALIVE ");
			long now = (new Date()).getTime();
			long end = cookieReader.getLong("end", 0);	
			// Save received data, if we haven't saved yet
			if (end == 0 || end < now ) {
				log("[DataComponent][processRegister] - "+
						"Saving received info into cookie.");
				String timerData = serviceResponse.get("timeout");
				if (timerData == null 
						|| serviceResponse.get("deliveryContent") == null) {
					log("[DataComponent][saveRegisterInfo] - "+
										"Error, don't have timerData! ");
					currentState = InteractionState.FAILURE;
					log("[DataComponent][saveRegisterInfo] - Ended. "+
							   "State will be changed to: " + currentState);
					return currentState;
				}
				log("[DataComponent][saveRegisterInfo] ");
				cookieReader.save("registerID", serviceResponse.get("deliveryContent"));
				cookieReader.save("begin" , "" + Parser.parseTimerData(timerData)[0]);
				cookieReader.save("end" , "" + Parser.parseTimerData(timerData)[1]);				
				cookieReader.save("interval" , "" + Parser.parseTimerData(timerData)[2]);
				cookieReader.save("hasData", "true");
				currentState = InteractionState.HAS_SESSION;
			} else {
				log("[DataComponent][processRegister] - "+
						"Timer data found in cache!");
				// If we've already had session and it still be valid
				currentState = InteractionState.HAS_SESSION; 
			}
		} else {
			cookieReader.erase();
			currentState = InteractionState.FAILURE;
		}
		log("[DataComponent][load] - Ended. "+
				"State will be changed to: " + currentState);
		return currentState;
	}

	public String  processInformResponse(MMDispatcherEvent event, 
									   String requestId, 
									   String previousState) {
		log("[DataComponent][processInformResponse] - Started ");
		
		
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		String currentState = "";
		
		// Parsing response
		Map<String, String> serviceResponse = 
				Parser.parseReceivedData(event.getData());
		String timerData = serviceResponse.get("timeout");
		
		// Processing the timer data
		if (timerData != null) {
			long now = (new Date()).getTime();
			long begin = cookieReader.getLong("begin", 0);
			long end = cookieReader.getLong("end", 0);
			long interval = cookieReader.getLong("interval", 0);
			
			// Timer elapsed, the system is dead
			if (now >= end) {
				currentState = InteractionState.DEAD;
				log("[DataComponent][processListeningResponse] - "+
					" Invalid data:");
				log("		now: " + (new Date(now)).toString());
				log("		end: " + (new Date(end)).toString());
				return currentState;
			}
			
			// else, we save it
			cookieReader.save("begin", "" + begin);
			cookieReader.save("end", "" + end);
			cookieReader.save("interval", "" + interval);
			
			log("[DataComponent][processInformResponse] - "+
				"Update timer data");
			log("		begin: " + (new Date(begin)).toString());
			log("		end: " + (new Date(end)).toString());
			log("		interval: " + (new Date(interval)).toString());
			
			// update stated based on current state.
			if (previousState.equals(InteractionState.HAS_SESSION)) {
				currentState = InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED;
			} else {
				currentState = InteractionState.DEAD;
			}
		}
		
		// Logging and return.
		log("[DataComponent][processInformResponse] - Ended. "+
				"State will be changed to: " + currentState);
		return currentState;
	}
	
	@Override
	public void log(String message) {
		System.out.println(message);
	}
}
