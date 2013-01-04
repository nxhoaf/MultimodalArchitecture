package architecture;

public class MCFactory {
	public static Object createSimpleMc(String name) {
		// Not implemented yet
		return null;
	}
	
	public static ComplexMc createComplexMc(String componentName) {
		// Not implemented yet
		ComplexMc complexMc = new ComplexMc(componentName);
		
		Controller controller = new Controller(componentName);
		complexMc.setController(controller);
		return complexMc;
	}
}
