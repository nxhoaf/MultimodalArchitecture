console.log("CCFactory.js loaded");

var CCFactory = function() {};

CCFactory.createAdvertiseManager = function(name) {
	advertiseManager = new AdvertiseManager(name);
	return advertiseManager;
}

CCFactory.createInteractionManager = function(aName, aController) {
	interactionManager = new InteractionManager(aName, aController);
	return interactionManager;
}

CCFactory.createStateManager = function(name) {
	stateManager = new StateManager(name);
	return stateManager;
}