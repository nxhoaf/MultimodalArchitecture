/**
 * Implementation of timer in svg, which based on animate object
 */
function createTimer(id) {
	console.log("[timer][createTimer] - Started ");
	xlinkns = 'http://www.w3.org/1999/xlink';
	defs = document.getElementById('defs');
	var timer = document.createElement('animate');
	timer.setAttribute('attributeName', 'visibility');
	timer.setAttribute('from', 'visible');
	timer.setAttribute('to', 'hidden');
	timer.setAttribute('dur', '0');
	timer.setAttribute('repeatCount', '0');
	timer.setAttribute('begin', 'indefinite');
	timer.setAttribute('id', id);
	defs.appendChild(timer);
	timer.duration = 0;
	timer.running = false;
	timer.value = 0;
	timer.loop = false;
	timer.nb_ticks = 1;
	timer.set = function(dur, ticks) {
		if(!ticks)
			ticks = 1;
		this.nb_ticks = ticks;
		this.duration = dur;
		this.setAttribute('dur', '' + dur / ticks);
		this.setAttribute('repeatCount', '' + ticks);
	}

	timer.start = function() {
		this.running = true;
		this.value = 0;
		this.fraction = 0;
		this.on_fraction(0);
		this.beginElement();
	}

	timer.on_fraction = function(value) {
	}
	timer.on_end = function(value) {
	}

	timer._on_end = function() {
		this.fraction = 1;
		this.on_fraction(timer.fraction);
		if(this.loop) {
			this.value = 0;
			this.beginElement();
		} else {
			this.running = false;
			this.on_end();
		}
	}
	timer.stop = function() {
		this.endElement();
	}

	timer._on_fraction = function() {
		timer.value++;
		timer.fraction = timer.value / timer.nb_ticks;
		timer.on_fraction(timer.fraction);
	}
	timer.addEventListener('repeatEvent', timer._on_fraction, false);
	timer.addEventListener('endEvent', timer._on_end, false);
	console.log("[timer][createTimer] - Ended ");
	return timer;
};