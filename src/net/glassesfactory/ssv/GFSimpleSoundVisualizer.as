/*////////////////////////////////////////////

GFSimpleSoundVisualizer

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/02/14

Copyright 2011 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////


/**
 * とりあえず SoundMixer.computeSpectrumを使用した版　 
 */

package net.glassesfactory.ssv
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;

	public class GFSimpleSoundVisualizer extends Bitmap
	{
		/*/////////////////////////////////
		* getter / setter
		/*/////////////////////////////////
		
		/**
		 * EQのバンド数。 
		 * @return 
		 * 
		 */		
		public function get band():uint{ return _band; }
		public function set band( value:uint ):void
		{
			if( value < 2 ){ throw new Error( "2以上を指定してください" ); }
			_band = value | 0;
			_initializeView();
		}
		private var _band:uint = 8;
		
		
		/**
		 * EQゲージの太さ 
		 * @return 
		 */		
		public function get thickness():uint{ return _thickness; }
		public function set thickness( value:uint ):void
		{
			if( thickness < 1 ){ throw new Error( "1以上を指定してください。" ); }
			_thickness = value | 0;
			_initializeView();
		}
		private var _thickness:uint = 1;
		
		/**
		 * EQゲージの色
		 * @return 
		 * 
		 */		
		public function get color():uint{ return _color; }
		public function set color( value:uint ):void
		{
			_color = value;
			_initializeView();
		}
		private var _color:uint = 0xffffff;
		
		/**
		 * 塗りつぶしの背景色 
		 * @return 
		 * 
		 */		
		public function get backgroundColor():uint{ return _backgroundColor; }
		public function set backgroundColor( value:uint ):void
		{
			_backgroundColor = value;
			_initializeView();
		}
		private var _backgroundColor:uint = 0x000000;
		
		
		/**
		 * 透過するかどうか 
		 * @return 
		 * 
		 */		
		public function get transpearent():Boolean{ return _transpearent; }
		public function set transpearent( value:Boolean ):void
		{
			_transpearent = value;
			_initializeView();
		}
		private var _transpearent:Boolean = false;
		
		
		/**
		 * EQゲージの間隔 
		 * @return 
		 * 
		 */		
		public function get margin():uint{ return _margin; }
		public function set margin( value:uint ):void
		{
			_margin = value;
			_initializeView();
		}
		private var _margin:uint = 1;
		
		
		/**
		 * 対象となるサウンド 
		 * @return 
		 * 
		 */		
		public function get sound():Sound{ return _source; }
		public function set sound( value:Sound ):void
		{
			_source = value;
		}
		private var _source:Sound;
		
		
		//--private---
		private var _buffer:Vector.<Vector.<Number>>;
		private var _data:Vector.<int>;
		private var _bytes:ByteArray;
		private var _view:BitmapData;
		private var _column:int;
		
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		/**
		 * コンストラクタ 
		 * @param divide EQ のバンド数。
		 * @param thickness EQゲージの太さ
		 * @param color EQゲージの色
		 * @param source 対象となるサウンド
		 * 
		 */		
		public function GFSimpleSoundVisualizer( band:uint = 8, thickness:uint = 1, color:uint = 0xffffff, source:Sound = null )
		{
			super( _view, "auto", false );
			_band = band;
			_thickness = thickness;
			_source = source;
			_color = color;
			
			_buffer = new Vector.<Vector.<Number>>( 2, true );
			_bytes = new ByteArray();
			
			_initializeView();
		}
		
		
		/**
		 * 見た目だけを初期化します。 
		 * @param thickness
		 */		
		public function visualInit( thickness:uint = 1, color:uint = 0xffffff, transpearent:Boolean = false ):void
		{
			_thickness = thickness;
			_color = color;
			_transpearent = transpearent;
			_initializeView();
		}
		
		/**
		 * 再生を開始します。 
		 */		
		public function play():void
		{
			this.addEventListener( Event.ENTER_FRAME, _enterFrameHandler );
			_source.play();
		}
		
		
		/**
		 * 停止します。 
		 */		
		public function stop():void
		{
			this.removeEventListener( Event.ENTER_FRAME, _enterFrameHandler );
			_source.close();
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		/**
		 * 見た目の初期化 
		 */		
		private function _initializeView():void
		{
			_column = _thickness + _margin;
			_view = new BitmapData( _column * _band, _column * _band, _transpearent, _backgroundColor );
			_data = new Vector.<int>();
			this.bitmapData = _view;
		}
		
		
		private function _enterFrameHandler( e:Event ):void
		{
			update();
			draw();
		}
		
		
		/**
		 * サウンド解析したデータをアップデート 
		 */		
		public function update():void
		{
			SoundMixer.computeSpectrum( _bytes, true, 0 );
			
			var value:Number = 0;
			
			for( var i:int = 0; i < 256; ++i )
			{
				value = _bytes.readFloat();
				var d:int = i /  ( 256 / _band ) | 0;
				if( d < _band )
				{
					_data[d] = Math.round( value / _band * 100 * _thickness );
				}
			}
		}
		
		
		/**
		 * 描画 
		 */		
		public function draw():void
		{
			_view.lock();
			_view.fillRect( _view.rect, _backgroundColor );
						
			var row:int;
			var xx:int, yy:int;
			for( var i:int = 0; i < _band; ++i )
			{
				xx = i * _column;
				row = _data[i];
				outerloop: for( var j:int = 0; j < _thickness; ++j )
				{
					
					if( row < 1 ){ continue outerloop; }
					
					for( yy = 0; yy < row; ++yy )
					{
						_view.setPixel32( xx, _view.height - yy, _color );
					}
					xx++;
				}
			}
			_view.unlock( _view.rect );
		}
	}
}