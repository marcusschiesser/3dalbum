package de.marcusschiesser.album3d {
	
	import de.marcusschiesser.util.MathUtil;
	
	import five3D.display.Bitmap3D;
	import five3D.display.Scene3D;
	import five3D.display.Sprite3D;
	
	import mx.effects.easing.Sine;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	
	[Event(name="pictureClick", type="de.marcusschiesser.album3d.AlbumEvent")]
	[Event(name="pictureRollOver", type="de.marcusschiesser.album3d.AlbumEvent")]
	[Event(name="pictureRollOut", type="de.marcusschiesser.album3d.AlbumEvent")]
	[Event(name="pictureLoaded", type="de.marcusschiesser.album3d.AlbumEvent")]

	public class Album3D extends UIComponent {
		
		public var numRows:int = 3;
		public var padding:Number = 20;
		public var tileWidth:int = 266;
		public var tileHeight:int = 200;
		public var fullViewZ:Number = 1000;
		public var zoomViewZ:Number = -300;
		public var zoomFilter:IFactory = new ZoomFilterFactory();
		public var tileRenderer:ITileFactory = new DefaultTileFactory();
		public var fontSize:int = 26;
		public var startPosX:Number = 0;
		// if true, a TextField with the size of the component is created in the background
		// (that way mouse events for every pixel are send to this album component - hints for other workaround are appreciated ;-) )
		public var createMousePanel:Boolean = true;
		
		public var pictureField:String = "picture";
		public var labelField:String = "label";
		public var showShadows:Boolean = true;

		private var _collection:ArrayCollection;
		
		private var _scene:Scene3D;
		private var _album:Sprite3D;
		
		private var _darker:ColorTransform = new ColorTransform(.8, .8, .8, 1, 0, 0, 0, 0);
		private var _lighter:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		
		private var _zoomMode:Boolean = false;
		
		private var _mousePanel:TextField;
		
		private var _mask:Shape;
		
		private var _objLookup:Dictionary;
		
		public function Album3D() {
			_collection = new ArrayCollection();
			_objLookup = new Dictionary();
		}
		
	    public function get dataProvider():Array
	    {
	        return _collection.source;
	    }
	    
	    public function set dataProvider(value:Array):void
	    {
	    	removePictures();
	        _collection = new ArrayCollection(value);
	        loadPictures();
	    }
	    
	    private function removePictures():void {
	    	PictureLoader.getInstance().stop();
	    	for(var i:int = _album.numChildren-1; i>=0; i--) {
	    		_album.removeChildAt(i);
	    	}
	    	_objLookup = new Dictionary();
	    	_zoomMode = false;
	    	_album.x = startPosX;
	    	_album.y = 0;
			_album.z = fullViewZ;
	    }
	    
		private function loadPictures():void {
			PictureLoader.getInstance().loadPictures(function(index:int, picture:BitmapData):void {
				dispatchEvent(new AlbumEvent(AlbumEvent.PICTURE_LOADED_EVENT, _collection[index]));		
				addPictureAt(index, picture, _collection[index][labelField]);
			}, _collection.toArray(), pictureField);
		}
		
		override protected function createChildren():void {
			if(createMousePanel) {
				_mousePanel = new TextField();
				addChild(_mousePanel);
			}
			
			_mask = new Shape();
			addChild(_mask);

			_scene = new Scene3D();
			addChild(_scene);
			
			_album = new Sprite3D();
			_album.x = startPosX;
			_album.z = fullViewZ;
			_album.buttonMode = true;
			_scene.addChild(_album);
			
			var startX:Number;
			var oldX:Number;
			var lastMoved:int=0;
			_album.addEventListener(MouseEvent.ROLL_OVER, onOver, true);
			_album.addEventListener(MouseEvent.ROLL_OUT, onOut, true);
			_album.addEventListener(MouseEvent.CLICK, createOnClick(), true);
			addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				if(_zoomMode) return;
				oldX = startX = e.stageX;
			});
			addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(_zoomMode || !e.buttonDown) return;
				if(lastMoved>0 && flash.utils.getTimer()-lastMoved > 500) {
					startX = oldX;
				}
				var xSpeed:Number = MathUtil.clamp((e.stageX-startX) / 200); // 200 pixel is max speed
				moveAlbum(xSpeed);
				oldX = e.stageX;
				lastMoved = flash.utils.getTimer();
			});
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(createMousePanel) {
				_mousePanel.x = 0;
				_mousePanel.y = 0;
				_mousePanel.width = unscaledWidth;
				_mousePanel.height = unscaledHeight; 
			}
			
			_mask.graphics.beginFill(0xFF0000);
			_mask.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			
			_scene.x = Math.round(unscaledWidth/2);
			_scene.y = Math.round(unscaledHeight/2);
			_album.mask = _mask;
		}

		private function addPictureAt(index:int, bitmapData:BitmapData, label:String):void {
			var picture3d:Sprite3D = tileRenderer.createTile(bitmapData, label, tileWidth, tileHeight, fontSize);
			var row:Number = Math.floor(index / numRows) - 1;
			var col:Number = index % numRows - 1;
			var pw:Number = tileWidth + padding;
			var ph:Number = tileHeight + padding;
			picture3d.x = row * pw; 
			picture3d.y = col * ph - tileHeight/2;
			
			picture3d.transform.colorTransform = _darker;
			picture3d.buttonMode = true;
			_album.addChild(picture3d);
			  
			if(col==numRows-2 && showShadows) {
				var shadow:Bitmap3D = tileRenderer.createShadow(bitmapData, tileWidth, tileHeight, fontSize);
				tileRenderer.moveShadow(shadow, picture3d.x, picture3d.y + tileHeight, tileWidth, tileHeight, fontSize);
				_album.addChild(shadow);
			}
			_objLookup[picture3d] = _collection[index];
		}
		
		private function isClickTile(o:Object):Boolean {
			return (o is ITile) && !_zoomMode; 
		}
		
		private function onOver(me:MouseEvent):void {
			if (isClickTile(me.target)) {
				var tile:Sprite3D = Sprite3D(me.target);
				_album.swapChildren(_album.getChildAt(_album.numChildren-1), tile);
				tile.transform.colorTransform = _lighter;
				if(ITile(tile).label!=null)
					ITile(tile).label.visible = true;
				dispatchEvent(new AlbumEvent(AlbumEvent.ROLL_OVER_EVENT, _objLookup[me.target]));
			}
		}
		
		private function onOut(me:MouseEvent):void {
			if (isClickTile(me.target)) {
				var tile:Sprite3D = Sprite3D(me.target);
				tile.transform.colorTransform = _darker;
				if(ITile(tile).label!=null)
					ITile(tile).label.visible = false;
				dispatchEvent(new AlbumEvent(AlbumEvent.ROLL_OUT_EVENT, _objLookup[me.target]));
			}
		}
		
		private function moveAlbum(xSpeed:Number, ySpeed:Number=0):void {
			if (_zoomMode) return; 
			
			TweenLite.killTweensOf(_album);
			
			TweenLite.to(_album, .3, {
				rotationY: 35 * xSpeed,
				rotationX: -15 * ySpeed,
				ease: Sine.easeOut,
				onComplete: function():void {
					TweenLite.to(_album, .3, {
						rotationY: 0,
						rotationX: 0,
						ease: Sine.easeOut });
				}
			}); 
			
			TweenLite.to(_album, .6, {x: _album.x+xSpeed*width/2, ease: Sine.easeOut, overwrite: false});
		}
		
		private function createOnClick():Function {
			var zoomedPicture:Sprite3D;
			var oldAlbumX:Number;
			var oldAlbumY:Number;
			return function(me:MouseEvent):void {
				if (isClickTile(me.target)) {
					zoomedPicture = me.target as Sprite3D;
					if(ITile(zoomedPicture).label!=null)
						ITile(zoomedPicture).label.visible = false;
					
					TweenLite.killTweensOf(_album);
					oldAlbumX = _album.x;
					oldAlbumY = _album.y;
					
					TweenLite.to(_album, .6, {
						z: zoomViewZ,
						rotationX: 0,
						rotationY: 0,
						x: - me.target.x - tileWidth/2,
						y: - me.target.y - tileHeight/2,
						ease: Sine.easeInOut,
						onComplete: function():void {
							dispatchEvent(new AlbumEvent(AlbumEvent.CLICK_EVENT, _objLookup[me.target]));
							var filters:Array = new Array();
							filters.push(zoomFilter.newInstance());
							zoomedPicture.filters = filters;
						}
					});
					_zoomMode = true;
				} else if (_zoomMode) {
					zoomedPicture.transform.colorTransform = _darker;
					zoomedPicture.filters = new Array();
					
					TweenLite.killTweensOf(_album);
					TweenLite.to(_album, .3, {
						z: fullViewZ,
						x: oldAlbumX,
						y: oldAlbumY,
						ease: Sine.easeOut,
						onComplete: function():void {
							_zoomMode = false;
						}
					});
				}
			};
		}
		
	}
}







