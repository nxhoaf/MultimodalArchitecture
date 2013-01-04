package main;

public class Event {
	private int startHour;
	private int endHour;
	private String room;
	private String description;
	
	public Event(int startHour, int endHour, 
					  String room, String description) {
		this.startHour = startHour;
		this.endHour = endHour;
		this.room = room;
		this.description = description;
	}

	public int getStartHour() {
		return startHour;
	}

	public void setStartHour(int startHour) {
		this.startHour = startHour;
	}

	public int getEndHour() {
		return endHour;
	}

	public void setEndHour(int endHour) {
		this.endHour = endHour;
	}

	public String getRoom() {
		return room;
	}

	public void setRoom(String room) {
		this.room = room;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
	public String toString() {
		StringBuffer result = new StringBuffer();
		result.append("\t Event: \n");
		result.append("\t\t Start: " + startHour + "h\n");
		result.append("\t\t End: " + endHour + "h\n");
		result.append("\t\t Room: " + room + "\n");
		result.append("\t\t Description: " + description + "\n");
		
		return result.toString();
	}
	
	public int compareTo(Event other) {
		// this is great than other
		if (this.startHour > other.startHour) {
			return 1;
		// this is less than other
		} else if (this.startHour < other.startHour) {
			return -1;
		} else {
		// startHour of this and other are equal
			
			// The longer an event take, the greater is be.
			if (this.endHour > other.endHour) {
				return 1;
			} else if (this.endHour < other.endHour) {
				return -1;
			} else {
			// If both start and end are the same, they're considered to be equal.
				return 0;
			}
		}
			
	}
}
