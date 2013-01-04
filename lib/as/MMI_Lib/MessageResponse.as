package MMI_Lib
{
	/**
	 * This class is used to construct message responses.
	 */ 
	public class MessageResponse extends MessageBase
	{
		//*******************************************************************************************
		// Data
		//*******************************************************************************************
		// Non normalized
		private var deliveryMode: String; 
		private var isDelivered: Boolean;
		
		// Normalized
		private var status: String; 
		private var statusInfo: String;
		
		// Optional
		private var immediate : Boolean = false;
		private var automaticUpdate: Boolean = false; 
		
		//*******************************************************************************************
		// Constructor
		//*******************************************************************************************
		public function MessageResponse (spec : Spec) {
			super(spec);
			this.setDeliveryMode(spec.getDeliveryMode());
			this.setDelivered(spec.getDelivered());
			this.setStatus(spec.getStatus());
			this.setStatusInfo(spec.getStatusInfo());
			
			if (deliveryMode == null || deliveryMode == "")
				throw new Error(Exception.DELIVERY_MODE_EMPTY);
			
			if (deliveryMode == null || deliveryMode == "")
				throw new Error(Exception.DELIVERY_MODE_EMPTY);
			
			if (deliveryMode == null || deliveryMode == "")
				throw new Error(Exception.DELIVERY_MODE_EMPTY);
		}
		
		//*******************************************************************************************
		// Getter and Setter
		//*******************************************************************************************
		public function getDeliveryMode () : String {
			return deliveryMode; 
		}
		public function setDeliveryMode (deliveryMode: String) {
			this.deliveryMode = deliveryMode;
		}
		
		public function isDelivered () : Boolean {
			return isDelivered; 
		}
		public function setDelivered (delivered: String) {
			this.isDelivered = delivered;
		}
		
		public function getStatus () : String {
			return status; 
		}
		public function setStatus (status: String) {
			this.status = status;
		}
		
		public function getStatusInfo () : String {
			return statusInfo; 
		}
		public function setStatusInfo (statusInfo: String) {
			this.statusInfo = statusInfo;
		}
		
		public function isImmediate () : Boolean {
			return immediate;
		}
		public function setImmediate (immediate: Boolean) {
			this.immediate = immediate;
		}
		
		public function isAutomaticUpdate () : Boolean {
			return this.automaticUpdate; 
		}
		public function setAutomaticUpdate (automaticUpdate: Boolean) {
			this.automaticUpdate = automaticUpdate;
		}
		
	 
	}
}