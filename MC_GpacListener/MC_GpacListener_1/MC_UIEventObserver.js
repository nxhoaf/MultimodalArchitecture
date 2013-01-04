/*===============================================================================================*/
/*=========================== VARIABLES DECLARATION =============================================*/
/*===============================================================================================*/
console.log("MC_UIEventObserver.js loaded");
console.log("=====================================================");


Controller = new Controller();
var isRegistered = false;
var isStarted = false;
timer = {};
counter = 0;

/*================================================================================================*/
/*================================ COMPONENT INITIALIZATION ======================================*/
/*================================================================================================*/

/**
 *	// Handles the component register and context recovery 
 */
init = function() {
	console.log("[MC_UIEventObserver]{init} - Started");
	
	if(isGPacComponent) {
		readCookie = readGpacCookie;
		createCookie = createGpacCookie;
		eraseCookie = eraseGpacCookie;
	}
	console.log("[MC_UIEventObserver]{init} disable buttons");
	console.log("[MC_UIEventObserver]{init} creates observer for orchestration events");
	Controller.observe(); 
	console.log("[MC_UIEventObserver]{init} - Ended");
}	

/*===============================================================================================*/
/*========================== ORCHESTRATION UPDATES HANDLING =====================================*/
/*===============================================================================================*/

/**
 * onHavingContext equivalent in .as lib 
 */
initDone = function() {
	console.log("[MC_UIEventObserver]{initDone} - Started");
	console.log("[MC_UIEventObserver]{initDone} - Ended");
}


