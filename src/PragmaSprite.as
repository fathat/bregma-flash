﻿package  
{
	import Box2D.Common.Math.b2Vec2;
	import flash.geom.Point;
	import org.flixel.*;
	
	import Math;
	
	public class PragmaSprite extends Character
	{	
		protected static var SPEED : Number = 60;
		protected static var ANIMATION_SPEED : Number = 12;
		
		[Embed(source="../content/sprites/pragma_smal.png")]
		protected var PragmaImage: Class;
		
		
		[Embed(source="../content/sounds/foot_left.mp3")]
		protected var FootLeft: Class;
		
		[Embed(source="../content/sounds/foot_right.mp3")]
		protected var FootRight: Class;
		
		public var knockBack:b2Vec2 = new b2Vec2();
		
		public var nextStep:int = 0;
		public var stepDelay:Number = 0;
		
		public function PragmaSprite(x : Number, y : Number) 
		{
			super(x, y, null);
			
			loadGraphic(PragmaImage, true, false, 12, 16, false);
			
			addAnimation("walk-up", [1, 0, 1, 2], ANIMATION_SPEED, true); 
			addAnimation("walk-right", [4, 3, 4, 5], ANIMATION_SPEED, true);
			addAnimation("walk-down", [7, 6, 7, 8], ANIMATION_SPEED, true);
			addAnimation("walk-left", [10, 9, 10, 11], ANIMATION_SPEED, true);
		
			addAnimation("idle-up", [1], 1, false);
			addAnimation("idle-right", [4], 1, false);
			addAnimation("idle-down", [7], 1, false);
			addAnimation("idle-left", [10], 1, false);
		}	
		
		
		override public function update():void 
		{
			var action : String = "idle";
			var direction : String = look_direction();
			
			velocity = new b2Vec2(0, 0)
			velocity.Add(knockBack);
			
			if (FlxG.keys.pressed('W')) {
				velocity.y -= SPEED;
				action = "walk";
				
			} 
			if (FlxG.keys.pressed('S')) {
				velocity.y += SPEED;
				action = "walk";
			} 
			if (FlxG.keys.pressed('A')) {
				velocity.x -= SPEED;
				action = "walk";
			} 
			if (FlxG.keys.pressed('D')) {
				velocity.x += SPEED;
				action = "walk";
			}
			
			if (FlxG.keys.justPressed('X')) {
				var choice:int = Math.random() * 4;
				if (choice == 0)
					FlxG.play(Sounds.BREGMA_CALL_1);
				else if (choice == 1)
					FlxG.play(Sounds.BREGMA_CALL_2);
				else if (choice == 2)
					FlxG.play(Sounds.BREGMA_CALL_3);
				else if (choice == 3)
					FlxG.play(Sounds.BREGMA_CALL_4);
			}
			
			if (FlxG.keys.justPressed('Z')) {
				FlxG.play(Sounds.BREGMA_SONG);

			}
			
			if (action == "walk")
			{
				stepDelay -= FlxG.elapsed;
				if (stepDelay <= 0)
				{
					if (nextStep == 0)
					{
						FlxG.play(FootLeft, 0.5);
						nextStep = 1;
					}
					else
					{
						FlxG.play(FootRight, 0.5);
						nextStep = 0;
					}
					stepDelay = 2.0 / ANIMATION_SPEED ;
				}
			}
			
			play(action + "-" + direction);
			knockBack = new b2Vec2(0, 0);
			super.update();
		}
		
		private function look_direction() : String
		{
			var dx : Number = FlxG.mouse.x - this.x;
			var dy : Number = FlxG.mouse.y - this.y;
			
			var l : Number = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
			
			var nx : Number = dx / l;
			var ny : Number = dy / l;
			
			if (Math.abs(nx) > Math.abs(ny)) {
				return (nx > 0) ? 'right' : 'left';
			} else {
				return (ny > 0) ? 'down' : 'up';
			}
		}
	}
}