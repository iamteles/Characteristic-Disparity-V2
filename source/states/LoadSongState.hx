package states;

import states.cd.MusicPlayer;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import flixel.addons.display.FlxBackdrop;
import data.Discord.DiscordIO;
import sys.thread.Mutex;
import sys.thread.Thread;

/*
*	preloads all the stuff before going into playstate
*	i would advise you to put your custom preloads inside here!!
*/
class LoadSongState extends MusicBeatState
{
	var threadActive:Bool = true;
	var mutex:Mutex;
	
	//var behind:FlxGroup;
	var behind:FlxGroup;
	var bg:FlxSprite;
	var logo:FlxSprite;

	var loadBar:FlxSprite;
	public static var loadPercent:Float = 0;

	public static function addBehind(item:FlxBasic, bhnd:FlxGroup)
	{
		bhnd.add(item);
		bhnd.remove(item);
	}
	
	override function create()
	{
		super.create();

		mutex = new Mutex();
		Main.setMouse(false);
		DiscordIO.changePresence("Loading", null);
		
		loadPercent = 0.0;
		behind = new FlxGroup();
		add(behind);
		
		var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		color.screenCenter();
		add(color);

		var tiles = new FlxBackdrop(Paths.image('all'), XY, 0, 0);
        tiles.velocity.set(30, 30);
        tiles.screenCenter();
		tiles.alpha = 0.7;
        add(tiles);

		logo = new FlxSprite().loadGraphic(Paths.image('menu/loading'));
		logo.scale.set(0.3,0.3);
		logo.updateHitbox();
		logo.x = FlxG.width - logo.width - 10;
		logo.y = FlxG.height - logo.height - 18;
		add(logo);

		loadBar = new FlxSprite().makeGraphic(FlxG.width, 20, 0xFFFFFFFF);
		loadBar.y = FlxG.height - loadBar.height + 10;
		loadBar.scale.x = 0;
		//loadBar.alpha = 0;
		add(loadBar);
		
		var oldAnti:Bool = FlxSprite.defaultAntialiasing;
		FlxSprite.defaultAntialiasing = false;

		var preloadThread = Thread.create(function()
		{
			mutex.acquire();
			load(behind);
			FlxSprite.defaultAntialiasing = oldAnti;
			threadActive = false;
			mutex.release();
		});
	}
	
