package Architecture
{
	import MMI_Lib.Spec;
	
	import flash.events.Event;

	public class InteractionEvent extends Event
	{	
		public static const BEFORE_NEW_CTX_REQUEST_SENT : String = "BEFORE_NEW_CTX_REQUEST_SENT";
		public static const ON_NEW_CTX_REQUEST_SENT : String = "ON_NEW_CTX_REQUEST_SENT";
		public static const ON_HAVING_CONTEXT : String = "ON_HAVING_CONTEXT";
		public static const ON_UI_UPDATE_SENT : String = "ON_UI_UPDATE_SENT";
		public static const ON_PROCESS_START_REQUEST : String = "ON_PROCESS_START_REQUEST";
		public static const ON_PROCESS_PAUSE_REQUEST : String = "ON_PROCESS_PAUSE_REQUEST";
		public static const ON_PROCESS_RESUME_REQUEST : String = "ON_PROCESS_RESUME_REQUEST";
		public static const ON_PROCESS_CANCEL_REQUEST : String = "ON_PROCESS_CANCEL_REQUEST";
		public static const ON_PROCESS_CLEAR_CTX_REQUEST : String = "ON_PROCESS_CLEAR_CTX_REQUEST";
		
		public static const HAS_CONTEXT 		: String = "HAS_CONTEXT";
		public static const STARTED 			: String = "STARTED";
		public static const PAUSED  			: String = "PAUSED";
		public static const RESUMED 			: String = "RESUMED";
		public static const CANCELED			: String = "CANCELED";
		
		public static const START_SCHEDULED 	: String = "START_SCHEDULED";
		public static const PAUSE_SCHEDULED 	: String = "PAUSE_SCHEDULED";
		public static const RESUME_SCHEDULED 	: String = "RESUME_SCHEDULED";
		public static const CANCEL_SCHEDULED 	: String = "CANCEL_SCHEDULED"; 
		
		private var state : InteractionState;
		private var data : String; 
		private var metadata : String;
		private var msg : Spec;
		public function InteractionEvent(type : String, 
										 bubbles: Boolean = false, 
										 cancelable: Boolean = false) {
			super (type, bubbles, cancelable);
		}
		public function getObservationState () : InteractionState {
			return state;
		}
		public function setObservationState (aState : InteractionState) : void {
			state = aState;
		}
		
		public function getData() : String {
			return data;
		}
		
		public function setData(data: String) : void {
			this.data = data;
		}
		
		public function getMetadata() : String {
			return metadata;
		}
		
		public function getMessage() : Spec {
			return msg;
		}
		
		public function setMessage(msg: Spec) : void {
			this.msg = msg;
		}
		
		public function setMetadata(metadata: String) : void {
			this.metadata = metadata;
		}
		
		public override function clone():Event{
			return new InteractionEvent(type, bubbles, cancelable) as Event;
		}
	}
}