/**
 * notification class
 * 
 * @param spec
 *            The spec object contains all of the information that the
 *            constructor needs to make an instance
 * @returns a new notification object
 */
interaction.notification = function (spec) {
	console.log("[Notification]{interaction.notification} - Started");
	var messageBase = this.messageBase(spec);
	
	// private attribute
	var method = spec.method;
	var name = spec.name;
	var status = spec.status;
	var statusInfo = spec.statusInfo;
	// getter and setter functions
	messageBase.setName = function(aName) {
		name = aName;
	};
	messageBase.getName = function() {
		return name;
	};
	
	messageBase.setStatus = function(aStatus) {
		status = aStatus;
	};
	messageBase.getStatus = function() {
		return status;
	};
	
	messageBase.setStatusInfo = function(aStatusInfo) {
		statusInfo = aStatusInfo;
	};
	messageBase.getStatusInfo = function() {
		return statusInfo;
	};
	
	// getter and setter functions
	messageBase.setMethod = function(aMethod) {
		method = aMethod;
	};
	messageBase.getMethod = function() {
		return method;
	};
	console.log("[Notification]{interaction.notification} - Ended");
	return messageBase;
}












