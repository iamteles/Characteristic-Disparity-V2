package states.cd;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import data.GameData.MusicBeatState;
import flixel.text.FlxText;
import flixel.sound.FlxSound;
import data.DoidoVideoSprite;
#if !html5
import sys.thread.Mutex;
import sys.thread.Thread;
#end

class Intro extends MusicBeatState
{
	var sprite:FlxSprite;
	var spriteSD:FlxSprite;
	override public function create():Void 
	{
		super.create();

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
		color.screenCenter();
		add(color);
        
		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("menu/intros/flixel");
		sprite.animation.addByPrefix('start', 		'haxe', 24, false);
		sprite.animation.addByPrefix('startI', 		'haxe0000', 24, false);
		sprite.animation.play('startI');
		sprite.updateHitbox();
		sprite.screenCenter();
		//sprite.x += 30;
		sprite.alpha = 0;
		add(sprite);

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			sprite.alpha = 1;
			sprite.animation.play('start');
			FlxG.sound.play(Paths.sound("intro/haxe"), 1, false, null, true);
		});

		new FlxTimer().start(3.2, function(tmr:FlxTimer)
		{
			finish();
		});
	
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (Controls.justPressed("ACCEPT") && SaveData.progression.get("firstboot"))
		{
			finish();
		}
	}
	
	private function finish():Void
	{
		Main.skipClearMemory = true;
		states.VideoState.name = "intro";
		Main.switchState(new states.VideoState());
	}
	
}

class Warning extends MusicBeatState
{
	var isPlaytester:Bool = false;
	override public function create():Void 
	{
		super.create();

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var tiles = new FlxBackdrop(Paths.image('all'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.7;
        add(tiles);

		var tex:String = "Warning!\n\nThis mod features flashing lights that may\nbe harmful to those with photosensitivity.\nYou can disable them in the Options menu.\n\nPress ENTER to continue!";
		if(isPlaytester)
			tex = "Hello playtester!\n\nThank you so much for helping us ensure\nthe mod has a bug-free experience.\nWe ask you that you NOT share anything in this\nbuild to anyone to keep the surprise!\nPlease report any bugs in the Google Forms\nthat was sent with the build.\n\nPress ENTER to continue!";
		var popUpTxt = new FlxText(0,0,0,tex);
		popUpTxt.setFormat(Main.gFont, 43, 0xFFFFFFFF, CENTER);
		popUpTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.5);
		popUpTxt.screenCenter();
		add(popUpTxt);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (Controls.justPressed("ACCEPT"))
			finish();
	}
	
	private function finish():Void
	{
		Main.switchState(new Intro.IntroLoading());
	}
	
}

class IntroLoading extends MusicBeatState
{
	var threadActive:Bool = true;

	#if !html5
	var mutex:Mutex;
	#end

	var bg:FlxSprite;
	var logo:FlxSprite;

	var loadBar:FlxSprite;
	var loadPercent:Float = 0;

	var timerLol:Bool = false;
	
	override function create()
	{
		super.create();

		#if !html5
		mutex = new Mutex();
		#end
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
		logo.scale.set(0.3,0.3);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 15;
		logo.y = FlxG.height - logo.height - 15;
		add(logo);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		#if !html5
		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			#end

			Paths.preloadGraphic('menu/title/gradients/' + Main.possibleTitles[Main.randomized][0]);
			Paths.preloadGraphic('menu/title/tiles/' + Main.possibleTitles[Main.randomized][0]);
			Paths.preloadGraphic('menu/title/logo');
			//Paths.preloadSound("intro/end");
			Paths.preloadGraphic("menu/intros/flixel");
			//Paths.preloadSound("intro/haxe");

       		var video = new DoidoVideoSprite();
			video.load(Paths.video("intro"));
			video.destroy();

			var video2 = new DoidoVideoSprite();
			video2.load(Paths.video("test"));
			video2.destroy();

			loadPercent = 1.0;
			trace('finished loading');

			new FlxTimer().start(2.3, function(tmr:FlxTimer)
			{
				timerLol = true;
			});

			FlxSprite.defaultAntialiasing = oldAnti;
			#if !html5
			threadActive = false;
			mutex.release();
		});
		#else
		Main.skipClearMemory = true;
		Main.switchState(new states.cd.Intro());
		#end
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if !html5
		if(!threadActive && !byeLol && timerLol)
		{
			byeLol = true;
			Main.skipClearMemory = true;
			if(FlxG.random.bool(1)) {
				states.VideoState.name = "test";
				Main.switchState(new states.VideoState());
			}
			else
				Main.switchState(new states.cd.Intro());
		}
		#end
	}
}