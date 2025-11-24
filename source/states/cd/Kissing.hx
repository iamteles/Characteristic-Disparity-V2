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
import gameObjects.MoneyCounter;


using StringTools;

class Kissing extends MusicBeatState
{
    var bxbNeutral:FlxSprite;
    var bxbKissing:FlxSprite;
    var bxbOops:FlxSprite;
    var bxbDie:FlxSprite;
    var bxbDust:FlxSprite;

    var breeLeft:FlxSprite;
    var breeRight:FlxSprite;
    var breeAngry:FlxSprite;

    var title:FlxSprite;

    var warning:FlxSprite;
    var scoreTxt:FlxText;
    var retry:FlxText;

    var score:Int = 0;
    var highscore:Int = 0;

    var begun:Bool = false;
    var tweening:Bool = false;
    public static var moneyCount:MoneyCounter;
    override function create()
    {
        super.create();
        highscore = SaveData.saveFile.data.kissScore;

        CoolUtil.playMusic("kiss");
        Main.setMouse(false);

        DiscordIO.changePresence("Playing: SUBGAME-2", null);

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(80,80,80));
		bg.screenCenter();
		add(bg);

        bxbNeutral = new FlxSprite().loadGraphic(Paths.image('minigame/bxbneutral'));
		bxbNeutral.updateHitbox();
		bxbNeutral.screenCenter();
		add(bxbNeutral);

        bxbKissing = new FlxSprite().loadGraphic(Paths.image('minigame/bxbkiss'));
		bxbKissing.updateHitbox();
		bxbKissing.screenCenter();
        bxbKissing.alpha = 0;
		add(bxbKissing);

        bxbOops = new FlxSprite().loadGraphic(Paths.image('minigame/bxboops'));
		bxbOops.updateHitbox();
		bxbOops.screenCenter();
        bxbOops.alpha = 0;
		add(bxbOops);

        bxbDie = new FlxSprite().loadGraphic(Paths.image('minigame/bxbdie'));
		bxbDie.updateHitbox();
		bxbDie.screenCenter();
        bxbDie.alpha = 0;
		add(bxbDie);

        bxbDust = new FlxSprite().loadGraphic(Paths.image('minigame/bxbdust'));
		bxbDust.updateHitbox();
		bxbDust.screenCenter();
        bxbDust.alpha = 0;
		add(bxbDust);

        breeLeft = new FlxSprite().loadGraphic(Paths.image('minigame/breeleft'));
		breeLeft.updateHitbox();
		breeLeft.screenCenter();
		add(breeLeft);

        breeRight = new FlxSprite().loadGraphic(Paths.image('minigame/breeright'));
		breeRight.updateHitbox();
		breeRight.screenCenter();
        breeRight.alpha = 0;
		add(breeRight);

        breeAngry = new FlxSprite().loadGraphic(Paths.image('minigame/breeangry'));
		breeAngry.updateHitbox();
		breeAngry.screenCenter();
        breeAngry.alpha = 0;
		add(breeAngry);

        warning = new FlxSprite().loadGraphic(Paths.image('minigame/warning'));
		warning.updateHitbox();
		warning.screenCenter();
        warning.alpha = 0;
		add(warning);

        scoreTxt = new FlxText(0,0,0,'Score: 0 | Highscore: $highscore');
		scoreTxt.setFormat(Main.dsFont, 40, 0xFFFFFFFF, CENTER);
		scoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        scoreTxt.y = FlxG.height - scoreTxt.height;
		scoreTxt.screenCenter(X);
        scoreTxt.antialiasing = false;
		add(scoreTxt);

        title = new FlxSprite().loadGraphic(Paths.image('minigame/title'));
		title.updateHitbox();
		title.screenCenter();
        //title.alpha = 0;
		add(title);