	var byeLol:Bool = false;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!threadActive && !byeLol && loadBar.scale.x >= 0.98)
		{
			byeLol = true;
			loadBar.scale.x = 1.0;
			loadBar.updateHitbox();
			Main.skipClearMemory = true;
			Main.switchState(new PlayState());
		}

		loadBar.scale.x = FlxMath.lerp(loadBar.scale.x, loadPercent, elapsed * 6);
		loadBar.updateHitbox();
	}
	
	public static function load(bhnd:FlxGroup) {
		PlayState.resetStatics();
		var assetModifier = PlayState.assetModifier;
		var SONG = PlayState.SONG;
		Paths.preloadPlayStuff(SONG.song);
		Rating.preload(assetModifier);
		
		var stageBuild = new Stage();
		addBehind(stageBuild, bhnd);
		var stages:Array<String> = [SONG.song];

		if(!SaveData.data.get("Low Quality")) {
			switch(SONG.song)
			{
				case 'desertion':
					stages.push("desertion2");
				case 'intimidate': //insane
					stages.push("divergence-e");
					stages.push("panic-attack-e");
					stages.push("wake");
				case 'cupid':
					stages.push("cupid2");
				default:
					//
			}
		}
		for (stage in stages) {
			stageBuild.reloadStageFromSong(stage);
		}

		trace('preloaded stage and hud');
		
		loadPercent = 0.2;

		var charList:Array<String> = [SONG.player1, SONG.player2];

		if(!SaveData.data.get("Low Quality")) {
			switch(SONG.song)
			{
				case 'nefarious':
					charList.push("bex-1alt");
				case 'divergence':
					charList.push("bella-1alt");
				case 'panic-attack':
					charList.push("bree-2bf");
					charList.push("bex-2bf");
					charList.push("bex-2balt");
				case 'desertion':
					charList.push("bella-2dp");
					charList.push("bella-2d");
					charList.push("bree-2dp");
					charList.push("bex-2dp");
				case 'intimidate':
					charList.push("bex-1e");
					charList.push("bex-2e");
					charList.push("bree-2e");
				case 'cupid':
					charList.push("bella-hp2");
					charList.push("bex-hp2");
				default:
					//trace('loaded lol');
			}
		}

		var foundDeath = false;

		for(i in charList) {
			var char = new Character();
			char.isPlayer = (i == SONG.player1);
			char.reloadChar(i);
			addBehind(char, bhnd);
			
			//trace('preloaded $i');

			var icon = new HealthIcon();
			icon.setIcon(i, (i == SONG.player1), SONG.song);
			addBehind(icon, bhnd);
			loadPercent += (0.6 - 0.2) / charList.length;

			if(i == "bex-2d") {
				Paths.preloadSound('sounds/death/duo_death');
				foundDeath = true;
			}
			else if(Paths.fileExists('sounds/death/${CoolUtil.formatChar(i)}_death.ogg') && (i == SONG.player1)) {
				Paths.preloadSound('sounds/death/${CoolUtil.formatChar(i)}_death');
				foundDeath = true;
			}
		}

		if(!foundDeath) {
			Paths.preloadSound('sounds/death/base_death');
		}

		var center = new HealthIcon();
		center.setIcon("center", false, SONG.song);
		addBehind(center, bhnd);
		
		trace('preloaded characters');
		loadPercent = 0.6;
		
		Paths.preloadSound('songs/${SONG.song}/Inst');
		if(SONG.needsVoices)
			Paths.preloadSound('songs/${SONG.song}/Voices');
		
		trace('preloaded music');
		loadPercent = 0.75;
		
		var thisStrumline = new Strumline(0, null, false, false, true, assetModifier);
		thisStrumline.ID = 0;
		addBehind(thisStrumline, bhnd);
		
		var noteList:Array<Note> = ChartLoader.getChart(SONG);
		for(note in noteList)
		{
			note.reloadNote(note.songTime, note.noteData, note.noteType, assetModifier);
			addBehind(note, bhnd);
			
			thisStrumline.addSplash(note);

			loadPercent += (0.9 - 0.75) / noteList.length;
		}
		
		trace('preloaded notes');
		loadPercent = 0.9;

		Paths.preloadGraphic("hud/base/gameover/heart");
		Paths.preloadGraphic("hud/base/gameover/retry");

		var isit:String = "";
		if(!SaveData.data.get("Downscroll"))
			isit = "-upscroll";
		Paths.preloadGraphic("hud/base/you" + isit);
		
		// add custom preloads here!!
		if(!SaveData.data.get("Low Quality")) {
			switch(SONG.song)
			{
				case "divergence":
					Paths.preloadGraphic("hud/base/divergence");
					Paths.preloadGraphic('backgrounds/week1/bgchars');
				case "convergence":
					Paths.preloadGraphic("hud/base/shes going to kill you");
					Paths.preloadGraphic("hud/base/convergence");
					Paths.preloadSound("sounds/thunder");
				case "desertion":
					//Paths.preloadGraphic("backgrounds/desertion/power up");
					Paths.preloadGraphic("backgrounds/desertion/bg");
					Paths.preloadGraphic("backgrounds/desertion/bex");
					Paths.preloadGraphic("backgrounds/desertion/bella");
					Paths.preloadGraphic("backgrounds/desertion/bar");
				case "nefarious" | "euphoria":
					Paths.preloadGraphic('backgrounds/week1/bgchars');
				case "heartpounder": // quarter pounder :joy:
					Paths.preloadGraphic("hud/base/sidebars");
					Paths.preloadGraphic("backgrounds/gfd/sd-tv");
				case "sin":
					Paths.preloadGraphic("backgrounds/helica/eyes");
					Paths.preloadGraphic("notes/taiko/strums");
					Paths.preloadGraphic("notes/taiko/play");
					/*Paths.preloadGraphic("notes/taiko/notes");
					Paths.preloadGraphic("notes/base/splashes"); //...?!*/
					Paths.preloadGraphic("menu/story/Taiko-" + SaveData.data.get("Taiko Style").toLowerCase());
					Paths.preloadSound("sounds/punch/punch_1");
					Paths.preloadSound("sounds/punch/punch_2");
					Paths.preloadSound("sounds/punch/punch_3");
					Paths.preloadSound("sounds/punch/punch_4");

					var taikoData = data.SongData.loadFromJson("sin", "taiko");
					var taikoList:Array<Note> = ChartLoader.getChart(taikoData);
					for(note in taikoList)
					{
						note.reloadNote(note.songTime, note.noteData, note.noteType, "taiko");
						addBehind(note, bhnd);
						
						thisStrumline.addSplash(note);

						//loadPercent += (0.9 - 0.75) / noteList.length;
					}
				case "intimidate":
					Paths.preloadGraphic("backgrounds/cave/vhs");
				default:
					//trace('loaded lol');
			}
		}

		loadPercent = 1.0;
		trace('finished loading');
	}
}