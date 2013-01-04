package fr.telecomParisTech.sound
{
	import cmodule.flac.CLibInit;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import fr.telecomParisTech.mmiLib.MessageBase;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;

	/**
	 * This class gets a recorded audio stream then send it to google. As a result, we will have 
	 * a json data structure containing text-form of our audio stream along with the 
	 * recognition's precision.
	 */
	public class Recognizer
	{
//*************************************************************************************************
// Variable
//*************************************************************************************************
		private static const FLOAT_MAX_VALUE:Number = 1.0;
		private static const SHORT_MAX_VALUE:int = 0x7fff;
		private static const PATH_SPEECH_TO_TEXT:String = "https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US";
		private static const PATH_TEXT_TO_SPEECH:String = "http://translate.google.com/translate_tts";		
		private var jsonData: String; 
		
//*************************************************************************************************
// Private methods  
//*************************************************************************************************
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
		public function Recognizer()
		{
			jsonData = null;
		}
		
		public function getJsonData () : String {
			return jsonData;
		}
		
		public function setJsonData (jsonData: String) {
			this.jsonData = jsonData;
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
		public function convertSpeechToText(command: MessageBase) : void {			
			var flacCodec:Object;
			flacCodec = (new cmodule.flac.CLibInit).init();
			var inputStream : ByteArray = command.getData();
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
					Alert.show(urlLoader.data);
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
			
//			var urlStream : URLStream = new URLStream();
//			urlStream.addEventListener(Event.COMPLETE, loaderCompleteHandler);
//			urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
//			urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
//			urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler)
//			
//			try {
//				urlStream.load(urlRequest);
//			} catch (error:Error) {
//				throw new Error("Unable to load URL");
//			}
					
			
			
//			var urlLoader:URLLoader = new URLLoader();
////			urlRequest.data = "tl=en&q=text";
//			urlRequest.method = URLRequestMethod.GET;
//			
//			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
//			urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
//			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
//			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
//			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler)
//			
//			try {
//				urlLoader.load(urlRequest);
//			} catch (error:Error) {
//				throw new Error("Unable to load URL");
//			}
//			
//			function loaderCompleteHandler(e:Event):void {
////				var variables:URLVariables = new URLVariables( e.target.data );
////				if(variables.success) {
////					trace(variables.path);
////				}
//				Alert.show(urlLoader.data);
//			}
//			function httpStatusHandler (e:Event):void {
//				trace("httpStatusHandler:" + e);
//			}
//			function securityErrorHandler (e:Event):void {
//				throw new Error("securityErrorHandler:" + e);
//			}
//			function ioErrorHandler(e:Event):void {
//				throw new Error("ioErrorHandler: " + e);
//			}
//			function urlLoader_complete(evt:Event):void {
//				Alert.show(urlLoader.data);
//				setJsonData(urlLoader.data);
//			}
//			function urlLoader_error(evt:ErrorEvent): void {
//				throw new Error("Exception occured at Recognizer: " + evt.toString());
//			}
			
			
						
//			var urlVariables : URLVariables = new URLVariables("tl=en&q=text");		
//			urlVariables.url = "http://translate.google.com/translate_tts?tl=en&q=text";
////			var urlRequest : URLRequest = new URLRequest("http://translate.google.com/translate_tts?tl=en&q=text");
//			var urlRequest : URLRequest = new URLRequest("proxy.php");
//			urlRequest.method = URLRequestMethod.POST;
//			urlRequest.data = urlVariables;
//			
//			var _speech:Sound = new Sound();
//			var _channel:SoundChannel;
//			_speech.load(urlRequest);
//			_channel = _speech.play();
			
//			var req:URLRequest = new URLRequest("http://localhost/proxy.php");
//			req.method = URLRequestMethod.POST;
//			var vars:URLVariables = new URLVariables();
//			vars.url = "http://translate.google.com/translate_tts?tl=en&q=text";
//			req.data = vars;
//			
//			var _speech:Sound = new Sound();
//			var _channel:SoundChannel;
//			_speech.load(req);
//			_channel = _speech.play();

		}
	}
}

















