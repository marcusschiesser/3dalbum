package five3D.utils
{
	import flash.geom.ColorTransform;
	
	public class ColorUtilities
	{
		public function ColorUtilities()
		{
		}

		public static function createBrightnessTransform(value:Number, alpha:Number):ColorTransform
		{
			value = clampValue(value);
			var percentage:Number = 1 - Math.abs(value);
			if(value > 0)
				return new ColorTransform(percentage, percentage, percentage, alpha, value * 255, value * 255, value * 255);
			else
				return new ColorTransform(percentage, percentage, percentage, alpha, 0, 0, 0);
		}
		
		private static function clampValue(value:Number):Number {
			if(value > 1)
				return 1;
			else if(value < -1) 
				return -1;
			else
				return value;
		}
	}
}