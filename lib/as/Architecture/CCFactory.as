package Architecture
{
	import Architecture.AdvertiseManager;
	import Architecture.InteractionManager;
	import Architecture.StateManager;

	public class CCFactory
	{
		public function CCFactory()
		{
		}
		
		public static function createAdvertiseManager(name: String) 
															: AdvertiseManager {
			return (new AdvertiseManager(name));
		}
		
		public static function createInteractionManager(name: String, 
												 		controller:Controller) : 
															InteractionManager {
			return (new InteractionManager(name, controller)); 
		}
		
		public static function createStateManager(name: String) : StateManager {
			return (new StateManager(name));	
		}
	}
}