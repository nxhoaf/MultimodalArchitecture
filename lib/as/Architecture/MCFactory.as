package Architecture
{
	public class MCFactory
	{
		public function MCFactory()
		{
		}
		
		public static function createSimpleMc(name : String) : void {
			
		}
		
		public static function createComplexMc(name : String) : Object {
			var complexMc : Object = new Object();
			complexMc.controller = new Controller(name);
			return complexMc;
		}
	}
}