package states.cd;

import data.Discord.DiscordIO;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import data.GameData.MusicBeatState;
import gameObjects.MenuChar;

typedef BioData = {
	var name:String;
	var ?series:String;
	var ?age:String;
	var ?height:String;
	var ?about:String;
}
class BiosMenuState extends MusicBeatState
{
	// this makes so you can only read one character's bio
	// idk if this is unlockable, but coding it just in case
	public var unlockedTwoCharBio:Bool = false;
	
	var bgColors:BioBGColor;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	
	var bgBio:FlxSprite;
	var textBio:FlxText;
	
	public var curMenu:Int = 0;
	
	public var curChars:Array<MenuChar> = [];
	public var curNames:Array<Array<FlxText>> = [];
	public final possibleChars:Array<String> = [
		"none", "bella", "bex", "bree",
		"watts", "nila", "helica", "drown",
		"wave", "empitri", "spicy-v2",
	];
	
	// INDEX, CHARACTERS THAT DON'T INTERACT
	public final charInfo:Map<String, Array<Dynamic>> = [
		"none"		=> [0, ["none"]],
		"bella" 	=> [1, ["bella", "drown", "wave", "spicy-v2"]],
		"bex" 		=> [2, ["bex", "empitri", "drown", "wave", "spicy-v2"]],
		"bree" 		=> [4, ["bree", "nila", "empitri", "drown", "wave"]],
		"watts" 	=> [8, ["watts", "empitri", "drown", "wave", "spicy-v2"]],
		"nila" 		=> [16, ["nila", "bree", "helica", "empitri", "drown", "wave", "spicy-v2"]],
		"helica" 	=> [32, ["helica", "nila", "empitri", "drown", "wave", "spicy-v2"]],
		"drown" 	=> [64, ["drown", "bella", "bex", "bree", "watts", "nila", "helica", "spicy-v2"]],
		"wave" 		=> [128, ["wave", "bella", "bex", "bree", "watts", "nila", "helica", "spicy-v2"]],
		"empitri" 	=> [256, ["empitri", "bex", "bree", "watts", "nila", "helica", "spicy-v2"]],
		"spicy-v2" 	=> [512, ["bella", "bex", "watts", "nila", "helica", "drown", "wave", "empitri", "spicy-v2"]],
	];
	
	final colorMap:Map<String, Null<FlxColor>> = [
		"none" => null,
		"bella" => 0xFFff6057,
		"bex" => 0xFF07427c,
		"bree" => 0xFF7d5a99,
		"watts" => 0xffffe987,
		"nila" => 0xFF66CC99,
		"helica" => 0xFFf8d7c8,
		"drown" => 0xff2f6e79,
		"wave" => 0xFFee6d48,
		"empitri" => 0xFFffcfcf,
		"spicy-v2" => 0xFFa60910,
	];
	
	public final bioInfo:Map<Int, BioData> = [];
	
