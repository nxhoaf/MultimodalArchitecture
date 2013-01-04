var spec = function () {
	var that = {};
	
	var api;  
	var type;
	var metadata = metadata();
	var deliveryMode;
	var delivered;
	var method;
	
	// normalized-attributes
	var requestId;
	var source;
	var target;
	var data;
	var context;
	var confidential;
	var status;
	var statusInfo;
	var name;
	
	
	var content;
	var contentUrl;
	var immediate;
	var automaticUpdate = 0; // default
	// getter and setter functions
	that.setApi= function(aApi) { 
		api = aApi;
	};  

	that.getApi = function() {
		return api;
	};
	
	that.setType = function(aType) { 
		type = aType;
	};  
	
	that.getType = function() {
		return type;
	};

	that.setMetadata = function(aMetadata) {  	 
	   	metadata = aMetadata;

	};  
	that.getMetadata = function() {
		return metadata;
	};
	
	that.setDeliveryMode = function(aDeliveryMode) { 
		deliveryMode = aDeliveryMode;
	};  
	
	that.getDeliveryMode = function() {
		return deliveryMode;
	};
	
	that.setDelivered = function(aDelivered) {
		delivered = aDelivered;
	};
	that.getDelivered = function() {
		return delivered;
	};
	
	that.setMethod = function(aMethod) {
		method = aMethod;
	};
	that.getMethod = function() {
		return method;
	};
	

	
	that.getRequestId = function() {
		return requestId;
	};
	that.setRequestId = function (aRequestId) {
		requestId = aRequestId;
	};
	
	that.setSource = function(aSource) {
		source = aSource;
	};
	
	that.getSource = function() {
		return source;
	};

	that.setTarget = function(aTarget) {
		target = aTarget;
	};
	that.getTarget = function() {
		return target;
	};

	that.setData = function(aData) {
		data = aData;
	};
	that.getData = function() {
		return data;
	};
	
	that.setContext = function (aContext) {
		context = aContext;
	};
	that.getContext = function () {
		return context;
	};

	that.setConfidential = function (aConfidential) {
		confidential = aConfidential;
	};
	that.getConfidential = function () {
		return confidential;
	};
	that.setStatus = function(aStatus) {
		state = aStatus;
	};
 
	that.getStatus  = function() { 
		return status;
	}; 
	
	that.setStatusInfo = function(aStatusInfo) {
		statusInfo = aStatusInfo;
	};
	that.getStatusInfo = function() {
		return statusInfo;
	};
	
	that.setName = function(aName) {
		name = aName;
	};
	that.getName = function() {
		return name;
	};
	that.setContentUrl = function(aContentUrl) {
		contentUrl = aContentUrl;
	};
	that.getContentUrl = function() {
		return contentUrl;
	};
	
	that.setContent = function(aContent) {
		content = aContent;
	};
	that.getContent = function() {
		return content;
	};
	
	that.setImmediate = function(aImmediate) {
		immediate = aImmediate;
	};
	
	that.getImmediate = function() {
		return immediate;
	};
	
	that.setAutomaticUpdate = function(aAutomaticUpdate) {
		automaticUpdate = aAutomaticUpdate;
	};
	
	that.getAutomaticUpdate = function() {
		return automaticUpdate;
	};
	
	return that;
};
