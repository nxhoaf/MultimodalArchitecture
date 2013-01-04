package
{
	public class MC_config
	{
		public static var componentName : String = "MC_FlexSynthetizer_1";
		public static var mc_metadata : String = "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}";
		public static var mc_confidential : Boolean = false;
		
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