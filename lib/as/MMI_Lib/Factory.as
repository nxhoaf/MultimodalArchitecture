package MMI_Lib
{
	import mx.events.Request;
	import mx.messaging.MessageResponder; 
	
	public class Factory
	{
		include "../config.as"; 
		//*******************************************************************************************
		// Create Requests
		//*******************************************************************************************
		public static function createRequest (spec: Spec) : MessageRequest {
			var messageRequest : MessageRequest = new MessageRequest(spec);
			switch(spec.getType())
			{
				case MessageType.NEW_CONTEXT:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.CLEAR_CONTEXT:
					// Place-holder for future use.
					// We've already had all fields needed, do nothingg
					break;
				
				case MessageType.PREPARE:
					messageRequest.setContentUrl(spec.getContentUrl());
					messageRequest.setContent(spec.getContent());
					break;
				
				case MessageType.START:
					messageRequest.setContentUrl(spec.getContentUrl());
					messageRequest.setContent(spec.getContent());
					break;
				
				case MessageType.CANCEL:
					messageRequest.setContentUrl(spec.getContentUrl());
					messageRequest.setContent(spec.getContent());
					
					// Handling exception
					if (spec.getImmediate() == "null") {
						throw new Error(Exception.IMMEDIATE_EMPTY);
					}
					messageRequest.setImmediate(spec.getImmediate());
					break;
				
				case MessageType.PAUSE:
					messageRequest.setContentUrl(spec.getContentUrl());
					messageRequest.setContent(spec.getContent());
					
					// Handling exception
					if (spec.getImmediate() == "null") {
						throw new Error(Exception.IMMEDIATE_EMPTY);
					}
					messageRequest.setImmediate(spec.getImmediate());
					break;
				
				case MessageType.RESUME:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.STATUS: 
					messageRequest.setAutomaticUpdate(spec.getAutomaticUpdate());
					break;
				
				default:
				{
					break;
				}
					messageRequest.setType(spec.getType());
					return messageRequest;
			}
		}
		
		//*******************************************************************************************
		// Create Responses
		//*******************************************************************************************
		public static function createResponse (spec: Spec) : MessageResponse {
			var messageResponse : MessageResponse = new MessageResponse(spec);
			
			switch(spec.getType())
			{
				case MessageType.NEW_CONTEXT:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.CLEAR_CONTEXT:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.PREPARE:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.START:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.CANCEL:
					// Handling exception
					if (spec.getImmediate() == "null") {
						throw new Error(Exception.IMMEDIATE_EMPTY);
					}
					messageResponse.setImmediate(spec.getImmediate());
					break;
				
				case MessageType.PAUSE:
					// Handling exception
					if (spec.getImmediate == "null") {
						throw new Error(Exception.IMMEDIATE_EMPTY);
					}
					messageResponse.setImmediate(spec.getImmediate());
					break;
				
				case MessageType.RESUME:
					// Place-holder for future use.
					// We've already had all fields needed, do nothing
					break;
				
				case MessageType.STATUS:
					messageResponse.setAutomaticUpdate(spec.getAutomaticUpdate());
					break;
				
				default:
				{
					break;
				}
					
					messageResponse.setType(spec.getType());
					return messageResponse;
					
			}
		}
		
		//*******************************************************************************************
		// Create Notification
		//*******************************************************************************************
		public static function createNotification (spec: Spec) : Notification {
			var notification : Notification = new Notification(spec);
			switch(spec.getType())
			{
				case MessageType.EXTENSION_NOTIFICATION:
					// exception
					if (typeof spec.getName() == null || spec.getName() == "" )
						throw new Error(Exception.NAME_EMPTY);
					notification.setName(spec.getName());
					break;
				
				case MessageType.DONE_NOTIFICATION:
					// exception
					if (spec.getStatus() == null || spec.getStatus() == "" ) 
						throw new Error(Exception.STATUS_EMPTY);
					notification.setStatus(spec.getStatus());
					notification.setStatusInfo(spec.getStatusInfo());
					break;
				
				default:
				{
					break;
				}
					notification.setType(spec.getType());
					return notification;
			}
		}
	}
	
}
