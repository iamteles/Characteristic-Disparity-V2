package states.menu;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import data.GameData.MusicBeatState;
import gameObjects.menu.AlphabetMenu;
import gameObjects.menu.options.*;
import SaveData.SettingType;
import flixel.addons.display.FlxBackdrop;
import data.Discord.DiscordIO;

class OptionsState extends MusicBeatState
{
	var optionShit:Map<String, Array<String>> =
	[
		"main" => [
			"Gameplay",
			"Appearance",
			"Accessibility",
			#if !mobile
			"Controls",
			#end
			//"Extras"
		],
		"gameplay" => [
			"Ghost Tapping",
			"Downscroll",
			"Hitsounds",
			//"Preload Songs", // very misleading i guess so its getting axed
			"Taiko Style",
			"Middlescroll Style",
			"Preload in Dialogue",
			"Dialogue in Freeplay",
		],
		"appearance" => [
			"Skin",
			"Note Splashes",
			"Menu Style",
			//"Song Timer",
			//"Smooth Healthbar",
			"Dark Mode",
			"Cutscenes",
			"FPS Cap",
			"Resolution",
		],
		"accessibility" => [
			"Flashing Lights",
			"FPS Counter",
			"Antialiasing",
			"Shaders",
			"Low Quality",
			"Text Speed",
			"Discord RPC"
		],
		"extras" => [
			"Jumpscares",
			"Flashbang Mode",
			//"Miss on Ghost Tap",
			"Munchlog"
		],
		"save" => [
			"Reset Progression",
			"Reset Options",
			"Reset Highscores",
			"Reset All"
		],
		"controls" => [
			"nothin"
		]
	];

	public static var curCat:String = "main";

	static var curSelected:Int = 0;
	static var storedSelected:Map<String, Int> = [];

	var grpTexts:FlxTypedGroup<FlxText>;
	var grpAttachs:FlxTypedGroup<FlxBasic>;
	var infoTxt:FlxText;
	var verTxt:FlxText;
	var square:FlxSprite;
	var notes:FlxSprite;

	// makes you able to go to the options and go back to the state you were before
	static var backTarget:FlxState;
	var buttonsMain:FlxTypedGroup<FlxSprite>;
	var scary:Bool = false;
	public function new(?newBackTarget:FlxState, scary:Bool = false)
	{
		super();
		this.scary = scary;
		if(newBackTarget == null)
		{
			newBackTarget = new states.cd.MainMenu();
			if(backTarget == null)
				backTarget = newBackTarget;
		}
		else
			backTarget = newBackTarget;
	}

	override function create()
	{
		super.create();
		if(scary)
			CoolUtil.playMusic("fault");
		else
			CoolUtil.playMusic("movement");
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFDBBF9B);
		color.screenCenter();
		add(color);

		DiscordIO.changePresence("In the Options", null);

		/*if(SaveData.eggCheck())
			optionShit.get("main").push("Extras");*/

		var tiles = new FlxBackdrop(Paths.image('menu/freeplay/tile'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.9;
        add(tiles);

		square = new FlxSprite().loadGraphic(Paths.image("menu/options/square"));
		square.updateHitbox();
		square.screenCenter();
		add(square);

		notes = new FlxSprite();
		notes.loadGraphic(Paths.image("menu/options/notes"), true, 460, 115);
		notes.updateHitbox();
		notes.animation.add("cd", [0], 0, false);
		notes.animation.add("base", [1], 0, false);
		notes.animation.add("pixel", [2], 0, false);
		notes.animation.add("tails", [3], 0, false);
		notes.animation.add("mlc", [4], 0, false);
		notes.animation.add("shack", [5], 0, false);
		notes.animation.add("doido", [6], 0, false);
		notes.animation.add("ylyl", [7], 0, false);
		notes.animation.add("fitdon", [8], 0, false);
		notes.animation.add("fnfdon", [9], 0, false);
		notes.animation.play(SaveData.skin());
		notes.screenCenter(X);
		notes.y -= 4;
		add(notes);

		grpTexts = new FlxTypedGroup<FlxText>();
		grpAttachs = new FlxTypedGroup<FlxBasic>();
		buttonsMain = new FlxTypedGroup<FlxSprite>();

		add(grpTexts);
		add(grpAttachs);
		add(buttonsMain);
		
		infoTxt = new FlxText(0, 0, FlxG.width * 0.92, "");
		infoTxt.setFormat(Main.dsFont, 28, 0xFFFFFFFF, CENTER);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		infoTxt.antialiasing = false;
		add(infoTxt);

		verTxt = new FlxText(0,0,0,'Press X to reset your save data.');
		verTxt.setFormat(Main.dsFont, 28, 0xFFFFFFFF, CENTER);
		verTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        verTxt.y = FlxG.height - verTxt.height;
		if(!SaveData.eggCheck())
			verTxt.screenCenter(X);
		else
			verTxt.x = 3;
		verTxt.antialiasing = false;
		add(verTxt);

		if(scary) {
			var vg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('vignette')); //like the???
			vg.updateHitbox();
			vg.screenCenter();
			vg.alpha = 0.8;
			add(vg);
		}
	
		reloadCat();
	}

