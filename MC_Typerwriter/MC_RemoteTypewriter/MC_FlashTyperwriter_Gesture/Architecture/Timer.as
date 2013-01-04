package Architecture
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Timer
	{
		//**********************************************************************
		// Attributes, Varables and Constants
		//**********************************************************************
		private var lifeTime : Number; // Life time in miliseconds
		// Interval between two request consecutive
		private var interval : Number; 
		private var sleep : Number; // Sleep time before sending first message
		private var timer : flash.utils.Timer; 
		private var listeners : Array;
		//**********************************************************************
		// Getter and Setter functions
		//**********************************************************************
		public function getLifeTime() : Number {
			return lifeTime;
		}
		public function setLifeTime(lifeTime : Number) : void {
			this.lifeTime = lifeTime;
		}
		
		public function getInterval() : Number {
			return this.interval;
		}
		public function setInterval(interval : Number) : void {
			this.interval = interval;
		}
		
		private function getSleep() : Number {
			return this.sleep;
		}
		private function setSleep(sleep : Number) : void {
			this.sleep = sleep;
		}
		//**********************************************************************
		// Public functions
		//**********************************************************************
		
		public function Timer(sleep : int = 0, 
							  lifeTime : int = 0, 
							  interval : int = 0) {
			trace("[Timer][start] - Timer created");
			var repeatCount : Number;
			listeners = new Array();
			this.sleep = sleep;
			this.interval = interval;
			this.lifeTime = lifeTime;
			
			if (lifeTime <= 0 || interval <= 0) {
				repeatCount = 1;
				interval = 1;
			} else {
				repeatCount = lifeTime / interval;
				repeatCount = Math.floor(repeatCount);
			}
			
			timer = new flash.utils.Timer(interval,repeatCount);			
			
		}
		
		public function update(sleep : int = 0, 
							   lifeTime : int = 0, 
							   interval : int = 0) : void {
			var repeatCount : Number;
			this.sleep = sleep;
			this.interval = interval;
			this.lifeTime = lifeTime;
			
			if (lifeTime <= 0) {
				trace("Lifetime = " + lifeTime + " timer will not be updated");
				return;
			};
			
			if (interval <= 0) {
				trace("Interval = " + interval + " timer will not be updated");
				return;
			}
			
			repeatCount = lifeTime / interval;
			timer.stop();
			
			timer = new flash.utils.Timer(interval,repeatCount);
			var i : int;
			var f : Function;
			for (i = 0; i < listeners.length; i++) {
				f = listeners[i] as Function;
				timer.addEventListener(TimerEvent.TIMER, f);
			}
			
//			timer.start();
			start();
			trace("[Timer][update] - Started");
			trace("[Timer][update] - LifeTime: " + lifeTime + " (ms)");
			trace("[Timer][update] - "+
						"RepeatCounter: " + Math.floor(lifeTime / interval));				
			trace("[Timer][update] - Inverval: " + interval + " (ms)");				
		}
		
		public function start() : void {
			if (lifeTime <= 0) {
				trace("Lifetime = " + lifeTime + " timer will not be started");
				return;
			}
			
			if (interval <= 0) {
				trace("Interval = " + interval + " timer will not be started");
				return;
			}
			
			trace("[Timer][start] - Sleep: "+ sleep + " (ms) before starting");
			if (sleep > 0) {
				var sleepTimer : flash.utils.Timer = 
							new flash.utils.Timer(sleep,1);
				sleepTimer.addEventListener(TimerEvent.TIMER, onSleepElapsed);
				sleepTimer.start();
			} else {
				timer.start();
				trace("[Timer][start] - Started");
				trace("[Timer][start] - LifeTime: " + lifeTime + " (ms)");
				trace("[Timer][start] - "+
						"RepeatCounter: " + Math.floor(lifeTime / interval));				
				trace("[Timer][start] - Inverval: " + interval + " (ms)");
				
			}
			function onSleepElapsed() : void {
				timer.start();
				trace("[Timer][start] - Started");
				trace("[Timer][start] - LifeTime: " + lifeTime + " (ms)");
				trace("[Timer][start] - "+
						"RepeatCounter: " + Math.floor(lifeTime / interval));				
				trace("[Timer][start] - Inverval: " + interval + " (ms)");
			}
		}
		
		public function stop() : void {
			trace("[Timer][stop] - Started");
			timer.stop();
			trace("[Timer][stop] - Ended");
		}
		
		public function addEventListener(timerEvent : String, 
										 listener: Function) : void {
			timer.addEventListener(timerEvent, listener);
			listeners.push(listener);
		}
		public function removeEventListener(timerEvent : String, 
											listener: Function) : void {
			timer.removeEventListener(timerEvent, listener);
			listeners.splice(listeners.indexOf(listener),1);
		}
	}
}