package mmiLib;

public enum Status {
	UNKNOWN("-1"),
	DEAD("0"),
	SUCCESS("1"),
	ALIVE("1"),
	LOAD("2"),
	DESIGN("3");
	
	private final String status;
	
	Status(String status) {
		this.status = status;
	}
	
	public String status(){  
        return this.status;  
    } 
}
