var Validator = {
	validate : function(serviceResponse, requestId) { 
		
		console.log("[Validator]{validate} =============================== MMI EVENT TYPE RECEIVED: "+getEventType(serviceResponse.type)+" code "+serviceResponse.type);
		var message = "";
		var type = "";
		if(serviceResponse.type == null) {
			message += exception.TYPE_EMPTY + "\n";
		} else {
			type = serviceResponse.type;
			message += "messageType: " + type + "\n";
			console.log("[Validator]{validate} Verifies Message base properties "); 
			if(serviceResponse.id == null)
				message += exception.REQUEST_ID_EMPTY + "\n";
			else {
				if(serviceResponse.id != requestId)
					message += "RequestId not matched, requestId: " + requestId 
					+ " received: " + serviceResponse.id +  "\n";
			}

			if(serviceResponse.source == null)
				message += exception.SOURCE_EMPTY + "\n";

			if(serviceResponse.target == null)
				message += exception.TARGET_EMPTY + "\n";

			if(serviceResponse.context == null)
				message += exception.CONTEXT_EMPTY + "\n"
			
			console.log("[Validator]{validate} Verifies Message response properties "); 
			if(serviceResponse.deliveryMode == null)
				message += exception.DELIVERY_MODE_EMPTY + "\n";

			// if(serviceResponse.delivery == null)
				// message += exception.IS_DELIVERED_EMPTY + "\n";

			if(serviceResponse.status == null)
				message += exception.STATUS_EMPTY + "\n";
			else {
					var currentStatus = serviceResponse.status;
				}
			
			console.log("[Validator]{validate} Verifies Specific properties "); 
			switch (type) {
				case messageType.STATUS :
					if(serviceResponse.automaticUpdate == null)
						message += exception.AUTOMATIC_UPDATE_EMPTY + "\n";

					break;

				case messageType.NEW_CONTEXT :
					// No more properties
					break;

				case messageType.PREPARE :
					// No more properties

					break;

				case messageType.START :
				// No more properties

				default :
					break;
			}

			// Don't have errors
			if(message == "messageType: " + type + "\n")
				message = "OK";
		}

		// Return validation result
		if(message == "")
			message = "OK";
		return message; 
	}
}
console.log("Observer_Lib loaded");