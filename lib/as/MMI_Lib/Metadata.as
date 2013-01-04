package MMI_Lib
{
	public class Metadata {
	 
		private var type: String; 
		private var url : String; 
		
		public function Metadata (aMetadata: String) {

			aMetadata = aMetadata.replace("{", "");
			aMetadata = aMetadata.replace("}", "");
			aMetadata = aMetadata.replace(" ", ""); 
			
			var temp:Array = new Array();
			temp = aMetadata.split(",");
			
			var tempType:Array  = temp[0].split(":");
			var tempUrl:Array   = temp[1].split("':");
			this.setType(tempType[1]);
			this.setUrl(tempUrl[1]);
			
		}
		
		public function getType ():String {
			return type; 
		}
		public function setType (type: String) :void{
			this.type = type;
		}
		
		public function getUrl ():String  {
			return url; 
		}
		public function setUrl (url: String):void  {
			this.url = url;
		}
		 
	}
}