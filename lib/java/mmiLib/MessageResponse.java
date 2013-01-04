package mmiLib;

import utilities.Loggable;

public class MessageResponse extends MessageBase implements Loggable {
	private String deliveryMode;
	private Boolean isDelivery;
	private String status;
	private String method;
	private String statusInfo;
	
	public MessageResponse() {
		super();
		this.deliveryMode = "";
		this.isDelivery = true;
		this.status = "";
		this.method = "";
		this.statusInfo = "";
	}

	public String getDeliveryMode() {
		return deliveryMode;
	}

	public void setDeliveryMode(String deliveryMode) {
		this.deliveryMode = deliveryMode;
	}

	public Boolean getIsDelivery() {
		return isDelivery;
	}

	public void setIsDelivery(Boolean isDelivery) {
		this.isDelivery = isDelivery;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getMethod() {
		return method;
	}

	public void setMethod(String method) {
		this.method = method;
	}

	public String getStatusInfo() {
		return statusInfo;
	}

	public void setStatusInfo(String statusInfo) {
		this.statusInfo = statusInfo;
	}
	
	
}
