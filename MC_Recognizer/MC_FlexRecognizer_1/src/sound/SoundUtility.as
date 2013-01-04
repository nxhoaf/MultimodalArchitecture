package sound
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class SoundUtility
	{
		
		private static const FLOAT_MAX_VALUE:Number = 1.0;
		private static const SHORT_MAX_VALUE:int = 0x7fff;
		public function SoundUtility() {
		}
		
		/**
		 * Converts an (raw) audio stream from 32-bit (signed, floating point) 
		 * to 16-bit (signed integer).
		 * 
		 * @param source The audio stream to convert.
		 */
		public static function convert32to16(source:ByteArray):ByteArray {
			trace("BitrateConvertor.convert32to16(source)", source.length);
			
			var result:ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;
			
			while( source.bytesAvailable ) {
				var sample:Number = source.readFloat() * SHORT_MAX_VALUE;
				
				// Make sure we don't overflow.
				if (sample < -SHORT_MAX_VALUE) sample = -SHORT_MAX_VALUE;
				else if (sample > SHORT_MAX_VALUE) sample = SHORT_MAX_VALUE;
				
				result.writeShort(sample);
			}
			
			trace(" - result.length:", result.length);
			result.position = 0;
			return result;
			
		}
	
	}
}