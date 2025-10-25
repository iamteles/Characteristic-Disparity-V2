package states.cd;

import flixel.FlxG;
import flixel.FlxSprite;
import data.GameData.MusicBeatState;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import data.Discord.DiscordIO;

using StringTools;

class Swat extends MusicBeatState
{
    public static var swatted:Int = 0;
    public static var playerHealth:Int = 5;

    var flies:FlxTypedGroup<Fly>;
    var info:FlxText;

    var cooldown:Bool = false;
    var cooldownTimer:FlxTimer;
    override function create() {
        super.create();

        playerHealth = 5;
        swatted = 0;

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

        flies = new FlxTypedGroup<Fly>();
		add(flies);
        
        info = new FlxText(0,0,0,'er');
		info.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        info.x = 5;
        info.y = FlxG.height - info.height - 5;
        info.antialiasing = false;
		add(info);

        cooldownTimer = new FlxTimer();

        Main.setMouse(true);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        var cdTime:Float = (cooldownTimer.active ? FlxMath.roundDecimal(cooldownTimer.timeLeft,2) : 0);
        info.text = 'Flies Swatted: $swatted | Cooldown: $cdTime | Health: $playerHealth';

        if(Controls.justPressed("ACCEPT"))
            startFly();

        if(FlxG.keys.justPressed.R)
            Main.switchState();

        if(FlxG.mouse.justPressed && !cooldown) {
            for(fly in flies) {
                if(CoolUtil.mouseOverlap(fly, FlxG.camera) && !fly.swatted) {
                    fly.swat();
                    if(fly.swatted && diff == 1) {
                        new FlxTimer().start(spawnTime, function(tmr:FlxTimer) {
                            startFly();
                        });
                    }
                    swatted++;
                }
            }
            
            cooldown = true;
            if(cooldownTimer.active)
                cooldownTimer.cancel();
            cooldownTimer.start(0.25, function(tmr:FlxTimer) {
                cooldown = false;
            });
        }
    }

    function startFly() {
        var fly = new Fly();
        flies.add(fly);
        fly.startFly(true);

        if(diff > 1) {
            new FlxTimer().start(spawnTime, function(tmr:FlxTimer) {
                startFly();
            });
        }
    }

    public static function damage() {
        playerHealth--;
        if(playerHealth <= 0)
            die();
    }

    public static function die() {
        Main.switchState();
    }

    public static var diff(get,never):Int;
    public static function get_diff() {
        if(swatted >= 200)
            return 6; // what the fuck
        else if(swatted >= 100)
            return 5; // extreme
        else if(swatted >= 40)
            return 4; // hard
        else if(swatted >= 20)
            return 3; // normal
        else if(swatted >= 10)
            return 2; // easy
        else
            return 1; // safe
    }

    public static var spawnTime(get,never):Float;
    public static function get_spawnTime() {
        var diffMod:Float = 0;
        if(diff == 1)
            diffMod = 1.5;
        else if(diff == 2 || diff == 3)
            diffMod = 2;
        else if(diff == 4)
            diffMod = 1.5;
        else
            diffMod = 1;
        return diffMod;
    }

    public static function sizeRoll(type:Int = 1) {
        if(diff < 3 && type == 3)
            return 1;
        else if(type == 4)
            return 3;
        else {
            var roll:Int = FlxG.random.int(1,100);
            var rangeBig:Int = 101;
            var rangeMed:Int = 65;

            if(diff == 4) {
                rangeBig = 75;
                rangeMed = 50;
            }
            else if(diff == 5) {
                rangeBig = 80;
                rangeMed = 25;
            }
            else if(diff == 6) {
                rangeBig = 75;
                rangeMed = -5;
            }

            trace('roll: $roll, big: $rangeBig, med: $rangeMed');
            return (roll > rangeBig ? 3 : (roll > rangeMed ? 2 : 1));
        }
    }

