package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import data.Highscore;
import openfl.system.Capabilities;
import data.Discord.DiscordIO;

enum SettingType
{
	CHECKMARK;
	SELECTOR;
}

class SaveData
{
	public static var data:Map<String, Dynamic> = [];
	public static var displaySettings:Map<String, Dynamic> = [
		"Resolution" => [
			"1280x720",
			SELECTOR,
			"Change the game's resolution if it doesn't fit your monitor.",
			["640x360","854x480","960x540","1024x576","1152x648","1280x720","1366x768","1600x900","1920x1080", "2560x1440", "3840x2160"],
		],
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			"Makes you able to press keys freely without breaking notes.",
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			"Decides if the notes should scroll down or up."
		],
		"Middlescroll" => [
			false,
			CHECKMARK,
			"Moves your notes to the center of the screen and hides the opponent's."
		],
		"Antialiasing" => [
			true,
			CHECKMARK,
			"Smoothing on sprite scaling. Disabling this may improve performance."
		],
		"Shaders" => [
			#if mobile
			false,
			#else
			true,
			#end
			CHECKMARK,
			"Fancy graphical effects. Disable this if you get GPU related crashes or low performance."
		],
		"Note Splashes" => [
			"ON",
			SELECTOR,
			"Whether a splash should appear when you hit a note perfectly.",
			["ON", "PLAYER ONLY", "OFF"],
		],
		"Skin" => [
			"CD",
			SELECTOR,
			"Note Skins can be acquired in Watts' Shop!",
			["CD", "Tails.EXE", "The Funk Shack", "Mirror Life Crisis", "Classic", "Pixel Classic", "YLYL Reloaded", "FITDON", "FNFDON", "Doido"],
		],
		"Ratings on HUD" => [
			false,
			CHECKMARK,
			"Makes the ratings stick on the game HUD."
		],
		"FPS Cap"	=> [
			"60", // 120
			SELECTOR,
			"How many frames can displayed in a second.",
			["30", "60", "75", "120", "144"]
		],
		
		"Split Holds" => [
			false,
			CHECKMARK,
			"Cuts the end of each hold note like classic engines did."
		],
		"Smooth Healthbar" => [
			true,
			CHECKMARK,
			"Makes the healthbar move smoothly."
		],
		"Song Timer" => [
			true,
			CHECKMARK,
			"Whether the song timer appears or not."
		],
		
		"Cutscenes" => [
			#if mobile
			"STATIC",
			#else
			"ON",
			#end
			SELECTOR,
			"Decides if the song cutscenes should play.",
			["ON", "STATIC", "OFF"],
		],

