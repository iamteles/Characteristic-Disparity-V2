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
	
	// this makes so you can only read one character's bio
	// idk if this is unlockable, but coding it just in case
	public var unlockedTwoCharBio:Bool = true;
	
	public var curMenu:Int = 0;
	
	final colorMap:Map<String, Null<FlxColor>> = [
		"none" => null,
		"bella" => 0xFFff6057,
		"bex" => 0xFF07427c,
		"bree" => 0xFF7d5a99,
		"watts" => 0xFFf8ff87,
		"nila" => 0xFFbb6060,
		"helica" => 0xFFf8d7c8,
		"drown" => 0xFF4a2f79,
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

	override function create()
	{
		super.create();
		var bg = new FlxSprite().loadGraphic(Paths.image("menu/bios/bio-bg"));
		bg.screenCenter();
		add(bg);
		
		bgColors = new BioBGColor();
		bgColors.reloadColors(colorMap.get("bella"));
		add(bgColors);
		
		for(i in 0...2)
		{
			var char = new BioChar();
			char.flipX = (i == 1);
			char.reloadChar(["bella", "none"][i]);
			curChars.push(char);
			char.ID = i;
			add(char);
		}
		changeMenu(0);
	}
	
	final charOffsets:Array<Array<Int>> = [
		[0, FlxG.width], // first menu
		[-350, 350], // second menu
		[-380, -50], // reading (two chars)
		[-320, FlxG.width], // reading (one char)
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
		var char = curChars[curMenu];
		var otherChar = curChars[curMenu == 0 ? 1 : 0];
		
		var index:Int = possibleChars.indexOf(char.name) + change;
		index = loopAround(index);
		if (possibleChars[index] == otherChar.name)
			index += change;
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
	
	public function new()
	{
		super();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(x, targetX, elapsed * 8);
		y = FlxMath.lerp(y, FlxG.height+32, elapsed * 8);
	}
	
	public function reloadChar(char:String):BioChar
	{
		targetX += (width / 2);
		this.name = char;
		loadGraphic(Paths.image("menu/freeplay/characters/" + char));
		scale.set(0.75, 0.75);
		updateHitbox();
		
		targetX -= (width / 2);
		y = FlxG.height + 64;
		offset.y = height;
		return this;
	}
}