        retry = new FlxText(0,0,0,'You died!\nPress ACCEPT to restart.');
		retry.setFormat(Main.dsFont, 50, 0xFFFFFFFF, CENTER);
		retry.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.4);
        retry.screenCenter(X);
        retry.y = FlxG.height - retry.height - 65;
        retry.antialiasing = false;
        retry.alpha = 0;
		add(retry);

        moneyCount = new MoneyCounter(0, 0);
		add(moneyCount);

        //loop();
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

    var isKissing:Bool = false;
    var breeWaiting:Bool = true;
    var kissTimer:FlxTimer;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed("BACK") && !begun && !tweening) {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }
        
        if(Controls.justPressed("PAUSE") && !dead && begun) {
            activateTimers(false);
            openSubState(new subStates.SubgamePause());
        }

        if(Controls.justPressed("ACCEPT") && finishDie)
            Main.switchState();

		if(Controls.justPressed("ACCEPT") && !dead)
		{
            if(!begun) {

                if(!tweening) {
                    FlxTween.tween(title, {alpha: 0}, 1, {ease: FlxEase.circInOut, onComplete: function(twn:FlxTween)
                        {
                            begun = true;
                            loop();
                        }});

                    tweening = true;
                }
            }
            else if (!Controls.pressed("PAUSE")) {
                if(!breeWaiting) {
                    triggerDeath();
                }
                else {
                    bxbNeutral.alpha = 0;
                    bxbKissing.alpha = 1;
                    FlxG.sound.play(Paths.sound('minigame/kiss'));
        
                    isKissing = true;
        
                    if(kissTimer != null)
                        if(kissTimer.active)
                            kissTimer.cancel();
        
                    kissTimer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
                    {
                        bxbNeutral.alpha = 1;
                        bxbKissing.alpha = 0;
        
                        isKissing = false;
                    });
        
                    score++;
        
                    scoreTxt.text = "Score: " + score + " | " + "Highscore: " + highscore;
                    scoreTxt.screenCenter(X);
                }
            }
		}
    }

    var preWarning:FlxTimer;
    var preLook:FlxTimer;
    var preLeft:FlxTimer;
    function loop() {
        breeLeft.alpha = 1;
        breeRight.alpha = 0;

        warning.alpha = 0;

        breeWaiting = true;

        if(preWarning != null)
            if(preWarning.active)
                preWarning.cancel();

        preWarning = new FlxTimer().start(FlxG.random.float(calc(true), calc(false)), function(tmr:FlxTimer)
        {
            FlxG.sound.play(Paths.sound('minigame/surprised'));
            warning.alpha = 1;

            if(preLook != null)
                if(preLook.active)
                    preLook.cancel();

            preLook = new FlxTimer().start(0.5, function(tmr:FlxTimer)
            {
                breeWaiting = false;
                breeLeft.alpha = 0;
                breeRight.alpha = 1;

                if(preLeft != null)
                    if(preLeft.active)
                        preLeft.cancel();

                preLeft = new FlxTimer().start(FlxG.random.float(1, 3), function(tmr:FlxTimer)
                {  
                    loop();
                });
            });
        });
    }
    
    var dead:Bool = false;
    var finishDie:Bool = false;

    function triggerDeath()
    {
        dead = true;

        if(score > highscore) {
            highscore = score;
            SaveData.saveFile.data.kissScore = score;
            SaveData.save();
        }

        if(kissTimer != null)
            if(kissTimer.active)
                kissTimer.cancel();

        if(preWarning != null)
            if(preWarning.active)
                preWarning.cancel();

        if(preLeft != null)
            if(preLeft.active)
                preLeft.cancel();

        if(preLook != null)
            if(preLook.active)
                preLook.cancel();

        breeAngry.alpha = 1;
        breeLeft.alpha = 0;
        breeRight.alpha = 0;

        bxbNeutral.alpha = 0;
        bxbKissing.alpha = 0;
        bxbOops.alpha = 1;

        warning.alpha = 0;

        FlxG.sound.play(Paths.sound('miss/miss1'));
        new FlxTimer().start(0.7, function(tmr:FlxTimer)
        {
            bxbOops.alpha = 0;
            bxbDie.alpha = 1;

            FlxG.sound.play(Paths.sound('thunder-loud'));

            new FlxTimer().start(1.4, function(tmr:FlxTimer)
            {
                bxbDie.alpha = 0;
                bxbDust.alpha = 1;

                finishDie = true;
                FlxTween.tween(retry, {alpha: 1}, 0.5);

                var moneyScore:Int = Std.int(score/5);
                trace(moneyScore);

                if(moneyScore > 0) {
                    SaveData.transaction(moneyScore);
                }
            });
        });
    }

    function calc(minr:Bool = true):Float {
        var base:Float = 5;
        var min = 1 - ((score^2) * 0.00002);
        var max = base - ((score^2) * 0.00002);

        if(min<0)
            min = 0.02;

        if(max<0)
            max = 0.07;

        if(!minr)
            return max;
        else
            return min;
    }
}