package utilities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.Random;

/**
 * This class contains all cofiguration informations
 *
 */
public class ConfigurationReader
{
	public static final String GLOBAL_CONFIGURATION = "config/Configuration";
	public static final String LOCAL_CONFIGURATION = "config/Mc_config";
	public static final String COOKIE = "config/Cookie";
	
	private Properties properties;
	private String path;
	
	public ConfigurationReader(String path){
		log("[Configuration][loadConfigFile] - Started. File to load: " + path);
		try {	
			properties = new Properties();
			this.path = path;
			File f = new File(path);
			if (!f.exists()) 
				f.createNewFile();	

            //load a properties file
			FileInputStream fis = new FileInputStream(path);
	 		properties.load(fis);
	 		fis.close();
	 		log("[Configuration][loadConfigFile] - Ended");
	 	} catch (IOException ex) {
			log("[Configuration][loadConfigFile] - Cache not found: " + path);
	 		ex.printStackTrace();
	 		log("[Configuration][loadConfigFile] - Ended");
	 	}
	}
	
	/**
	 * Find integer value of a specific name, if not found, return the default value
	 * @param name name of the property
	 * @param def default value
	 * @return value
	 */
	public int getInt(String name, int def)
	{
		String value = properties.getProperty(name);
		if (value == null)
			return def;
		else 
			return Integer.parseInt(value);
	}
	/**
	 * Find string value of a specific name, if not found, return the default value
	 * @param name name of the property
	 * @param def default value
	 * @return value
	 */
	public String getString (String name, String def)
	{
		String value = properties.getProperty(name);
		if (value == null)
			return def;
		else 
			return value;
	}
	
	
	public Boolean getBoolean(String name, Boolean def) {
		String value = properties.getProperty(name);
		if (value == null)
			return def;
		else 
			return Boolean.parseBoolean(value);
	}
	/**
	 * Find long value of a specific name, if not found, return the default value
	 * @param name name of the property
	 * @param def default value
	 * @return value
	 */
	public long getLong(String name, long def)
	{
		String value = properties.getProperty(name);
		if (value == null)
			return def;
		else 
			return Long.parseLong(value);
	}
	
	/**
	 * Find boolean value of a specific name, if not found, return the default value
	 * @param name name of the property
	 * @param def default value
	 * @return value
	 */
	public boolean getLong(String name, boolean def)
	{
		String value = properties.getProperty(name);
		if (value == null)
			return def;
		else 
			return Boolean.parseBoolean(value);
	}
	/**
	 * Create a random number between a specific interval
	 * @param lower lower value
	 * @param upper upper value
	 * @return the random number
	 */
	public int createRandom(int lower, int upper)
	{
		Random r = new Random();	
		int range = upper - lower;
		if (range == 0)
			return upper;
		else
			return lower + r.nextInt(range);
	}

	public synchronized void save(String key, String value) {
		log("[Configuration][save] - key: " + key + " value: " + value);
		try {
			FileOutputStream out = new FileOutputStream(path);
			properties.setProperty(key, value);
			properties.store(out, "Last modified: ");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(1);
		}
	}
	
	public synchronized void erase() {
		File f = new File(path);
		try {
			// override
			FileOutputStream out = new FileOutputStream(f, false);
			out.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public synchronized void reload() {
		log("[Configuration][reload]");
		FileInputStream fis = null;
		try {
            //load a properties file
			fis = new FileInputStream(path);
	 		properties.load(fis);
	 		fis.close();
	 	} catch (IOException ex) {
	 		ex.printStackTrace();
	 		
	 	}
	}
	public void log(String message) {
		// TODO Auto-generated method stub
		System.out.println(message);
	}
}