    public static function typeRoll() {
        if(diff < 2)
            return 2;
        else {
            var roll:Int = FlxG.random.int(1,100);
            var rangeHelica:Int = 101;
            var rangeWatts:Int = 101;
            var rangeBella:Int = 80;

            if(diff == 3) {
                rangeBella = 70;
            }
            else if(diff == 4) {
                rangeBella = 60;
                rangeWatts = 80;
            }
            else if(diff == 5) {
                rangeBella = 40;
                rangeWatts = 70;
                rangeHelica = 90;
            }
            else if(diff == 6) {
                rangeBella = 30;
                rangeWatts = 60;
                rangeHelica = 80;
            }

            trace('roll: $roll, bella: $rangeBella, watts: $rangeWatts, helica: $rangeHelica');
            return (roll > rangeHelica ? 4 : (roll > rangeWatts ? 3 : (roll > rangeBella ? 2 : 1)));
        }
    }
}

class Fly extends FlxSprite
{
    public var swatted:Bool = false;
    public var flyHealth(get,set):Int;
    public var type:Int = 1;
    var cooldown:Bool = false;
    var cooldownTimer:FlxTimer;

    public function new() {
        super();
        type = Swat.typeRoll();
        flyHealth = Swat.sizeRoll(type);

        makeGraphic(50, 50, typeColor);
        cooldownTimer = new FlxTimer();

        var vert = FlxG.random.int(1,4);
        if(vert < 3)
            setPosition(FlxG.random.float(0-width,FlxG.width),FlxG.height*(vert-1));
        else
            setPosition(FlxG.width*(vert-3),FlxG.random.float(0-height,FlxG.height));
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);

        if(!cooldown) {
            if(type == 2) {
                if(CoolUtil.mouseOverlap(this, FlxG.camera) && !swatted) {
                    startFly(false, true);
                    cooldown = true;
                    if(cooldownTimer.active)
                        cooldownTimer.cancel();
                    cooldownTimer.start(2, function(tmr:FlxTimer) {
                        cooldown = false;
                    });
                }
            }

            if(type == 3) { //centbomb
                cooldown = true;
                if(cooldownTimer.active)
                    cooldownTimer.cancel();
                cooldownTimer.start(2, function(tmr:FlxTimer) {
                    cooldown = false;
                });
            }
        }
    }

    public var flyTween:FlxTween;
    public var colorTween:FlxTween;
    public function startFly(first:Bool = false, hurry:Bool = false) {
        if(swatted) return;

        if(first) {
            if(colorTween != null) colorTween.cancel();
		    colorTween = FlxTween.color(this, 3, 0xFFFFFFFF, FlxColor.RED, {
                startDelay: 1,
                onComplete: die
            });
        }

        if(flyTween != null) flyTween.cancel();
        flyTween = FlxTween.tween(this, {
            x: fwrap(FlxG.random.float(x-600,x+600), 70, FlxG.width-width-70),
            y: fwrap(FlxG.random.float(y-400,y+400), 70, FlxG.height-height-70)},
            FlxG.random.float(0.3,0.8), {
                startDelay: ((first || hurry) ? 0 : FlxG.random.float(0.5,1.5)),
                onComplete: function(twn:FlxTween) {
                    startFly();
                },
                ease: FlxEase.cubeOut
            }
        );
    }

    function die(twn:FlxTween) {
        Swat.damage();
        flyHealth = 0;
        swat();
    }

    public function swat() {
        flyHealth--;

        if(flyTween != null) flyTween.cancel();
        if(colorTween != null) colorTween.cancel();

        if(flyHealth <= 0) {
            swatted = true;
            flyTween = FlxTween.tween(this, {alpha: 0}, 0.2, {
                onComplete: function(twn:FlxTween) {
                    destroy();
                }
            });
        }
        else {
            startFly(true);
        }
    }

    function fwrap(value:Float, min:Float, max:Float):Float {
		var range:Float = max - min + 1;

		if (value < min)
			value += range * Std.int((min - value) / range + 1);

		return min + (value - min) % range;
	}

    var _flyHealth:Int = 1;
    function get_flyHealth():Int {
        return _flyHealth;
    }

    function set_flyHealth(value:Int):Int {
        _flyHealth = value;
        if(_flyHealth > 0) {
            scale.set(_flyHealth,_flyHealth);
            updateHitbox();
        }
        return _flyHealth;
    }

    var typeColor(get,never):FlxColor;
    function get_typeColor():FlxColor {
        if(type == 4)
            return 0xFFFFFB00;
        if(type == 3)
            return 0xFFFFA600;
        if(type == 2)
            return 0xFFFFFFFF;
        else
            return 0xFF433883;
    }
}