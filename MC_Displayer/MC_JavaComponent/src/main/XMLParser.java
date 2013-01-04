package main;

import java.io.File;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.omg.PortableInterceptor.SYSTEM_EXCEPTION;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XMLParser {
	
	
	
	public XMLParser() {
		
	}
	
	public static List<DailyData> parseXmlFile(String filePath) {
		System.out.println("[StateManager][parseXmlFile] - Started");
		List<DailyData> result = new LinkedList<DailyData>();
		try {
			File xmlFile = new File(filePath);
			result = new LinkedList<DailyData>();
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(xmlFile);
			doc.getDocumentElement().normalize();
			
			NodeList dailyDataList = doc.getElementsByTagName(DailyData.DAILY_DATA);
			for (int i = 0; i < dailyDataList.getLength(); i++) {			
				Node dailyDataNode = dailyDataList.item(i);	
				
				// each dailyDataNode is a nested node itself
				if (dailyDataNode.getNodeType() == Node.ELEMENT_NODE) {
					Element dataElement = (Element) dailyDataNode;
					
					NodeList eventList = dataElement.getElementsByTagName("dailyEvent");
					List<Event> events = new LinkedList<Event>();
					
					for (int j = 0; j < eventList.getLength(); j++) {
						Node eventNode = eventList.item(j);
						if (eventNode.getNodeType() == Node.ELEMENT_NODE) {
							Element eventElement = (Element) eventNode;
							
							int startHour = Integer.parseInt(getTagValue(eventElement, "startHour")); 
							int endHour = Integer.parseInt(getTagValue(eventElement, "endHour"));
							String room = getTagValue(eventElement, "room");
							String description = getTagValue(eventElement, "description");
							
							Event event = new Event(startHour, endHour, room, description);
							//System.out.println(event.toString());
							events.add(event);
						}

					}
					
					@SuppressWarnings("deprecation")
					String date = dataElement.getAttribute("date");
					DailyData dailyData = new DailyData(events, date, "dd/MM/yy");
					//System.out.println(dailyData.toString());
					result.add(dailyData);
					
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		System.out.println("[StateManager][parseXmlFile] - Ended");
		return result;
	}
	
	private static String getTagValue(Element eElement, String sTag) {
		NodeList nlList = eElement.getElementsByTagName(sTag).item(0).getChildNodes();
	 
	        Node nValue = (Node) nlList.item(0);
	 
		return nValue.getNodeValue();
	  }
	
	
	
	
	
	
	
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		List<DailyData> list = XMLParser.parseXmlFile("config/schedulingInfo.xml");
		for (int i = 0; i < list.size(); i ++ ) {
			System.out.println(list.get(i).toString());
		}
	}

}
