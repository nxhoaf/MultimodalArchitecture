package architecture;

import java.util.Date;
import java.util.Map;

import utilities.ConfigurationReader;
import utilities.Loggable;

public class StateManager implements Loggable{
	private String componentName;
	private long sleepTime;
	public StateManager(String componentName) {
		this.componentName = componentName;
	}
	
	public String getComponentName() {
		return componentName;
	}

	public void setComponentName(String componentName) {
		this.componentName = componentName;
	}

	public long getSleepTime() {
		return sleepTime;
	}

	public void setSleepTime(long sleepTime) {
		this.sleepTime = sleepTime;
	}

	public String load() {
		log("[StateManager][load] - Started");
		// -------------------- Algorithme Load --------------------------------
		String currentState = InteractionState.DEAD;
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		Boolean hasData = cookieReader.getBoolean("hasData", false);
		long now =  (new Date()).getTime();
		if (hasData) {
			long loadedSleep = cookieReader.getLong("begin", -1) - now;
			long loadedLife = cookieReader.getLong("end", -1);
			
			if (now < loadedLife) {
				currentState = InteractionState.ALIVE;
				if (loadedSleep > 0) {
					currentState = InteractionState.SLEEP;
					sleepTime = loadedSleep;
				}
			} else {
				currentState = InteractionState.DEAD;
			}
		}
		log("[StateManager][load] - Ended." + 
				"State will be changed to: " + currentState);
		return currentState;
	}
	
	public String processNewCtxResponse(Map<String, String> serviceResponse) {
		log("[StateManager][processNewCtxResponse] - Started");
		String context = serviceResponse.get("context");
		String currentState = "";
		
		// If not have context, schedule for another new ctx request
		if (context.equalsIgnoreCase("ALIVE")) {
			currentState = InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED;
		} else {
			// Else, save new ctx info and change state to HAS_CONTEXT
			ConfigurationReader cookieReader = 
					new ConfigurationReader(ConfigurationReader.COOKIE);
			currentState = InteractionState.HAS_CONTEXT;
			cookieReader.save("context", serviceResponse.get("context"));
			if (serviceResponse.get("token") != null) {
				cookieReader.save("token", serviceResponse.get("token"));
			}
			cookieReader.save("requestId", serviceResponse.get("id"));
		}
		
		// Log the change and return.
		log("[StateManager][load] - Ended." + 
				"State will be changed to: " + currentState);
		return currentState;
	}
	
	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}
}
