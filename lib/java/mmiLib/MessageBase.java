package mmiLib;

import utilities.Loggable;

public class MessageBase implements Loggable{
	private String api;
	private String type;
	private String metadata;
	private String token;
	private String requestId;
	private String source;
	private String target;
	private String data;
	private String context;
	private String confidential;
	
	public MessageBase() {
		this.api = "";
		this.type = "";
		this.metadata = "";
		this.token = "";
		this.requestId = "";
		this.source = "";
		this.target = "";
		this.data = "";
		this.context = "";
		this.confidential = ""; 
	}
	
	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}

	public String getApi() {
		return api;
	}

	public void setApi(String api) {
		this.api = api;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getMetadata() {
		return metadata;
	}

	public void setMetadata(String metadata) {
		this.metadata = metadata;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public String getRequestId() {
		return requestId;
	}

	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getTarget() {
		return target;
	}

	public void setTarget(String target) {
		this.target = target;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public String getContext() {
		return context;
	}

	public void setContext(String context) {
		this.context = context;
	}

	public String getConfidential() {
		return confidential;
	}

	public void setConfidential(String confidential) {
		this.confidential = confidential;
	}

	
}
