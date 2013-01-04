var interaction = {};
/**
* messageBase class
* 
* @param spec
*            The spec object contains all of the information that the
*            constructor needs to make an instance
* @returns a new eventBase objectZ
*/
interaction.messageBase = function(spec) { 
	console.log("[MessageBase]{interaction.messageBase} created with the other features ");
	
		var message = {};
		//private attributes
		// non-normalized attributes
		var api = spec.api;  
		var type = spec.type;
		var metadata = spec.metadata;
		var token = spec.token;
		
		
		// normalized-attributes
		var requestId = spec.requestId;
		var source = spec.source;
		var target = spec.target;
		var data = spec.data;
		var context = spec.context;
		var confidential = spec.confidential; 
 
		// getter and setter functions
		message.setApi= function(aApi) { 
			api = aApi;
		};  
		message.getApi = function() {
			return api;
		};
		
		message.setType = function(aType) { 
			type = aType;
		};  	
		message.getType = function() {
			return type;
		};

		message.setMetadata = function(aMetadata) {
			metadata = aMetadata;
		}
		message.getMetadata = function() {
			return metadata;
		}
		
		message.setToken = function(aToken) {
		token = aToken;
		};		
		message.getToken = function() {
		return token;
		};
		
		// read-only attribute
		message.getRequestId = function() {
		return requestId;
		};

		message.setSource = function(aSource) {
			source = aSource;
		};	
		message.getSource = function() {
		return source;
		};

		message.setTarget = function(aTarget) {
		target = aTarget;
		};
		message.getTarget = function() {
			return target;
		};

		message.setData = function(aData) {
			data = aData;
		};
		message.getData = function() {
			return data;
		};

		message.setContext = function (aContext) {
			context = aContext;
		};		
		message.getContext = function () {
			return context;
		};

		message.setConfidential = function (aConfidential) {
			confidential = aConfidential;
		};
		message.getConfidential = function () {
			return confidential;
		};
		
		// handling exceptions
		// non-normalized
			
		// normalized
		if (typeof requestId == "undefined") {
			throw exception.REQUEST_ID_EMPTY;
		};
		
		if (typeof source == "undefined") {
			throw exception.SOURCE_EMPTY;
		};

		if (typeof target == "undefined") {
			throw exception.TARGET_EMPTY;
		}; 

		// if (typeof context == "undefined") {
			// throw exception.CONTEXT_EMPTY;
		// } 
		
		return message;  	
}