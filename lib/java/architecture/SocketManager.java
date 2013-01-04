package architecture;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import utilities.Loggable;


public class SocketManager extends Thread implements Loggable {
	// Message terminator
	char EOF = (char)0x00;
	
	private String hostName;
	private List<SocketEventListener> listeners;
	private int port;
	private Socket socket;
	private PrintWriter printWriter;
	private BufferedReader bufferedReader;
	private Boolean isStopped;
	public synchronized void addEventListener(SocketEventListener listener) {
		listeners.add(listener);
	}
	
	public synchronized void removeEventListener(SocketEventListener listener) {
		listeners.remove(listener);
	}
	
	private synchronized void fireEvent(String type, SocketEvent socketEvent) {
		if (listeners.size() == 0) 
			return;
		Iterator<SocketEventListener> i = listeners.iterator();
		SocketEventListener listener;
		while (i.hasNext()) {
			listener = i.next();
			if (type.equals(SocketEvent.ON_CONNECTING)) {
				listener.connectHandler(socketEvent);
			} else if (type.equals(SocketEvent.ON_RECEIVING_DATA)) {
				listener.dataHandler(socketEvent);
			} else if (type.equals(SocketEvent.ON_CLOSING)) {
				listener.closeHandler(socketEvent);
			}
		}
	}
	
	public SocketManager(String hostName, int port) {
		isStopped = false;
		this.hostName = hostName;
		listeners = new ArrayList<SocketEventListener>();
		this.port = port;
		
	}
	
	public void listen() {
		String data;
		try {
			while ((data = bufferedReader.readLine()) != null) {
				
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public void close() {
		fireEvent(SocketEvent.ON_CLOSING, null);
	}
	@Override
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}

	private void init() {
		socket = null;
		printWriter = null;
		bufferedReader = null;
		
		// -------------------- Variables declaration  -------------------------
		try {
			socket = new Socket(hostName, port);
			log("[SocketManager] - "+
					"Connected to " + socket.getRemoteSocketAddress());
			fireEvent(SocketEvent.ON_CONNECTING, null);
			
			OutputStream out = socket.getOutputStream();
			printWriter = new PrintWriter(out, true);
			
			InputStream in = socket.getInputStream();
			InputStreamReader inReader = new InputStreamReader(in);
			bufferedReader = new BufferedReader(inReader);
			
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(1);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(1);
		}
	}
	@Override
	public void run() {
		// TODO Auto-generated method stub
		
		// Init the socket
		init();
		
		// Connect
		String data;
		while (!isStopped) {
			try {
				data = bufferedReader.readLine();
				if (!data.equals("EXIT")) {
					SocketEvent event = new SocketEvent(this);
					event.setData(data);
					fireEvent(SocketEvent.ON_RECEIVING_DATA, event);
					Thread.sleep(1000);
				} else {
					System.out.println(data);
					SocketEvent event = new SocketEvent(this);
					event.setData(data);
					fireEvent(SocketEvent.ON_CLOSING, event);
//					
//					printWriter.close();
//					bufferedReader.close();
//					socket.close();
					return;
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}	
		}
	}
}


//isStopped = false;
//this.hostName = hostName;
//listeners = new ArrayList<SocketEventListener>();
//this.port = port;
//socket = null;
//printWriter = null;
//bufferedReader = null;
//
//try {
//	socket = new Socket(hostName, port);
//	log("[SocketManager] - "+
//			"Connected to " + socket.getRemoteSocketAddress());
//	fireEvent(SocketEvent.ON_CONNECTING, null);
//	
//	OutputStream out = socket.getOutputStream();
//	printWriter = new PrintWriter(out, true);
//	
//	InputStream in = socket.getInputStream();
//	InputStreamReader inReader = new InputStreamReader(in);
//	bufferedReader = new BufferedReader(inReader);
//	
//} catch (UnknownHostException e) {
//	// TODO Auto-generated catch block
//	e.printStackTrace();
//	System.exit(1);
//} catch (IOException e) {
//	// TODO Auto-generated catch block
//	e.printStackTrace();
	














