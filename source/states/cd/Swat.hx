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
import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import flixel.FlxCamera;

using StringTools;

class Swat extends MusicBeatState
{
    public static var stremMode:Bool = false; // :sob:
    public static var hitboxTest:Bool = false;
    public static var testSize:Int = 3;
    public static var testType:Int = 1;

    public static var highscore:Int = 0;
    public static var swatted:Int = 0;
    public static var playerHealth:Int = 5;

    public static var camFollow:FlxObject = new FlxObject();
    public static var camGame:FlxCamera;
    public static var camHUD:FlxCamera;
    public static var camZoom = 1;
    public static var camSpeed = 5;

    public static var flies:FlxTypedGroup<Fly>;
    public static var retry:FlxText;    
    var title:FlxSprite;
    var info:FlxText;
    public static var scare:FlxSprite;

    var begun:Bool = false;
    var tweening:Bool = false;

    override function create() {
        super.create();
        CoolUtil.playMusic();

        DiscordIO.changePresence("Playing: SUBGAME-1", null);

        stremMode = SaveData.data.get("Jumpscares");

        highscore = SaveData.saveFile.data.swatScore;

        camZoom = 1;
        camSpeed = 3;
        dead = false;

        camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;

        FlxG.cameras.add(camHUD, false);

        camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());
        FlxG.camera.setScrollBoundsRect(0, 0, FlxG.width, FlxG.height, true);

        playerHealth = 5;
        swatted = 0;

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

        var tiles = new FlxBackdrop(Paths.image('menu/freeplay/tile'), XY, 0, 0);
        tiles.velocity.set(30, 0);
        tiles.screenCenter();
		tiles.alpha = 0.9;
        add(tiles);

        flies = new FlxTypedGroup<Fly>();
		add(flies);
        
        info = new FlxText(0,0,0,'er');
		info.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        info.x = 5;
        info.y = FlxG.height - info.height - 5;
        info.antialiasing = false;
        info.cameras = [camHUD];
		add(info);

        retry = new FlxText(0,0,0,'You died!\nPress ACCEPT to restart.');
		retry.setFormat(Main.dsFont, 50, 0xFFFFFFFF, CENTER);
		retry.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
        retry.screenCenter(X);
        retry.y = FlxG.height - retry.height - 65;
        retry.antialiasing = false;
        retry.cameras = [camHUD];
        retry.alpha = 0;
		add(retry);

        title = new FlxSprite().loadGraphic(Paths.image('minigame/swat/title-fly'));
		title.updateHitbox();
		title.screenCenter();
        title.cameras = [camHUD];
        //title.alpha = 0;
		add(title);

        scare = new FlxSprite();
        scare.frames = Paths.getSparrowAtlas('minigame/swat/texture');
        scare.animation.addByPrefix('ah',  'AH1', 24, true);
        scare.animation.play('ah');
        scare.alpha = 0;
        scare.cameras = [camHUD];
        add(scare);

