var Parser = {
	parseReceivedData : function (data) { 
		console.log("[Parser]{parseReceivedData} " + data.toString());
		var first, last;	
		var content;
		var jsonData = {};
		var serviceResponse = {};
		// Remove outer-most {}
		data = data.substr(1, data.length - 2);
		first = data.indexOf("{");
		last = data.lastIndexOf("}");
		if (last <= (first + 1))
			return "";
		content = data.slice(first, last + 1);
		
		jsonData = eval("(" + content + ")");
		
		for(var propertyName in jsonData) {
			if (typeof jsonData[propertyName] != "object") {
				serviceResponse[propertyName] = jsonData[propertyName];
				console.log("[Parser]{parseReceivedData} " + propertyName + " = " + jsonData[propertyName]);
			}			 
		}
		
		for(var propertyName in jsonData.data) {
			if (typeof jsonData.data[propertyName] != "object") {
				serviceResponse[propertyName] = jsonData.data[propertyName];
				console.log("[Parser]{parseReceivedData} " + propertyName + " = " + jsonData.data[propertyName]);
			}
		}
		return serviceResponse;		
	}, 
	
	parseTimerData : function (timerData) {
		console.log("[Parser]{parseTimerData} parses timeout triplet ");	
		
		var parsedData = new Array();
		var now, sleepTime, duration, interval; 
		timerData = timerData.substr(1, timerData.length - 2); // // Get data, exclude { and }
		parsedData = timerData.split("-"); 
		now = (new Date()).getTime();
		sleepTime = new Number(parsedData[0]);
		duration = new Number(parsedData[1]);
		interval = new Number(parsedData[2]);
		
		parsedData[0] = now + sleepTime;
		parsedData[1] = now + sleepTime + duration;
		parsedData[2] = interval; 
		return parsedData; 
	} , 
	 
	parseUrlArgs : function (urlArgs) {
		console.log("[Parser]{parseUrlArgs} urlArgs are \n"+urlArgs);
		var args = {}; // Start with an empty object
		var pairs = urlArgs.split("&");// Split at ampersands
		for(var i = 0; i < pairs.length; i++) {// For each fragment
			var pos = pairs[i].indexOf('='); // Look for "name=value"
			if(pos == -1)
				continue; // If not found, skip it
			var name = pairs[i].substring(0, pos); // Extract the name
			var value = pairs[i].substring(pos + 1); // Extract the value
			value = decodeURIComponent(value); // Decode the value
			args[name] = value;	// Store as a property
		}
		console.log("[Parser]{parseUrlArgs} - Ended ");
		return args;
		// Return the parsed arguments
	}

}
