var Timer = function (aSleep, aLifeTime, anInterval) {
	var timer ={};
	var lifeTime;
	var interval; 
	var sleep; 
	var counter; 
	var t; // timer
	
	
	if (aSleep) {
		sleep = aSleep;
	} else {
		sleep = 0;
	}
	
	if (aLifeTime) {
		lifeTime = aLifeTime;
	} else {
		lifeTime = 0;
	}
	
	if (anInterval) {
		interval = anInterval;
	} else {
		interval = 0;
	}
	
	timer.getLifeTime = function () {
		return lifeTime;
	}
	
	timer.setLifeTime = function (aLifeTime) {
		lifeTime = aLifeTime;
	}
	
	timer.getCounter = function () {
		return counter;
	}
	timer.setCounter = function (aCounter) {
		counter = aCounter;
	}
	
	timer.getInterval = function () {
		return interval;
	}
	
	timer.setInterval = function (anInterval) {
		interval = anInterval;
	}
	
	timer.getSleep = function () {
		return sleep;
	}
	
	timer.setSleep = function (aSleep) {
		sleep = aSleep;
	}
	timer.getTimer = function () {
		return t;
	}
	
	timer.start = function () { 
		if (lifeTime <= 0) {
			console.log("[Timer]{start} Lifetime: "+ lifeTime + " (ms)");				
			return;
		}
		console.log("[Timer]{start} Sleep: "+ sleep + " (ms) before starting");
		if (sleep > 0) {
			setTimeout(timer.onSleepElapsed, sleep);
		}
		else {
			counter = Math.floor(lifeTime / interval);
			timer.setCounter(counter);
			t = setInterval(function () {
						timer.setCounter(timer.getCounter() - 1);
						if (timer.getCounter() == 0) {
							timer.stop();
						} else
							timer.onTimerElapsed();
					}, interval);
			
			console.log("[Timer]{start} Timer Launched with \nLifeTime: " + lifeTime + " (ms)  \nRepeatCounter: " + counter+" \nInterval: " + interval + " (ms)");		
		}
	}
	
	timer.update = function (aSleep, aLifeTime, anInterval) {
		var repeatCount;
		var f; // to store listener function
		sleep = aSleep;
		lifeTime = aLifeTime;
		interval = anInterval;
		
		if (lifeTime <= 0) {
			console.log("[Timer]{start} Lifetime: "+ lifeTime + " (ms). Timer will not be updated");				
			return;
		}
		
		if (lifeTime <= 0) {
			console.log("[Timer]{start} Interval: "+ interval + " (ms). Timer will not be updated");				
			return;
		}
		
		repeatCount = lifeTime/interval;
		repeatCount = Math.floor(repeatCount);
		timer.stop(); // Stop the current Timer
		
		timer.start(); // Start the updated Timer
		
	}
	
	timer.onSleepElapsed = function () {
		console.log("[Timer][onSleepElapsed] - Started");
		t = setInterval(function () {
						timer.setCounter(timer.getCounter() - 1);
						if (timer.getCounter() == 0) 
							clearInterval(self.timer);
						else
							timer.onTimerElapsed();
				}, interval);
		
		console.log("[Timer]{start} Timer Launched with \nLifeTime: " + lifeTime + " (ms)  \nRepeatCounter: " + counter+" \nInterval: " + interval + " (ms)");
 
	}
	
	timer.onTimerElapsed = function () {
		console.log("[Timer]{onTimerElapsed} observe again");
		// Will be overrided. 
	}
	
	timer.stop = function () {
		console.log("[Timer]{stop} clear timer");
		clearInterval(t); 
	}
	return timer;
}






