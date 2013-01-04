package Architecture
{
	import flash.net.XMLSocket;
	
	import mx.collections.ArrayList;
	
	public class SocketManager {
		private var hostName : String;
		private var port : int;
		private var xmlSocket : XMLSocket;
		private var listeners : Array;
		
		public function SocketManager(hostName : String = null, 
									  port : int = 0) {
			this.hostName = hostName;
			this.port = port;
			xmlSocket = new XMLSocket(hostName, port);
			listeners = new Array();
		}
		
		public function getHostName() : String {
			return hostName;
		}
		
		public function setHostName(hostName : String) : void {
			this.hostName = hostName;
		}
		
		public function getPort() : int {
			return port;
		}
		
		public function setPort(port : int) : void {
			this.port = port;
		}
		
		public function getTimeout() : int {
			return xmlSocket.timeout;
		}
		
		public function setTimeout(timeout : int) : void {
			xmlSocket.timeout = timeout;
		}
		
		public function connect(hostName : String, port : int) : void {
			xmlSocket.connect(hostName, port);
		}
		
		public function send(data:Object):void {
			trace("[Controller][onEventReceived] - "+
						" Started. Data is: " + data);
			xmlSocket.send(data + "\n");
		}
		
		public function addEventListener(socketEvent : String, 
										 listener : Function) : void {
			xmlSocket.addEventListener(socketEvent, listener);
			listeners.push(listener);
		}
		
		public function removeEventListener(timerEvent : String, 
											listener: Function) : void {
			xmlSocket.removeEventListener(timerEvent, listener);
			listeners.splice(listeners.indexOf(listener),1);
		}
	}
}