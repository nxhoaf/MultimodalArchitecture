package architecture;

import java.util.EventObject;

public class SocketEvent extends EventObject {
	private static final long serialVersionUID = 1L;
	public static final String ON_CONNECTING = "ON_CONNECTING";
	public static final String ON_RECEIVING_DATA = "ON_RECEIVING_DATA";
	public static final String ON_CLOSING = "ON_CLOSING";
	
	private String data;
	
	public SocketEvent(Object source) {
		super(source);
		// TODO Auto-generated constructor stub
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	
}
