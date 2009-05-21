package de.marcusschiesser.album3d
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	
	import mx.core.IFactory;

	public class ZoomFilterFactory implements IFactory
	{
		public function ZoomFilterFactory()
		{
		}

		public function newInstance():*
		{
           var color:Number = 0xffffff;
            var alpha:Number = 0.8;
            var blurX:Number = 35;
            var blurY:Number = 35;
            var strength:Number = 2;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
		}
		
	}
}