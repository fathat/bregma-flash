package
{
	import flash.display.Sprite;
	import flash.net.FileReferenceList;
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.*;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		/*[Embed(source = "../content/level0/layer0.txt", mimeType = "application/octet-stream")] public static var data_map:Class;
		[Embed(source = "../content/level0/layer1.txt", mimeType = "application/octet-stream")] public static var data_map2:Class;
		[Embed(source = "../content/level0/sheet.png", mimeType = "image/png")] public static var data_tiles:Class;*/
		
		[Embed(source = "../content/level1/level1.txt", mimeType = "application/octet-stream")] public static var data_map:Class;
		[Embed(source = "../content/level1/stuff.txt", mimeType = "application/octet-stream")] public static var stuff_map:Class;
		[Embed(source = "../content/level1/collision.txt", mimeType = "application/octet-stream")] public static var collision_map:Class;
		[Embed(source = "../content/level1/sheet.png", mimeType = "image/png")] public static var data_tiles:Class;
		[Embed(source = "../content/level1/collision.png", mimeType = "image/png")] public static var collision_tiles:Class;
		
		
		[Embed(source = "../content/level1/lighting.png", mimeType = "image/png")] public static var lighting_image:Class;
		[Embed(source = "../content/ui/vignette.png", mimeType = "image/png")] public static var VIGNETTE:Class;
		
		
		public var dynamicLayer:FlxLayer = new FlxLayer();
		public var particleLayer:FlxLayer = new FlxLayer();
		public var lighting:FlxSprite;
		public var vignette:FlxSprite;
		public var collisionMap:FlxTilemap;
		
		public var pragma : PragmaSprite;
		public var bregma : Cat;
		
		public var cats:Array = new Array();
		public var rain:Rain;
		
		public var _kid : Kid;
		
		private var fadeIn:Number = 0;
		
		public function PlayState()
		{
			super();
			
			dynamicLayer.world = world;
			
			screen.alpha = 0;
			var myMap : FlxTilemap = new FlxTilemap();
			myMap.loadMap(new data_map, data_tiles, 16, 16);
			add(myMap);
			
			var stuffMap : FlxTilemap = new FlxTilemap();
			stuffMap.loadMap(new stuff_map, data_tiles, 16, 16);
			add(stuffMap);
			
			collisionMap = new FlxTilemap();
			collisionMap.loadMap(new collision_map, collision_tiles, 16, 16);
			collisionMap.visible = false;
			add(collisionMap);
			
			FlxG.followBounds(0, 0, myMap.width-16, myMap.height-16);
			
			lighting = new FlxSprite(0, 0, lighting_image);
			lighting.blend = "multiply";
			
			vignette = new FlxSprite(0, 0, VIGNETTE);
			vignette.blend = "multiply";
			vignette.alpha = 0.9
			
			pragma = new PragmaSprite(270, 210);
			bregma = new Cat(230, 210, new RandomPathing());
			var hose : Hose = new Hose(pragma, bregma, particleLayer);
			
			rain = new Rain(screen);
			
			FlxG.follow(pragma);
			
			FlxG.play(Music.RainLoop, 1.0, true);
		
			add(dynamicLayer);
			add(rain);
			add(particleLayer);
			dynamicLayer.add(pragma);
			dynamicLayer.add(hose);
			dynamicLayer.add(bregma);
			
			
			
			addCats(32, 97, 96, 64, 24);
			
			addCats(270, 97, 300, 200, 12);
			
			//_kid = new Kid(290, 200, new RandomPathing());
			//dynamicLayer.add(_kid);
			
			FlxG.showCursor(Bregma.Cursor);
		}
		
		public function addCats(startx:Number, starty:Number, width:Number, height:Number, count:int) : void
		{
			var pathing : IBehavior = new RandomPathing();
			
			for (var i:int = 0; i < count; i++)
			{
				var c:Cat = new Cat(width * Math.random()+startx, height * Math.random() + starty, new RandomPathing());
				cats.push(c);
				dynamicLayer.add(c);
			}
		}
		
		override public function initPhysics():void 
		{
			super.initPhysics();
			
			world = new b2World(new b2Vec2(0, 0), false);
			trace("Initializing world physics... ", world);
		}
		
		override public function update():void 
		{
			super.update();
			fadeIn += FlxG.elapsed*0.5;
			if (fadeIn > 1)
				fadeIn = 1;
			screen.alpha = fadeIn;
			
			this.rain.update();
			
			if(FlxG.keys.justPressed("Q"))
				add(new FlxText(0, 0, 200, "BREGMA"));

			dynamicLayer.children().sortOn("foot_y");
		}
		
		override public function postProcess():void 
		{
			super.postProcess();
			
			screen.draw(lighting, FlxG.scroll.x, FlxG.scroll.y);
			rain.postProcess();
			screen.draw(vignette);
		}
		
	}
}