	public function new()
	{
		super();
		// these two repeat dialogue soo...
		function breeAbout(who:String) {
			return "In Bree's almighty quest to become the most powerful god of all time, there's nothing that makes her more angry than people stronger than her, especially if that power is “misplaced” as she'd call it. "
			+ who + " and her partner with their combined power do become stronger than her, so they must stay vigilant to make sure she doesn't smite them down.";
		}
		function helicaAbout(who:String) {
			return "While never once directly talking, Helica has felt the immense power coming from the couple. They're a special case, considered a myth among the gods. Helica believes "
			+ who + "can do great things, and wants to keep them as safe as possible, and that includes stopping Bree if she goes after them.";
		}
		
		// ooh boy
		bioInfo = [
		// NONE
		0 => {
			name: "None",
			series: "",
			about: "how are you here???\nyou shouldn't be able to read this get out!!!",
		},
		// bella
		1 => {
			name: "Bella Wright",
			series: "Characteristic Disparity",
			age: "20",
			height: "5'10",
			about: "The bubbly, loveable, huggable bundle of sweets hailing from New Jersey. Bella loves to interact and make friends with others. She is a lesbian, which helped her find her current forever girlfriend, Bex. She is incredibly loyal to Bex and wouldn’t trade her for the world. Her favorite pastime is drawing. She has whole sketchbooks filled with art, though most of it is of her beloved.",
		},
		// bex
		2 => {
			name: "Bex Parker",
			series: "Characteristic Disparity",
			age: "20",
			height: "5'09",
			about: "The shy, emo, rock and roll ready gal from New Jersey. Bex is more shy and introverted compared to her girlfriend Bella. However, she loves her to death, and will go to the ends of the earth for her. Bex likes to play guitar, and even has a gig and the bar she works at. She likes to smoke, as it helps her release a lot of stress from her anxiety.",
		},
		// bree
		4 => {
			name: "Bree",
			series: "Characteristic Disparity",
			age: "21",
			height: "5'11",
			about: "The shy, emo, rock and roll ready gal from New Jersey. Bex is more shy and introverted compared to her girlfriend Bella. However, she loves her to death, and will go to the ends of the earth for her. Bex likes to play guitar, and even has a gig and the bar she works at. She likes to smoke, as it helps her release a lot of stress from her anxiety.",
		},
		// watts
		8 => {
			name: 'Kecia "Watts" Johnson',
			series: "Characteristic Disparity",
			age: "21",
			height: "5'11",
			about: "The shopkeeper with a motherly attitude. Watts runs her store “Johnson’s” on her own with support from her family. She aspires to be a mother and treats other people, especially her friends, as she is theirs. She loves to give to her community and help those in need. However she does have anger issues..and a gun under desk. Don’t get on her bad side now!",
		},
		// nila
		16 => {
			name: "Nila Robinson",
			series: "Characteristic Disparity",
			age: "11",
			height: "4'09",
			about: "The silly little scientist supreme. Nila is often babysat by Watts, whom she likes to call “Mom 2”. Theyve grown a deep inseparable bond over the last couple of years, and love doing experiments and engineering together. Shes got a hyperactive attitude, which while does mesh well with Bella, doesnt mix as well with Bex, leading to her to prefer Bellas company.",
		},
		// helica
		32 => {
			name: "Helica",
			series: "Characteristic Disparity",
			age: "22",
			height: "6'00",
			about: "The guardian angel for all. Helica is a high class god hailing from the Pantheon. She teaches other gods in the status below her how to use their powers, in preparation to help look after earth one day. One of her students is Bree. The 2 hate each other, and Helica always ends up cleaning after her. Stopping Bree’s reign of terror is one of her ultimate goals and she will stop at nothing to get it done.",
		},
		// drown
		64 => {
			name: 'Naomi Liu "Drown"',
			series: "The Funk Shack",
			age: "18",
			height: "5'01",
			about: "Naomi Liu, nickname Drown, is a college dropout roaming the streets of Maryland. She is desperate for attention and will do anything for it. Surprisingly, she doesn’t have a lot of friends. She can be really shy when you first meet her, but once you get to know her she is a whole different demon. Her favorite place to spend time, to the dismay of the employees, is a music store called “The Shack”.",
		},
		// wave
		128 => {
			name: "Waverly Baker",
			series: "The Funk Shack",
			age: "17",
			height: "5'08",
			about: "The bully with a penchant for pranks. Wave loves to pick fights with everyone and everything. She is a rowdy teen who doesn’t really know what she wants to do with her life. She works at a music store called “The Shack”, since her parents wanted her to go outside and do literally anything else but sit at home. She has a crush on her coworker Empitri, but is too chicken to tell her.",
		},
		// empitri
		256 => {
			name: "Empitri Palmer",
			series: "The Funk Shack",
			age: "21",
			height: "6'04",
			about: "The chronically online cashier. Empitri is an employee at a music store called “The Shack”. She likes to play on her phone, talk on her phone, and watch her phone (I’m noticing a trend here). While it may look like she’s never paying attention she actually listens and will respect you. She quite enjoys her job and her life and is a really good friend. Break that trust though, and you’ll never see the end of her.",
		},
		// spicy-v2
		512 => {
			name: "Spicy",
			series: "Flavor Rave",
			age: "??",
			height: "?'??",
			about: "Woah! Looks like we don’t have data on this character. They must be from some other universe...",
		},
		
		// TWO PEOPLE!!
		// explaining how this works
		// the ID is the sum of the two people's IDs
		// "bella/bex" is 1 + 2, so the ID is 3
		
		// bella/bex 1+2
		3 => {
			name: "Love Wins!",
			about: "It is whispered amongst the gods that when Aphrodite, goddess of love, vanished, she said she would leave her power split between the 2 beings with the strongest love on Earth. That power has found its way to Bella and Bex, which while absolutely deserving of it, leaves them the targets of people like Bree, who believes power should be exclusively handled by gods.",
		},
		
		// Bella-Bree 1+4
		5 => {
			name: "Roadblocks",
			about: breeAbout("Bella"),
		},
		// Bex-Bree 2+4
		6 => {
			name: "Roadblocks",
			about: breeAbout("Bex"),
		},
		
		// Bella-Watts 1+8
		9 => {
			name: "High-School Homegirls",
			about: "They met in the 6th grade and have been friends ever since. Watts was one of the only people who could handle Bella's hyper active attitude, and was there to comfort her when times got tough. They often consider themselves sisters though they aren't related by blood, they're that close!",
		},
		
		// Bella-Helica 1+32
		33 => {
			name: "Guardian Angel",
			about: helicaAbout("Bella"),
		},
		// Bex-Helica 2+32
		34 => {
			name: "Guardian Angel",
			about: helicaAbout("Bex"),
		},
		
		// Bella-Nila 1+16
		17 => {
			name: "I like this one",
			about: "When you put 2 chaos gremlins together, you should expect nothing but chaos, that's what Watts would say. These 2 formed a deep bond over their hyperactivity, and if they're together, they stick like glue. Watts often says its like babysitting a kid and… and a much bigger kid.",
		},
		
		// Bella-Empitri 1+256
		257 => {
			name: "Statewide Buddies",
			about: "Bella's Uncle once took her to a small music store in Maryland named The Shack. Empitri works there as the cashier, and her incredibly nice attitude pulled Bella in immediately. The 2 exchanged numbers and have exchanged numbers and have been talking for a couple months.",
		},
		
		// Bex-Watts 2+8
		10 => {
			name: "Bar Buddies",
			about: "Met at a bar as teens, bonded over a glass of water since they couldn't drink, and have been talking since. Initially they only ever talked about music, but ever since Bex got with Bella, the 2 have been super close friends. Though they dont see each other too much outside of when both Bella and Bex are together, they love hanging out and chatting.",
		},
		
		// Bex-Nila 2+16
		18 => {
			name: "I like this one a little less",
			about: "Bex and Nila dont get along too well. She can handle Bella's hyperactivity, but Nila’s is a whole different ball game. She often gets headaches when shes over Nilas home because it ends up being too loud due to the antics she gets up too. Nila still does have a heart for her though. When she feels like being quiet, she'll lean on Bex's shoulder.",
		},
		
		// Bree-Helica 4+32
		36 => {
			name: "Eyes on You",
			about: "These 2 watch each other like hawks. Helica is Bree's current biggest road block to achieving greatness outside BnB. As the daughter of the god of all light, Helica seeks to end Bree's reign of evil and protect those who need it. A difficult task when Bree is always at your neck.",
		},
		
		// Bree-Watts 4+8
		12 => {
			name: "Target Practice",
			about: "Watts only knows Bree through what Bella and Bex told her. She vows to protect them from her as best she can, but since she has no powers, she sticks to practicing shooting with the golden gun she has under her desk, for the off chance Bree comes strolling into her store.",
		},
		
		// Bree-Spicy 4+512
		516 => {
			name: "Otherworldly Chaos",
			about: "After Bree and Spicy's bout at the Show Hall, Bree's fuse broke and she caused major damage to the structure, which led to her being called up by Helica. Spicy went back to her home, far far away. Through some unknown force, Bree goes there to keep tabs on her, where she learns of her Rave powers, and you know how she is about humans having powers.",
		},
		
		// Watts-Helica 8+32
		40 => {
			name: "A Good Fit",
			about: "Helica keeps tabs on Watts, just as she does BnB. She admires Watts’ loyalty and determination to face someone like Bree though she is powerless. One day, Helica wishes to bestow upon her a gift of power to help aid in her ability to protect once she deems her ready.",
		},
		
		// Watts-Nila 8+16
		24 => {
			name: "Like Mom and Kid",
			about: "Nila is like the kid Watts hopes to one day have. The 2 are practically inseparable, and even led to Watts developing separation anxiety once they got attached. Watts has become Nilas full time baby sitter and good friend with her parents, though her parents aren't usually around due to their line of work.",
		},
		
		// Drown-Wave 64+128
		192 => {
			name: "Break It Up",
			about: "Not a single conversation between these 2 that hasn't broken into some kind of debate. Wave is normally the first person Drown sees when she walks in the store, so she always bugs her first. It takes a lot of restraint to not shove her out because it would be “against store policy”",
		},
		
		// Drown-Empitri 64+256
		320 => {
			name: "Teddy Scare",
			about: "Despite how annoying Drown can be, Em handles it really graciously. She handles her small little requests with ease, and even sometimes gives her a big bear hug on the way out, which while feeling nice, does typically fend Drown off for a few days because it embarrasses her.",
		},
		
		// Wave-Empitri 128+256
		384 => {
			name: "An Open Closet",
			about: "Wave is crushing on Empitri.. hard. She tries her best to hide it but ends up being incredibly oblivious to people around her, and even then a lot of her cheesy attempts to hit on her go unnoticed by Em, since she's so glued to her phone. Wave hopes one day she can overcome her fumbles and finally ask her out.",
		},
		
		];
	}

