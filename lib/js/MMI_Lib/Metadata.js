var metadata = function (metadataString) {
	var that = {};
	var type;
	var url;
	
	if (typeof metadataString != "undefined") {
		metadataString = metadataString.replace("{", "");
		metadataString = metadataString.replace("}", "");
		metadataString = metadataString.replace(" ", ""); 

		var temp = new Array();
		temp = metadataString.split(",");
		var tempType  = temp[0].split(":");
		var tempUrl  = temp[1].split("':");

		type = tempType[1];
		url = tempUrl[1];
	}
	
	
	that.setType = function(aType) { 
		type = aType;
	};  
	that.getType = function() {
		return type;
	};
	
	that.setUrl = function(aUrl) {
		url = aUrl; 
	};
	that.getUrl = function() {
		url;
	};
	
	return metadata;
};