package architecture;

import java.util.EventObject;

import mmiLib.Spec;

public class InteractionEvent extends EventObject {

	private static final long serialVersionUID = 1L;
	public static final String BEFORE_NEW_CTX_REQUEST_SENT = "BEFORE_NEW_CTX_REQUEST_SENT";
	public static final String ON_NEW_CTX_REQUEST_SENT = "ON_NEW_CTX_REQUEST_SENT";
	public static final String ON_HAVING_CONTEXT = "ON_HAVING_CONTEXT";
	public static final String ON_PROCESS_START_REQUEST = "ON_PROCESS_START_REQUEST";
	public static final String ON_PROCESS_PAUSE_REQUEST = "ON_PROCESS_PAUSE_REQUEST";
	public static final String ON_PROCESS_RESUME_REQUEST = "ON_PROCESS_RESUME_REQUEST";
	public static final String ON_PROCESS_CANCEL_REQUEST = "ON_PROCESS_CANCEL_REQUEST";
	
	private Spec msg;
	private String name;
	
	public InteractionEvent(Object source) {
		super(source);
		// TODO Auto-generated constructor stub
		msg = null;
		name = "";
	}

	public InteractionEvent(Object source, String name, Spec msg) {
		this(source);
		this.msg = msg;
		this.name = name;
	}

	public InteractionEvent(Object source, String name) {
		super(source);
		this.msg = null;
		this.name = name;
	}
	public Spec getMsg() {
		return msg;
	}

	public void setMsg(Spec msg) {
		this.msg = msg;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	

}