	override function create()
	{
		super.create();
		DiscordIO.changePresence("In the Bios Menu", null);
		CoolUtil.playMusic("LoveLetter");
	
		unlockedTwoCharBio = true;
		//unlockedTwoCharBio = SaveData.shop.get("biop");
		
		var bg = new FlxSprite().loadGraphic(Paths.image("menu/bios/bio-bg"));
		bg.screenCenter();
		add(bg);

		bgColors = new BioBGColor();
		bgColors.reloadColors(colorMap.get("bella"));
		add(bgColors);
		
		for(i in 0...2)
		{
			var char = new MenuChar();
			//char.flipX = (i == 1);
			char.reloadChar(["bella", "none"][i]);
			curChars.push(char);
			char.ID = i;
			add(char);

			var name:FlxText;
    		var desc:FlxText;

			name = new FlxText(0,0, FlxG.width, "Bella Wright");
			name.setFormat(Main.dsFont, 82, 0xFFFFFFFF, CENTER);
			name.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
			name.antialiasing = false;
			add(name);

			desc = new FlxText(0,0, FlxG.width, "Characteristic Disparity");
			desc.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
			desc.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			desc.antialiasing = false;
			add(desc);

			name.y = FlxG.height - name.height - desc.height - 15;
			desc.y = FlxG.height - desc.height - 15;

			curNames.push([name, desc]);
		}

		leftArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		leftArrow.scale.set(0.7, 0.7);
		leftArrow.updateHitbox();
        leftArrow.screenCenter(Y);
		add(leftArrow);
		
		rightArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		rightArrow.flipX = true;
		rightArrow.scale.set(0.7, 0.7);
		rightArrow.updateHitbox();
		rightArrow.screenCenter(Y);
		rightArrow.x = FlxG.width - rightArrow.width;
		add(rightArrow);
		
		bgBio = new FlxSprite().loadGraphic(Paths.image("menu/bios/bio-box"));
		bgBio.screenCenter(Y);
		bgBio.x = FlxG.width + 20;
		add(bgBio);
		
		textBio = new FlxText(0, 0, bgBio.width - 32, ">:D");
		textBio.setFormat(Main.dsFont, 37, 0xFFFFFFFF, LEFT);
		textBio.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		textBio.antialiasing = false;
		textBio.y = bgBio.y + 16;
		textBio.x = FlxG.width + 20;
		add(textBio);

		changeMenu(0);
	}
	
