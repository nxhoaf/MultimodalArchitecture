console.log("Commander_Lib.js loaded");
var PlayerButton = {};  
var request = 0;
 
PlayerButton.play = function ( method , requestKind , spec) {  
	var myFactory = Object.create(factory); 
	var response; 
	var myDispatcher = Object.create(MMDispatcher);  
	var msg;   
	try { msg = myFactory.createRequest(spec); } catch (err) { alert("Exception: " + err); }
	response = myDispatcher.sendAsynchronous( msg , method, requestKind ); 
	return false; 
};

PlayerButton.stop = function () { 
	request++;
	spec.requestId = "r"+request;
	spec.type = messageType.STATUS;
	spec.context = "Alive";
 	spec.status = 1;
	spec.statusInfo = "None";
	spec.isDelivered = 1;
	spec.contentUrl = "http";
	spec.deliveryMode = 'visual,cognitive';
		
	var myFactory = Object.create(factory); 
	var response; 
	var myDispatcher = Object.create(MMDispatcher);  
	var msg;  
	
	try {
		msg = myFactory.createRequest(spec);
	} catch (err) {
		alert("Exception: " + err);
	}
	
	response = myDispatcher.sendAsynchronous( msg , "POST", "MMI" ); 
	return false;
};

var commandInterface = new Interface ( 'Command' , ['execute'] );
var Command = 
{ 
	name: "Command", 
	actions: { 
		execute: function() { }
	}
};

var CommandLinker = function ( Command ) {
 	Interface.implement( Command.actions , commandInterface ); 
	this.name = Command.name;
	this.methods = Command.actions; 
	this.receiver = null;
	this.methods.linkCommand = function( aTarget ) { this.receiver = aTarget; } 
}

var myButton = Object.create( PlayerButton ); 
var myCommand = Object.create( Command );
var ButtonCommand = { }; 
ButtonCommand.button = null; 
ButtonCommand.receive = function ( MMICommand , method , requestKind , spec ) { 
	var myBindCommand = new CommandLinker ( myCommand ); 
	myBindCommand.methods.linkCommand( myButton );
	
	switch(MMICommand) {
		case 'register' :
			var myFactory = Object.create(factory); 
			var response; 
			var myDispatcher = Object.create(MMDispatcher);  
			var msg;
			try { msg = myFactory.createRequest(spec); } catch (err) { alert("Exception: " + err); }
			response = myDispatcher.sendAsynchronous( msg , method, requestKind ); 
			break;		
		case 'start' : 
			myBindCommand.methods.execute = function() { myButton.play(method , requestKind , spec); };
			break;
		case 'stop' : 
			myBindCommand.methods.execute = function() { myButton.stop(method , requestKind , spec); };  
			break; 	
	}
 
	this.setCommand( myBindCommand ); 
	this.fireCommand();
	
};
ButtonCommand.setCommand = function ( aCommand ) { button = aCommand;};
ButtonCommand.fireCommand = function () { button.methods.execute(); };  

var ExecutionCommand = { };
ExecutionCommand.setData = function ( name , duration , content ) {
	createCookie( name , content , duration );
	return true;
}
ExecutionCommand.getData = function ( name ) { 
	return readCookie( name ) ;
}
ExecutionCommand.clearData = function ( name , duration , content ) {
	readCookie( name ) ;
	return true;
}