	public function reloadCat(curCat:String = "main")
	{
		trace("went to " + curCat);
		storedSelected.set(OptionsState.curCat, curSelected);

		OptionsState.curCat = curCat;
		grpTexts.clear();
		grpAttachs.clear();
		buttonsMain.clear();

		if(storedSelected.exists(curCat))
			curSelected = storedSelected.get(curCat);
		else
			curSelected = 0;

		FlxG.sound.play(Paths.sound("menu/scroll"));

		if(curCat == "main")
		{
			verTxt.visible = true;
			square.alpha = 0;
			notes.visible = false;
			for(i in 0...optionShit.get(curCat).length)
			{
				var name = optionShit.get(curCat)[i];
				var index = i;
	
				var button = new FlxSprite();
				button.frames = Paths.getSparrowAtlas('menu/options/icons');
				button.animation.addByPrefix('idle',  name + '0', 24, true);
				button.animation.play('idle');
				button.ID = i;
	
				button.scale.set(0.95,0.95);
				button.updateHitbox();
	
	
				switch(index) {
					case 0:
						button.screenCenter();
						button.x -= 300;
						button.y -= 170;
					case 1:
						button.screenCenter();
						button.x += 300 + 30;
						button.y -= 170;
					case 2:
						button.screenCenter();
						button.x -= 300;
						button.y += 180;
					case 3:
						button.screenCenter();
						button.x += 300 + 30;
						button.y += 180;
					case 4:
						button.scale.set(0.8,0.8);
						button.updateHitbox();

						button.screenCenter(X);
						button.x += 26;
						button.y += FlxG.height - button.height + 20;
				}
	
				buttonsMain.add(button);
			}
		}
		else if(curCat == "save") {
			verTxt.visible = true;
			square.alpha = 0;
			notes.visible = false;
			for(i in 0...optionShit.get(curCat).length)
			{
				var item = new FlxText(0, 0, FlxG.width * 0.92, "");
				item.setFormat(Main.gFont, 70, 0xFFFFFFFF, CENTER);
				item.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
				item.text = optionShit.get(curCat)[i];

				grpTexts.add(item);

				item.ID = i;
				item.updateHitbox();

				var spaceY:Float = 36;

				item.screenCenter(X);
				item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
				item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
				item.y -= (item.height / 2);
			}
		}
		else
		{
			verTxt.visible = false;
			square.alpha = 1;

			if(curCat == "appearance")
				notes.visible = true;
			else
				notes.visible = false;

			for(i in 0...optionShit.get(curCat).length)
			{
				var daOption:String = optionShit.get(curCat)[i];
				var item = new FlxText(0, 0, FlxG.width * 0.92, "");
				item.setFormat(Main.gFont, 70, 0xFFFFFFFF, LEFT);
				item.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
				item.text = daOption;
				grpTexts.add(item);

				item.ID = i;

				item.scale.set(0.7,0.7);
				item.updateHitbox();

				item.x += 128;
				if(optionShit.get(curCat).length <= 9)
				{

					var spaceY:Float = 12;

					item.y = (FlxG.height / 2) + ((item.height + spaceY) * i);
					item.y -= (item.height + spaceY) * (optionShit.get(curCat).length - 1) / 2;
					item.y -= (item.height / 2);
				}

				if(SaveData.displaySettings.exists(daOption))
				{
					var daDisplay:Dynamic = SaveData.displaySettings.get(daOption);

					switch(daDisplay[1])
					{
						case CHECKMARK:
							var daCheck = new OptionCheckmark(SaveData.data.get(daOption), 0.7);
							daCheck.ID = i;
							daCheck.x = FlxG.width - 128 - daCheck.width;
							grpAttachs.add(daCheck);

						case SELECTOR:
							var array:Array<Dynamic> = daDisplay[3];
							if(daOption == "Skin")
								array = SaveData.returnSkins();
							var daSelec = new OptionSelector(
								daOption,
								SaveData.data.get(daOption),
								array
							);
							daSelec.xTo = FlxG.width - 128;
							daSelec.updateValue();
							daSelec.ID = i;
							grpAttachs.add(daSelec);

						default: // uhhh
					}
				}
			}
		}

		updateAttachPos();
		changeSelection();
	}

