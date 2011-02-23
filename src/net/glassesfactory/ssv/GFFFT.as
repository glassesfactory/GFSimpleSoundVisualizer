/*////////////////////////////////////////////

GFSimpleSoundVisualizer

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/02/16

Copyright 2010 glasses factory
http://glasses-factory.net

original
General Purpose FFT (Fast Fourier/Cosine/Sine Transform) Package free license.
Copyright Takuya OOURA, 1996-2001

http://www.kurims.kyoto-u.ac.jp/~ooura/fftman/

/*////////////////////////////////////////////

/**
 * FFT module; 
 */

package net.glassesfactory.ssv
{
	public class GFFFT
	{
		//テーブル系
		private var _waveTable:Vector.<Number> = new Vector.<Number>();
		private var _btTmp:Vector.<Number> = new Vector.<Number>(256);
		private var _len:Number = 0;
		
		//Constractor
		public function GFFFT()
		{
			_makeWaveTable();
		}
				
		public function cdft( isgn:int, source:Vector.<Number> ):void
		{
			if( isgn >= 0 )
			{
				_bitrv2( source, _len );
				_cftfsub( source, _len );
			}
			else
			{
				_bitrv2conj( source, _len );
				_cftfsub( source, _len );
			}
		}
		
		
		/**
		 * 計算用テーブルの初期化 
		 */		
		private function _makeWaveTable():void
		{
			_len = 2048 >> 1;
			_waveTable.length = _len >> 2;
			var i:int, iMax:int = _len >> 3,tableLen:int = _waveTable.length, 
			delta:Number, x:Number, y:Number;
			
			delta = 0.000743744292926;
			_waveTable[0] = 1;
			_waveTable[1] = 0;
			_waveTable[iMax + 1] = _waveTable[iMax] = 0.999911658341005;
			
			for( i = 0; i < iMax; i += 2 )
			{
					x = Math.cos( delta * i );
					y = Math.sin( delta * i );
					_waveTable[i] = x;
					_waveTable[i + 1] = y;
					_waveTable[tableLen - i] = y;
					_waveTable[tableLen - i + 1] = x;
			}
			_bitrv2( _waveTable, tableLen );
		}
		
		
		private function _bitrv2( source:Vector.<Number>, len:int ):void
		{
			var j:int, j1:int, k:int, k1:int, l:int, m:int, m2:int;
			var xr:Number, xi:Number, yr:Number, yi:Number;
			
			_btTmp[0] = 0;
			l = len;
			m = 1;
			
			while(( m << 3 ) < l )
			{
				l >>= 1;
				for( j = 0; j < m; j++ )
				{
					_btTmp[m + j] = _btTmp[j] + l;
				}
				m <<= 1;
			}
			
			m2 = 2 * m;
			if(( m << 3 ) == l )
			{
				for( k = 0; k < m; k++ )
				{
					for( j = 0; j < k; j++ )
					{
						j1 = 2 * j + _btTmp[k];
						k1 = 2 * k + _btTmp[j];
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 += 2 * m2;
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 +1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 -= m2;
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 +1] = xi;
						j1 += m2;
						k1 += 2 * m2;
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
					}
					j1 = 2 * k + m2 + _btTmp[k];
					k1 = j1 + m2;
					xr = source[j1];
					xi = source[j1 + 1];
					yr = source[k1];
					yi = source[k1 + 1];
					source[j1] = yr;
					source[j1 + 1] = yi;
					source[k1] = xr;
					source[k1 + 1] = xi;
				}
			}
			else
			{
				for( k = 1; k < m; k++ )
				{
					for( j = 0; j < k; j++ )
					{
						j1 = 2 * j + _btTmp[k];
						k1 = 2 * k + _btTmp[j];
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 += m2;
						xr = source[j1];
						xi = source[j1 + 1];
						yr = source[k1];
						yi = source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
					}
				}
			}
		}
		
		
		private function _bitrv2conj( source:Vector.<Number>, len:int ):void
		{
			var j:int, j1:int, k:int, k1:int, l:int, m:int, m2:int;
			var xr:Number, xi:Number, yr:Number, yi:Number;
			
			_btTmp[0] = 0;
			l = len;
			m = 1;
			
			while(( m << 3 ) < l )
			{
				l >>= 1;
				for( j = 0; j < m; j++ )
				{
					_btTmp[m + j] = _btTmp[j] + l;
				}
				m <<= 1;
			}
			m2 = 2 * m;
			if(( m << 3 ) == l )
			{
				for( k = 0; k < m; k++ )
				{
					for( j = 0; j < k; j++ )
					{
						j1 = 2 * j + _btTmp[k];
						k1 = 2 * k + _btTmp[j];
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						j1 += m2;
						k1 += 2 * m2;
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 -= m2;
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						source[j1] = yr;
						source[j1 +1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 += 2 * m2;
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
					}
					k1 = 2 * k + _btTmp[k];
					source[k1 +1] = -source[k1 + 1];
					j1 = k1 + m2;
					k1 = j1 + m2;
					xr = source[j1];
					xi = -source[j1 + 1];
					yr = source[k1];
					yi = -source[k1 + 1];
					source[j1] = yr;
					source[j1 + 1] = yi;
					source[k1] = xr;
					source[k1 + 1] = xi;
					k1 += m2;
					source[k1 + 1] = -source[k1 + 1];
				}
			}
			else
			{
				source[1] = -source[1];
				source[m2 + 1] = -source[m2 + 1];
				for( k = 1; k < m; k++ )
				{
					for( j = 0; j < k; j++ )
					{
						j1 = 2 * j + _btTmp[k];
						k1 = 2 * k + _btTmp[j];
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
						j1 += m2;
						k1 += m2;
						xr = source[j1];
						xi = -source[j1 + 1];
						yr = source[k1];
						yi = -source[k1 + 1];
						source[j1] = yr;
						source[j1 + 1] = yi;
						source[k1] = xr;
						source[k1 + 1] = xi;
					}
					k1 = 2 * k + _btTmp[k];
					source[k1 + 1] = -source[k1 + 1];
					source[k1 + m2 + 1] = -source[k1 + m2 + 1];
				}
			}
		}
		
		
		private function _cftfsub( source:Vector.<Number>, len:int ):void
		{
			var j:int, j1:int, j2:int, j3:int, l:int,
			x0r:Number, x0i:Number, x1r:Number, x1i:Number, x2r:Number, x2i:Number, x3r:Number, x3i:Number;
			
			l = 2;
			_cft1st( source );
			l = 8;
			while(( l << 2 ) == _len )
			{
				_cftmdl( source, l );
				l <<= 2;
			}
			
			if(( l << 2 ) == _len )
			{
				for( j = 0; j < l; j += 2 )
				{
					j1 = j + l;
					j2 = j1 + l;
					j3 = j2 + l;
					x0r = source[j] + source[j1];
					x0i = -source[j + 1] - source[j1 + 1];
					x1r = source[j] - source[j1];
					x1i = -source[j + 1] + source[j1 + 1];
					x2r = source[j2] + source[j3];
					x2i = source[j2 + 1] + source[j3 + 1];
					x3r = source[j2] - source[j3];
					x3i = source[j2 + 1] - source[j3 + 1];
					source[j] = x0r + x2r;
					source[j + 1] = x0i - x2i;
					source[j2] = x0r - x2r;
					source[j2 + 1] = x0i + x2i;
					source[j1] = x1r - x3i;
					source[j1 + 1] = x1i - x3r;
					source[j3] = x1r + x3i;
					source[j3 + 1] = x1i + x3r;
				}
			}
			else
			{
				for( j = 0; j < l; j += 2 )
				{
					j1 = j + l;
					x0r = source[j] - source[j1];
					x0i = -source[j + 1] + source[j1 +1];
					source[j] += source[j1];
					source[j + 1] = -source[j + 1] - source[j1 + 1];
					source[j1] = x0r;
					source[j1 + 1] = x0i;
				}
			}
		}
		
		
		private function _cft1st( source:Vector.<Number> ):void
		{
			var j:int, k1:int, k2:int,
			wk1r:Number, wk1i:Number, wk2r:Number, wk2i:Number, wk3r:Number, wk3i:Number,
			x0r:Number, x0i:Number, x1r:Number, x1i:Number, x2r:Number, x2i:Number, x3r:Number, x3i:Number;
			
			x0r = source[0] + source[2];
			x0i = source[1] + source[3];
			x1r = source[1] - source[2];
			x1i = source[1] - source[3];
			x2r = source[4] + source[6];
			x2i = source[5] + source[7];
			x3r = source[4] - source[6];
			x3i = source[5] - source[7];
			source[0] = x0r + x2r;
			source[1] = x0i + x2i;
			source[4] = x0r - x2r;
			source[5] = x0i - x2i;
			source[2] = x1r - x3i;
			source[3] = x1i + x3r;
			source[6] = x1r + x3i;
			source[7] = x1i - x3r;
			wk1r = _waveTable[2];
			x0r = source[8] + source[10];
			x0i = source[9] + source[11];
			x1r = source[8] - source[10];
			x1i = source[9] - source[11];
			x2r = source[12] + source[14];
			x2i = source[13] + source[15];
			x3r = source[12] - source[14];
			x3i = source[13] - source[15];
			source[8] = x0r + x2r;
			source[9] = x0i + x2i;
			source[12] = x2i - x0i;
			source[13] = x0r - x2r;
			x0r = x1r - x3i;
			x0i = x1i + x3r;
			source[14] = wk1r * ( x0i - x0r );
			source[15] = wk1r * ( x0i + x0r );
			k1 = 0;
			
			for( j = 16; j < _len; j += 16 )
			{
				k1 += 2;
				k2 = 2 * k1;
				wk2r = _waveTable[k1];	wk2i = _waveTable[k1 + 1];
				wk1r = _waveTable[k2];	wk1i = _waveTable[k2 + 1];
				wk3r = wk1r - 2 * wk2i * wk1i;
				wk3i = 2 * wk2i * wk1r - wk1i;
				x0r = source[j] + source[j + 2];	x0i = source[j + 1] + source[j + 3];
				x1r = source[j] - source[j + 2];	x1i = source[j + 1] - source[j + 3];
				x2r = source[j + 4] + source[j + 6]; x2i = source[j + 5] + source[j + 7];
				x3r = source[j + 4] - source[j + 6]; x3r = source[j + 5] - source[j + 7]; 
				
				source[j] = x0r + x2r;
				source[j + 1] = x0i + x2i;
				x0r -= x2r; x0i -= x2i;
				source[j + 4] = wk2r * x0r - wk2i * x0i;
				source[j + 5] = wk2r * x0i + wk2i * x0r;
				x0r = x1r - x3i;	x0i = x1i + x3r;
				source[j + 2] = wk1r * x0r - wk1i * x0i;
				source[j + 3] = wk1r * x0i + wk1i * x0r;
				x0r = x1r + x3i;	x0i = x1i - x3r;
				source[j + 6] = wk3r * x0r - wk3i * x0i;
				source[j + 7] = wk3r * x0i + wk3i * x0r;
				wk1r = _waveTable[k2 + 2];	wk1i = _waveTable[k2 + 3];
				wk3r = wk1r - 2 * wk2r * wk1i;
				wk3i = 2 * wk2r * wk1r - wk1i;
				x0r = source[j + 8] + source[j + 10];
				x0i = source[j + 9] + source[j + 11];
				x1r = source[j + 8] - source[j + 10];
				x1i = source[j + 9] - source[j + 11];
				x2r = source[j + 12] + source[j + 14];
				x2i = source[j + 13] + source[j + 15];
				x3r = source[j + 12] - source[j + 14];
				x3i = source[j + 13] - source[j + 15];
				source[j + 8] = x0r + x2r;
				source[j + 9] = x0i + x2i;
				x0r -= x2r; 	x0i -= x2i;
				source[j + 12] = -wk2i * x0r - wk2r * x0i;
				source[j + 13] = -wk2i * x0i + wk2r * x0r;
				x0r = x1r - x3i;	x0i = x1i + x3r;
				source[j + 10] = wk1r * x0r - wk1i * x0i;
				source[j + 11] = wk1r * x0i + wk1i * x0r;
				x0r = x1r + x3i;	x0i = x1i - x3r;
				source[j + 14] = wk3r * x0r - wk3i * x0i;
				source[j + 15] = wk3r * x0i + wk3i * x0r;
			}
		}
		
		private function _cftmdl( source:Vector.<Number>, len:int ):void
		{
			var j:int, j1:int, j2:int, j3:int, k:int, k1:int, k2:int, m:int, m2:int,
			wk1r:Number, wk1i:Number, wk2r:Number, wk2i:Number, wk3r:Number, wk3i:Number,
			x0r:Number, x0i:Number, x1r:Number, x1i:Number, x2r:Number, x2i:Number, x3r:Number, x3i:Number;
			
			m = len << 2;
			
			for( j = 0; j < len; j += 2 )
			{
				j1 = j + len;
				j2 = j1 + len;
				j3 = j2 + len;
				x0r = source[j] + source[j1];
				x0i = source[j + 1] + source[j1 + 1];
				x1r = source[j] - source[j1];
				x1i = source[j + 1] - source[j1 + 1];
				x2r = source[j2] + source[j3];
				x2i = source[j2 + 1] + source[j3];
				x3r = source[j2] - source[j3];
				x3i = source[j2 + 1] - source[j3 + 1];
				source[j] = x0r + x2r;
				source[j + 1] = x0i + x2i;
				source[j2] = x0r - x2r;
				source[j2 + 1] = x0i - x2i;
				source[j1] = x1r - x3r;
				source[j1 + 1] = x1i + x3r;
				source[j3] = x1r + x3i;
				source[j3 + 1] = x1i - x3r;
			}
			
			wk1r = _waveTable[2];
			
			for( j = m; j < len + m; j += 2 )
			{
				j1 = j + len;
				j2 = j1 + len;
				j3 = j2 + len;
				x0r = source[j] + source[j1];
				x0i = source[j + 1] + source[j1 + 1];
				x1r = source[j] - source[j1];
				x1i = source[j + 1] - source[j1 + 1];
				x2r = source[j2] + source[j3];
				x2i = source[j2 + 1] + source[j3 + 1];
				x3r = source[j2] - source[j3];
				x3i = source[j2 +1] - source[j3 + 1];
				source[j] = x0r + x2r;
				source[j + 1] = x0i + x2i;
				source[j2] = x2i - x0i;
				source[j2 + 1] = x0r - x2r;
				x0r = x1r - x3i;
				x0i = x1i + x3r;
				source[j1] = wk1r * ( x0r - x0i );
				source[j1 + 1] =  wk1r * ( x0r + x0i );
				x0r = x3i + x1r;
				x0i = x3r - x1i;
				source[j3] = wk1r * ( x0i - x0r );
				source[j3 + 1] = wk1r * ( x0i + x0r );
			}
			k1 = 0;
			m2 = 2 * m;
			
			for( k = m2; k < _len; k += m2 )
			{
				k1 += 2;
				k2 = 2 * k1;
				wk2r = _waveTable[k1];
				wk2i = _waveTable[k1 + 1];
				wk1r = _waveTable[k2];
				wk1i = _waveTable[k2 + 1];
				wk3r = wk1r - 2 * wk2i * wk1i;
				wk3i = 2 * wk2i * wk1r - wk1i;
				
				for( j = k; j < len + k; j += 2 )
				{
					j1 = j + len;
					j2 = j1 + len;
					j3 = j2 + len;
					x0r = source[j] + source[j1];
					x0i = source[j + 1] + source[j1 + 1];
					x1r = source[j] - source[j1];
					x1i = source[j + 1] - source[j1 + 1];
					x2r = source[j2] + source[j3];
					x2i = source[j2 + 1] + source[j3 + 1];
					x3r = source[j2] - source[j3];
					x3i = source[j2 + 1] - source[j3 + 1];
					source[j] = x0r + x2r;
					source[j + 1] = x0i + x2i;
					x0r -= x2r;
					x0i -= x2i;
					source[j2] = wk2r * x0r - wk2i * x0i;
					source[j2 + 1] = wk2r * x0i + wk2i * x0r;
					x0r = x1r - x3i;
					x0i = x1i + x3r;
					source[j1] = wk1r * x0r - wk1i * x0i;
					source[j1 + 1] = wk1r * x0i + wk1i * x0r;
					x0r = x1r + x3i;
					x0i = x1i - x3r;
					source[j3] = wk3r * x0r - wk3i * x0i;
					source[j3 + 1] = wk3r * x0i + wk3i * x0r;
				}
				wk1r = _waveTable[k2 + 2];
				wk1i = _waveTable[k2 + 3];
				wk3r = wk1r - 2 * wk2r * wk1i;
				wk3i = 2 * wk2r * wk1r - wk1i;
				for( j = k + m; j < len +(k + m); j += 2 )
				{
					j1 = j + len;
					j2 = j1 + len;
					j3 = j2 + len;
					x0r = source[j] + source[j1];
					x0i = source[j + 1]  + source[j1 + 1];
					x1r = source[j] - source[j1];
					x1i = source[j + 1] - source[j1 + 1];
					x2r = source[j2] + source[j3];
					x2i = source[j2 + 1] - source[j3 + 1];
					x3r = source[j2] - source[j3];
					x3i = source[j2 + 1] - source[j3 + 1];
					source[j] = x0r + x2r;
					source[j + 1] = x0i + x2i;
					x0r -= x2r;
					x0i -= x2i;
					source[j2] = -wk2i * x0r - wk2r * x0i;
					source[j2 + 1] = -wk2i * x0i + wk2r * x0r;
					x0r = x1r - x3i;
					x0i = x1i + x3r;
					source[j1] = wk1r * x0r - wk1i * x0i;
					source[j1 + 1] = wk1r * x0i + wk1i * x0r;
					x0r = x1r + x3i;
					x0i = x1i - x3r;
					source[j3] = wk3r * x0r - wk3i * x0i;
					source[j3 + 1] = wk3i * x0i + wk3i * x0r;
				}
			}
		}
	}
}