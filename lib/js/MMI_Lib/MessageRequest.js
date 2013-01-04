/**
 * messageRequest class
 * 
 * @param spec
 *            The spec object contains all of the information that the
 *            constructor needs to make an instance
 * @returns a new requestBase object
 */
interaction.messageRequest = function(spec) { 
 	console.log("[MessageRequest]{interaction.messageRequest} created with status and method features ");
	var messageBase = this.messageBase(spec);  
 
	// private attributes
	// non-normalized attributes
	var method = spec.method;
	var status = spec.status;


	// getter and setter functions
	messageBase.setMethod = function(aMethod) {
		method = aMethod;
	};
	messageBase.getMethod = function() {
		return method;
	};
	
	messageBase.setStatus = function(aStatus) {
		state = aStatus;
	};
	messageBase.getStatus  = function() { 
		return status;
	};

	// Excepction handling
	if (typeof method == "undefined") {
		throw exception.METHOD_EMPTY;
	};
	return messageBase;  

}