package Sound_Lib
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
		private var jsonData: String; 
		
		private function getUrlData(text : String = "hello", lang : String = Language.ENGLISH): String {
			var result: String = "";
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
		public function convertTextToSpeech (txt: String, lang: String) : void {
			var urlRequest:URLRequest = new URLRequest(PATH_TEXT_TO_SPEECH);
			urlRequest.method = URLRequestMethod.GET;
			urlRequest.data = getUrlData(txt,lang);
			
			var fileReference : FileReference = new FileReference();
			fileReference.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler)
			try {
				// Prompt and downlod file
				fileReference.download( urlRequest, "output.mp3" );
			} catch (error:Error) {
				trace("Unable to download file.");
			} 
			
			function loaderCompleteHandler(e:Event):void {
				trace("loaderCompleteHandler:" + e);
			}
			function httpStatusHandler (e:Event):void {
				trace("httpStatusHandler:" + e);
			}
			function securityErrorHandler (e:Event):void {
				throw new Error("securityErrorHandler:" + e);
			}
			function ioErrorHandler(e:Event):void {
				throw new Error("ioErrorHandler: " + e);
			}
		}
		
	}
}