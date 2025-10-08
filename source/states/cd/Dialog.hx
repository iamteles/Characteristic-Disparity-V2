package states.cd;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.util.FlxTimer;
import states.*;
import gameObjects.DialogChar;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import data.Discord.DiscordIO;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// same dialog code as mlc btw
typedef Dialogue =
{
	var characters:Array<String>;
	var lines:Array<DialogueLine>;
	var finisher:Null<String>;
    var initial:Null<Array<String>>;
    var background:Null<String>;
    var song:Null<String>;
}

typedef DialogueLine =
{
	var character:String;
	var frame:String;
	var text:String;
	var delay:Null<Float>;
    var thing:Null<String>;
}

typedef PastDialogue =
{
    var lines:Array<PastLine>;
    var boxName:String;
}

typedef PastLine =
{
    var text:String;
    var name:String;
}

class Dialog extends MusicBeatState
{
    var bg:FlxSprite;
    var box:FlxSprite;

    var name:FlxText;
    var tex:FlxTypeText;

    var left:DialogChar;
    var right:DialogChar;
    var right2:DialogChar;
    var log:Dialogue;
    var pastLog:PastDialogue;

    var curLine:Int = 0;
	var loaded:Bool = false;
    var hasScrolled:Bool = false;
    public static var dialog:String = 'log';
    
    var introCenterAlpha:Float = 0;
    var ypos:Int = 30;
    var thirdpos:Int = 30;

    var clickSfx:FlxSound;
    override function create()
    {
        super.create();

        try
        {
            log = haxe.Json.parse(Paths.getContent('data/log/' + dialog + '.json').trim());

            loaded = true;
        }
        catch (e)
        {
            //
        }

        if(log.song != null)
            CoolUtil.playMusic("dialogue/" + log.song);

        Main.setMouse(false);

        DiscordIO.changePresence("Reading dialogue...", null);

        bg = new FlxSprite().loadGraphic(Paths.image('dialog/bgs/' + log.background));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        var boxName:String = "box";
        if(dialog == "ripple" || dialog == "customer-service") {
            ypos = 120;
            thirdpos = 90;
            //introCenterAlpha = 0.6;
            boxName = "shack";
        }
        else if(dialog == "sin")
            boxName = "bree";

        left = new DialogChar();
        left.reloadChar(log.characters[0]);
		left.setPosition(
            -50,
            ypos
		);
        left.alpha = introCenterAlpha;
        left.fakeAlpha = introCenterAlpha;
        add(left);

        right = new DialogChar();
        right.reloadChar(log.characters[1]);
		//right.flipX = true;
		right.setPosition(
            FlxG.width + 56,
            ypos
		);
        right.alpha = introCenterAlpha;
        right.fakeAlpha = introCenterAlpha;
        add(right);

        if(log.characters[2] != null) {
            right2 = new DialogChar();
            right2.reloadChar(log.characters[2]);
            //right.flipX = true;
            right2.setPosition(
                (FlxG.width/2) - (right2.width/2),
                thirdpos + 56
            );
            right2.alpha = introCenterAlpha;
            right2.fakeAlpha = introCenterAlpha;
            add(right2);
        }

        /*
        if(dialog == "ripple" || dialog == "customer-service") {
            right2.isActive = true;
            right.isActive = true;
            left.isActive = true;
        }
        */

        box = new FlxSprite().loadGraphic(Paths.image('dialog/dialogue-$boxName'));
        box.scale.set(0.65,0.65);
		box.updateHitbox();
		box.screenCenter(X);
        box.y = FlxG.height - box.height - 10;
		add(box);

        clickSfx = new FlxSound();
		clickSfx.loadEmbedded(Paths.sound('menu/scroll'), false, false);
		FlxG.sound.list.add(clickSfx);

        tex = new FlxTypeText(box.x + 25, box.y + 123, Std.int(FlxG.width - 110), 'placeholder', true);
		tex.alpha = 1;
		tex.setFormat(Main.gFont, 36, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 2;
        switch(SaveData.data.get("Text Speed")) {
            case "FAST":
                tex.delay = 0.02;
            case "SLOW":
                tex.delay = 0.05;
            case "INSTANT":
                tex.delay = 0.0000001;
            default:
                tex.delay = 0.035;
        }
		if(SaveData.data.get("Text Speed") != "INSTANT") tex.sounds = [clickSfx];
		tex.finishSounds = false;
		add(tex);

        name = new FlxText(0,box.y + 22,0,"Bella", 200);
		name.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
        name.screenCenter(X);
        name.x -= namePos;
        add(name);

        /*var skipTxt = new FlxText(0,0,0,"Press BACK to skip.");
		skipTxt.setFormat(Main.dsFont, 34, 0xFFFFFFFF, CENTER);
		skipTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        skipTxt.y = FlxG.height - skipTxt.height;
		skipTxt.screenCenter(X);
		add(skipTxt);*/

        var hud = new FlxSprite().loadGraphic(Paths.image('dialog/hud'));
        hud.scale.set(0.8,0.8);
		hud.updateHitbox();
        //hud.x = FlxG.width - hud.width;
        hud.screenCenter(X);
        hud.alpha = 0;
        FlxTween.tween(hud, {alpha: 0.75}, 1, {
            ease: FlxEase.cubeOut,
            startDelay: 0.8,
            onComplete: function(twn:FlxTween)
            {
                FlxTween.tween(hud, {alpha: 0}, 1, {
                    ease: FlxEase.cubeIn,
                    startDelay: 2.8
                });
            }
		});
		add(hud);

        pastLog = {lines: [], boxName:boxName};

        if(loaded)
            textbox();
        
    }

    var waveGone:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(left.isActive) {
            left.x = FlxMath.lerp(left.x, 50,    elapsed*8);
            left.y = FlxMath.lerp(left.y, ypos,  elapsed*8);
            left.alpha = FlxMath.lerp(left.alpha, left.fakeAlpha,  elapsed*8);
        }
        else if(waveGone) {
            left.x = FlxMath.lerp(left.x, -50,    elapsed*8);
            left.y = FlxMath.lerp(left.y, ypos,  elapsed*8);
            left.alpha = FlxMath.lerp(left.alpha, 0,  elapsed*8);
        }

        if(right.isActive) {
            right.x = FlxMath.lerp(right.x, FlxG.width - right.width - 56, elapsed*8);
            right.y = FlxMath.lerp(right.y, ypos, elapsed*8);
            right.alpha = FlxMath.lerp(right.alpha, right.fakeAlpha,  elapsed*8);
        }

        if(log.characters[2] != null) {
            if(right2.isActive) {
                right2.x = FlxMath.lerp(right2.x, (FlxG.width/2) - (right2.width/2), elapsed*8);
                right2.y = FlxMath.lerp(right2.y, thirdpos, elapsed*8);
                right2.alpha = FlxMath.lerp(right2.alpha, right2.fakeAlpha,  elapsed*8);
            }
        }

        if(Controls.justPressed("BACK"))
            end();

        if(Controls.justPressed("LOOP"))
            FlxG.state.openSubState(new subStates.DialogHistorySubState(pastLog));

        if((Controls.justPressed("ACCEPT"))) {
            if(!hasScrolled)
                tex.skip();
            else {
                FlxG.sound.play(Paths.sound('dialog/skip'));

                if(curLine == log.lines.length) {
                    if(log.finisher != null) {
                        end();
                    }
                }
                else
                    textbox();
            }
        }
    }

