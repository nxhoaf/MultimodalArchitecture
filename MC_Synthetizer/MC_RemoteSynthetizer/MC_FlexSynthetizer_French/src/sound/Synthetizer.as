package sound
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class Synthetizer
	{
		private static const FLOAT_MAX_VALUE:Number = 1.0;
		private static const SHORT_MAX_VALUE:int = 0x7fff;
		private static const PATH_TEXT_TO_SPEECH:String = "http://translate.google.com/translate_tts";
		public static const LANGUAGE	:String = "fr";
		private var jsonData: String; 
		
		private function makeParam(text : String = "Bonjour"): String {
			var result: String = "";
			var lang : String = LANGUAGE;
			result += "tl=" + lang;
			result += "&q=" + encodeURI(text);
			return result;
		}
		
		public function Synthetizer()
		{
			jsonData = null;
		}
		
		public function getJsonData () : String {
			return jsonData;
		}
		
		public function setJsonData (jsonData: String) : void{
			this.jsonData = jsonData;
		}
		
		/**
		 * Convert Text to Speech using Google Translate api
		 */  
		public function convertTextToSpeech (txt: String) : String {
			var url : String;
			url = PATH_TEXT_TO_SPEECH + "?" + makeParam(txt);
			return url;
		}
		
	}
}