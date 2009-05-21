package de.marcusschiesser.util
{
	public class MathUtil
	{
		public function MathUtil()
		{
		}

		public static function clamp(n:Number, clamp:Number=1):Number {
			if(n>clamp) return clamp;
			else if(n<-clamp) return -clamp;
			else return n;
		}
	}
}