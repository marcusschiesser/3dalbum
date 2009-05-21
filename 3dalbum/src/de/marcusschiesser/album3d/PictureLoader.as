package de.marcusschiesser.album3d
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class PictureLoader
	{
		private static var _instance:PictureLoader;
		
		private var loader:Loader;
		
		public function PictureLoader(access:Private)
		{
			if(access==null)
				throw new Error("Singleton error");
		}
		
		public static function getInstance():PictureLoader {
			if(_instance==null)
				_instance = new PictureLoader(new Private());
			return _instance;
		}

		public function loadPictures(adder:Function, collection:Array, pictureField:String, index:int=0):void {
			if(index>=collection.length) return;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				var picture:BitmapData = (e.target.content as Bitmap).bitmapData;
				adder(index, picture);
				loadPictures(adder, collection, pictureField, index+1);
			});
			// prevent error 2036 if using debug player
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				e.stopPropagation();
			});
			var url:URLRequest = new URLRequest(collection[index][pictureField]);
			loader.load(url, new LoaderContext(true));
		}
		
		public function stop():void {
			if(loader!=null) 
			{
				try{
					loader.close();
				} catch(e:Error) {}
			}
		}
	}
}

class Private {
}