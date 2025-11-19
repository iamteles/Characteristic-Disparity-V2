package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class MenuChar extends FlxSprite
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
	
	public function reloadChar(char:String):MenuChar
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