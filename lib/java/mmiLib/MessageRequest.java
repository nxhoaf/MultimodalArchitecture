package mmiLib;

import utilities.Loggable;

public class MessageRequest extends MessageBase implements Loggable {
	private String method;
	private String status;
	
	public MessageRequest() {
		super();
		this.method = "";
		this.status = "";
	}
	
	public String getMethod() {
		return method;
	}
	public void setMethod(String method) {
		this.method = method;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	
	
}
