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

class BiosMenuState extends MusicBeatState
{
	public var bgColors:BioBGColor;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	
	// this makes so you can only read one character's bio
	// idk if this is unlockable, but coding it just in case
	public var unlockedTwoCharBio:Bool = false;
	
	public var curMenu:Int = 0;
	
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
	
	public var curChars:Array<BioChar> = [];
	public var possibleChars:Array<String> = [
		"none", "bella", "bex", "bree",
		"watts", "nila", "helica", "drown",
		"wave", "empitri", "spicy-v2",
	];
	public var ignoreChars:Map<String, Array<String>> = [
		"none" => ["none"],
		"bella" => ["bella", "drown", "wave", "spicy-v2"],
		"bex" => ["bex", "empitri", "drown", "wave", "spicy-v2"],
		"bree" => ["bree", "nila", "empitri", "drown", "wave"],
		"watts" => ["watts", "empitri", "drown", "wave", "spicy-v2"],
		"nila" => ["nila", "bree", "helica", "empitri", "drown", "wave", "spicy-v2"],
		"helica" => ["helica", "nila", "empitri", "drown", "wave", "spicy-v2"],
		"drown" => ["drown", "bella", "bex", "bree", "watts", "nila", "helica", "spicy-v2"],
		"wave" => ["wave", "bella", "bex", "bree", "watts", "nila", "helica", "spicy-v2"],
		"empitri" => ["empitri", "bex", "bree", "watts", "nila", "helica", "spicy-v2"],
		"spicy-v2" => ["bella", "bex", "watts", "nila", "helica", "drown", "wave", "empitri", "spicy-v2"],
	];

	override function create()
	{
		super.create();
		DiscordIO.changePresence("In the Bios Menu", null);
		CoolUtil.playMusic("LoveLetter");

		unlockedTwoCharBio = SaveData.shop.get("biop");
		var bg = new FlxSprite().loadGraphic(Paths.image("menu/bios/bio-bg"));
		bg.screenCenter();
		add(bg);

		bgColors = new BioBGColor();
		bgColors.reloadColors(colorMap.get("bella"));
		add(bgColors);
		
		for(i in 0...2)
		{
			var char = new BioChar();
			//char.flipX = (i == 1);
			char.reloadChar(["bella", "none"][i]);
			curChars.push(char);
			char.ID = i;
			add(char);
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

		changeMenu(0);
	}
	
	final charOffsets:Array<Array<Int>> = [
		[0, FlxG.width], // first menu
		[-280, 280], // second menu
		[-420, -50], // reading (two chars)
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
		
		// add the actual bios texts later
		if (reading)
		{
			
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
	public function changeChar(change:Int = 0, skipSfx:Bool = false)
	{
		if(change == -1)
			leftArrow.x -= 8;
		else if(change == 1)
			rightArrow.x += 8;

		if(!skipSfx)
            FlxG.sound.play(Paths.sound("menu/scroll"));

		var char = curChars[curMenu];
		var otherChar = curChars[curMenu == 0 ? 1 : 0];
		
		var index:Int = possibleChars.indexOf(char.name) + change;
		index = loopAround(index);
		while(ignoreChars.get(otherChar.name).contains(possibleChars[index]))
		{
			index += change;
			index = loopAround(index);
		}
		index = loopAround(index);
		
		char.reloadChar(possibleChars[index]);
		char.y += 32;
		
		updateColors();
	}
	public function updateColors() {
		bgColors.reloadColors(
			colorMap.get(curChars[0].name),
			colorMap.get(curChars[1].name)
		);
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

			leftArrow.x = FlxMath.lerp(leftArrow.x, 0, elapsed*8);
			rightArrow.x = FlxMath.lerp(rightArrow.x, FlxG.width - rightArrow.width, elapsed*8);
		}
		else {
			leftArrow.x = FlxMath.lerp(leftArrow.x, -leftArrow.width-3, elapsed*8);
			rightArrow.x = FlxMath.lerp(rightArrow.x, FlxG.width+3, elapsed*8);
		}
		
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
class BioChar extends FlxSprite
{
	public var name:String = "";
	public var targetX:Float = 0.0;

	public var offsets:Map<String, Array<Float>> = [
		"none" => [0,0],
		"bella" => [0,0],
		"bex" => [0,0],
		"bree" => [0,0],
		"watts" => [0,-30],
		"nila" => [0,-60],
		"helica" => [0,0],
		"drown" => [0,0],
		"wave" => [0,30],
		"empitri" => [0,70],
		"spicy-v2" => [0,0],
	];
	
	public function new()
	{
		super();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(x, targetX + offsets.get(name)[0], elapsed * 8);
		y = FlxMath.lerp(y, FlxG.height+32 + offsets.get(name)[1], elapsed * 8);
	}
	
	public function reloadChar(char:String):BioChar
	{
		targetX += (width / 2);
		this.name = char;
		loadGraphic(Paths.image("menu/freeplay/characters/" + char));
		scale.set(0.9, 0.9);
		updateHitbox();
		
		targetX -= (width / 2);
		y = FlxG.height + 64 + offsets.get(name)[1];
		offset.y = height;
		x = targetX + offsets.get(name)[0];
		return this;
	}
}