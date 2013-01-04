package sound
{
	import cmodule.flac.CLibInit;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Recognizer
	{
		
		//*************************************************************************************************
		// Variable
		//*************************************************************************************************
		private static const FLOAT_MAX_VALUE:Number = 1.0;
		private static const SHORT_MAX_VALUE:int = 0x7fff;
		private static const PATH_SPEECH_TO_TEXT:String = "https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US";
		private static const PATH_TEXT_TO_SPEECH:String = "http://translate.google.com/translate_tts";	
	
		private var jsonData : String;
		
		//*************************************************************************************************
		// Private methods  
		//*************************************************************************************************
		public function getJsonData () : String {
			return jsonData;
		}
		
		public function setJsonData (jsonData: String) : void{
			this.jsonData = jsonData;
		}
		
		private function getUrlData(text : String = "hello", lang : String = Language.ENGLISH): String {
			var result: String = "";
			result += "tl=" + lang;
			result += "&q=" + encodeURI(text);
			return result;
		}
		//*************************************************************************************************
		// Constructor, Getter and Setter  
		//*************************************************************************************************
		/**
		 * Constructor
		 */
		public function Recognizer() {
		}	
		
		
		//*************************************************************************************************
		// Public methods  
		//*************************************************************************************************
		/**
		 * Get a recorded audio stream then send it to google. As a result, we will have 
		 * a json data structure containing text-form of our audio stream along with the 
		 * recognition's precision.
		 * 
		 * @param command MMI command
		 * @param inputStream stream which we want to get text form  
		 */
		public function convertSpeechToText() : void {			
			var flacCodec:Object;
			flacCodec = (new cmodule.flac.CLibInit).init();
//			var inputStream : ByteArray = command.getData();
			var inputStream : ByteArray = null;
			inputStream.position = 0;
			var rawData: ByteArray = new ByteArray();
			var flacData : ByteArray = new ByteArray();
			rawData = SoundUtility.convert32to16(inputStream);
			flacData.endian = Endian.LITTLE_ENDIAN;
			flacCodec.encode(	encodingCompleteHandler, 
				encodingProgressHandler, 
				rawData, 
				flacData, 
				rawData.length, 
				30);			
			function encodingCompleteHandler(event:*):void {
				trace("FLACCodec.encodingCompleteHandler(event):", event);
				var urlRequest:URLRequest = new URLRequest(PATH_SPEECH_TO_TEXT);
				var urlLoader:URLLoader = new URLLoader();
				urlRequest.contentType = "audio/x-flac; rate=44000";
				urlRequest.data = flacData;
				urlRequest.method = URLRequestMethod.POST;
				
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT; // default
				urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);
				urlLoader.addEventListener(ErrorEvent.ERROR, urlLoader_error);
				urlLoader.load(urlRequest);
				
				function urlLoader_complete(evt:Event):void {
					setJsonData(urlLoader.data);
				}
				function urlLoader_error(evt:ErrorEvent): void {
					throw new Error("Exception occured at Recognizer: " + evt.toString());
				}
			}
			
			function encodingProgressHandler(progress:int):void {
				trace("FLACCodec.encodingProgressHandler(event):", progress);;
			}	
		}
	}
}