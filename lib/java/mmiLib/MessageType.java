package mmiLib;

public enum MessageType {
	NEW_CONTEXT("0"),
	CLEAR_CONTEXT("1"),
	PREPARE("2"),
	START("3"),
	CANCEL("4"),
	PAUSE("5"),
	RESUME("6"),
	STATUS("7"),
	EXTENSION_NOTIFICATION("8"),
	DONE_NOTIFICATION("9"), 
	UI_UPDATE("10");
	
	private final String status;
	
	MessageType(String status) {
		this.status = status;
	}
	
	public String status(){  
        return this.status;  
    }  
}
