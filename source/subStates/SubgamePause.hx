package subStates;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound ;
import data.Conductor;
import data.GameData.MusicBeatSubState;
import gameObjects.menu.AlphabetMenu;
import states.*;
import flixel.addons.display.FlxBackdrop;

class SubgamePause extends MusicBeatSubState
{
	public function new()
	{
		super();
		var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		var pause = new FlxText(0,0,0,'PAUSED');
		pause.setFormat(Main.dsFont, 120, 0xFFFFFFFF, CENTER);
		pause.setBorderStyle(OUTLINE, 0xFF000000, 4);
        pause.screenCenter();
        pause.antialiasing = false;
		add(pause);

        banana.alpha = 0.5;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		for(item in members)
		{
			if(Std.isOfType(item, FlxBasic))
				cast(item, FlxBasic).cameras = [lastCam];
		}

		if(Controls.justPressed("ACCEPT")) {
            close();
        }
			
		// works the same as resume
		if(Controls.justPressed("BACK"))
			Main.switchState(new states.cd.MainMenu());
	}
}