//*************************************************************************************************
// UPnP
//*************************************************************************************************
/**
 * Check if an array contain an item
 * @param {Object} item to check
 * @param {Object} a array to check
 */
function contain(item, a) {
	var current;
	var i;
	if (!a.length)
		return false;
	
	for( i = 0; i < a.length; i++) {
		current = a[i];
		if(current.name == item.name)
			return true;
	}
	return false;
};

/**
 * Get the abbreviation name of the service
 * @param service the service which we want to get its short name
 * @return short name of service
 */
function getServiceShortName(service) {
	if (!service.Name)
		return "Unknown";
	var partition = [];
	partition = service.Name.split(":");
	
	if (partition.length > 0 )
		return partition[partition.length - 1];
	else 
		return "Unknown";
};

/**
 * Get the service type excluding its name space
 */
function getServiceShortType(service) {
	var partition = [];
	var shortDes = "";
	var i; 
	if (!service.Type) 
		shortDes += "URN: Unknown";
	else {
		partition = service.Type.split(":");
		// The first and second element should be urn and its value
		shortDes += "URN: " + partition[0] + ":" + partition[1];
	}
	return shortDes;
};

/**
 * Get content of a description by removing its first <xml> and last </xml> tag
 */
function getDescriptionContent(description) {
	var desContent = "";
	var first, last; 
	first = description.indexOf(">"); // Get index of first closing tag
	last = description.lastIndexOf("</"); // Get index of last beginning tag
	if (last <= (first + 1))
		return "";
	// Get the content if any
	desContent = description.slice(first + 1,last);
	return desContent; 
}

/**
 * Create MmiData for a specific service
 */
function createMmiData(service) {
	var mmiData = ""; 
	mmiData += "<name>" + service.Name + "</name>";
	mmiData += "<type>" + getServiceShortType(service.Type ) + "</type>";
	mmiData += "<url>" + service.Hostname + "</url>";
	//alert(' Name ' + service.Name + "Type: " + service.Type);
	mmiData += "<description>" + getDescriptionContent(service.GetSCPD()) + "</description>";
	return mmiData; 
};

/**
 * Get MmiDataList
 */
function getMmiDataList() {
	return mmiDataList;
};

/**

function getAllXmlServiceDescription(device) {
	var i;
	var description;
	if(!device.ServicesCount)
		return "Description for this device is unavailable";
	while(i < device.ServicesCount) {
		var service = device.GetService(i);
		alert('  UPnP Service #' + (i + 1) + ' Name: ' + service.Name + ' type: ' + service.Type + ' Host: ' + service.Hostname);
		alert('  UPnP Service #' + (i + 1) + ' SCPD XML: ' + service.GetSCPD());
		i += 1;
	}
}
 */
// if('UPnP object type: ' != undefined + type of UPnP)
// ;
// alert('UPnP Media Renderer on: ' + UPnP.MediaRendererEnabled);
// alert('UPnP Media Server on: ' + UPnP.MediaServerEnabled);
// alert('UPnP Media Controler on: ' + UPnP.MediaControlEnabled);

UPnP.onDeviceAdd = function(device, is_add) {
	console.log("[table.js][onDeviceAdd]");
	var i = 0;
	var service;
	var item = {}; 
	//alert('UPnP device ' + ( is_add ? 'added' : 'removed'));
	if(is_add) {
		while(i < device.ServicesCount) {
			service = device.GetService(i);			
			item.name = getServiceShortName(service);
			item.info = getServiceShortType(service) + ",   URL: " + service.Hostname;
			
			// Make sure that there isn't duplication in our service list.
			if(!contain(item, data)) {
				data.push(item);
				//console.log("[table.js][onDeviceAdd] - item: " + item.name + "info: " + item.info);
				mmiDataList.push(createMmiData(service));
			};
				
			i += 1;
		}
	}

	//startup();
}
// function getServiceInfo() {
// UPnP.onDeviceAdd = function(device, is_add) {
// alert('UPnP device ' + ( is_add ? 'added' : 'removed'));
// if(is_add) {
// alert(' UPnP device Name ' + device.Name + ' - UUID: ' + device.UUID);
// alert(' UPnP device Nb Services: ' + device.ServicesCount);
// var i = 0;
// while(i < device.ServicesCount) {
// var service = device.GetService(i);
// alert('  UPnP Service #' + (i + 1) + ' Name: ' + service.Name + ' type: ' + service.Type + ' Host: ' + service.Hostname);
// alert('  UPnP Service #' + (i + 1) + ' SCPD XML: ' + service.GetSCPD());
// i += 1;
// }
// }
// }
// }