	public function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.get(curCat).length - 1);

		for(item in grpTexts.members)
		{
			//item.focusY = item.ID;
			item.alpha = 0.4;
			if(item.ID == curSelected)
			{
				item.alpha = 1;
			}
			//if(curSelected > 9)
			//{
			//	item.focusY -= curSelected - 9;
			//}
		}
		for(item in grpAttachs.members)
		{
			var daAlpha:Float = 0.4;
			if(item.ID == curSelected)
				daAlpha = 1;

			if(Std.isOfType(item, OptionCheckmark))
			{
				var check = cast(item, OptionCheckmark);
				check.alpha = daAlpha;
			}
			
			if(Std.isOfType(item, OptionSelector))
			{
				var selector = cast (item, OptionSelector);
				for(i in selector.members)
				{
					i.alpha = daAlpha;
				}
			}
		}
		
		infoTxt.text = "";
		if(curCat != "main" && curCat != "save")
		{
			try{
				
				infoTxt.text = SaveData.displaySettings.get(optionShit.get(curCat)[curSelected])[2];
				infoTxt.y = FlxG.height - infoTxt.height - 16;
				infoTxt.screenCenter(X);
				
				infoTxt.y -= 30;
				
			} catch(e) {
				trace("no description found");
			}
		}

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));

		// uhhh
		selectorTimer = Math.NEGATIVE_INFINITY;
	}

	function updateAttachPos()
	{
		for(item in grpAttachs.members)
		{
			for(text in grpTexts.members)
			{
				if(text.ID == item.ID)
				{
					if(Std.isOfType(item, OptionCheckmark))
					{
						var check = cast(item, OptionCheckmark);
						check.y = text.y + text.height / 2 - check.height / 2;
					}
					
					if(Std.isOfType(item, OptionSelector))
					{
						var selector = cast(item, OptionSelector);
						selector.setY(text);
					}
				}
			}
		}
	}

	var selectorTimer:Float = Math.NEGATIVE_INFINITY;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateAttachPos();
		if(infoTxt.text != "")
			infoTxt.y = FlxMath.lerp(infoTxt.y, FlxG.height - infoTxt.height - 16, elapsed * 8);

		if(Controls.justPressed("BACK"))
		{
			if(curCat == "main")
			{
				storedSelected.set("main", curSelected);
				FlxG.sound.play(Paths.sound("menu/back"));
				Main.switchState(backTarget);
				backTarget = null;    
			}
			else
				reloadCat("main");
		}

		if(curCat == "main") {
			for(item in buttonsMain.members) {
				if(curSelected == item.ID) {
					item.alpha = 1;
				}
				else
					item.alpha = 0.6;
			}

			if(Controls.justPressed("UI_UP"))
				changeSelection(-2);
			if(Controls.justPressed("UI_DOWN"))
				changeSelection(2);
			if(Controls.justPressed("UI_LEFT"))
				changeSelection(-1);
			if(Controls.justPressed("UI_RIGHT"))
				changeSelection(1);

			if(Controls.justPressed("BOTPLAY")) {
				if(optionShit.exists("save"))
					reloadCat("save");
			}
		}
		else {
			if(Controls.justPressed("UI_UP"))
				changeSelection(-1);
			if(Controls.justPressed("UI_DOWN"))
				changeSelection(1);
		}


		if(Controls.justPressed("ACCEPT"))
		{
			if(curCat == "save")
			{
				storedSelected.set("Save Data", curSelected);
				var daOption:String = grpTexts.members[curSelected].text;
				FlxG.sound.play(Paths.sound("menu/scroll"));
				switch(daOption.toLowerCase())
				{
					case "reset progression":
						SaveData.wipe('PROGRESS');
						Main.switchState(new states.cd.Intro.IntroLoading());
					case "reset highscores":
						SaveData.wipe('HIGHSCORE');
					case "reset options":
						SaveData.wipe('OPTIONS');
						//Main.resetState();
					case "reset all":
						SaveData.wipe('ALL');
						Main.switchState(new states.cd.Intro.Warning());
				}
			}
			else if(curCat != "main")
			{
				var curAttach = grpAttachs.members[curSelected];
				if(Std.isOfType(curAttach, OptionCheckmark))
				{
					var checkmark = cast(curAttach, OptionCheckmark);
					checkmark.setValue(!checkmark.value);

					SaveData.data.set(optionShit[curCat][curSelected], checkmark.value);
					SaveData.save();

					FlxG.sound.play(Paths.sound("menu/scroll"));
				}
			}
			else {
				var justSelected:String = optionShit.get(curCat)[curSelected].toLowerCase();
				switch(justSelected)
				{
					default:
						if(optionShit.exists(justSelected))
							reloadCat(justSelected);

					
					case "controls":
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							openSubState(new subStates.ControlsSubstate());
						});
					
				}
			}
		}
		
		if(Controls.pressed("UI_LEFT") || Controls.pressed("UI_RIGHT"))
		{
			var curAttach = grpAttachs.members[curSelected];
			if(Std.isOfType(curAttach, OptionSelector))
			{
				var selector = cast(curAttach, OptionSelector);

				if(Controls.justPressed("UI_LEFT") || Controls.justPressed("UI_RIGHT"))
				{
					selectorTimer = -0.5;
					FlxG.sound.play(Paths.sound("menu/scroll"));

					if(Controls.pressed("UI_LEFT"))
						selector.updateValue(-1);
					else
						selector.updateValue(1);

					if(selector.label == "Resolution")
						SaveData.updateWindowSize();
					else if(selector.label == "Menu Style")
						Main.randomizeTitle();
				}

				if(Controls.pressed("UI_LEFT"))
					selector.arrowL.alpha = 1;

				if(Controls.pressed("UI_RIGHT"))
					selector.arrowR.alpha = 1;

				if(selectorTimer != Math.NEGATIVE_INFINITY && !Std.isOfType(selector.bounds[0], String))
				{
					selectorTimer += elapsed;
					if(selectorTimer >= 0.02)
					{
						selectorTimer = 0;
						if(Controls.pressed("UI_LEFT"))
							selector.updateValue(-1);
						if(Controls.pressed("UI_RIGHT"))
							selector.updateValue(1);
					}
				}
			}
		}
		if(Controls.released("UI_LEFT") || Controls.released("UI_RIGHT"))
		{
			selectorTimer = Math.NEGATIVE_INFINITY;
			for(attach in grpAttachs.members)
			{
				if(Std.isOfType(attach, OptionSelector))
				{
					var selector = cast(attach, OptionSelector);
					if(Controls.released("UI_LEFT"))
						selector.arrowL.animation.play("idle");

					if(Controls.released("UI_RIGHT"))
						selector.arrowR.animation.play("idle");
				}
			}
		}

		notes.animation.play(SaveData.skin());
	}
}