    var bumpbumpbump:Int = 20;
    public static var namePos:Int = 470;
    function textbox()
    {
        hasScrolled = false;
        tex.resetText(log.lines[curLine].text);

        if(log.lines[curLine].thing != null) {
            switch(log.lines[curLine].thing) {
                case 'hideleft':
                    left.isActive = false;
                    waveGone = true;
            }
        }

        switch (log.lines[curLine].character) {
            case 'left':
                left.playAnim(log.lines[curLine].frame);
                if(left.isActive)left.y += bumpbumpbump;
                left.isActive = true;
                if(right.fakeAlpha != 0)right.fakeAlpha = 0.6;
                left.fakeAlpha = 1;
                name.text = left.name;
                if(log.characters[2] != null && right2.fakeAlpha != 0) right2.fakeAlpha = 0.6;
            case 'right':
                right.playAnim(log.lines[curLine].frame);
                if(right.isActive)right.y += bumpbumpbump;
                right.isActive = true;
                if(left.fakeAlpha != 0)left.fakeAlpha = 0.6;
                right.fakeAlpha = 1;
                name.text = right.name;
                if(log.characters[2] != null && right2.fakeAlpha != 0) right2.fakeAlpha = 0.6;
            case 'center':
                if(log.characters[2] != null) {
                    right2.playAnim(log.lines[curLine].frame);
                    if(right2.isActive)right2.y += bumpbumpbump;
                    right2.isActive = true;
                    right2.fakeAlpha = 1;
                    if(left.fakeAlpha != 0)left.fakeAlpha = 0.6;
                    if(right.fakeAlpha != 0)right.fakeAlpha = 0.6;
                    name.text = right2.name;
                }
        }

        name.screenCenter(X);
        name.x -= namePos;

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            tex.start(false, function()
                {
                    new FlxTimer().start(0.1, function(tmr:FlxTimer)
                    {
                        hasScrolled = true;
                    });
                });
        });

        var newPast:PastLine = {name:name.text, text:log.lines[curLine].text};
        pastLog.lines.push(newPast);

        curLine ++;
    }

    function end() {
        switch (log.finisher) {
            case "euphoria":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("euphoria", "normal");
                Main.switchState(new LoadSongState());
            case "nefarious":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("nefarious", "normal");
                Main.switchState(new LoadSongState());
            case "divergence":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("divergence", "normal");
                Main.switchState(new LoadSongState());
            case "allegro":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("allegro", "normal");
                Main.switchState(new LoadSongState());
            case "panic-attack":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("panic-attack", "normal");
                Main.switchState(new LoadSongState());
            case "convergence":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("convergence", "normal");
                Main.switchState(new LoadSongState());
            case "desertion":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("desertion", "normal");
                Main.switchState(new LoadSongState());
            case "sin":
                PlayState.isStoryMode = true;
                PlayState.SONG = SongData.loadFromJson("sin", "normal");
                Main.switchState(new LoadSongState());
            case "song":
                Main.switchState(new LoadSongState());
            default:
                //close();
        }
    }
}