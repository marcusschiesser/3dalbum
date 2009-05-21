package de.marcusschiesser.album3d
{
	import flash.events.Event;

	public class AlbumEvent extends Event
	{
		public static const CLICK_EVENT:String = "pictureClick";
		public static const ROLL_OVER_EVENT:String = "pictureRollOver";
		public static const ROLL_OUT_EVENT:String = "pictureRollOut";
		public static const PICTURE_LOADED_EVENT:String = "pictureLoaded";
		
		private var _data:Object;
		
		public function AlbumEvent(type:String, data:Object)
		{
			super(type, false, false);
			_data = data;
		}
		
		public function get data():Object {
			return _data;
		}
		
	}
}