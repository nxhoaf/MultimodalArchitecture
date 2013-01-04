//*************************************************************************************************
// Data
//*************************************************************************************************
var svgNS = "http://www.w3.org/2000/svg";
var mainGroup;
var rectangle;
var text, txtNode, txtHeight, tspan;
var lineH = 25.7;
var visibleLines = 0;
var page = 1;
var pageLines = 17;
var prefixIdCol1 = 'service';
var prefixIdCol2 = 'info';
var end = 0;
var nextPage;
data = [];
mmiDataList = []; // List of xml file to send
//*************************************************************************************************
// Display
//*************************************************************************************************
  
  function startup () { 
 
    mainGroup = document.getElementById("mainGroup");
 
    for (i = 0; i < data.length; i++) {
      
      var bgOK = createListBackground( mainGroup , i );
      if(bgOK == false) break;      
      newText = createText ( prefixIdCol1 +i, "#333" , 9, lineH*i+18 , 12 , cutContent(data[i].name, 35) );
      mainGroup.appendChild(newText);
      newText = createText ( prefixIdCol2 +i, "#333" , 230, lineH*i+18 , 12 , cutContent(data[i].info, 107) );
      mainGroup.appendChild(newText);
      visibleLines ++;
    }
    
  }   
 
  function changePage( dir ) { 
    var total = data.length/pageLines;
    total = Math.ceil( total );
 
    validateNewPage ( dir , total );
     fillLines();
    eraseLines( end , pageLines );
    handleButtons( page , total );
  
    debug =  document.getElementById("debugText"); 
    debug.firstChild.nodeValue = "Server OK"; 

  }

  function validateNewPage ( dir , total ){
    if ( dir == 'next' ) {  
      nextPage =  page + 1; 
      if( nextPage > total ) return;  
      page++;     
      
    } else if( dir=='back' ) {
      nextPage =  page - 1;     
      if( nextPage < 0 ) return;   
      page--;
      visibleLines = ( pageLines * page ) - pageLines ;
      end = 0; 
    }
  }


  function fillLines( ){
    var totalData = data.length;
    for (i = 0; i < totalData; i++) {
      targetCol1 =  document.getElementById(prefixIdCol1 + i);  
      targetCol2 =  document.getElementById(prefixIdCol2 + i);   
      var newVisible = i+visibleLines;
      if(newVisible< totalData && newVisible< pageLines*page) {
        targetCol1.firstChild.nodeValue = cutContent(data[newVisible].name, 35); 
        targetCol2.firstChild.nodeValue = cutContent(data[newVisible].info, 107);
      }  else {
        visibleLines = newVisible;
        end = i;
        break;
      } 
    }
    return;
  }
 
  function cutContent(content, limit) {
    var finalContent = content.substring( 0 , limit );
    if( content.length > limit ) finalContent = finalContent +'...';
    return finalContent;
  }

  function eraseLines( end , pageLines ){
    if( end < pageLines) { 
      for (r = end; r < pageLines; r++) { 
        targetEraseLine =  document.getElementById(prefixIdCol1 + r); 
        targetEraseLine.firstChild.nodeValue = ""; 
        targetEraseLine =  document.getElementById(prefixIdCol2 + r); 
        targetEraseLine.firstChild.nodeValue = "";
      }
    } else {
      end = 0;
    }
  }
  
  
  function handleButtons( page , total ){
    if (  page > 1  && page != total ) {  
      changeVisibility('back' , 'inline' ); 
      changeVisibility('backLine' , 'inline' );
      changeVisibility('next' , 'inline' ); 
      changeVisibility('nextLine' , 'inline' ); 
    }
 
    if ( page > 1 && page == total ) {   
      changeVisibility('next' , 'none' ); 
      changeVisibility('nextLine' , 'none' ); 
      changeVisibility('back' , 'inline' ); 
      changeVisibility('backLine' , 'inline' );
    } 
 
    if ( page == 1 ) { 
      changeVisibility('back' , 'none' ); 
      changeVisibility('backLine' , 'none' );  
      changeVisibility('next' , 'inline' ); 
      changeVisibility('nextLine' , 'inline' ); 
    }
  }
  
  function changeColor(el , tcolor ) {
    boutonLine =  document.getElementById(el); 
    boutonLine.setAttributeNS(null,"fill", tcolor); 
  }
  
  function changeVisibility(el , visible ) {
    bouton =  document.getElementById(el); 
    bouton.setAttributeNS(null,"display", visible); 
    boutonText =  document.getElementById(el + 'Text'); 
    if (visible=='none' && boutonText) { 
      boutonText.setAttributeNS(null,"fill-opacity", '0.2'); 
    } else if (boutonText){
      boutonText.setAttributeNS(null,"fill-opacity", '1'); 
    }
  }
  
  function createText ( name, color , x , y , size , txt ) {
    var newText = document.createElementNS(svgNS,"text");
    newText.setAttributeNS(null,"id", name);
    newText.setAttributeNS(null,"x", x);    
    newText.setAttributeNS(null,"y", y);  
      newText.setAttributeNS(null,"font-size", size );
      newText.setAttributeNS(null,"text-anchor","left");  
      newText.setAttributeNS(null,"fill", color );
      var textNode = document.createTextNode(txt );
      newText.appendChild(textNode);
    return newText;
  }
  
  function createLine ( number, color , y , height , shadow) {
    rectangle = document.createElementNS(svgNS,"rect");
    rectangle.setAttributeNS(null,"id","line"+ number + shadow );
    rectangle.setAttributeNS(null,"x",0);
    rectangle.setAttributeNS(null,"y",y);
    rectangle.setAttributeNS(null,"width",790);
    rectangle.setAttributeNS(null,"height", height);
    rectangle.setAttributeNS(null,"fill", color);
    return rectangle;
  }
  
  function createListBackground( mainGroup , i ) {
      if ( i%2 != 1 && i < pageLines ) {
        rectangle = createLine ( i , "#FFF" , lineH*i  , lineH, '' ); 
        mainGroup.appendChild(rectangle); 
        return true;
      } else if ( i < pageLines ) { 
        rectangle = createLine ( i , "#E4E4E4" , lineH*i , lineH, '' );
        mainGroup.appendChild(rectangle);
        rectangle = createLine ( i , "#D0D0D0" , lineH*i + 24 , 0.5, 'shadow' );
        mainGroup.appendChild(rectangle);   
        return true;
      } else {
        page = 1;
        visibleLines = pageLines;
        return false;  
      } 
  }

//*************************************************************************************************
// GPAC
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

	startup();
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
