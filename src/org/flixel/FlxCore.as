package org.flixel
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	
	/**
	 * This is the base class for most of the display objects (<code>FlxSprite</code>, <code>FlxText</code>, etc).
	 * It includes some basic attributes about game objects, including retro-style flickering,
	 * basic state information, sizes, and scrolling.  This class also contains the
	 * basic collision methods used by every flixel object.
	 */
	public class FlxCore
	{
		/**
		 * Kind of a global on/off switch for any objects descended from <code>FlxCore</code>.
		 */
		public var exists:Boolean;
		/**
		 * If an object is not alive, the game loop will not automatically call <code>update()</code> on it.
		 */
		public var active:Boolean;
		/**
		 * If an object is not visible, the game loop will not automatically call <code>render()</code> on it.
		 */
		public var visible:Boolean;
		/**
		 * If an object is dead, the functions that automate collisions will skip it (see <code>FlxG.overlapArrays()</code> and <code>FlxG.collideArrays()</code>).
		 */
		public var dead:Boolean;
		/**
		 * If an object is 'fixed' in space, it will not budge when it collides with a not-fixed object.
		 */
		public var fixed:Boolean;

		/**
		 * @default 0
		 */
		public var width:uint;
		/**
		 * @default 0
		 */
		public var height:uint;
		/**
		 * @default 0
		 */
		public var x:Number;
		/**
		 * @default 0
		 */
		public var y:Number;
		/**
		 * Stores the last position of the sprite, used by collision detection algorithm.
		 */
		public var last:Point;
		
		/**
		 * A point that can store numbers from 0 to 1 (for X and Y independently)
		 * that governs how much this object is affected by the camera subsystem.
		 * 0 means it never moves, like a HUD element or far background graphic.
		 * 1 means it scrolls along a the same speed as the foreground layer.
		 * scrollFactor is initialized as (1,1) by default.
		 */
		public var scrollFactor:Point;
		
		public var body : b2Body;
		
		public var shapes : Array;
		
		/**
		 * Internal helper used for retro-style flickering.
		 */
		protected var _flicker:Boolean;
		/**
		 * Internal helper used for retro-style flickering.
		 */
		protected var _flickerTimer:Number;
		
		/**
		 * Creates a new <code>FlxCore</code> object.
		 */
		public function FlxCore()
		{
			exists = true;
			active = true;
			visible = true;
			dead = false;
			fixed = false;
			
			width = 0;
			height = 0;
			x = 0;
			y = 0;
			last = new Point(x,y);
			
			scrollFactor = new Point(1,1);
			_flicker = false;
			_flickerTimer = -1;
		}
		
		virtual public function initPhysics(world:b2World) : void
		{
		}
		
		/**
		 * Called by <code>FlxLayer</code> when states are changed (if it belongs to a layer)
		 */
		virtual public function destroy():void
		{
			//Nothing to destroy by default, core just stores some simple variables.
		}
		
		/**
		 * Just updates the flickering.  <code>FlxSprite</code> and other subclasses
		 * override this to do more complicated behavior.
		 */
		virtual public function update():void
		{
			last.x = x;
			last.y = y;
			
			
			if (body != null)
			{
				x = body.GetPosition().x;
				y = body.GetPosition().y;				
			}
			
			if(flickering())
			{
				if(_flickerTimer > 0)
				{
					_flickerTimer -= FlxG.elapsed;
					if(_flickerTimer == 0)
						_flickerTimer = -1;
				}
				if(_flickerTimer < 0)
					flicker(-1);
				else
				{
					_flicker = !_flicker;
					visible = !_flicker;
				}
			}
		}
		
		/**
		 * <code>FlxSprite</code> and other subclasses override this to draw their contents to the screen.
		 */
		virtual public function render():void {}
		
		/**
		 * Checks to see if some <code>FlxCore</code> object overlaps this <code>FlxCore</code> object.
		 * 
		 * @param	Core	The object being tested.
		 * 
		 * @return	Whether or not the two objects overlap.
		 */
		virtual public function overlaps(Core:FlxCore):Boolean
		{
			var tx:Number = x;
			var ty:Number = y;
			if((scrollFactor.x != 1) || (scrollFactor.y != 1))
			{
				tx -= Math.floor(FlxG.scroll.x*(1-scrollFactor.x));
				ty -= Math.floor(FlxG.scroll.y*(1-scrollFactor.y));
			}
			var cx:Number = Core.x;
			var cy:Number = Core.y;
			if((Core.scrollFactor.x != 1) || (Core.scrollFactor.y != 1))
			{
				cx -= Math.floor(FlxG.scroll.x*(1-Core.scrollFactor.x));
				cy -= Math.floor(FlxG.scroll.y*(1-Core.scrollFactor.y));
			}
			if((cx <= tx-Core.width) || (cx >= tx+width) || (cy <= ty-Core.height) || (cy >= ty+height))
				return false;
			return true;
		}
		
		/**
		 * Checks to see if a point in 2D space overlaps this <code>FlxCore</code> object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	PerPixel	Whether or not to use per pixel collision checking (only available in <code>FlxSprite</code> subclass).
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		virtual public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			var tx:Number = x;
			var ty:Number = y;
			if((scrollFactor.x != 1) || (scrollFactor.y != 1))
			{
				tx -= Math.floor(FlxG.scroll.x*(1-scrollFactor.x));
				ty -= Math.floor(FlxG.scroll.y*(1-scrollFactor.y));
			}
			if((X <= tx) || (X >= tx+width) || (Y <= ty) || (Y >= ty+height))
				return false;
			return true;
		}
		
	
		/**
		 * Call this function to "kill" a sprite so that it no longer 'exists'.
		 */
		virtual public function kill():void
		{
			exists = false;
			dead = true;
		}
		
		/**
		 * Tells this object to flicker, retro-style.
		 * 
		 * @param	Duration	How many seconds to flicker for.
		 */
		public function flicker(Duration:Number=1):void { _flickerTimer = Duration; if(_flickerTimer < 0) { _flicker = false; visible = true; } }
		
		/**
		 * Check to see if the object is still flickering.
		 * 
		 * @return	Whether the object is flickering or not.
		 */
		public function flickering():Boolean { return _flickerTimer >= 0; }
		
		/**
		 * Check and see if this object is currently on screen.
		 * 
		 * @return	Whether the object is on screen or not.
		 */
		public function onScreen():Boolean
		{
			var p:Point = new Point();
			getScreenXY(p);
			if((p.x + width < 0) || (p.x > FlxG.width) || (p.y + height < 0) || (p.y > FlxG.height))
				return false;
			return true;
		}
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	P	Takes a <code>Point</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		virtual public function getScreenXY(P:Point=null):Point
		{
			if(P == null) P = new Point();
			P.x = Math.floor(x)+Math.floor(FlxG.scroll.x*scrollFactor.x);
			P.y = Math.floor(y)+Math.floor(FlxG.scroll.y*scrollFactor.y);
			return P;
		}
		
		/**
		 * Handy function for reviving game objects.
		 * Resets their existence flags and position, including LAST position.
		 * 
		 * @param	X	The new X position of this object.
		 * @param	Y	The new Y position of this object.
		 */
		virtual public function reset(X:Number,Y:Number):void
		{
			exists = true;
			active = true;
			visible = true;
			dead = false;
			last.x = x = X;
			last.y = y = Y;
			
			if (body)
			{
				body.SetPositionAndAngle(new b2Vec2(x, y), 0);
			}
		}
	}
}
