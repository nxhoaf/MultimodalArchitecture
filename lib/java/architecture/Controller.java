package architecture;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import mmiLib.MessageType;
import mmiLib.Spec;
import mmiLib.Status;

import utilities.ConfigurationReader;
import utilities.Loggable;
import xhrLib.MMDispatcher;
import xhrLib.MMDispatcherEvent;
import xhrLib.MMDispatcherEventListener;

public class Controller implements Loggable, MMDispatcherEventListener,
		TimerEventListener, SocketEventListener {
	private String componentName;
	private DataComponent dataComponent;
	private Boolean isNewCtxPrepared;
	private Boolean isPullMode;
	private InteractionManager interactionManager;
	private MMDispatcher mmDispatcher;
	private InteractionState state;
	private SocketManager socketManager;
	private StateManager stateManager;
	private Timer timer;

	public Controller(String name) {
		componentName = name;

		// Create dispatcher object and add eventListener to it.
		mmDispatcher = new MMDispatcher();
		mmDispatcher.addEventListener(this);

		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);

		// Create socket manager and add event listener to it.
		String hostName = globalConf.getString("hostName", "localhost");
		int port = globalConf.getInt("port", 9999);
		socketManager = new SocketManager(hostName, port);
		socketManager.addEventListener(this);

		// Sub component
		stateManager = CCFactory.createStateManager(componentName);
		interactionManager = CCFactory.createInteractionManager(componentName,
				this);
		dataComponent = DCFactory.createDc();

		// State-related variable.
		isNewCtxPrepared = false;
		isPullMode = false;
		state = new InteractionState();

		// Create new timer object and add eventListener to it.
		timer = new Timer();
		timer.addEventListener(this);
	}

	public synchronized void addEventListener(InteractionEventListener listener) {
		interactionManager.addEventListener(listener);
	}

	public synchronized void removeEventListener(
			InteractionEventListener listener) {
		interactionManager.removeEventListener(listener);
	}

	public String getComponentName() {
		return componentName;
	}

	public void setComponentName(String componentName) {
		this.componentName = componentName;
	}

	private void checkUpdate() {
		log("[Controller]{checkUpdate} - Started ");
		// -------------------- Send Notification ------------------------------
		sendNotification();
		
		// -------------------- Listen to the server ---------------------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// Create message
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationRegister", "MC_register"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo++;
		cookieReader.save("requestNo", "" + requestNo);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Type, confidential, context, status
		spec.setType("" + MessageType.STATUS.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());

		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");
		state.setCurrentState(InteractionState.CHECK_UPDATE_SENT);
		log("[Controller]{checkUpdate} - " + state.getStatus());

		log("[Controller]{checkUpdate} - Ended ");
	}

	@Override
	public void closeHandler(SocketEvent socketEvent) {
		log("[Controller][closeHandler] - Close socket, timer will be stopped");
		timer.stop();
	}

	@Override
	public void connectHandler(SocketEvent socketEvent) {
		// TODO Auto-generated method stub

	}

	@Override
	public void dataHandler(SocketEvent socketEvent) {
		log("[Controller][dataHandler] - Started ");
		// TODO Auto-generated method stub
		// -------------------- Check received data ----------------------------
		// check data
		Map<String, String> serviceResponse = Parser
				.parseReceivedData(socketEvent.getData());

		String requestId = serviceResponse.get("id");

		String validationResult = Validator
				.validate(serviceResponse, requestId);
		if (!validationResult.equalsIgnoreCase("OK")) {
			System.err.println("Crash: message is not well formed,"
					+ " sytem cannot continue: " + validationResult);
			System.exit(1);
		}

		String type = serviceResponse.get("type");

		if (type.equals(MessageType.START.status())) {
			log("[Controller][dataHandler] - START");
			processStartRequest(requestId);

		} else if (type.equals(MessageType.PAUSE.status())) {
			log("[Controller][dataHandler] - PAUSE");
			processPauseRequest(requestId);

		} else if (type.equals(MessageType.RESUME.status())) {
			log("[Controller][dataHandler] - RESUME");
			processResumeRequest(requestId);

		} else if (type.equals(MessageType.CANCEL.status())) {
			log("[Controller][dataHandler] - CANCEL");
			processCancelRequest(requestId);

		} else {
			log("[Controller][processEvent] - " + "Default: "
					+ state.getCurrentState());
		}
		log("[Controller][dataHandler] - Ended ");
	}

	public void inform() {
		log("[Controller][inform] - Started");
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// -------------------- Create Inform Request---------------------------
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationRegister", "MC_register"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo++;
		cookieReader.save("requestNo", "" + requestNo);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Type, confidential, context, status
		spec.setType("" + MessageType.STATUS.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());

		// -------------------- Send Inform request ---------------------------
		// Send
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");
		// Mark the change
		state.setCurrentState(InteractionState.INFORM_SENT);
		log("[Controller]{inform} - " + state.getStatus());

		log("[Controller][inform] - Ended");
	}

	public void load() {
		log("[Controller][load] - Started");
		// -------------------- Load informations in cache ---------------------
		String currentState = stateManager.load();
		state.setCurrentState(currentState);
		log("[Controller]{load} - " + state.getStatus());

		// Check if we need to sleep before sending register or not.
		if (currentState.equals(InteractionState.SLEEP)) {

			// ok, let's sleep.
			log("[Controller][load] - Sleep");
			try {
				System.out.println(stateManager.getSleepTime());
				Thread.sleep(stateManager.getSleepTime());
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			// then send message
			sendRegister(currentState);
		} else {
			// if not, send immediately message
			log("[Controller][load] - Don't sleep");
			sendRegister(currentState);
		}
		log("[Controller][load] - Ended");
	}

	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}

	@Override
	public void onTimerElapsed() throws IOException {
		// TODO Auto-generated method stub
		log("[Controller][onTimerElapsed] - Started");
		if (state
				.currentStateEquals(InteractionState.NEW_CONTEXT_REQUEST_SCHEDULED)) {
			log("[Controller][onTimerElapsed] - sendNewCtxRequest ");

			// For the first time, we need to notify prepare to GUI.
			if (!isNewCtxPrepared) {
				interactionManager.beforeNewCtxRequestSent();
				isNewCtxPrepared = true;
			}

			// Send New Context Request and inform that event
			sendNewCtxRequest();
			
			// Notify the SendNewCtxRequest Event
			interactionManager.onNewCtxRequestSent();

		} else if (state.currentStateEquals(InteractionState.HAS_CONTEXT)) {
			ConfigurationReader cookieReader = new ConfigurationReader(
					ConfigurationReader.COOKIE);

			log("[Controller]{onTimerElapsed} " + "Context found: "
					+ cookieReader.getString("context", "c11"));
			// ***** Found context!!! ******
			interactionManager.onHavingContext();

			// In pull mode, we won't use socket, but periodic pull request
			// instead.
			if (!isPullMode) {
				socketManager.start();
				state.setCurrentState(InteractionState.UI_UPDATE_SCHEDULED);
			}
		} else if (state
				.currentStateEquals(InteractionState.UI_UPDATE_SCHEDULED)) {
			log("[Controller][onTimerElapsed] - UI Update Scheduled");
			sendNotification();

		} else if (state.currentStateEquals(InteractionState.PULL_MODE)) {
			log("[Controller][onTimerElapsed] - PULL_MODE");
			checkUpdate();

		} else {
			log("[Controller][onTimerElapsed] - default. " + "State: "
					+ state.getCurrentState() + " *** DO NOTHING ***");
		}

	}

	public void processCancelRequest(String requestId) {
		log("[Controller]{processCancelRequest} - Started");
		// -------- Create Cancel Response, send it to the server---------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String data = "{\"code\":\"" + cookieReader.getInt("registerId", -1)
				+ "\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.RESUME.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send start response to the server
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create Extension Notif
		spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		data = "{\"state\":\"MUST_UPDATE\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.EXTENSION_NOTIFICATION.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send it to the Interaction Manager
		interactionManager.processCancelRequest(spec);

		log("[Controller]{processCancelRequest} - Ended");
	}

	public void processCancelResponse(Spec msg) {
		log("[Controller]{processCancelResponse} - Started");
		log("[Controller]{processCancelResponse} - Started, raw data: " + msg);
		// Place-holder.
		log("[Controller]{processCancelResponse} - Ended");
	}

	private void processCheckUpdateResponse(InteractionState state,
			MMDispatcherEvent event) {
		log("[Controller]{processCheckUpdateResponse} - Started ");

		// -------------------- Check received data ----------------------------
		// check data
		Map<String, String> serviceResponse = Parser.parseReceivedData(event
				.getData());

		String requestId = serviceResponse.get("id");

		String validationResult = Validator
				.validate(serviceResponse, requestId);
		if (!validationResult.equalsIgnoreCase("OK")) {
			System.err.println("Crash: message is not well formed,"
					+ " sytem cannot continue: " + validationResult);
			System.exit(1);
		}

		String type = serviceResponse.get("type");

		if (type.equals(MessageType.START.status())) {
			processStartRequest(requestId);

		} else if (type.equals(MessageType.PAUSE.status())) {
			processPauseRequest(requestId);

		} else if (type.equals(MessageType.RESUME.status())) {
			processResumeRequest(requestId);

		} else if (type.equals(MessageType.CANCEL.status())) {
			processCancelRequest(requestId);

		} else {
			log("[Controller][processCheckUpdateResponse] - " + "Default: "
					+ state.getCurrentState());
		}

		// After sending message, return to pull mode
		state.setCurrentState(InteractionState.PULL_MODE);
		log("[Controller]{processCheckUpdateResponse} - Ended ");
	}
	
	@Override
	public void processEvent(MMDispatcherEvent event) throws IOException {
		log("[Controller]{processEvent} - Started ");
		log("[Controller]{processEvent} - data: " + event.getData());

		if (state.currentStateEquals(InteractionState.MC_REGISTER_SENT)) {
			processRegisterResponse(state, event);
			
			
		} else if (state.currentStateEquals(InteractionState.INFORM_SENT)) {
			processInformResponse(state, event);
			
			
		} else if (state.currentStateEquals(InteractionState.NEW_CONTEXT_REQUEST_SENT)) {
			processNewCtxResponse(state, event);
			
			
		} else if (state.currentStateEquals(InteractionState.CHECK_UPDATE_SENT)) {
			processCheckUpdateResponse(state, event);
			
			
		} else {
			log("[Controller][processEvent] - " + "Default: "
					+ state.getCurrentState());
		}
		
		
		log("[Controller]{processEvent} - Ended ");

	}

	private void processInformResponse(InteractionState state,
			MMDispatcherEvent event) {
		log("[Controller]{processInformResponse} - Started ");
		// -------------------- Process response -------------------------------
		// Load cookieReader
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// Process inform response
		int requestNo = cookieReader.getInt("requestNo", 1);
		requestNo--;
		String returnedState = dataComponent.processInformResponse(event, "r"
				+ requestNo, state.getOldState());

		// Update state
		state.setCurrentState(returnedState);
		log("[Controller][processInformResponse] - " + state.getStatus());

		// Update the timer data based on received data
		updateTimer();

		log("[Controller]{processInformResponse} - Ended ");
	}

	private void processNewCtxResponse(InteractionState state,
			MMDispatcherEvent event) {
		log("[Controller]{processNewCtxResponse} - Started ");
		// -------------------- Mark as received ------------------------------
		state.setCurrentState(InteractionState.MC_REGISTER_RECEIVED);
		log("[Controller][processNewCtxResponse] - " + state.getStatus());

		// -------------------- Check received data and process it--------------
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// Check data
		int requestNo = cookieReader.getInt("requestNo", 1);
		requestNo--;
		Map<String, String> serviceResponse = Parser.parseReceivedData(event
				.getData());
		String validationResult = Validator.validate(serviceResponse, "r"
				+ requestNo);
		if (!validationResult.equalsIgnoreCase("OK")) {
			System.err.println("Crash: message is not well formed,"
					+ " sytem cannot continue: " + validationResult);
		}

		// Process it
		String returnedState = stateManager
				.processNewCtxResponse(serviceResponse);

		// Update state
		state.setCurrentState(returnedState);
		log("[Controller][processNewCtxResponse] - " + state.getStatus());

		log("[Controller]{processNewCtxResponse} - Ended ");
	}

	public void processPauseRequest(String requestId) {
		log("[Controller]{processPauseRequest} - Started");
		// -------- Create PauseResponse, send it to the server-----------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String data = "{\"code\":\"" + cookieReader.getInt("registerId", -1)
				+ "\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.PAUSE.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send start response to the server
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create Extension Notif
		spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		data = "{\"state\":\"MUST_UPDATE\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.EXTENSION_NOTIFICATION.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send it to the Interaction Manager
		interactionManager.processPauseRequest(spec);
		log("[Controller]{processPauseRequest} - Ended");
	}

	public void processPauseResponse(Spec msg) {
		log("[Controller]{processPauseResponse} - Started");
		log("[Controller]{processPauseResponse} - Started, raw data: " + msg);
		// Place-holder.
		log("[Controller]{processPauseResponse} - Ended");
	}

	private void processRegisterResponse(InteractionState state,
			MMDispatcherEvent event) {
		log("[Controller]{processRegisterResponse} - Started ");

		// -------------------- Mark as received and process it ---------------
		state.setCurrentState(InteractionState.MC_REGISTER_RECEIVED);
		log("[Controller][processRegisterResponse] - " + state.getStatus());

		// -------------------- Check received data ----------------------------
		// Get cookie reader
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// check data
		int requestNo = cookieReader.getInt("requestNo", 1);
		requestNo--;
		Map<String, String> serviceResponse = Parser.parseReceivedData(event
				.getData());
		String validationResult = Validator.validate(serviceResponse, "r"
				+ requestNo);
		if (!validationResult.equalsIgnoreCase("OK")) {
			System.err.println("Crash: message is not well formed,"
					+ " sytem cannot continue: " + validationResult);
		}

		// Process data
		String returnedState = dataComponent.saveRegisterInfo(serviceResponse);
		state.setCurrentState(returnedState);
		log("[Controller][processRegisterResponse] - " + state.getStatus());

		// Go to next step
		inform();
		log("[Controller]{processRegisterResponse} - Ended ");
	}

	public void processResumeRequest(String requestId) {
		log("[Controller]{processResumeRequest} - Started");
		// -------- Create ResumeResponse, send it to the server----------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String data = "{\"code\":\"" + cookieReader.getInt("registerId", -1)
				+ "\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.RESUME.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send start response to the server
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create Extension Notif
		spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		data = "{\"state\":\"MUST_UPDATE\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.EXTENSION_NOTIFICATION.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send it to the Interaction Manager
		interactionManager.processResumeRequest(spec);

		log("[Controller]{processResumeRequest} - Ended");
	}

	public void processResumeResponse(Spec msg) {
		log("[Controller]{processResumeResponse} - Started");
		log("[Controller]{processResumeResponse} - Started, raw data: " + msg);
		// Place-holder.
		log("[Controller]{processResumeResponse} - Ended");
	}

	public void processStartRequest(String requestId) {
		log("[Controller]{processStartRequest} - Started");
		// -------- Create StartResponse, send it to the server-----------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);
		// Create Start Response
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String data = "{\"code\":\"" + cookieReader.getInt("registerId", -1)
				+ "\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.START.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send start response to the server
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");

		// --------- Create Extension Notif, send to interactionManager---------
		// Create Extension Notif
		spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		spec.setRequestId(requestId);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		data = "{\"state\":\"MUST_UPDATE\"}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.EXTENSION_NOTIFICATION.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.SUCCESS.status());

		// Send it to the Interaction Manager
		interactionManager.processStartRequest(spec);
		log("[Controller]{processStartRequest} - Ended");
	}
	
	public void processStartResponse(Spec msg) {
		log("[Controller]{processStartResponse} - Started");
		log("[Controller]{processStartResponse} - Started, raw data: " + msg);
		// Place-holder.
		log("[Controller]{processStartResponse} - Ended");
	}

	private void sendNewCtxRequest() {
		log("[Controller][sendNewCtxRequest] - Started ");
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// -------------------- Create NewCtxRequest ---------------------------
		Spec spec = new Spec();
		int requestNo = cookieReader.getInt("requestNo", 1);

		spec.setMethod(globalConf.getString("operationOrchestrate",
				"MC_orchestrate"));
		spec.setSource(cookieReader.getString("registerID", null));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		log("[Controller][sendNewCtxRequest] -  requestId: r" + requestNo);
		spec.setRequestId("r" + requestNo);
		requestNo++;
		cookieReader.save("requestNo", "" + requestNo);

		spec.setTarget(globalConf.getString("serviceController", null));

		String data = "{\"code\":\""
				+ cookieReader.getString("registerID", null) + "\"}";
		spec.setData(data);
		spec.setType("" + MessageType.NEW_CONTEXT.status());

		spec.setConfidential(localConf.getBoolean("mc_confidential", false));

		// ----------------- Send NewCtxRequest to the server ------------------
		// Send the message
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");
		// Mark as sent
		state.setCurrentState(InteractionState.NEW_CONTEXT_REQUEST_SENT);
		log("[Controller]{sendRegister} - " + state.getStatus());

		log("[Controller][sendNewCtxRequest] - Ended ");
	}

	private void sendNotification() {
		log("[Controller]{sendNotification} - Started ");
		// -------------------- Create Notif Request---------------------------
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);
		// Create register Request
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationRegister", "MC_register"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo++;
		cookieReader.save("requestNo", "" + requestNo);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String data = "{state:" + InteractionState.HAS_INPUT + ", type:"
				+ MessageType.START + "}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.STATUS.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());

		// -------------------- Send Inform request ---------------------------
		// Send
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI");

		log("[Controller]{sendNotification} - Ended ");
	}

	public void sendRegister(String currentState) {
		log("[Controller][sendRegister] - Started. State: " + currentState);
		// Load config file
		ConfigurationReader globalConf = new ConfigurationReader(
				ConfigurationReader.GLOBAL_CONFIGURATION);
		ConfigurationReader localConf = new ConfigurationReader(
				ConfigurationReader.LOCAL_CONFIGURATION);
		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// -------------------- Create Register Request-------------------------
		Spec spec = new Spec();

		// Method, source, token
		spec.setMethod(globalConf.getString("operationRegister", "MC_register"));
		spec.setSource(localConf.getString("componentName", "MC_JavaComponent"));
		spec.setToken(globalConf.getString("defaultToken", "MC_1234"));

		// Request Id
		int requestNo = cookieReader.getInt("requestNo", 1);
		spec.setRequestId("r" + requestNo);
		requestNo++;
		cookieReader.save("requestNo", "" + requestNo);

		// Target, requestAutomatic update
		spec.setTarget(globalConf.getString("serviceRegister", null));
		spec.setRequestAutomaticUpdate(false);

		// Data
		String typeToSend = MessageType.STATUS.status();
		String urlToSend = "toto";
		String data = "{'state':'" + currentState + "'," + " 'metadata': '{"
				+ "'type':'" + typeToSend + "'," + "'url':'" + urlToSend
				+ "'}'}";
		spec.setData(data);

		// Type, confidential, context, status
		spec.setType("" + MessageType.STATUS.status());
		spec.setConfidential(localConf.getBoolean("mc_confidential", false));
		spec.setContext(globalConf.getString("defaultContext", "Unknown"));
		spec.setStatus("" + Status.LOAD.status());

		// ----------------- Send register request to the server ---------------
		mmDispatcher.sendAsynchronous(spec, "GET", "MMI"); // Send
		// Mark as sent
		state.setCurrentState(InteractionState.MC_REGISTER_SENT);
		log("[Controller]{sendRegister} - " + state.getStatus());

		log("[Controller][sendRegister] - Ended");
	}

	public void switchToCometMode() {
		log("[Controller][switchToCometMode] - Started ");
		String currentState = state.getCurrentState();
		isPullMode = false;
		if (currentState == InteractionState.PULL_MODE) {
			log("[Controller][switchToCometMode] - The system is "
					+ "already in COMET_MODE ");
		} else {
			state.setCurrentState(InteractionState.UI_UPDATE_SCHEDULED);
			log("[Controller][switchToCometMode] - System changed "
					+ "to  COMET_MODE");
		}

		log("[Controller][switchToCometMode] - Ended ");
	}

	public void switchToPullMode() {
		log("[Controller][switchToPullMode] - Started ");
		String currentState = state.getCurrentState();
		isPullMode = true;
		if (currentState == InteractionState.PULL_MODE) {
			log("[Controller][switchToPullMode] - The system is "
					+ "already in PULL_MODE");
		} else {
			state.setCurrentState(InteractionState.PULL_MODE);
			log("[Controller][switchToPullMode] - System changed "
					+ "to  PULL_MODE");
		}
		log("[Controller][switchToPullMode] - Ended ");
	}

	private void updateTimer() {
		log("[Controller]{updateTimer} - Started ");

		ConfigurationReader cookieReader = new ConfigurationReader(
				ConfigurationReader.COOKIE);

		// Read timer data
		long now = (new Date()).getTime();

		long sleep = cookieReader.getLong("begin", 0) - now;
		if (sleep < 1000)
			sleep = 0; // less than one second

		long lifeTime = cookieReader.getLong("end", 0) - now;
		if (lifeTime < 1000)
			sleep = 0; // less than one second

		long interval = cookieReader.getLong("interval", 0);
		if (interval < 1000)
			sleep = 0; // less than one second

		// Hard-coding: for testing purpose, you should comment these
		// two lines.
		sleep = 0;
		interval = 1000;

		// Update timer
		timer.update(sleep, lifeTime, interval);

		log("[Controller]{updateTimer} - Ended ");
	}
	
}
