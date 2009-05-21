package de.marcusschiesser.album3d
{
	import five3D.display.Bitmap3D;
	import five3D.display.Sprite3D;
	
	import flash.display.BitmapData;
	
	public interface ITileFactory
	{
		function createTile(bitmapData:BitmapData, label:String, tileWidth:int, tileHeight:int, fontSize:int):Sprite3D;
	 	function createShadow(bitmapData:BitmapData, tileWidth:int, tileHeight:int, fontSize:int):Bitmap3D;
		function moveShadow(shadow:Bitmap3D, x:int, y:int, tileWidth:int, tileHeight:int, fontSize:int):void;
	}
}