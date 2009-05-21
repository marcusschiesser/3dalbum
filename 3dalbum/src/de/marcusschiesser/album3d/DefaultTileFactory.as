package de.marcusschiesser.album3d
{
	import five3D.display.Bitmap3D;
	import five3D.display.Sprite3D;
	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	
	public class DefaultTileFactory implements ITileFactory
	{
		private const SHADOW_DISTANCE:int = 4;
		
		public function DefaultTileFactory()
		{
		}
		
		public function createTile(bitmapData:BitmapData, label:String, tileWidth:int, tileHeight:int, fontSize:int):Sprite3D {
		  return new DefaultTile(bitmapData, label, tileWidth, tileHeight, fontSize);
		}
		
		public function createShadow(bitmapData:BitmapData, tileWidth:int, tileHeight:int, fontSize:int):Bitmap3D {
			const shadowTransform:ColorTransform = new ColorTransform(1, 1, 1, .1, 0, 0, 0, 0);
			var shadow:Bitmap3D = new Bitmap3D(bitmapData);
			shadow.scaleX = Math.min(tileWidth/Number(bitmapData.width), (tileHeight)/Number(bitmapData.height));
			shadow.scaleY = shadow.scaleX/2;
			shadow.rotationX = 180;
			shadow.transform.colorTransform = shadowTransform;
			return shadow;
		}
		
		public function moveShadow(shadow:Bitmap3D, x:int, y:int, tileWidth:int, tileHeight:int, fontSize:int):void {
			shadow.x = x;
			shadow.y = y + (tileHeight)/2 + SHADOW_DISTANCE;
		}
		
	}
	
}

import five3D.display.Sprite3D;
import de.marcusschiesser.album3d.ITile;
import flash.display.BitmapData;
import five3D.display.DynamicText3D;
import five3D.typography.HelveticaBold;
import five3D.display.Bitmap3D;
import flash.filters.BevelFilter;
import five3D.typography.HelveticaLight;
import five3D.typography.HelveticaMedium;
import flash.filters.GlowFilter;
import mx.utils.StringUtil;

class DefaultTile extends Sprite3D implements ITile
{
	private var _label:DynamicText3D;
	
	public function DefaultTile(bitmapData:BitmapData, label:String, tileWidth:int, tileHeight:int, fontSize:int)
	{
	  var bitmap:Bitmap3D = new Bitmap3D(bitmapData);
	  // scale picture to tile size
	  bitmap.scaleX = Math.min(tileWidth/Number(bitmapData.width), (tileHeight)/Number(bitmapData.height));
	  bitmap.scaleY = bitmap.scaleX;
	  addChild(bitmap);
	  if(label!=null) {
		  _label = new DynamicText3D(HelveticaMedium);
		  // we have to filter the label as five3d does not support every character
		  var re:RegExp = /[^A-Za-z0-9,.\-"' ]/g;
		  var filteredLabel:String = label.replace(re, "");
		  _label.text = filteredLabel;
		  _label.size = fontSize;
		  _label.color = 0xffffff;
		  _label.visible = false;
		  var filters:Array = new Array();
		  filters.push(new GlowFilter(0));
		  _label.filters = filters;
		  _label.y = tileHeight-fontSize/2;
		  _label.x = tileWidth/2 - _label.textWidth/2;
		  addChild(_label);
	  }
 	}
 	
 	public function get label():DynamicText3D {
 		return _label;
 	}

}