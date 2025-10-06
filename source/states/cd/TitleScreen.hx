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
import data.Conductor;

class TitleScreen extends MusicBeatState
{
    var bg:FlxSprite;
    var tiles:FlxBackdrop;
    var logo:FlxSprite;
    var info:FlxText;

    public static var fromIntro:Bool = false;
    override public function create():Void 
    {
        super.create();

        CoolUtil.playMusic("intro");
        Conductor.setBPM(185);
        SaveData.progression.set("firstboot", true);
        SaveData.save();

		Main.setMouse(false);

        DiscordIO.changePresence("In the Menus...", null);

        CoolUtil.flash(FlxG.camera, 0.5);

        if(fromIntro) {
            if(FlxG.sound.music != null)
			    FlxG.sound.music.time = (Conductor.crochet * (8*4));

            fromIntro = false;
        }

        bg = new FlxSprite().loadGraphic(Paths.image('menu/title/gradients/' + Main.possibleTitles[Main.randomized][0]));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
        
		tiles = new FlxBackdrop(Paths.image('menu/title/tiles/' + Main.possibleTitles[Main.randomized][0]), XY, 0, 0);
        tiles.velocity.set(40,40);
        tiles.screenCenter();
        add(tiles);

        logo = new FlxSprite(204.05, 46.7).loadGraphic(Paths.image('menu/title/logo'));
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
    }

    var started:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed("ACCEPT"))
            end();
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