package architecture;



import java.util.Map;

import mmiLib.Exception;
import mmiLib.MessageType;

public class Validator {
	public static String validate(Map<String, String> returnedValues, String requestId) {
		System.out.println("[Validator][validate] - Started ");
		String message = "";
		String type = "";
		if(returnedValues.get("type") == null) {
			message += Exception.TYPE_EMPTY + "\n";
		} else {
			type = returnedValues.get("type");
			message += "messageType: " + type + "\n";
			
			// ******************** Message base properties ********************
			if (returnedValues.get("id") == null)
				message += Exception.REQUEST_ID_EMPTY + "\n";
			else {
				if (!returnedValues.get("id").equalsIgnoreCase(requestId))
					message += "RequestId not matched: received: "+ returnedValues.get("id")
						+ " current: " + requestId + "\n";
					System.out.println("[Validator][validate] - returnedId: " + returnedValues.get("id") + 
							" currentId: " + requestId);
			}
				
			
			if (returnedValues.get("source") == null)
				message += Exception.SOURCE_EMPTY + "\n";			
			
			if (returnedValues.get("target") == null)
				message += Exception.TARGET_EMPTY + "\n";
			
			if (returnedValues.get("context") == null)
				message += Exception.CONTEXT_EMPTY + "\n";
			
			// ******************** Message response properties ********************
			if (returnedValues.get("deliveryMode") == null)
				message += Exception.DELIVERY_MODE_EMPTY + "\n";
			
			if (returnedValues.get("status") == null)
				message += Exception.STATUS_EMPTY + "\n";
			
			// ******************** Specific properties ********************
			if (type.equals(MessageType.STATUS.status())) {
				if (returnedValues.get("automaticUpdate") == null)
					message += Exception.AUTOMATIC_UPDATE_EMPTY + "\n";
			} else if (type.equals(MessageType.NEW_CONTEXT.status())) {
				// No more properties
			} else if (type.equals(MessageType.PREPARE.status())) {
				// No more properties
			} else if (type.equals(MessageType.START.status())) {
				// No more properties
			} else {
				// @Todo : default
			}
			
			
			// Don't have errors
			if (message.equals("messageType: " + type + "\n") )
				message = "OK";
			
		}
		System.out.println("[Validator][validate] - Ended ");
		return message;
	}
}
