package xhrLib;

import java.io.IOException;
import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.ning.http.client.AsyncCompletionHandler;
import com.ning.http.client.AsyncHttpClient;
import com.ning.http.client.Response;

import mmiLib.Spec;
import utilities.Loggable;

public class MMDispatcher implements Loggable {
	private AsyncHttpClient asyncHttpClient;
	private List<MMDispatcherEventListener> listeners;
	
	public MMDispatcher () {
		asyncHttpClient = new AsyncHttpClient();
		listeners = new ArrayList<MMDispatcherEventListener>();
	}
	
	public synchronized void addEventListener(MMDispatcherEventListener listener) {
		listeners.add(listener);
	}
	
	public synchronized void removeEventListener(MMDispatcherEventListener listener) {
		listeners.remove(listener);
	}
	
	private synchronized void fireEvent(MMDispatcherEvent event) throws IOException {
		Iterator<MMDispatcherEventListener> i = listeners.iterator();
		MMDispatcherEventListener listener;
		while (i.hasNext()) {
			listener = i.next();
			listener.processEvent(event);
		}
	}
	
	
	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}
	public void sendAsynchronous(Spec msg, String method, String kind){
		log("[MMDispatcher][sendAsynchronous] - Started");
		// Assign params to variable
		String requestMethod = method;
		String requestKind = kind;
		// Normalize
		requestMethod = requestMethod.toUpperCase();
		requestKind = requestKind.toUpperCase();
		
		try {
			if (requestKind.equals("XML")) {
				if(requestMethod.equals("GET")) {;
					msg.setApi("json");
					this.sendJsonRequest(msg);
				} else {
					msg.setApi("soap");
					this.sendSoapRequest(msg);
				}
			} else {
				if(requestMethod.equals("GET")) {
					msg.setApi("json_mmi");
					this.sendJsonRequest(msg);
				} else {
					msg.setApi("soap");
					this.sendSoapRequest(msg);
				}
			}
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		log("[MMDispatcher][sendAsynchronous] - Ended");
	}
	
	private void sendJsonRequest(Spec msg) throws IOException {
		log("[MMDispatcher][sendJsonRequest] - Started");
		String targetUrl = msg.getTarget();
		String fullUrl = addParamsToUrl(targetUrl, msg);
		log("[MMDispatcher][sendJsonRequest] - FullUrl: " + fullUrl);
		asyncHttpClient.prepareGet(fullUrl).execute(new AsyncCompletionHandler<Response>(){

	    	 @Override
		        public void onThrowable(Throwable t){
		            // Something wrong happened.
		        }
	    	
	        @Override
	        public Response onCompleted(Response response) throws Exception{
	            String data = response.getResponseBody();
	        	MMDispatcherEvent event = new MMDispatcherEvent(this, data);
	        	fireEvent(event);
	        	return response;
	        }

	       
	    });
		log("[MMDispatcher][sendJsonRequest] - Ended");
	}
	
	private String addParamsToUrl(String targetUrl, Spec msg) throws UnsupportedEncodingException {
		log("[MMDispatcher][addParamsToUrl] - Started");
		
		String fullUrl = "";
		
		// api
		if(!msg.getApi().isEmpty())
			fullUrl += "?api=" + URLEncoder.encode(msg.getApi(), "ISO-8859-1");
		
		// method
		if(!msg.getMethod().isEmpty())
			fullUrl += "&method=" + URLEncoder.encode(msg.getMethod(), "ISO-8859-1");
		
		// caller (source)
		if(!msg.getSource().isEmpty())
			fullUrl += "&caller=" + URLEncoder.encode(msg.getSource(), "ISO-8859-1");
		
		// token
		if(!msg.getToken().isEmpty())
			fullUrl += "&token=" + URLEncoder.encode(msg.getToken(), "ISO-8859-1");
				
		// requestId
		if(!msg.getRequestId().isEmpty())
			fullUrl += "&id=" + URLEncoder.encode(msg.getRequestId(), "ISO-8859-1");
		
		// metadata
		if(!msg.getMetadata().isEmpty())
			fullUrl += "&metadata=" + URLEncoder.encode(msg.getMetadata(), "ISO-8859-1");		
		
		// type
		if(!msg.getType().isEmpty())
			fullUrl += "&type=" + URLEncoder.encode(msg.getType(), "ISO-8859-1");
		
		// context
		if(!msg.getContext().isEmpty())
			fullUrl += "&context=" + URLEncoder.encode(msg.getContext(), "ISO-8859-1");
		
		// status
		if(!msg.getStatus().isEmpty())
			fullUrl += "&status=" + URLEncoder.encode(msg.getStatus(), "ISO-8859-1");
		
		// requestAutomaticUpdate
		if(msg.getAutomaticUpdate())
			fullUrl += "&requestAutomaticUpdate=1";
		
		// data
		if(!msg.getData().isEmpty())
			fullUrl += "&data=" + URLEncoder.encode(msg.getData(), "ISO-8859-1");
		
		fullUrl = targetUrl + fullUrl;
		log("[MMDispatcher][addParamsToUrl] - Ended");
		return fullUrl;
	}
	
	private void sendSoapRequest(Spec msg) {
		
	}
}
