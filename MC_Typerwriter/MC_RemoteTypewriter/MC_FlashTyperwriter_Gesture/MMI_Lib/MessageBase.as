package MMI_Lib
{
	public class MessageBase
	{
		
		//*******************************************************************************************
		// Data
		//*******************************************************************************************
		// Non-normalized attributes
		private var api : String; 
		private var type : String; 
		private var metadata : String;
		
		// Normalized attributes
		private var requestId : Number; 
		private var source : String;
		private var target : String; 
		private var data : String; 
		private var context : String; 
		private var confidential : String;
		
		//*******************************************************************************************
		// Constructor
		//*******************************************************************************************
		public function MessageBase(spec: Spec) {
			// Init value
			this.setApi(spec.getApi());
			this.setType(spec.getType());
			this.setMetadata(spec.getMetadata());
			
			this.setRequestId(spec.getRequestId());
			this.setSource(spec.getSource());
			this.setTarget(spec.getTarget());
			this.setData(spec.getData());
			this.setContext(spec.getContext());
			this.setConfidential(spec.getConfidential());
			
			// Throw exception if any
			if (requestId == null)
				throw new Error(Exception.REQUEST_ID_EMPTY);
			
			if (source == null || source == "")
				throw new Error(Exception.SOURCE_EMPTY);
			
			if (target == null || target == "")
				throw new Error(Exception.TARGET_EMPTY);
			
			if (context == null || context == "")
				throw new Error(Exception.CONTEXT_EMPTY);
		}
		
		//*******************************************************************************************
		// Getter and Setter
		//*******************************************************************************************
		// Non-normalized attributes
		public function getApi () : String {
			return api; 
		}
		public function setApi (api: String) {
			this.api = api;
		}
		
		public function getType () : String {
			return type; 
		}
		public function setType (type: String) {
			this.type = type;
		}
		
		public function getMetadata() : String {
			return metadata;
		}
		
		public function setMetadata(aMetadata: String) {
			metadata = aMetadata;
		}
		
		// Normalized attributes
		public function getRequestId () : Number {
			return requestId; 
		}
		public function setRequestId (requestId: Number) {
			this.requestId = requestId;
		}
		
		public function getSource () : String {
			return source; 
		}
		public function setSource (source: String) {
			this.source = source;
		}
		
		public function getTarget () : String {
			return target; 
		}
		public function setTarget (target: String) {
			this.target = target;
		}
		
		public function getData () : String {
			return data; 
		}
		public function setData (data: String) {
			this.data = data;
		}
		
		public function getContext () : String {
			return context; 
		}
		public function setContext (context: String) {
			this.context = context;
		}
		
		public function getConfidential () : String {
			return confidential; 
		}
		public function setConfidential (confidential: String) {
			this.confidential = confidential;
		}
	}
}

//		public function getMetadata (isOutputRawdata : Boolean = false) : Object {
//			var outputString : String = "";
//			if (!isOutputRawdata)
//				return metadata;
//			else {
//				outputString += "{\'type\':"+ metadata.getType()+ ",\'url\':"+ metadata.getUrl()+ "}";
//				return outputString;
//			}
//		};
//		public function setMetadata (aMetadata: String) {
//			aMetadata = aMetadata.replace("{", "");
//			aMetadata = aMetadata.replace("}", "");
//			aMetadata = aMetadata.replace(" ", ""); 
//			
//			var temp = new Array();
//			temp = aMetadata.split(",");
//			var tempType  = temp[0].split(":");
//			var tempUrl  = temp[1].split("':");
//			
//			metadata.setType(tempType[1])
//			metadata.setUrl(tempUrl[1]);
//			
//		}