package mmiLib;

import utilities.Loggable;

public class Notification extends MessageBase implements Loggable {
	private String name;
	private String status;
	private String statusInfo;
	
	public Notification() {
		super();
		this.name = "";
		this.status = "";
		this.statusInfo = "";
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatusInfo() {
		return statusInfo;
	}

	public void setStatusInfo(String statusInfo) {
		this.statusInfo = statusInfo;
	}
	
	
}
