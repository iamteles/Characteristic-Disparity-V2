package states;

import data.Discord.DiscordIO;
import data.GameTransition;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import gameObjects.menu.Alphabet;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DebugState extends MusicBeatState
{
	var optionShit:Array<String> = ["menu", "video", "ending", "shop reset"];
	static var curSelected:Int = 0;

	var optionGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("MENU");

		Main.setMouse(true);

		// Updating Discord Rich Presence
		DiscordIO.changePresence("In the Debug Menu...", null);

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

		optionGroup = new FlxTypedGroup<Alphabet>();
		add(optionGroup);

		for(i in 0...optionShit.length)
		{
			var item = new Alphabet(0,0, "nah", false);
			item.align = CENTER;
			item.text = optionShit[i].toUpperCase();
			item.x = FlxG.width / 2;
			item.y = 50 + ((item.height + 100) * i);
			item.ID = i;
			optionGroup.add(item);
		}

		var gif = new FlxSprite();
		gif.frames = Paths.getSparrowAtlas("menu/bios/text");
		gif.animation.addByPrefix("idle", 'Símbolo 1', 24, false);
		gif.animation.play("idle");
		gif.scale.set(2.3, 2.4);
		gif.updateHitbox();
		gif.screenCenter();
		add(gif);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(gif, {alpha: 0}, 0.6, {
				ease: FlxEase.cubeOut,
				startDelay: 0.8
			});
		});

		changeSelection();
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if(Controls.justPressed("BOTPLAY")) { // INFINITE MONEY HAX
			SaveData.transaction(150);
		}

		if(Controls.justPressed("ACCEPT"))
		{
			switch(optionShit[curSelected])
			{
				case "test":
					Main.switchState(new states.PlayState());
				case "shop reset":
					SaveData.progression.set("nila", false);
					SaveData.progression.set("nilaentrance", false);
					SaveData.save();
				case "menu":
					Main.switchState(new states.cd.MainMenu());
				case "dialog":
					Main.switchState(new states.cd.Dialog());
				case "ending":
					Main.switchState(new states.cd.Ending());
				case "kiss":
					Main.switchState(new states.cd.Kissing());
				case "swat":
					Main.switchState(new states.cd.Swat());
				case "intimidating":
					Main.switchState(new states.cd.fault.MainMenu());
				case "video":
					states.VideoState.name = "divergence";
					Main.switchState(new states.VideoState());
				case "shop":
					Main.switchState(new states.ShopState());
				case "transition":
					openSubState(new GameTransition(false));
				case "options":
					Main.switchState(new states.menu.OptionsState());
			}
		}
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);

		for(item in optionGroup.members)
		{
			var daText:String = optionShit[item.ID].toUpperCase().replace("-", " ");

			var daBold = (curSelected == item.ID);

			if(item.bold != daBold)
			{
				item.bold = daBold;
				if(daBold)
					item.text = '> ' + daText + ' <';
				else
					item.text = daText;
				item.x = FlxG.width / 2;
			}
		}
	}
}