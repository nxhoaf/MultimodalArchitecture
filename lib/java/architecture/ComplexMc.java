package architecture;

public class ComplexMc {
	private Controller controller;
	public ComplexMc(String name) {
		controller = new Controller(name);
	}
	public Controller getController() {
		return controller;
	}
	public void setController(Controller controller) {
		this.controller = controller;
	}
	
	
}