        Main.setMouse(true);
    }

    function activateTimers(apple:Bool = true)
	{
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if(!tmr.finished)
				tmr.active = apple;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if(!twn.finished)
				twn.active = apple;
		});
	}

    override function closeSubState()
	{
		activateTimers(true);
		super.closeSubState();
	}

    override public function update(elapsed:Float) {
        super.update(elapsed);

        camGame.followLerp = elapsed * camSpeed;
        camGame.zoom = FlxMath.lerp(camGame.zoom, camZoom, elapsed * camSpeed);

        info.text = 'Flies Swatted: $swatted | Health: $playerHealth | Highscore: $highscore';

        if(Controls.justPressed("BACK") && !begun && !tweening) {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        if(Controls.justPressed("ACCEPT")) {
            if(!begun && !tweening) {
                FlxTween.tween(title, {alpha: 0}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
                {
                    CoolUtil.playMusic("fly");
                    begun = true;
                    startFly();
                }});
                tweening = true;
            }
            else if(dead)
                Main.switchState();
        }

        if(Controls.justPressed("PAUSE") && !dead && begun) {
            activateTimers(false);
            openSubState(new subStates.SubgamePause());
        }

        if(FlxG.mouse.justPressed && !dead && begun) {
            var playedSound:Bool = false;
            for(fly in flies) {
                if(CoolUtil.mouseOverlap(fly, FlxG.camera) && !fly.swatted) {
                    if(!hitboxTest) {
                        fly.swat();
                        if(fly.swatted && diff == 1) {
                            new FlxTimer().start(spawnTime, function(tmr:FlxTimer) {
                                startFly();
                            });
                        }
                        swatted++;

                        if(!playedSound) {
                            FlxG.sound.play(Paths.sound('thunder-loud'));
                            FlxG.sound.play(Paths.sound('minigame/swat/${fly.type}'));
                            playedSound = true;
                        }
                    }
                    else {
                        if(fly.flyHealth > 1)
                            fly.swat();
                        trace("touch!");
                    }
                }
            }

            if(!playedSound)
                FlxG.sound.play(Paths.sound('botplayOff'));
        }
    }

    public static function startFly() {
        if(dead) return;

        var fly = new Fly();
        flies.add(fly);
        if(!hitboxTest) fly.startFly(true);
        else fly.screenCenter();

        if(diff > 1 && !hitboxTest) {
            new FlxTimer().start(spawnTime, function(tmr:FlxTimer) {
                startFly();
            });
        }
    }

    public static var dead:Bool = false;
    public static function damage(fly:Fly) {
        if(playerHealth>0) {
            playerHealth--;
            if(diff == 1) {
                new FlxTimer().start(spawnTime, function(tmr:FlxTimer) {
                    startFly();
                });
            }
        }
        else if(!dead)
            die(fly);
    }

    public static function die(fly:Fly) {
        if(dead) return;
        fly.killerFly = true;
        for(flyDie in flies) {
            flyDie.flyHealth = 0;
            flyDie.swat();
        }
        dead = true;
        camZoom = 2;
        camFollow.setPosition(fly.x + (fly.width/2),fly.y + (fly.height/2));
        //Main.switchState();

        retry.alpha = 1;

        if(stremMode) {
            CoolUtil.playMusic();
            FlxG.sound.play(Paths.sound('minigame/swat/jesus'));
            scare.alpha = 1;
        }
        else
            FlxG.sound.play(Paths.sound('minigame/swat/death'));

        if(swatted > highscore) {
            highscore = swatted;
            SaveData.saveFile.data.swatScore = highscore;
            SaveData.save();
        }
    }

    public static var diff(get,never):Int;
    public static function get_diff() {
        if(swatted >= 150)
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
            diffMod = 1.25;
        else if(diff == 5)
            diffMod = 0.8;
        else
            diffMod = 0.5;
        return diffMod;
    }

    public static function sizeRoll(type:Int = 1) {
        if(hitboxTest)
            return testSize;
        else if(type == 1)
            return 1;
        else if(type == 4)
            return 3;
        else
            return 2;
    }

    public static function typeRoll() {
        if(hitboxTest)
            return testType;
        if(diff < 2)
            return 1;
        else {
            var roll:Int = FlxG.random.int(1,100);
            var rangeHelica:Int = 101;
            var rangeWatts:Int = 101;
            var rangeBella:Int = 60;

            if(diff == 3) {
                rangeBella = 50;
            }
            else if(diff == 4) {
                rangeBella = 25;
                rangeWatts = 75;
            }
            else if(diff == 5) {
                rangeBella = 30;
                rangeWatts = 60;
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
    public var killerFly:Bool = false;

    var sprite:FlxSprite;
    public function new() {
        super();
        type = Swat.typeRoll();
        flyHealth = Swat.sizeRoll(type);

        makeGraphic(94, 94, 0xFFFF0000);

        var vert = FlxG.random.int(1,4);
        if(vert < 3)
            setPosition(FlxG.random.float(0-width,FlxG.width),FlxG.height*(vert-1));
        else
            setPosition(FlxG.width*(vert-3),FlxG.random.float(0-height,FlxG.height));

        var anim:Array<Int> = [0,0,1];
        if(type == 3)
            anim = [0,0,0,1];
        else if(type == 2)
            anim = [0,1];
        else if(type == 4)
            anim = [0];

        sprite = new FlxSprite();
		sprite.loadGraphic(Paths.image("minigame/swat/"+type), true, 36, 39);
		sprite.updateHitbox();
		sprite.animation.add("fly", anim, 6, true);
		sprite.animation.play("fly");
        sprite.antialiasing = false;
        sprite.scale.set(3.5,3.5);
        alpha = (Swat.hitboxTest ? 0.8 : 0);
    }

    var spriteScale:Float = 3.5;
    override function update(elapsed:Float)
	{
		super.update(elapsed);
        sprite.update(elapsed);

        sprite.scale.set(
            FlxMath.lerp(sprite.scale.x, spriteScale, FlxG.elapsed * 6),
            FlxMath.lerp(sprite.scale.y, spriteScale, FlxG.elapsed * 6)
        );
        sprite.updateHitbox();
        //trace('sprite: x ${sprite.x}, y ${sprite.y}');
        //trace('hbx: x $x, y $y');
    }

    override function draw()
    {
        sprite.setPosition(x + (width/2) - (sprite.width/2), y + (height/2) - (sprite.height/2));
        sprite.draw();
        super.draw();// DONT render hitbox
    }

    public var flyTween:FlxTween;
    public var colorTween:FlxTween;
    public function startFly(first:Bool = false, hurry:Bool = false) {
        if(swatted) return;

        if(first) {
            if(colorTween != null) colorTween.cancel();
		    colorTween = FlxTween.color(sprite, 3, 0xFFFFFFFF, FlxColor.RED, {
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
        Swat.damage(this);
        flyHealth = 0;
        swat();
    }

    public function swat() {
        flyHealth--;

        if(Swat.hitboxTest) return;
        if(flyTween != null) flyTween.cancel();
        if(colorTween != null) colorTween.cancel();

        if(flyHealth > 0)
            startFly(true);
        else if((Swat.playerHealth > 0) || !killerFly) {
            swatted = true;
            flyTween = FlxTween.tween(sprite, {alpha: 0}, 0.2, {
                onComplete: function(twn:FlxTween) {
                    destroy();
                }
            });
        }
        else {
            //
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
            spriteScale = 3.5 + (0.6*(_flyHealth-1));
        }
        return _flyHealth;
    }
}