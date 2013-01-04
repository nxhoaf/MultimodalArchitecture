package architecture;

import java.net.URLDecoder;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Parser {
	public static Map<String, String> parseReceivedData(String data) {
		try {
			// Normalize data
			data = URLDecoder.decode(data, "ISO-8859-1"); // decode data
			data = data.replace("'", "\""); // Replace ' by " (if any) in json object
			// Parse data
			@SuppressWarnings("unchecked")
			HashMap<String,Object> rawMap = 
					new ObjectMapper().readValue(data, HashMap.class);
			Map<String, String> resultMap = parseMap(rawMap);
			return resultMap;
		} catch (Exception e) {
			System.err.println("[Parser] Error: malformed Data: " + data);
			System.out.println("System will exit...");
			System.exit(1);
			return null;
		}	
	}
	
	@SuppressWarnings("rawtypes")
	private static Map<String, String> parseMap(Map<String, Object> map) {
		Map<String, String> resultMap = new HashMap<String, String>();
		
		Set<String> keys = map.keySet();
		Iterator<String> i = keys.iterator();
		String key = "";
		Object value = null;
		
		while (i.hasNext()) {
			key = i.next();
			value = map.get(key);
			
			// Is a string, put it into hashmap
			if (value instanceof java.lang.String) {
				resultMap.put(key, (String)value);
			} else {
			// Not a string, it's another HashMap
				@SuppressWarnings("unchecked")
				Set<String> subKeys = ((Map) value).keySet();
				Iterator<String> j = subKeys.iterator();
				
				String subKey = "";
				Object subValue = null;
				while (j.hasNext()) {
					subKey = j.next();
					subValue = ((Map) value).get(subKey);
					if (subValue instanceof java.lang.String) {
						resultMap.put(subKey, (String)subValue);
					} else {
						@SuppressWarnings("unchecked")
						Map<String, String> subMap = 
								parseMap((Map<String, Object>) subValue);
						resultMap = mergeMap(resultMap, subMap);
					}
				}
			}
		}		
		return resultMap;
	}
	
	private static Map<String, String> mergeMap(Map<String, String> parent, 
												Map<String, String> child) {
		Set<String> childKeys = child.keySet();
		Iterator<String> i = childKeys.iterator();
		String key = "";
		String value = "";
		
		while (i.hasNext()) {
			key = i.next();
			value = child.get(key);
			parent.put(key, value);
		}	
		return parent;
	}

	public static long[] parseTimerData(String timerData) {
		// Normalized
		timerData = timerData.substring(1, timerData.length() - 1); // Get data, exclude { and }
		timerData = timerData.replaceAll(" ", ""); // Remove space
		String[] parsedData = timerData.split("-");
		
		long now = (new Date()).getTime();
		long sleepTime = Long.parseLong(parsedData[0]);
		long duration = Long.parseLong(parsedData[1]);
		long interval = Long.parseLong(parsedData[2]);
		
		long[] returnData = new long[3];
		returnData[0] = now + sleepTime; // Begin 
		returnData[1] = now + sleepTime + duration; // End
		returnData[2] = interval; // Interval
		
		return returnData;
	}

	
}
