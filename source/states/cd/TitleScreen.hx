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

class TitleScreen extends MusicBeatState
{
    //actual title
    var bg:FlxSprite;
    var tiles:FlxBackdrop;
    var logo:FlxSprite;
    var info:FlxText;

    //intro
    var introBack:FlxSprite;

    static var introEnded:Bool = false;
    override public function create():Void 
    {
        super.create();
		if(!introEnded)
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				CoolUtil.playMusic("intro");
			});
		}
        else {
            CoolUtil.playMusic("intro");
            //FlxG.sound.music.time = (Conductor.crochet * (8*4));
        }
        Conductor.setBPM(185);
        SaveData.progression.set("firstboot", true);
        SaveData.save();

		Main.setMouse(false);

        DiscordIO.changePresence("In the Title Screen", null);

        CoolUtil.flash(FlxG.camera, 0.5);

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
		info.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
        info.screenCenter(X);
        info.y = 599.95;
        add(info);

        var verTxt = new FlxText(0,0,0,'@Team Shatterdisk 2025');
		verTxt.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		verTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        verTxt.x = 5;
        verTxt.y = FlxG.height - verTxt.height - 5;
        verTxt.antialiasing = false;
		add(verTxt);

        introBack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0,0,0));
		introBack.screenCenter();
		add(introBack);

        if(introEnded)
			skipIntro(true);
    }

    override function beatHit()
	{
		super.beatHit();

		if(!introEnded)
		{
			switch(curBeat)
			{
                case 1:
                    trace("sd logo");
                case 7:
                    trace("sd logo hide");
                case 8:
                    trace("powered by");
                case 15:
                    trace("powered by hide");
                case 16:
                    trace("bella and bex");
                case 20:
                    trace("bree and watts");
                case 23:
                    trace("nila");
                case 24:
                    trace("logo show up");
                case 28:
                    trace("logo move to left and plus show");
                case 31:
                    trace("logo hide and plus center");
				case 32:
					skipIntro();
			}
		}
	}

    public function skipIntro(skip:Bool = false)
	{
		introEnded = true;
		
		if(FlxG.sound.music != null && skip)
			FlxG.sound.music.time = (Conductor.crochet * (8*4));
		
		introBack.visible = false;
		CoolUtil.flash(FlxG.camera, Conductor.crochet * 4 / 1000, 0xFFFFFFFF);
	}

    var started:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(FlxG.sound.music != null)
			if(FlxG.sound.music.playing)
				Conductor.songPos = FlxG.sound.music.time;

        if(Controls.justPressed("ACCEPT")) {
            if(introEnded)
                end();
            else
                skipIntro(true);
        }
    }

    function end()
    {
        if(started) return;
        started = true;
        CoolUtil.playMusic("");
        FlxG.sound.play(Paths.sound("intro/end"));
        CoolUtil.flash(FlxG.camera, 1, 0xffffffff); 
        FlxFlicker.flicker(info, 2, 0.06, true, false, function(_)
        {
            Main.switchState(new states.cd.MainMenu());
        });
    }
}