console.log("Comet_lib.js loaded");

// Creates a JS Object to carry the data sended by the server
// Writes a DOM div element to contain the data
// Writes an iFrame
console.log("Comet_Lib.js loaded");
var comet = {
				connection : false,
				iframediv : false,

				initialize : function() { 
					if(navigator.appVersion.indexOf("MSIE") != -1) {

						// For IE browsers
						comet.connection = new ActiveXObject("htmlfile");
						comet.connection.open();
						comet.connection.write("<html>");
						comet.connection.write("<script>document.domain = '" + document.domain + "'");
						comet.connection.write("</html>");
						comet.connection.close();
						comet.iframediv = comet.connection.createElement("div");
						comet.connection.appendChild(comet.iframediv);
						comet.connection.parentWindow.comet = comet;
						comet.iframediv.innerHTML = "<iframe id='comet_iframe' src='"+cometIFramePath+"'></iframe>";

					} else {

						// For other browser (Firefox...)
						comet.connection = document.createElement('iframe');
						comet.connection.setAttribute('id', 'comet_iframe');
						with(comet.connection.style) {
							left = top = "-100px";
							height = width = "1px";
							visibility = "hidden";
							display = 'none';
						}
						comet.iframediv = document.createElement('iframe');
						comet.iframediv.setAttribute('src', cometIFramePath);
						comet.connection.appendChild(comet.iframediv);
						document.body.appendChild(comet.connection);

					}
				},
				onDataReceived : function(data) {
				// redefined in Controller Component to process the data received	
				}, 

				onUnload : function() {
					 if(comet.connection) {
						 comet.connection = false;
										// release the iframe to prevent problems with IE when reloading the page
					}
				}
}





			






