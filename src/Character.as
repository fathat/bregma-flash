package  
{
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
	import flash.geom.Point;
	import org.flixel.data.FlxAnim;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Ian
	 */
	public class Character extends FlxSprite
	{
		
		public function Character(x:Number = 0, y:Number = 0, image:Class = null)
		{
			super(x, y, image);
			
		}
		
		override public function initPhysics(world:b2World):void 
		{
			super.initPhysics(world);
			
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(x, y);
			bodyDef.active = true;
			bodyDef.type = b2Body.b2_dynamicBody;
			body = world.CreateBody(bodyDef);
			
			body.CreateFixture2(new b2CircleShape(this.width/2), 1.0);
			body.SetLinearDamping(10.0);
			body.SetAwake(true);
		}
		
		public function get center() : Point {
			return new Point(x+this.width/2, y+this.height/2);
		}
		
		public function set center(p:Point) : void {
			x = p.x - width / 2;
			y = p.y - height / 2;
		}
		
		public function get foot() : Point {
			return new Point(x+this.width/2, y+this.height);
		}
		
		
		public function get foot_y() : Number {
			return y+this.height;
		}
		
	}

}