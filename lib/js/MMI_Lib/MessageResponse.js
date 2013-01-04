/**
 * responseBase class
 * 
 * @param spec
 *            The spec object contains all of the information messageBase. the
 *            constructor needs to make an instance
 * @returns a new responseBase object
 */
interaction.messageResponse = function(spec) { 
	console.log("[MessageResponse][messageResponse] - Started ");
	var messageBase = this.messageBase(spec); 
	// private attributes
	// non-normalized
	var deliveryMode = spec.deliveryMode;
	var isDelivered = spec.isDelivered;
	
	// normalized
	var status = spec.status;
	var method = spec.method;
	var statusInfo = spec.statusInfo;
	
	// getter and setter functions
	messageBase.setDeliveryMode = function(aDeliveryMode) {
		deliveryMode = aDeliveryMode;
	};
	messageBase.getDeliveryMode = function() {
		return deliveryMode;
	};
	
	messageBase.setDelivered = function(delivered) {
		isDelivered = delivered;
	};
	messageBase.isDelivered = function() {
		return isDelivered;
	};
	
	messageBase.setStatus = function(aStatus) {
		state = aStatus;
	};
	messageBase.getStatus  = function() { 
		return status;
	}; 
	
	messageBase.setMethod = function(aMethod) {
		method = aMethod;
	};
	messageBase.getMethod = function() {
		return method;
	};
	
	messageBase.setStatusInfo = function(aStatusInfo) {
		statusInfo = aStatusInfo;
	};
	messageBase.getStatusInfo = function() {
		return statusInfo;
	};
	
	if (typeof status == "undefined") {
		throw "[MessageResponse][messageResponse]" + exception.STATUS_EMPTY;
	};
 	console.log("[MessageResponse][messageResponse] - Started ");
	return messageBase;
};