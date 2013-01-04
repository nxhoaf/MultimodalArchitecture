var isInit = false;
var timer;

var observator = new Observator();
var isRegistered = false;
var isStarted = false;

function test() {
	alert("test timeout");
	//timer.set(1);
	//timer.start();
};

function send() {
	console.log("[gpacListener_1.js][send] - Started ");
	var spec = {
		method : "MC_register",
		source : "MC_1234",
		target : "http://www.berthele.com/soa2m/services/servicesCC/CCs_Register.php",
		requestId : "r1",
		metadata : "{\'type\':\'ontology\',\'url\':\'http://www.toto.com\'}",
		type : messageType.STATUS,
		context : "c1",
		status : 1,
		data : getMmiDataList(),
		confidential : 1
	};

	var msg;
	try {
		msg = factory.createRequest(spec);
	} catch (err) {
		alert("Exception: " + err);
	}
	MMDispatcher.sendAsynchronous(msg, "GET", "XML");
	console.log("[gpacListener_1.js][send] - Ended ");
};

// var dataReceived = function(data) {
	// console.log("[table.svg][dataReceived] - Started ");
	// alert("*** var dataReceived = function (data) ***: " + data);
	// console.log("[table.svg][dataReceived] - Started ");
//   
// }
function init() {
	console.log("************************************************** ");
	console.log("[gpacListener_1.js][init] - Started! ");
	observator.observe();
	 if(!isInit) {
		alert("[gpacListener_1.js][startup] - Started! ");
		isInit = true;
		//observator.observe();
		timer = createTimer('myTimer');
		timer.on_fraction = function() {
			//send();
			test();
		}
		timer.set(2,5);
		timer.start();

		//send();
		alert("[gpacListener_1.js][startup] - Started ");
	 };
	console.log("[gpacListener_1.js][init] - End! ");
}

