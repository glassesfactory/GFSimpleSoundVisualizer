/*////////////////////////////////////////////

GFSimpleSoundVisualyzer

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/02/09

Copyright 2010 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////


/**
 * sound.extract() で byteArray を取得したあと
 * 自力でゴニョゴニョ 
 */

package net.glassesfactory.ssv
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	

	public class GFSoundVisualizer extends Bitmap
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* getter / setter
		/*/////////////////////////////////
		
		/**
		 * EQのバンド数。 
		 * @default 8
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
		 * @default 1;
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
		 * @default 0xffffff
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
		 * @default false;
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
		 * @default 1; 
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
		 * ボリュームが小さく、あまり派手にならない場合はこの値を大きく、
		 * 大きすぎる場合は 0.n ~ で調整。
		 * 音量の調整ではないです。
		 * @return 
		 */		
		public function get visualGain():Number{ return _visualGain; }
		public function set visualGain( value:Number ):void{ _visualGain = value; }
		private var _visualGain:Number = 1;
		
		
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
		//test
		private var _data:Vector.<int>;
		private var _tmpWave:Vector.<Number> = new Vector.<Number>( 2048, true );
		
		//test
		private var _imag:Vector.<Number>;
		private var _bytes:ByteArray;
		private var _view:BitmapData;
		private var _column:int;
		private var _sc:SoundChannel;
		private var _samplingRate:Number = 0;
		private var _soundPos:int = 0;
		
		private const PI:Number = Math.PI; 
		private var _fft:GFFFT;
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function GFSoundVisualizer( thickness:uint = 1, color:uint = 0xffffff, source:Sound = null )
		{
			super( _view, "auto", false );
			_thickness = thickness;
			_source = source;
			_bytes = new ByteArray();
			_fft = new GFFFT();
			_initializeView();
		}
		
		
		/**
		 * 見た目を初期化します。 
		 * @param thickness
		 */		
		public function visualInit( thickness:uint, color:uint, transpearent:Boolean ):void
		{
			_thickness = thickness;
			_color = color;
			_transpearent = transpearent;
			_initializeView();
		}
		
		
		/**
		 * 解析するサウンドを変えます。 
		 * @param source
		 * 
		 */		
		public function regiserSound( source:Sound ):void
		{
			_source = source;
		}
		
		
		public function play():SoundChannel
		{
			this.addEventListener( Event.ENTER_FRAME, _enterFrameHandler );
			_sc = _source.play();
			return _sc;
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		private function _initializeView():void
		{
			_column = _thickness + _margin;
			_view = new BitmapData( _column * _band, _column * _band, _transpearent, _backgroundColor );
			_data = new Vector.<int>( 8 );
			this.bitmapData = _view;
		}
		
		
		/**
		 * 毎フレーム実行される処理。 
		 * @param e
		 * 
		 */		
		private function _enterFrameHandler( e:Event ):void
		{
			update();
			draw();
		}
		
		public function update():void
		{
			if( _source.length != 0 )
			{
				_bytes = new ByteArray();
				_soundPos = int( _sc.position / 2048 * 44100 );
				_samplingRate = _source.extract( _bytes, 2048, _soundPos );
				var l:Number;
				var r:Number;
				
				for( var i:int = 0; i < _samplingRate; ++i )
				{
					_bytes.position = int( i ) * 4;
					l = _bytes.readFloat();
					_bytes.position = int( i ) * 4 + 4;
					r = _bytes.readFloat();
					//でかいほう取る
					_tmpWave[i] = ( l < r ) ? r : l;
				}
				_fft.cdft( 1, _tmpWave );
				
				var  d:int;
				var value:Number;
				for( i = 0; i < 256; ++i )
				{
					d = i /  ( 256 / _band ) | 0;
					//test
					value =  _tmpWave[d * i];
					value = Math.abs( value * 10 );
					if( d < _band )
					{
						_data[d] = Math.round( value * _visualGain * _thickness );
					}
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
			var i:int, j:int;
			for( i = 0; i < _band; ++i )
			{
				xx = i * _column;
				row = _data[i];
				columnloop: for( j = 0; j < _thickness; ++j )
				{
					if( row < 1 ){ continue columnloop; }
					else if( row > _view.height ){ row = _view.height; } 
					for( yy = 0; yy < row; ++yy )
					{
						_view.setPixel32( xx, _view.height - yy, _color );
					}
					xx++;
				}
			}
			_view.unlock( _view.rect );
		}
		
		/**
		 * IIRピーキングフィルタを使えばバンド数固定にはなるけど周波数帯を指定して取得できる…はず…
		 * そのうちロジックに組み込み予定 
		 */		
		/*
		private function _iirPeaking( fc:Number, q:Number, g:Number, a:Vector.<Number>, b:Vector.<Number> ):void
		{
			fc = Math.tan( PI * fc) / (2.0 * PI);
			
			a[0] = 1.0 + 2.0 * PI * fc / q + 4.0 * PI * PI * fc * fc;
			a[1] = ( 8.0 * PI * PI * fc * fc - 2.0 ) / a[0];
			a[2] = ( 1.0 - 2.0 * PI * fc / q + 4.0 * PI * PI * fc * fc ) / a[0];
			b[0] = ( 1.0 + 2.0 * PI * fc / q * (1.0 + g ) + 4.0 * PI * PI * fc * fc ) / a[0];
			b[1] = ( 8.0 * PI * PI * fc * fc - 2.0 ) / a[0];
			b[2] = ( 1.0 - 2.0 * PI * fc / q * ( 1.0 + g ) + 4.0 * PI * PI * fc * fc ) / a[0];
			
			a[0] = 1.0;
		}
		*/
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		
	}
}