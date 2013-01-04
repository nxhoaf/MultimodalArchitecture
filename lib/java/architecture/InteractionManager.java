package architecture;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import mmiLib.MessageType;
import mmiLib.Spec;
import mmiLib.Status;
import utilities.ConfigurationReader;
import utilities.Loggable;
import xhrLib.MMDispatcherEvent;
import xhrLib.MMDispatcherEventListener;

public class InteractionManager implements Loggable {
	private String componentName;
	private Controller controller;
	private List<InteractionEventListener> listeners;
	
	public InteractionManager(String componentName, Controller controller) {
		this.componentName = componentName;
		this.controller = controller;
		listeners = new ArrayList<InteractionEventListener>();
	}
	
	public synchronized void addEventListener(InteractionEventListener listener) {
		listeners.add(listener);
	}
	
	public synchronized void removeEventListener(InteractionEventListener listener) {
		listeners.remove(listener);
	}
	
	private synchronized void fireEvent(InteractionEvent event) {
		Iterator<InteractionEventListener> i = listeners.iterator();
		InteractionEventListener listener;
		while (i.hasNext()) {
			listener = i.next();
			listener.processInteractionEvent(event);
		}
	}
	
	public void beforeNewCtxRequestSent() {
		log("[InteractionManager]{beforeNewCtxRequestSent} - Started");
		
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		
		// --------------------  Send Prepare Request to GUI -------------------
		// Create prepare Request
		Spec spec = new Spec();
		int requestNo = cookieReader.getInt("requestNo", 1);
		
		spec.setMethod(globalConf.getString("operationRegister", "MC_register"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		spec.setRequestId("r" + requestNo);
		requestNo ++;
		cookieReader.save("requestNo", "" + requestNo);
		
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setMetadata(localConf.getString("mc_metadata", null));
		spec.setType("" + MessageType.STATUS.status());
		
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());
		spec.setData(localConf.getString("mc_data", null));
		
		// Ok, attach it to an event, and then fire the event.
		InteractionEvent event = 
				new InteractionEvent(this, 
									InteractionEvent.BEFORE_NEW_CTX_REQUEST_SENT, 
									spec);
		
		fireEvent(event);
		
		log("[InteractionManager]{beforeNewCtxRequestSent} - Ended");
	}

	public void onNewCtxRequestSent() {
		log("[InteractionManager]{onNewCtxRequestSent} - Started");
		InteractionEvent event = 
				new InteractionEvent(this,InteractionEvent.ON_NEW_CTX_REQUEST_SENT);
		fireEvent(event);
		log("[InteractionManager]{onNewCtxRequestSent} - Ended");
	}
	
	public void onHavingContext() {
		log("[InteractionManager]{onHavingContext} - Started");
		InteractionEvent event = 
				new InteractionEvent(this, InteractionEvent.ON_HAVING_CONTEXT);
		fireEvent(event);
		log("[InteractionManager]{onHavingContext} - Ended");
	}
	
	public void processCancelRequest(Spec msg) {
		log("[InteractionManager]{processCancelRequest} - Started");
		// -------------------- Create Resume Request to send to UI -------------
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		spec.setRequestId(msg.getRequestId());
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{\"code\":\"" + 
				cookieReader.getString("registerId", null) + "\"}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.CANCEL.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());
		
		// Notify the UI
		InteractionEvent event = 
				new InteractionEvent(this, InteractionEvent.ON_PROCESS_CANCEL_REQUEST);
		event.setMsg(spec);
		fireEvent(event);
		
		log("[InteractionManager]{processCancelRequest} - Ended");
	}

	public void processCancelResponse(Spec msg) {
		log("[InteractionManager]{processCancelResponse} - Started");
		//--- Create UI Update Notification, send it to send to controller -----
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo ++;
		cookieReader.save("requestNo", "" + requestNo);
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{state:" + InteractionState.HAS_INPUT + ", "+
			"type:" + MessageType.CANCEL + "}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.UI_UPDATE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());
		
		// Send it to controller
		controller.processPauseResponse(spec);
		log("[InteractionManager]{processCancelResponse} - Ended");
	}

	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}

	public void processPauseRequest(Spec msg) {
		log("[InteractionManager]{processPauseRequest} - Started");
		// -------------------- Create Pause Request to send to UI -------------
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		spec.setRequestId(msg.getRequestId());
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{\"code\":\"" + 
				cookieReader.getString("registerId", null) + "\"}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.PAUSE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());
		
		// Notify the UI
		InteractionEvent event = 
				new InteractionEvent(this, InteractionEvent.ON_PROCESS_PAUSE_REQUEST);
		event.setMsg(spec);
		fireEvent(event);
		
		log("[InteractionManager]{processPauseRequest} - Ended");
	}

	public void processPauseResponse(Spec msg) {
		log("[InteractionManager]{processPauseResponse} - Started");
		//--- Create UI Update Notification, send it to send to controller -----
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo ++;
		cookieReader.save("requestNo", "" + requestNo);
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{state:" + InteractionState.HAS_INPUT + ", "+
			"type:" + MessageType.PAUSE + "}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.UI_UPDATE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());
		
		// Send it to controller
		controller.processPauseResponse(spec);
		log("[InteractionManager]{processPauseResponse} - Ended");
	}

	public void processResumeRequest(Spec msg) {
		log("[InteractionManager]{processResumeRequest} - Started");
		// -------------------- Create Resume Request to send to UI -------------
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		spec.setRequestId(msg.getRequestId());
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{\"code\":\"" + 
				cookieReader.getString("registerId", null) + "\"}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.RESUME.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());
		
		// Notify the UI
		InteractionEvent event = 
				new InteractionEvent(this, InteractionEvent.ON_PROCESS_RESUME_REQUEST);
		event.setMsg(spec);
		fireEvent(event);
		
		log("[InteractionManager]{processResumeRequest} - Ended");
	}
	
	public void processResumeResponse(Spec msg) {
		log("[InteractionManager]{processResumeResponse} - Started");
		//--- Create UI Update Notification, send it to send to controller -----
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo ++;
		cookieReader.save("requestNo", "" + requestNo);
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{state:" + InteractionState.HAS_INPUT + ", "+
			"type:" + MessageType.RESUME + "}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.UI_UPDATE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());
		
		// Send it to controller
		controller.processResumeResponse(spec);
		log("[InteractionManager]{processResumeResponse} - Ended");
	}

	public void processStartRequest(Spec msg) {
		log("[InteractionManager]{processStartRequest} - Started");
		// -------------------- Create Start Request to send to UI -------------
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		spec.setRequestId(msg.getRequestId());
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{\"code\":\"" + 
				cookieReader.getString("registerId", null) + "\"}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.START.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());
		
		// Notify the UI
		InteractionEvent event = 
				new InteractionEvent(this, InteractionEvent.ON_PROCESS_START_REQUEST);
		event.setMsg(spec);
		fireEvent(event);
		
		
		log("[InteractionManager]{processStartRequest} - Ended");
	}
	
	public void processStartResponse(Spec msg) {
		log("[InteractionManager]{processStartResponse} - Started");
		//--- Create UI Update Notification, send it to send to controller -----
		// Load config file
		ConfigurationReader globalConf = 
				new ConfigurationReader(ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = 
				new ConfigurationReader(ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = 
				new ConfigurationReader(ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();
		
		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate", "MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));
		
		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo ++;
		cookieReader.save("requestNo", "" + requestNo);
		
		
		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);
		
		// Data
		String data = "{state:" + InteractionState.HAS_INPUT + ", "+
			"type:" + MessageType.START + "}";
		spec.setData(data);
					
		// Type, confidential, context, status
		spec.setType("" + MessageType.UI_UPDATE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());
		
		// Send it to controller
		controller.processStartResponse(spec);
		log("[InteractionManager]{processStartResponse} - Ended");
	}

	
}
