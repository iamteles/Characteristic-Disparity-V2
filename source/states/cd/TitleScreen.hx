package states.cd;

import data.Discord.DiscordIO;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import data.Conductor;
import openfl.display.BlendMode;
import flixel.math.FlxMath;
import gameObjects.MenuChar;

class TitleScreen extends MusicBeatState
{
    //actual title
    var bg:FlxSprite;
    var tiles:FlxBackdrop;
    var logo:FlxSprite;
    var info:FlxText;

    //intro
    var introBack:FlxSprite;
    var vhs:FlxSprite;
    var shatterdisk:FlxSprite;
    var sdText:FlxText;
    var tpt:FlxText;
    var oldLogo:FlxSprite;
    var plus:FlxSprite;
    var game:FlxSprite;
    var gameText:FlxText;

    var sdActive:Bool = false;
    var tptActive:Bool = false;
    var logoActive:Bool = false;
    var plusActive:Bool = false;
    var gameActive:Bool = false;

    static var introEnded:Bool = false;
    override public function create():Void 
    {
        super.create();

        if(introEnded){
            CoolUtil.playMusic("intro_plus");
            FlxG.sound.music.time = (Conductor.crochet * 16);
        }
        else {
            new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                CoolUtil.playMusic("intro_plus");
            });
        }

        Conductor.setBPM(105);
		Main.setMouse(false);
        DiscordIO.changePresence("In the Title Screen", null);

        bg = new FlxSprite().loadGraphic(Paths.image('menu/title/gradients/' + Main.curTitle[0]));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
        
        var tile:String = Main.curTitle[0];
        var tileAlpha:Float = 1;
        if(tile == "retro") {
            tile = "main";
            tileAlpha = 0;
        }
		tiles = new FlxBackdrop(Paths.image('menu/title/tiles/' + tile), XY, 0, 0);
        tiles.velocity.set(40,40);
        tiles.screenCenter();
        tiles.alpha = tileAlpha;
        add(tiles);

        var logoName:String = "-plus";
        if(Main.curTitle[0] == "retro")
            logoName = "-retro";
        logo = new FlxSprite(204.05, 46.7).loadGraphic(Paths.image('menu/title/logo' + logoName));
        if(logoName == "-plus")
            logo.scale.set(0.7,0.7);
        logo.updateHitbox();
        logo.screenCenter(X);
        var storeY:Float = logo.y;
		logo.y -= 20;
		FlxTween.tween(logo, {y: storeY + 20}, 1.6, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
		add(logo);

        var text:String = "Press START!";
        info = new FlxText(0,0,0,text);
		info.setFormat(Main.titleFont, 50, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
        info.screenCenter(X);
        info.y = 599.95;
        add(info);

        var verTxt = new FlxText(0,0,0,'v2.5.0');
		verTxt.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		verTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        verTxt.x = 5;
        verTxt.y = FlxG.height - verTxt.height - 5;
        verTxt.antialiasing = false;
		add(verTxt);

        introBack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0,0,0));
		introBack.screenCenter();
		add(introBack);

        shatterdisk = new FlxSprite().loadGraphic(Paths.image('menu/title/shatterdisk'));
        shatterdisk.scale.set(0.8,0.8);
        shatterdisk.updateHitbox();
		shatterdisk.screenCenter();
        shatterdisk.y += 80;
        shatterdisk.alpha = 0;
		add(shatterdisk);

        sdText = new FlxText(0,0,0,"Presents");
		sdText.setFormat(Main.titleFont, 42, 0xFFFFFFFF, CENTER);
        sdText.screenCenter(X);
        sdText.y = shatterdisk.y + shatterdisk.height - 80 - 10;
        sdText.alpha = 0;
        add(sdText);

        tpt = new FlxText(0,0,0,"Originally made for the\nTurtle Pals Tapes Mod Jam");
		tpt.setFormat(Main.titleFont, 60, 0xFFFFFFFF, CENTER);
        tpt.screenCenter();
        tpt.y += 80;
        tpt.alpha = 0;
        add(tpt);

        oldLogo = new FlxSprite().loadGraphic(Paths.image('menu/title/logo-basic'));
        oldLogo.scale.set(0.8,0.8);
        oldLogo.updateHitbox();
		oldLogo.screenCenter();
        oldLogo.y += 80;
        oldLogo.alpha = 0;
		add(oldLogo);

        plus = new FlxSprite().loadGraphic(Paths.image('menu/title/plus'));
        plus.scale.set(0.8,0.8);
        plus.updateHitbox();
		plus.screenCenter();
        plus.alpha = 0;
		add(plus);

        game = new FlxSprite();
        game.frames = Paths.getSparrowAtlas("menu/title/game");
        game.animation.addByPrefix("stop", 'idle0000', 20, true);
        game.animation.addByPrefix("idle", 'idle', 30, false);
        game.animation.play('stop');
        game.scale.set(2, 2);
        game.updateHitbox();
        game.screenCenter();
        game.y += 80;
        game.alpha = 0;
        add(game);

        gameText = new FlxText(0,0,0,"Characteristic Disparity");
		gameText.setFormat(Main.titleFont, 60, 0xFFFFFFFF, CENTER);
        gameText.screenCenter(X);
        gameText.y = game.y + game.height + 10 - 80;
        gameText.alpha = 0;
        add(gameText);

        vhs = new FlxSprite();
        vhs.frames = Paths.getSparrowAtlas("backgrounds/cave/vhs");
        vhs.animation.addByPrefix("idle", 'idle', 16, true);
        vhs.animation.play('idle');
        vhs.scale.set(3, 3);
        vhs.updateHitbox();
        vhs.screenCenter();
        vhs.alpha = 1;
        vhs.blend = SUBTRACT;
        vhs.antialiasing = false;
        add(vhs);

        if(introEnded)
			skipIntro(false);
    }

    override function stepHit()
	{
		super.stepHit();

		if(!introEnded)
		{
			switch(curStep)
			{
                case 1:
                    started = true;
                    trace("show");
                    tptActive = true;
                case 10:
                    trace("hide");
                    tptActive = false;
                    tpt.alpha = 0;
                case 16:
                    trace("show");
                    game.animation.play('idle');
                    gameActive = true;
                case 26:
                    trace("hide");
                    gameActive = false;
                    game.alpha = 0;
                    gameText.alpha = 0;
                case 32:
                    trace("show");
                    sdActive = true;
                case 42:
                    trace("hide");
                    sdActive = false;
                    shatterdisk.alpha = 0;
                    sdText.alpha = 0;
                case 48:
                    trace("show");
                    logoActive = true;
                    plusActive = true;
                case 50:
                    FlxTween.tween(plus, {alpha: 1}, 1.5);
                case 60:
                    trace("hide");
                    logoActive = false;
                    plusActive = false;
                    oldLogo.alpha = 0;
                    plus.visible = false;
                case 64:
                    skipIntro();					
			}
		}
	}

    public function skipIntro(skip:Bool = false)
	{
        started = true;
		introEnded = true;

        SaveData.progression.set("firstboot", true);
        SaveData.save();
		
		if(FlxG.sound.music != null && skip)
			FlxG.sound.music.time = (Conductor.crochet * 16);

        vhs.visible = false;
		introBack.visible = false;
        shatterdisk.visible = false;
        sdText.visible = false;
        tpt.visible = false;
        oldLogo.visible = false;
        plus.visible = false;
        game.visible = false;
        gameText.visible = false;
		CoolUtil.flash(FlxG.camera, Conductor.crochet * 4 / 1000, 0xFFFFFFFF);
	}

    var started:Bool = false;
    var exiting:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(FlxG.sound.music != null)
			if(FlxG.sound.music.playing)
				Conductor.songPos = FlxG.sound.music.time;

        if(Controls.justPressed("ACCEPT") && started) {
            if(introEnded)
                end();
            else if(SaveData.progression.get("firstboot"))
                skipIntro(true);
        }

        if(sdActive) {
            shatterdisk.y = FlxMath.lerp(shatterdisk.y, (FlxG.height/2) - (shatterdisk.height/2), elapsed * 8);
            shatterdisk.alpha = FlxMath.lerp(shatterdisk.alpha, 1, elapsed * 8);
            sdText.alpha = FlxMath.lerp(sdText.alpha, 1, elapsed * 8);
        }

        if(tptActive) {
            tpt.y = FlxMath.lerp(tpt.y, (FlxG.height/2) - (tpt.height/2), elapsed * 8);
            tpt.alpha = FlxMath.lerp(tpt.alpha, 1, elapsed * 8);
        }

        if(logoActive) {
            oldLogo.y = FlxMath.lerp(oldLogo.y, (FlxG.height/2) - (oldLogo.height/2), elapsed * 8);
            oldLogo.alpha = FlxMath.lerp(oldLogo.alpha, 1, elapsed * 8);
        }

        if(plusActive) {
            plus.x = (FlxG.width/2) - (plus.width/2) + FlxG.random.float(-0.003 * plus.width, 0.003 * plus.width);
            plus.y = (FlxG.height/2) - (plus.height/2) + FlxG.random.float(-0.003 * plus.height, 0.003 * plus.height);
        }

        if(gameActive) {
            game.y = FlxMath.lerp(game.y, (FlxG.height/2) - (game.height/2), elapsed * 8);
            game.alpha = FlxMath.lerp(game.alpha, 1, elapsed * 8);
            gameText.alpha = FlxMath.lerp(gameText.alpha, 1, elapsed * 8);
        }
    }

    function end()
    {
        if(exiting) return;
        exiting = true;
        CoolUtil.playMusic("");
        FlxG.sound.play(Paths.sound("intro/end_plus"));
        CoolUtil.flash(FlxG.camera, 1, 0xffffffff); 
        FlxFlicker.flicker(info, 2, 0.06, true, false, function(_)
        {
            Main.switchState(new states.cd.MainMenu());
        });
    }
}