	final charOffsets:Array<Array<Int>> = [
		[0, FlxG.width], // first menu
		[-280, 280], // second menu
		[-430, -70], // reading (two chars)
		[-280, FlxG.width], // reading (one char)
	];
	public function setCharsPos(reading:Bool = false, ?onCreate:Bool = false)
	{
		var noOneRight:Bool = (curChars[1].name == "none");
		var index:Int = 0;
		if (reading) {
			index = (noOneRight ? 3 : 2);
		} else {
			index = (curMenu == 1 ? 1 : 0);
		}
		
		for(char in curChars)
		{
			char.targetX = (FlxG.width / 2) + charOffsets[index][char.ID];
			char.targetX -= (char.width / 2);
			if (onCreate)
				char.x = char.targetX;
		}
		if (onCreate) {
			updateTextLerp();
		}
		
		// add the actual bios texts later
		if (reading)
		{
			var data = bioInfo.get(
				charInfo.get(curChars[0].name)[0] +
				charInfo.get(curChars[1].name)[0]
			);
			
			if (data == null)
				textBio.text = "Uhh... :P";
			else
			{
				textBio.text = data.name;
				if (data.series != null)
					textBio.text += ' (${data.series})';
				if (data.age != null)
					textBio.text += '\n\nAGE: ${data.age}';
				if (data.height != null)
					textBio.text += '\n\nHEIGHT: ${data.height}';
				if (data.about != null)
					textBio.text += '\n\nABOUT: ${data.about}';
			}
		}
	}
	
