package MMI_Lib
{
	/**
	 * This class is used to create the notification
	 */ 
	public class Notification extends MessageBase
	{
		var name : String; 
		var status : String; 
		var statusInfo : String; 

		public function Notification(spec:Spec)
		{
			super(spec);
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
		
		public function getName () : String {
			return name; 
		}
		public function setName (name: String) {
			this.name = name;
		}
		 
	}
}