package architecture;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import utilities.Loggable;

public class Timer implements ActionListener, Loggable{
	private long lifeTime;
	private long interval;
	private long sleep;
	private Boolean isStarted;
	private javax.swing.Timer timer;
	private List<TimerEventListener> listeners;
	
	public Timer() {
		this(0,0,0);
	}
	public Timer(long sleep, long lifeTimer, long interval) {
		log("[Timer][start] - Timer created");
		isStarted  = false;
		listeners = new ArrayList<TimerEventListener>();
		this.sleep = sleep;
		this.interval = interval;
		this.lifeTime = lifeTimer;
		if (lifeTimer <= 0) {
			log("Lifetime = " + lifeTime + " clock will not be started"); 
			timer = null;
		} else {
			timer = new javax.swing.Timer((int) interval, this);
		}
	}
	
	public void update(long sleep, long lifeTime, long interval) {
		log("[Timer][update] - Started");
		this.sleep = sleep;
		this.lifeTime = lifeTime;
		this.interval = interval;
		
		if (lifeTime <= 0) {
			log("Lifetime = " + lifeTime + " timer will not be updated");
			return;
		};
		
		if (interval <= 0) {
			log("Interval = " + interval + " timer will not be updated");
			return;
		}
		
		if (isStarted)
			timer.stop();
		timer = new javax.swing.Timer((int) interval, this);
		start();
		log("[Timer][update] - Started");
		log("[Timer][update] - LifeTime: " + lifeTime + " (ms)");
		log("[Timer][update] - "+
					"RepeatCounter: " + Math.floor(lifeTime / interval));				
		log("[Timer][update] - Inverval: " + interval + " (ms)");	
		log("[Timer][update] - ended");
	}
	
	public void start() {
		if (lifeTime <= 0) {
			log("[Timer][start] - Lifetime: "+ lifeTime + " (ms)");				
			return;
		}
		
		if (interval <= 0) {
			log("Interval = " + interval + " timer will not be started");
			return;
		}
		
		log("[Timer][start] - Sleep: "+ sleep + " (ms) before starting");
		
		if (sleep > 0) {
			javax.swing.Timer sleepTimer = 
					new javax.swing.Timer((int) sleep, new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					// TODO Auto-generated method stub
					timer.start();
					log("[Timer][start] - Started");
					log("[Timer][start] - LifeTime: " + lifeTime + " (ms)");				
					log("[Timer][start] - Inverval: " + interval + " (ms)");
				}
			});
			sleepTimer.setRepeats(false);
			sleepTimer.start();
		} else {
			timer.start();
			log("[Timer][start] - Started");
			log("[Timer][start] - LifeTime: " + lifeTime + " (ms)");				
			log("[Timer][start] - Inverval: " + interval + " (ms)");
		}
		isStarted = true;
	}
	
	public void stop() {
		log("[Timer][stop] - The timer is now stopping");
		timer.stop();
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		log("[Timer][actionPerformed] - fireEvent");	
		try {
			fireEvent();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

	public long getLifeTime() {
		return lifeTime;
	}

	public void setLifeTime(int lifeTime) {
		this.lifeTime = lifeTime;
	}

	public long getInterval() {
		return interval;
	}

	public void setInterval(int interval) {
		this.interval = interval;
	}

	public long getSleep() {
		return sleep;
	}

	public void setSleep(int sleep) {
		this.sleep = sleep;
	}

	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}
	
	public synchronized void addEventListener(TimerEventListener listener) {
		listeners.add(listener);
	}
	
	public synchronized void removeEventListener(TimerEventListener listener) {
		listeners.remove(listener);
	}
	
	private synchronized void fireEvent() throws IOException {
		Iterator<TimerEventListener> i = listeners.iterator();
		TimerEventListener listener;
		while (i.hasNext()) {
			listener = i.next();
			listener.onTimerElapsed();
		}
	}
}
