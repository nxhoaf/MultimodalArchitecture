package Architecture
{
	
	import flash.net.SharedObject;

	public class DCFactory {
		public function DCFactory() {
		}
		
		public static function createDC(name : String) : DataComponent {
			return new 	DataComponent(name);
		}
	}
}