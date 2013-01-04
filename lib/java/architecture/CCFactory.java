package architecture;

public class CCFactory {
	public static StateManager createStateManager(String name) {
		return new StateManager(name);
	}
	
	public static InteractionManager createInteractionManager(String name, 
													Controller controller) {
		return new InteractionManager(name, controller);
	}
}
