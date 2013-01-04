package architecture;

public interface SocketEventListener {
	public void closeHandler(SocketEvent socketEvent);
	public void connectHandler(SocketEvent socketEvent);
	public void dataHandler(SocketEvent socketEvent);
}
