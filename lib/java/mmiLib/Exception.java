package mmiLib;

public enum Exception {
	CONFIDENTIAL_EMPTY(0, "confidentialEmpty"),
	CONTEXT_EMPTY(1, "contextEmpty"),
	DATA_EMPTY(2, "dataEmpty"),
	DELIVERY_MODE_EMPTY(3, "deliveryModeEmpty"),
	IMMEDIATE_EMPTY(4, "immediateEmpty"),
	IS_DELIVERED_EMPTY(5, "isDeliveredEmpty"),
	MEDIA_EMPTY(6, "mediaEmpty"),
	METHOD_EMPTY(7, "methodEmpty"),
	NAME_EMPTY(8, "nameEmpty"),
	REQUEST_ID_EMPTY(9, "requestIdEmpty"),
	SOURCE_EMPTY(10, "sourceEmpty"),
	STATUS_EMPTY(11, "statusEmpty"),
	STATUS_INFO_EMPTY(12, "statusInfoEmpty"),
	TARGET_EMPTY(13, "targetEmpty"),
	TYPE_EMPTY(14, "typeEmpty"), 
	AUTOMATIC_UPDATE_EMPTY(15, "automaticUpdateEmpty");
	
	private final int code;
	private final String description;
	
	Exception(int code, String description) {
		this.code = code;
		this.description = description;
	}
	
	public int getCode() {
		return code;
	}
	
	public String getDescription() {
		return description;
	}
}
