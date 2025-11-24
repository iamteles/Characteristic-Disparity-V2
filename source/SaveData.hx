package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import data.Highscore;
import openfl.system.Capabilities;
import data.Discord.DiscordIO;
import data.Windows;

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
		],
		"Dialogue in Freeplay" => [
			"UNSEEN",
			SELECTOR,
			"Whether the Freeplay features Dialogue.",
			["ON", "OFF", "UNSEEN"]
		],
		"Menu Style" => [
			"RANDOMIZE",
			SELECTOR,
			"What tile + music combo the menu uses. Defaults to HORIZON if you choose a locked style.",
			["RANDOMIZE","HORIZON","THUNDER", "COUNTER", "CLOUDS", "BEAKER", "CLOUDS-OLD", "V1"]
		],
		"Miss on Ghost Tap" => [
			false,
			CHECKMARK,
			"Whether the character plays a miss animation when you ghost tap."
		],
		"Munchlog"	=> [
			1,
			SELECTOR,
			"Self explanatory.",
			[1, 999]
		],
		'Song Speed' => [
			"1x",
			SELECTOR,
			"Song Speed multiplier. Does not affect scrolling. Multiplies your Score depending on what you pick.",
			["0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"],
		],
		'Note Speed' => [
			"1x",
			SELECTOR,
			"Scroll Speed multiplier. Does not affect overall song speed. Multiplies your Score depending on what you pick.",
			["0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"],
		],
		'Note Fade' => [
			"OFF",
			SELECTOR,
			"Whether notes fade in or out of view as they approach you.",
			["OFF", "FADE IN", "FADE OUT", "BOTH"],
		],
		'Fail Mode' => [
			"OFF",
			SELECTOR,
			"No Fail - You can't die (0.5x) | Sudden Death - You can't break (1.5x) | Perfect - You can't go below P Rank (2x)",
			["OFF", "NO FAIL", "SUDDEN DEATH", "PERFECT"],
		],
		"Mirror Mode" => [
			false,
			CHECKMARK,
			"Flips the notes around. Does not multiply score."
		],
		"Flashbang Mode" => [
			false,
			CHECKMARK,
			"Not recommended for those with photosensitivity. Doubles Score, for whatever reason."
		],
		"Jumpscares" => [
			false,
			CHECKMARK,
			"Scary little surprise. Score will be unaffected."
		],
		"Dark Mode" => [
			true,
			CHECKMARK,
			"Theme of the Window."
		],
	];

	public static var progression:Map<String, Dynamic> = [
		"shopentrance" => false,
		"nilaentrance" => false,
		"firstboot" => false,
		"intimidated" => false,
		"week2" => false,
		"week1" => false,
		"vip" => false,
		"oneofthem" => false,
		"debug" => false,
		"finished" => false,
		"story" => false,
		"nila" => false,
		"plus" => true,
		"100" => false,
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
		"cupid" => false
	];
	public static var wattsLines:Map<String, Dynamic> = []; //maybe fill it in overtime lol?
	public static var money:Int = 0;
	public static var wattsNum:Int = -1;
	public static var shop:Map<String, Dynamic> = [];
	public static var displayShop:Map<String, Dynamic> = [
		"crown" => [
			false,
			"People say it transports you to a far away place. Probably junk.",
			"Get me some water and we'll find out if this is real or not."
		],
		"mic" => [
			false,
			"Some old thing. I have no use for it myself.",
			"Mom 2's favorite, but she doesn't like admitting to it."
		],
		"ticket" => [
			false,
			"A ticket to a flavorful festival. Didn't feel like going myself, schedule too busy.",
			"Smells like cinnamon a little."
		],
		"time" => [
			false,
			"Nila's first attempt at a time travelling device. Didn't work like she wanted it to...",
			"This MAY look like a time travel machine but it actually opens portals to a special alternate reality!"
		],
		"tails" => [
			false,
			"It's just a can of fake blood. I'm not sure why anyone would want it.",
			"I think I heard about this on the internet, once."
		],
		"mlc" => [
			false,
			"Something to blow bubbles with. Very popular among sponges.",
			"SINCE WHEN DO WE HAVE ONE OF THESE HERE??? CAN I PLAY, MOM 2???"
		],
		"base" => [
			false,
			"Previously owned by some soldier guy. I don't have actual children of my own.",
			"I wonder if Mom 2 would like one of these..."
		],
		"shack" => [
			false,
			"FYI, this is not a drink. Don't drink it. Seriously. I'm not trying to get sued.",
			"Would go great with a pickle, probably. Try it and tell me how it tastes."
		],
		"music" => [
			false,
			"An old disc with some banger tunes to listen. Favourite among collectors.",
			"why am i here?"
		],
		"gallery" => [
			false,
			"Pretty nifty collection of art.",
			"why am i here?"
		],
		"bio" => [
			false,
			"Don't ask me how I got these. Special price since i need to get rid of these ASAP.",
			"why am i here?"
		],
		"biop" => [
			false,
			"Nila's personal research using the previous stash. Just take it and go.",
			"Mom 2 shouldn't be selling these, I dont think.. good thing I'm 11, maybe theyll buy that in court."
			//
		],
		"musicp" => [
			false,
			"Nila's own little mixtape... but on disc! Likely downloaded from the internet.",
			"What is this.. some kind of extra disk? ...ha, just kidding, I'd know, I made that!"
		],
		"galleryp" => [
			false,
			"From Nila's short lived papparazi phase. Watch out around her, maybe.",
			"Now it can hold more photos! Improvements by yours truly!"
		],
		"egg0" => [
			false,
			"In the mood for an out-of-season easter egg?",
			"'Ya sure 'ya want that now? I'd try some... 'discount codes' if I were you."
		],
		"egg1" => [
			false,
			"Let's set a world record together and get the most liked post on Slowpost.",
			"Please ignore the bite, I got a little hungry..."
		],
		"egg2" => [
			false,
			"All I'm good for is my yo-yo and my half-bitten egg...",
			"Dishcount codes really comin' in handy, hm? *chew*"
		],
		"egg3" => [
			false,
			"sigh.",
			"*burp* whoops."
		],
		"camera" => [
			false,
			"Something Nila got from her dad. She's selling this to pay for her research.",
			"It's a hand me down from my dad. Now it's yours, if you pay, of course."
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

	public static var saveFile:FlxSave;
	public static var progressionFile:FlxSave;

	public static var skinCodes:Array<String> = ["cd", "tails", "shack", "mlc", "base", "pixel", "ylyl", "fitdon", "fnfdon", "doido"];
	public static var menuBg:String = 'menu/main/bg';
	public static function init()
	{
		saveFile = new FlxSave();
		saveFile.bind("settings",	"teles/CDplus"); // use these for settings

		progressionFile = new FlxSave();
		progressionFile.bind("progression",	"teles/CDplus");

		FlxG.save.bind("save-data", "teles/CDplus"); // these are for other stuff

		load();

		Controls.load();
		Highscore.load();

		updateWindowSize();
		
		// uhhh
		subStates.editors.ChartAutoSaveSubState.load();
	}
	
	public static function load()
	{
		if(saveFile.data.volume != null)
			FlxG.sound.volume = saveFile.data.volume;
		if(saveFile.data.muted != null)
			FlxG.sound.muted  = saveFile.data.muted;

		if(saveFile.data.lastTaiko == null)
			saveFile.data.lastTaiko = "wat";

		if(saveFile.data.swatScore == null)
			saveFile.data.swatScore = 0;
		if(saveFile.data.kissScore == null)
			saveFile.data.kissScore = 0;

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

		if(saveFile.data.menuBg == null) {
			saveFile.data.menuBg = menuBg;
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

		if(progressionFile.data.wattsNum == null)
		{
			progressionFile.data.wattsNum = wattsNum;
		}

		if(progressionFile.data.wattsLines == null)
		{
			progressionFile.data.wattsLines = wattsLines;
		}

		songs = progressionFile.data.songs;
		wattsLines = progressionFile.data.wattsLines;
		wattsNum = progressionFile.data.wattsNum;
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

		if(findMod("settings", "teles/EELDB"))
		{
			buyItem("fnfdon");
			trace("found fnfdon");
		}
		else {
			trace("not found fnfdon");
		}
		
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

		progressionFile.data.money = money;
		progressionFile.data.shop = shop;
		progressionFile.data.progression = progression;
		progressionFile.data.songs = songs;
		progressionFile.data.wattsLines = wattsLines;
		progressionFile.data.wattsNum = wattsNum;
		progressionFile.flush();
		update();
	}

	static var lastDark:Bool = false;
	public static function update()
	{
		Main.changeFramerate(Std.parseInt(data.get("FPS Cap")));
		DiscordIO.check();
		FlxSprite.defaultAntialiasing = data.get("Antialiasing");
		#if windows
		if(SaveData.data.get("Dark Mode") != lastDark)
			Windows.setDarkMode(lime.app.Application.current.window.title, SaveData.data.get("Dark Mode"));

		lastDark = SaveData.data.get("Dark Mode");
		#end
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

	public static function wipe(?which:String = 'ALL'){
		switch(which) {
			case 'PROGRESS':
				money = 0;
				shop = [];
				progression = [
					"shopentrance" => false,
					"nilaentrance" => false,
					"firstboot" => false,
					"intimidated" => false,
					"week2" => false,
					"week1" => false,
					"vip" => false,
					"oneofthem" => false,
					"debug" => false,
					"finished" => false,
					"story" => false,
					"nila" => false,
					"plus" => true,
					"100" => false
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
				wattsNum = -1;
				wattsLines = [];
				progressionFile.erase();
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

	public static function completion() {
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
			"commotion",
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

		var lines:Array<String> = [
			"bellaA",
			"bellaB",
			"bellaC",
			"bellaD",
			"bexA",
			"bexB",
			"bexC",
			"bexD",
			"breeA",
			"breeB",
			"wattsA",
			"wattsC",
			"wattsD",
			"nilaA",
			"nilaB",
			"nilaC",
			"nilaD",
		];

		var progList:Array<String> = [
			"week1",
			"week2",
			"intimidated",
			"nila",
			"oneofthem",
			"story"
		];

		var shopItems:Array<String> = [
			"tails",
			"mlc",
			"base",
			"music",
			"gallery",
			"bio",
			"galleryp",
			"biop",
			"musicp",
			"camera",
			"time",
			"ylyl",
			"fitdon",
			"fnfdon"
		];

		for (song in songList) {
			if (songs.get(song))  count++;
		}

		for (prog in progList) {
			if (progression.get(prog))  count++;
		}

		for (watts in lines) {
			if (wattsLines.get(watts))  count++;
		}
		
		for (extra in shopItems) {
			if (shop.get(extra))  count++;
		}

		return Std.int((count/(songList.length+progList.length+lines.length+shopItems.length))*100);
	}

	public static function songCompletion() {
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
			"commotion",
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
			if (songs.get(song))  count++;
		}


		return '$count/${songList.length}';
	}

	public static function storyCompletion() {
		var count:Int = 0;
		var progList:Array<String> = [
			"week1",
			"week2",
			"intimidated",
			"nila",
			"oneofthem",
			"story"
		];

		var storySongs:Array<String> = [
			"ripple",
			"customer-service",
			"cupid",
		];

		var lines:Array<String> = [
			"bellaA",
			"bellaB",
			"bellaC",
			"bellaD",
			"bexA",
			"bexB",
			"bexC",
			"bexD",
			"breeA",
			"breeB",
			"wattsA",
			"wattsC",
			"wattsD",
			"nilaA",
			"nilaB",
			"nilaC",
			"nilaD",
		];

		for (song in storySongs) {
			if (songs.get(song))  count++;
		}

		for (prog in progList) {
			if (progression.get(prog))  count++;
		}

		for (watts in lines) {
			if (wattsLines.get(watts))  count++;
		}

		return Std.int((count/(progList.length+storySongs.length+lines.length))*100);
	}

	public static function extrasCompletion() {
		var count:Int = 0;
		var shopItems:Array<String> = [
			"tails",
			"mlc",
			"base",
			"music",
			"gallery",
			"bio",
			"galleryp",
			"biop",
			"musicp",
			"camera",
			"time",
			"ylyl",
			"fitdon",
			"fnfdon"
		];

		for (extra in shopItems) {
			if (shop.get(extra))  count++;
		}

		return Std.int((count/(shopItems.length))*100);
	}

	public static function subgameCompletion() {
		var count:Int = 0;
		if(progression.get("intimidated")) count++;
		if(SaveData.progression.get("finished")) count++;

		return '$count/2';
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
			"commotion",
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

	public static function eggCount() {
		var count:Int = 0;
		var songList:Array<String> = [
			"fnfdon",
			"fitdon",
			"ylyl",
		];

		for (song in songList) {
			if (shop.get(song))  count++;
		}

		for(checker in 0...3) {
			if(shop.get("egg"+checker)) {
				count = checker;
				break;
			}
		}

		return count;
	}

	public static function eggCheck():Bool {
		for(checker in 0...3) {
			if(shop.get("egg"+checker)) {
				return true;
			}
		}

		return false;
	}

	public static function eggData():Array<Dynamic> {
		var name:String = "Egg";
		var price:Int = 300;

		switch(eggCount()) {
			case 1:
				name = "Munched Egg";
				price = 150;
			case 2:
				name = "Crunched Egg";
				price = 50;
			case 3:
				name = "Egg?";
				price = 1;
		}
		
		return [name, price];
	}

	public static function shopCheck():Bool {
		var count:Int = 0;
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
		];

		if(progression.get("nila")) {
			shopItems = [
				"crown",
				"mic",
				"ticket",
				"tails",
				"mlc",
				"base",
				"shack",
				"galleryp",
				"biop",
				"musicp",
				"camera",
				"time"
			];
		}

		for (item in shopItems) {
			if (shop.get(item)) {
				trace("player has " + item);
				count++;
			}
			else
				trace("player doesnt have " + item);
		}

		trace(count);
		trace(shopItems.length);

		var check:Bool = count == (shopItems.length);

		if(check && progression.get("nila"))
			check = eggCheck();

		return check;
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