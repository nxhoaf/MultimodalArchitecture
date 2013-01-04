package Sound_Lib
{
	import cmodule.flac.CLibInit;
	
	import com.adobe.audio.format.WAVWriter;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import fr.kikko.lab.ShineMP3Encoder;
	
	import mx.controls.Alert;

	public class SoundRecorder
	{
//*************************************************************************************************
// Varables and Constants
//*************************************************************************************************
		private static const FLOAT_MAX_VALUE:Number = 1.0;
		private static const SHORT_MAX_VALUE:int = 0x7fff;
		
		private var audioStream:ByteArray;
		private var mic:Microphone;
		private var mp3Encoder : ShineMP3Encoder;
		private var jsonData : Object; // Data returned by calling google speech-to-text api
		public function SoundRecorder () {		
			mic = Microphone.getMicrophone();
		}
		
//*************************************************************************************************
// Constructor, Getter and Setter 
//*************************************************************************************************
		public function setMicrophone (mic : Microphone) {
			this.mic = mic;
		}
		public function getMicrophone () {
			return mic;
		}
		
		public function getAudioStream () : ByteArray {
			return audioStream;
		}
		
//*************************************************************************************************
// Private function
//*************************************************************************************************		
		private function onPlaying(event:SampleDataEvent): void {
			var sample:Number;
			for (var i:int = 0; i < 8192; i++) {
				if (!audioStream.bytesAvailable) return;
				sample = audioStream.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}
		
		private function onRecording(event:SampleDataEvent):void {
			while (event.data.bytesAvailable) {
				var sample:Number = event.data.readFloat();
				audioStream.writeFloat(sample);
			}
		}
		
		/**
		 * Encode recorded audio to .mp3
		 * @param inputStream stream which we want to encode  
		 * 
		 */ 
		private function encodeToMp3(bytes:ByteArray) : void {
			var wav:WAVWriter = new WAVWriter();
			wav.numOfChannels = 1;
			wav.sampleBitRate = 16;
			wav.samplingRate = 44100;
			
			bytes.position = 0;
			var wavData : ByteArray = new ByteArray();
			wavData.endian = Endian.BIG_ENDIAN;
			wav.processSamples(wavData,bytes,44100,1);			
			wavData.position = 0;
			
			mp3Encoder = new ShineMP3Encoder(wavData);
			mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
			mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
			mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
			mp3Encoder.start();
			
			function mp3EncodeProgress(event : ProgressEvent) : void {
			}
			
			function mp3EncodeError(event : ErrorEvent) : void {
				Alert.show(event.toString());
			}
			
			function mp3EncodeComplete(event : Event) : void {
				mp3Encoder.saveAs();
			}
		}
		
		/**
		 * Encode recorded audio to .wav
		 * @param inputStream stream which we want to encode 
		 * 
		 */ 
		private function encodeToWav(bytes:ByteArray) : void {
			var wav:WAVWriter = new WAVWriter();
			wav.numOfChannels = 1;
			wav.sampleBitRate = 16;
			wav.samplingRate = 	44100;
			
			bytes.position = 0;
			var wavData : ByteArray = new ByteArray();
			wavData.endian = Endian.BIG_ENDIAN;
			wav.processSamples(wavData,bytes,44100,1);			
			//wavData.position = 0;	
			(new FileReference()).save(wavData, ".wav");
		}
		
		/**
		 * Encode recorded audio to .flac
		 * @param inputStream stream which we want to encode 
		 * 
		 */ 
		private function encodeToFlac(bytes:ByteArray) : void {	
			var flacCodec:Object;
			flacCodec = (new cmodule.flac.CLibInit).init();
			bytes.position = 0;
			var rawData: ByteArray = new ByteArray();
			var flacData : ByteArray = new ByteArray();
			rawData = SoundUtility.convert32to16(bytes);
			flacData.endian = Endian.LITTLE_ENDIAN;
			flacCodec.encode(	encodingCompleteHandler, 
				encodingProgressHandler, 
				rawData, 
				flacData, 
				rawData.length, 
				30);			
			function encodingCompleteHandler(event:*):void {
				trace("FLACCodec.encodingCompleteHandler(event):", event);
				//Alert.show(flacData.length.toString());			
				(new FileReference()).save(flacData, ".flac");
			}
			
			function encodingProgressHandler(progress:int):void {
				trace("FLACCodec.encodingProgressHandler(event):", progress);;
			}
		}
		
		
//*************************************************************************************************
// Public function
//*************************************************************************************************	
		
		/**
		 * This function is called whenever we want to start recording
		 */ 
		public function startRecord() :void {
			this.audioStream = new ByteArray;
			mic.gain = 100;
			mic.rate = 44;
			mic.setSilenceLevel(0,4000);					
			// Remove playback listener if any
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, onPlaying);
			// Add record listener
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, onRecording);
		}
		
		/**
		 * This function is called whenever we want to stop recording
		 */
		public function stopRecord() {
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA,onRecording);
		}
		
		/**
		 * Play the audio stream which has already been recorded
		 */
		public function playback () {
			if (audioStream.length > 0) {
				audioStream.position = 0;
				var sound:Sound = new Sound();
				sound.addEventListener(SampleDataEvent.SAMPLE_DATA,onPlaying);
				sound.play();
			}
		}
		
		/**
		 * Save recorded audio stream to a wav format (this is the default format)
		 */ 
		public function save() {
			encodeToWav(audioStream);
		}
		
		/**
		 * Save recorded audio stream to a specific audio format
		 * @param soundFormat: expected sound format
		 */ 
		public function saveAs(soundFormat: String) {
			switch(soundFormat) {
				case SoundFormat.MP3: 
					encodeToMp3(audioStream);
					break;				
				case SoundFormat.WAV:
					encodeToWav(audioStream);
					break;
				case SoundFormat.FLAC:
					encodeToFlac(audioStream);
					break;
				default:
					encodeToWav(audioStream);
					break;
			}
		}
	}
}