	public function changeMenu(change:Int)
	{
		curMenu += change * (unlockedTwoCharBio ? 1 : 2);
		if (curMenu < 0)
		{
			Main.switchState(new states.cd.MainMenu());
			return;
		}
		
		if (curMenu == 0)
		{
			var noone = curChars[1];
			if (noone.name != "none") {
				noone.reloadChar("none");
				noone.y += 32;
				updateColors();
			}
		}
		
		if (curMenu == 2)
			setCharsPos(true);
		else
			setCharsPos(false, (change == 0));
	}
	
	private function loopAround(index:Int):Int
	{
		if (index < 0) index = possibleChars.length - 1;
		if (index > possibleChars.length - 1) index = 0;
		return index;
	}
	public function changeChar(change:Int = 0)
	{
		if(change == -1)
			leftArrow.x -= 8;
		else if(change == 1)
			rightArrow.x += 8;

        FlxG.sound.play(Paths.sound("menu/scroll"));

		var char = curChars[curMenu];
		var otherChar = curChars[curMenu == 0 ? 1 : 0];
		
		var index:Int = possibleChars.indexOf(char.name) + change;
		index = loopAround(index);
		while(charInfo.get(otherChar.name)[1].contains(possibleChars[index]))
		{
			index += change;
			index = loopAround(index);
		}
		
		char.reloadChar(possibleChars[index]);
		char.y += 32;

		for(i in 0...2) {
			var charIndex:Int = charInfo.get(curChars[i].name)[0];
			curNames[i][0].text = bioInfo.get(charIndex).name;
			curNames[i][1].text = bioInfo.get(charIndex).series;
		}
		
		updateColors();
	}
	public function updateColors() {
		bgColors.reloadColors(
			colorMap.get(curChars[0].name),
			colorMap.get(curChars[1].name)
		);
	}
	public function updateTextLerp(lerpX:Float = 1, lerpAlpha:Float = 1) {
		for(i in 0...2) {
			for(j in 0...2) {
				var daName = curNames[i][j];
				
				daName.x = FlxMath.lerp(
					daName.x,
					curChars[i].targetX + (curChars[i].width / 2) - (daName.width / 2),
					lerpX
				);
				
				daName.alpha = FlxMath.lerp(
					daName.alpha,
					(curMenu == 2) ? 0.0 : 1.0,
					lerpAlpha
				);
			}
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (curMenu < 2)
		{
			if (Controls.justPressed("UI_LEFT")) changeChar(-1);
			if (Controls.justPressed("UI_RIGHT")) changeChar(1);
			
			if (Controls.justPressed("ACCEPT"))
				changeMenu(1);
		}
		
		leftArrow.x = FlxMath.lerp(
			leftArrow.x,
			(curMenu == 2) ? -leftArrow.width - 3 : 0,
			elapsed * 8
		);
		rightArrow.x = FlxMath.lerp(
			rightArrow.x,
			(curMenu == 2) ? FlxG.width + 3 : FlxG.width - rightArrow.width,
			elapsed * 8
		);
		
		updateTextLerp(elapsed * 8, elapsed * 16);
		bgBio.x = FlxMath.lerp(bgBio.x, FlxG.width + ((curMenu == 2) ? -bgBio.width - 24 : 20), elapsed * 8);
		textBio.x = bgBio.x + 16;
		
		if (Controls.justPressed("BACK"))
			changeMenu(-1);
	}
}
class BioBGColor extends FlxSprite
{
	public function new()
	{
		super();
	}
	
	public function reloadColors(colorL:FlxColor, ?colorR:FlxColor):BioBGColor
	{
		if (colorR == null)
		{
			makeGraphic(FlxG.width, FlxG.height, colorL);
		}
		else
		{
			loadGraphic(FlxGradient.createGradientBitmapData(
				FlxG.width, FlxG.height, [colorL, colorR], 1, 0
			));
		}
		alpha = 0.5;
		screenCenter();
		return this;
	}
}