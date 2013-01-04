package main;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DailyData {
	public static final String DAILY_DATA = "dailyData";
	
	private List<Event> dailyEvents;
	private Date date;
	
	public DailyData(List<Event> dailyEvents, String date, String format) {
            try {
                this.dailyEvents = dailyEvents;
                this.date = new SimpleDateFormat(format).parse(date);
            } catch (ParseException ex) {
                Logger.getLogger(DailyData.class.getName()).log(Level.SEVERE, null, ex);
            }
	}
	
	public DailyData(Date date) {
		dailyEvents = new LinkedList<Event>();
		this.date = date;
	}
	
	public void addDailyEvent(Event e) {
		if(dailyEvents == null && dailyEvents.isEmpty()) {
			dailyEvents.add(e);
		} else if (dailyEvents.size() == 1) {
			Event oldEvent = dailyEvents.get(0);
			
			// old Event is greater than new event
			if (oldEvent.compareTo(e) == 1) {
				dailyEvents.add(0, e);
			} else {
				dailyEvents.add(e);
			}
		} else {
			for (int i = 0; i < dailyEvents.size() - 1; i++ ) {
				Event before = dailyEvents.get(i);
				Event after = dailyEvents.get(i+1);
				// Found one position to add
				if (before.compareTo(e) < 0 && after.compareTo(e) >= 0) {
					dailyEvents.add(i+1, e);
					return;
				}
			}
			// Function not return yet, add to the end
			dailyEvents.add(e);
		}
	}
	
	public void removeDailyEvent(Event e) {
		dailyEvents.remove(e);
	}

	public List<Event> getEvents() {
		return dailyEvents;
	}

	public void setEvents(List<Event> dailyEvents) {
		this.dailyEvents = new LinkedList<Event>();
		for (int i = 0; i < dailyEvents.size(); i ++) {
			this.dailyEvents.add(dailyEvents.get(i));
		}
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}
	
	public String toString() {
		StringBuffer result = new StringBuffer();
		result.append("DailyData: \n" );
		result.append("\t Date: " + date.toString()  + "\n");
		result.append("\t Event in this day: \n" );
		for (int i = 0; i < dailyEvents.size(); i ++) {
			result.append(dailyEvents.get(i).toString());
		}
		return result.toString();
		
	}
	
}
