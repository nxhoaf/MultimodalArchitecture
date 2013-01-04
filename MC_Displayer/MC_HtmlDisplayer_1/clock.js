console.log("Clock.js loaded");

var Clock = function(spec) {
	var that = {};

	// Hour, second, minute counters.
	var seconds = 0;
	var hours = 0;
	var minutes = 0;
	// Html element for displaying
	
	var hourPlaceHolder = spec.hourId;
	var minutePlaceHolder = spec.minuteId;
	var secondPlaceHolder = spec.secondId;

	var t; // timer
	var isStarted = false;

	that.getTime = function() {
		var time = 	that.normalize(hours) + " : " + 
					that.normalize(minutes) + " : " + 
					that.normalize(seconds) ;
		return time;
	}
	
	that.updateClock = function () {
		seconds += 1;
		if(seconds >= 60) {
			seconds -= 60;
			minutes += 1;
		}
		if(minutes >= 60) {
			minutes -= 60;
			hours += 1;
		}
	}
	
	that.start = function() {
		console.log("[clock.js][start] - Started ");
		if (!isStarted) {
			isStarted = true;
			t = setInterval(that.run, 1000);	
		} else {
			console.log("[clock.js][start] - Clock has already been started ");
		}
		
		console.log("[clock.js][start] - Ended ");
	};
	that.run = function() {
		that.updateClock();
		document.getElementById(hourPlaceHolder)
								.innerHTML = that.normalize(hours);
		document.getElementById(minutePlaceHolder)
								.innerHTML = that.normalize(minutes);
		document.getElementById(secondPlaceHolder)
								.innerHTML = that.normalize(seconds);
	}
	that.pause = function() {
		console.log("[clock.js][pause] - Started ");
		if (!isStarted) {
			console.log("[clock.js][pause] - Must start the clock first ");
			return;
		}
		isStarted = false;
		clearTimeout(t);
		console.log("[clock.js][pause] - Ended ");
	}
	
	that.resume = function () {
		console.log("[clock.js][resume] - Started ");
		if (!clearTimeout) {
			console.log("[clock.js][resume] - Must start the clock first ");
			return;
		}
		that.start();
		console.log("[clock.js][resume] - Ended ");
	}

	that.cancel = function() {
		console.log("[clock.js][cancel] - Started ");
		seconds = 0;
		hours = 0;
		minutes = 0;
		clearTimeout(t);
		document.getElementById(hourPlaceHolder)
								.innerHTML = that.normalize(hours);
		document.getElementById(minutePlaceHolder)
								.innerHTML = that.normalize(minutes);
		document.getElementById(secondPlaceHolder)
								.innerHTML = that.normalize(seconds);
		console.log("[clock.js][cancel] - Ended");
	}

	that.getState = function() {
		return state;
	}

	that.setState = function(aState) {
		state = aState;
	}
	/*
	 Adds a zero in front of minutes or seconds
	 */
	that.normalize = function (timeUnit) {
		if (timeUnit.toString().length == 1)
			return "0" + timeUnit;
		else return timeUnit;
	}

	return that;
};
Clock.UNKNOWN = "UNKNOWN";
Clock.STARTED = "STARTED";
Clock.PAUSED = "PAUSED";
Clock.RESUMED = "RESUMED";
Clock.CANCELED = "CANCELED";
Clock.EXITED = "EXITED";






















