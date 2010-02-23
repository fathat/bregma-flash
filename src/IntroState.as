package  
{
	import org.flixel.*;
	
	public class IntroState extends FlxState
	{
		private var _captionChain : CaptionChain;
		
		public function IntroState() 
		{
			_captionChain = new CaptionChain([
				new Caption("bregma...", FlxG.width/2-20, FlxG.height/2-10, 0.75,2 , 0.75),
				new Caption("..where are you bregma..", FlxG.width / 2 - 70,  FlxG.height / 2 - 10, 0.75,2, 0.75)
				//new Caption("...", FlxG.width/2-10,  FlxG.height/2 - 10, 0.75, 2, 0.75)
			]);
			
			add(_captionChain);
			FlxG.playMusic(Music.Prelude);
		}
		
		override public function update() : void
		{
			super.update();
			
			if (FlxG.mouse.justPressed())
			{
				_captionChain.skip();
			}
			
			if(_captionChain.state == 'done') 
			{
				FlxG.switchState(PlayState);
			}
		}
	}
}