		// this one doesnt actually appear at the regular options menu
		"Song Offset" => [
			0,
			SELECTOR,
			"no one is going to see this anyway whatever",
			[-500, 500],
		],
		'Colorblind Filter' => [
			'NONE',
			SELECTOR,
			'Filters to aid people with colorblindness.',
			['NONE', 'PROTANOPIA', 'PROTANOMALY', 'DEUTERANOPIA', 'DEUTERANOMALY', 'TRITANOPIA', 'TRITANOMALY', 'ACHROMATOPSIA', 'ACHROMATOMALY']
		],
		'Hitsounds' => [
			"OFF",
			SELECTOR,
			"Clicking sounds whenever you hit a note.",
			["CD", "OSU", "OFF"]
		],
		'Flashing Lights' => [
			"ON",
			SELECTOR,
			"Disable this if you have issues with Photosensitivity.",
			["ON", "REDUCED", "OFF"]
		],
		"Preload Songs" => [
			true,
			CHECKMARK,
			"Enable preloading song assets."
		],
		"FPS Counter" => [
			false,
			CHECKMARK,
			"Counter that can display debug information, such as the framerate or the memory usage.",
		],
		"Low Quality" => [
			false,
			CHECKMARK,
			"Disables extra assets that might make very low end computers lag."
		],
		"Taiko Style" => [
			"ACCURATE",
			SELECTOR,
			"CD mode requires you to hit both keys to hit a big note, while ACCURATE doesn't.",
			["CD", "ACCURATE"]
		],
		"Middlescroll Style" => [
			"HIDE OPPONENT",
			SELECTOR,
			"Whether opponent notes are shown in Middlescroll song events. HIDE makes notes easier to read.",
			["SHOW OPPONENT", "HIDE OPPONENT"]
		],
		"Text Speed" => [
			"MEDIUM",
			SELECTOR,
			"How fast should the text in the dialogue go by.",
			["FAST","INSTANT","SLOW","MEDIUM"]
		],
		'Discord RPC' => [
			#if DISCORD_RPC
			true,
			#else
			false,
			#end
			CHECKMARK,
			"Whether to use Discord's game activity.",
		],
		"Preload in Dialogue" => [
			true,
			CHECKMARK,
			"Lets the game load while reading dialogue, for a smoother experience."
		]
	];

	public static var progression:Map<String, Dynamic> = [
		"shopentrance" => false,
		"firstboot" => false,
		"intimidated" => false,
		"week2" => false,
		"week1" => false,
		"vip" => false,
		"oneofthem" => false,
		"debug" => false,
		"finished" => false
	];
	public static var songs:Map<String, Dynamic> = [
		"euphoria" => false,
		"nefarious" => false,
		"divergence" => false,
		"allegro" => false,
		"panic-attack" => false,
		"convergence" => false,
		"desertion" => false,
		"sin" => false,
		"conservation" => false,
		"irritation" => false,
		"kaboom" => false,
		"intimidate" => false,
		"heartpounder" => false,
		"ripple" => false,
		"exotic" => false,
		"customer-service" => false,
		"euphoria-vip" => false,
		"nefarious-vip" => false,
		"divergence-vip" => false,
		"cupid" => true
	];
	public static var money:Int = 0;
	public static var shop:Map<String, Dynamic> = [];
	public static var displayShop:Map<String, Dynamic> = [
		"crown" => [
			false,
			"People say it transports you to a far away place. Probably junk."
		],
		"mic" => [
			false,
			"Some old thing. I have no use for it myself."
		],
		"ticket" => [
			false,
			"A ticket to a flavorfull festival. Didn't feel like going myself, schedule too busy."
		],
		"time" => [
			false,
			"...I don't remember that ever being there. Are you sure you want this?"
		],
		"tails" => [
			false,
			"Its just a can of fake blood. I'm not sure why someone would want it."
		],
		"mlc" => [
			false,
			"Something to blow bubbles with. Very popular among sponges."
		],
		"base" => [
			false,
			"Previously owned by some soldier guy. I don't have actual children of my own."
		],
		"shack" => [
			false,
			"FYI, this is not a drink. Don't drink it. Seriously. I'm not trying to get sued."
		],
		"music" => [
			false,
			"An old disc with some banger tunes to listen. Favourite among collectors."
		],
		"gallery" => [
			false,
			"Pretty nifty collection of art."
		],
		"bio" => [
			false,
			"Don't ask me how I got these. Special price since i need to get rid of these ASAP."
		],
		"fitdon" => [
			false,
			"secret"
		],
		"fnfdon" => [
			false,
			"secret"
		],
		"ylyl" => [
			false,
			"secret"
		],
		"cd" => [
			true,
			"default"
		],
		"doido" => [
			true,
			"default"
		]
	];

	public static var initialTicks:Int = 0;

	public static var saveFile:FlxSave;
	public static var progressionFile:FlxSave;

	public static var skinCodes:Array<String> = ["cd", "tails", "shack", "mlc", "base", "pixel", "ylyl", "fitdon", "fnfdon", "doido"];
	public static var menuBg:String = 'menu/main/bg';
	public static function init()
	{
		saveFile = new FlxSave();
		saveFile.bind("settings",	"teles/CD"); // use these for settings

		progressionFile = new FlxSave();
		progressionFile.bind("progression",	"teles/CD");

		FlxG.save.bind("save-data", "teles/CD"); // these are for other stuff

		load();

		Controls.load();
		Highscore.load();

		updateWindowSize();
		
		// uhhh
		subStates.editors.ChartAutoSaveSubState.load();
	}
	
	public static function load()
	{
		if(saveFile.data.settings == null)
		{
			for(key => values in displaySettings)
				data[key] = values[0];
			
			saveFile.data.settings = data;
		}
		else if(Lambda.count(displaySettings) != Lambda.count(saveFile.data.settings)) {
			data = saveFile.data.settings;
			
			for(key => values in displaySettings) {
				if(data[key] == null)
					data[key] = values[0];
			}

			for(key => values in data) {
				if(displaySettings[key] == null)
					data.remove(key);
			}

			saveFile.data.settings = data;
		}

		if(saveFile.data.menuBg == null)
		{
			saveFile.data.menuBg = menuBg;
		}

		if(progressionFile.data.ticks == null) {
			progressionFile.data.ticks = 0;
		}

		if(progressionFile.data.money == null) {
			progressionFile.data.money = money;
		}

		if(progressionFile.data.money < 0)
			progressionFile.data.money = 0;

		
		if(progressionFile.data.shop == null)
		{
			trace("shop save null");
			for(key => values in displayShop)
				shop[key] = values[0];
			
			progressionFile.data.shop = shop;
		}

		if(progressionFile.data.progression == null)
		{
			progressionFile.data.progression = progression;
		}
		
		if(progressionFile.data.songs == null)
		{
			progressionFile.data.songs = songs;
		}

		initialTicks = progressionFile.data.ticks;
		songs = progressionFile.data.songs;
		money = progressionFile.data.money;
		shop = progressionFile.data.shop;
		progression = progressionFile.data.progression;
		data = saveFile.data.settings;
		menuBg = saveFile.data.menuBg;

		if(findMod("gameSettings", "fitdon"))
		{
			buyItem("fitdon");
			trace("found fitdon");
		}
		else {
			trace("not found fitdon");
		}

		if(findMod("save-data", "teles/EELDB"))
		{
			buyItem("fnfdon");
			trace("found fnfdon");
		}
		else {
			trace("not found fnfdon");
		}

		trace(percentage());

		save();

		trace("taiko " + data.get("Taiko Style"));
		trace("ms "+ data.get("Middlescroll Style"));
		trace("ts "+ data.get("Text Speed"));
		trace("rpc "+ data.get("Discord RPC"));
	}

	public static function findMod(file:String, localPath:String) {
		#if desktop
		var directory = lime.system.System.applicationStorageDirectory;
		var path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		
		file = StringTools.replace(file, "//", "/");
		file = StringTools.replace(file, "//", "/");
		
		if (StringTools.startsWith(file, "/"))
		{
			file = file.substr(1);
		}
		
		if (StringTools.endsWith(file, "/"))
		{
			file = file.substring(0, file.length - 1);
		}
		
		if (file.indexOf("/") > -1)
		{
			var split = file.split("/");
			file = "";
			
			for (i in 0...(split.length - 1))
			{
				file += "#" + split[i] + "/";
			}
			
			file += split[split.length - 1];
		}

		var yeah = path + file + ".sol";
		return sys.FileSystem.exists(yeah);
		#else
		return false;
		#end
	}
	
	public static function save()
	{
		saveFile.data.settings = data;
		saveFile.data.menuBg = menuBg;
		saveFile.flush();

		progressionFile.data.ticks = curTime();
		progressionFile.data.money = money;
		progressionFile.data.shop = shop;
		progressionFile.data.progression = progression;
		progressionFile.data.songs = songs;
		progressionFile.flush();
		update();
	}

	public static function update()
	{
		Main.changeFramerate(Std.parseInt(data.get("FPS Cap")));
		DiscordIO.check();
		FlxSprite.defaultAntialiasing = data.get("Antialiasing");
	}

	public static function buyItem(item:String) {
		shop.set(item, true);
		save();
	}

	public static function transaction(ammt:Int) {
		money += ammt;
		if(money < 0)
			money = 0;
		save();
	}

	public static function skin():String {
		var string:String = "base";
		var curMain:String = data.get("Skin");
		var skinArray = displaySettings.get("Skin")[3];
		var index:Int = skinArray.indexOf(curMain);
		string = skinCodes[index]; 
		//trace('current skin is $string');
		return string;
	}

	public static function skinFromCode(code:String):String {
		var index:Int = skinCodes.indexOf(code);
		var skin = displaySettings.get("Skin")[3][index];
		return skin;
	}

	public static function returnSkins():Array<String> {
		var skinArray:Array<String> = [];
		for(i in skinCodes) {
			if(shop.get(i)) {
				skinArray.push(skinFromCode(i));
				if(i == "base")
					skinArray.push("Pixel Classic");
			}
		}

		return skinArray;
	}

	public static function curTime():Int {
		return initialTicks + FlxG.game.ticks;
	}

	public static function wipe(?which:String = 'ALL'){
		switch(which) {
			case 'PROGRESS':
				progressionFile.erase();
				progression = [
					"shopentrance" => false,
					"firstboot" => false,
					"intimidated" => false,
					"week2" => false,
					"week1" => false,
					"vip" => false,
					"oneofthem" => false,
					"debug" => false,
					"finished" => false
				];
				songs = [
					"euphoria" => false,
					"nefarious" => false,
					"divergence" => false,
					"allegro" => false,
					"panic-attack" => false,
					"convergence" => false,
					"desertion" => false,
					"sin" => false,
					"conservation" => false,
					"irritation" => false,
					"kaboom" => false,
					"intimidate" => false,
					"heartpounder" => false,
					"ripple" => false,
					"exotic" => false,
					"customer-service" => false,
					"euphoria-vip" => false,
					"nefarious-vip" => false,
					"divergence-vip" => false,
					"cupid" => false
				];
				money = 0;
				//trace ("Wiping progress " + progressionSave.data.progression + ' ' + progressionSave.data.clowns);
			case 'HIGHSCORE':
				FlxG.save.erase();
			case 'OPTIONS':
				saveFile.erase();
				data = [];
			default:
				wipe("PROGRESS");
				wipe("HIGHSCORE");
				wipe("OPTIONS");
		}

		load();
	}

	public static function percentage() {
		var count:Int = 0;
		var songList:Array<String> = [
			"euphoria",
			"nefarious",
			"divergence",
			"allegro",
			"panic-attack",
			"convergence",
			"desertion",
			"sin",
			"conservation",
			"irritation",
			"kaboom",
			"intimidate",
			"heartpounder",
			"ripple",
			"exotic",
			"customer-service",
			"euphoria-vip",
			"nefarious-vip",
			"divergence-vip",
			"cupid"
		];

		for (song in songList) {
			if (songs.get(song))  count += 2;
		}
		
		var shopItems:Array<String> = [
			"crown",
			"mic",
			"ticket",
			"tails",
			"mlc",
			"base",
			"shack",
			"music",
			"gallery",
			"bio",
			"fitdon",
			"fnfdon",
			"ylyl"
		];

		for (item in shopItems) {
			if (shop.get(item))  count += 2;
		}

		if (progression.get("week1"))  count += 12;
		if (progression.get("week2"))  count += 13;
		if (progression.get("vip"))  count += 6;
		if (progression.get("intimidated"))  count += 9;

		if (progression.get("debug"))  count += 2; 

		return count;
	}

	public static function cupidCheck() {
		var count:Int = 0;
		var songList:Array<String> = [
			"euphoria",
			"nefarious",
			"divergence",
			"allegro",
			"panic-attack",
			"convergence",
			"desertion",
			"sin",
			"conservation",
			"irritation",
			"kaboom",
			"intimidate",
			"heartpounder",
			"ripple",
			"exotic",
			"customer-service",
			"euphoria-vip",
			"nefarious-vip",
			"divergence-vip"
		];

		for (song in songList) {
			if (songs.get(song))  count++;
		}

		return count == songList.length;
	}

	public static function updateWindowSize()
	{
		#if desktop
		if(FlxG.fullscreen) return;
		var ws:Array<String> = data.get("Resolution").split("x");
        	var windowSize:Array<Int> = [Std.parseInt(ws[0]),Std.parseInt(ws[1])];
        	FlxG.stage.window.width = windowSize[0];
        	FlxG.stage.window.height= windowSize[1];
		
		// centering the window
		FlxG.stage.window.x = Math.floor(Capabilities.screenResolutionX / 2 - windowSize[0] / 2);
		FlxG.stage.window.y = Math.floor(Capabilities.screenResolutionY / 2 - (windowSize[1] + 16) / 2);
		#end
	}
}