package
{
	public class MC_config
	{
		public static var componentName : String = "MC_AirRecorder_1";
		public static var mc_metadata : String = "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}";
		public static var mc_confidential : Boolean = false;
		
		public static var debug : Boolean = false;
		
		public static var advertiseDebug : Boolean = false;
		public static var interactionDebug : Boolean = true;
		
		public static var intervalDebug : int = 3000; 
		public static var lifeTimeDebug : int = 120000; 
		public static var sleepDebug : int = 0; 
		
		public function MC_config() {
			trace("MC_config.js loaded");
		}
		
		private static var requestNo: int;
		public static function getRequestId(requestNo : int) : String {
			if (!requestNo) return "r0";
			return "r" + requestNo;
		}	
	}
}