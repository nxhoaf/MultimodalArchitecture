package MMI_Lib
{
	public class MessageRequest extends MessageBase
	{
		//*******************************************************************************************
		// Data
		//*******************************************************************************************
		private var method : String;
		private var status : String;
		
		// Optional, they're null by default
		private var content : String = null; 
		private var contentUrl : String == null;
		private var immediate : Boolean == false;
		private var automaticUpdate: Boolean = false;
		
		
		//*******************************************************************************************
		// Constructor
		//*******************************************************************************************
		public function MessageRequest (spec: Spec) {
			super(spec);
			
			this.setMethod(spec.getMethod());
			this.setStatus(spec.getStatus());
		}
		
		
		//*******************************************************************************************
		// Getter and Setter
		//*******************************************************************************************
		public function getMethod () : String {
			return method; 
		}
		public function setMethod (method: String) {
			this.method = method;
		}
		public function getStatus () : String {
			return status; 
		}
		public function setStatus (status: String) {
			this.status = status;
		}
		
		// Optional 
		public function getContent () : String {
			return content; 
		}
		public function setContent (content: String) {
			this.content = content;
		}
		
		public function getContentUrl () : String {
			return contentUrl; 
		}
		public function setContentUrl (contentUrl: String) {
			this.contentUrl = contentUrl;
		}
		
		public function getImmediate () : Boolean {
			return this.immediate;
		}
		public function setImmediate (immediate : Boolean) {
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