package Architecture
{
	import MMI_Lib.Exception;
	import MMI_Lib.MessageType;
	import MMI_Lib.Status;
	
	import flash.net.URLVariables;

	public class Validator
	{
		public function Validator()
		{
		}
		public static function validate(serviceResponse : URLVariables, requestId : String) : String {
			var message : String = "";
			var type : String;
			
			if (serviceResponse.type == null) {
				message += Exception.TYPE_EMPTY + "\n";
			} else {
				type = serviceResponse.type;
				message += "messageType: " + type + "\n";
				
				// ******************** Message base properties ********************
				if (serviceResponse.id == null)
					message += Exception.REQUEST_ID_EMPTY + "\n";
				else {
					if (serviceResponse.id != requestId)
						message += "RequestId not matched" + "\n";
				}
					
				
				if (serviceResponse.source == null)
					message += Exception.SOURCE_EMPTY + "\n";			
				
				if (serviceResponse.target == null)
					message += Exception.TARGET_EMPTY + "\n";
				
				if (serviceResponse.context == null)
					message += Exception.CONTEXT_EMPTY + "\n";
				
				// ******************** Message response properties ********************
				if (serviceResponse.deliveryMode == null)
					message += Exception.DELIVERY_MODE_EMPTY + "\n";
				
				if (serviceResponse.status == null)
					message += Exception.STATUS_EMPTY + "\n";
				
		
				// ******************** Specific properties ********************
				switch (type) {
					case MessageType.STATUS :
						if (serviceResponse.automaticUpdate == null)
							message += Exception.AUTOMATIC_UPDATE_EMPTY + "\n";
				
						break;
					
					case MessageType.NEW_CONTEXT : 
						// No more properties
						break;
					
					case MessageType.PREPARE : 
						// No more properties
						
						break;
					
					case MessageType.START : 
						// No more properties
					
					default : 
						break;
				}
				
				// Don't have errors
				if (message == "messageType: " + type + "\n")
					message = "OK";
			}
			
			// Return validation result
			if (message == "") 
				message = "OK";
			return message;
		}
	}
}