package xhrLib;

import java.util.EventObject;

public class MMDispatcherEvent extends EventObject {
	
	private static final long serialVersionUID = 1L;
	private String data;
	
	public MMDispatcherEvent(Object source) {
		super(source);
		// TODO Auto-generated constructor stub
		this.data = "";
	}

	public MMDispatcherEvent(Object source, String data) {
		this(source);
		this.data = data;
	}
	
	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}
}
