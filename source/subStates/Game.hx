package subStates;

import data.Discord.DiscordIO;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.tweens.FlxTween;
import data.Highscore;
import data.Highscore.ScoreData;
import data.GameData.MusicBeatSubState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import states.*;
import flixel.util.FlxTimer;

class Game extends MusicBeatSubState
{
    var curSelected:Int = 0;

    var swatLogo:FlxSprite;
    var kissLogo:FlxSprite;

    var swatButton:FlxSprite;
    var kissButton:FlxSprite;

    var initX:Float;
    var info:FlxText;
	public function new()
    {
        super();

        var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);
		banana.alpha = 0;
        FlxTween.tween(banana, {alpha: 0.4}, 0.4);

        swatButton = new FlxSprite().loadGraphic(Paths.image('menu/main/game/swat'));
        swatButton.x = ((FlxG.width/2) - (swatButton.width/2));
        swatButton.y = 379.75;
        swatButton.alpha = 0;
        add(swatButton);
        
        var uh:String = (SaveData.progression.get("finished") ? "" : "-locked");
        kissButton = new FlxSprite().loadGraphic(Paths.image('menu/main/game/kiss$uh'));
        kissButton.x = ((FlxG.width/2) - (kissButton.width/2));
        kissButton.y = 379.75;
        kissButton.alpha = 0;
        add(kissButton);

        initX = swatButton.x;

        swatLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/main/game/swat-logo'));
        swatLogo.alpha = 0;
		add(swatLogo);

        kissLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('menu/main/game/kiss-logo'));
        kissLogo.alpha = 0;
		add(kissLogo);

        info = new FlxText(0,0,0,"Special Subgames!");
		info.setFormat(Main.dsFont, 30, 0xFFFFFFFF, CENTER);
		info.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
        info.y = FlxG.height - info.height - 5;
        info.screenCenter(X);
        //info.antialiasing = false;

        var bar = new FlxSprite().makeGraphic(FlxG.width, Std.int(info.height) + 10, 0xFF000000);
		bar.y = FlxG.height - bar.height;
		add(bar);
        add(info);

        new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			selected = false;
		});

        changeSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        swatLogo.y = FlxMath.lerp(swatLogo.y, 0, elapsed*6);
        swatLogo.alpha = (curSelected == 0 ? 1 : 0);
        
        kissLogo.y = FlxMath.lerp(kissLogo.y, 0, elapsed*6);
        if(SaveData.progression.get("finished"))
            kissLogo.alpha = (curSelected == 1 ? 1 : 0);

        if(!selected) {  
            swatButton.alpha = FlxMath.lerp(swatButton.alpha, (curSelected == 0 ? 1 : 0.5), elapsed*8);
            kissButton.alpha = FlxMath.lerp(kissButton.alpha, (curSelected == 1 ? 1 : 0.5), elapsed*8);
        }

        swatButton.x = FlxMath.lerp(swatButton.x, initX - 170, elapsed*6);
        kissButton.x = FlxMath.lerp(kissButton.x, initX + 170, elapsed*6);

        if(!selected) {
            if(Controls.justPressed("UI_LEFT"))
                changeSelection(-1);
            if(Controls.justPressed("UI_RIGHT"))
                changeSelection(1);

            if(Controls.justPressed("BACK")) {
                FlxG.sound.play(Paths.sound('menu/back'));
                //Freeplay.selected = false;
                states.cd.MainMenu.inSub = false;
                close();
            }
        }

        if(!selected && Controls.justPressed("ACCEPT")) {
            if(curSelected == 1 && !SaveData.progression.get("finished")) {
                shaking = true;
                FlxG.sound.play(Paths.sound("menu/locked"));
                new FlxTimer().start(0.1, function(tmr:FlxTimer)
                {
                    shaking = false;
                    kissButton.offset.set(0,0);
                });
            }
            else {
                selected = true;
                var item:FlxSprite = (curSelected == 0 ? swatButton : kissButton);
                var itemNo:FlxSprite = (curSelected == 1 ? swatButton : kissButton);
                FlxG.sound.play(Paths.sound("menu/select"));
                FlxTween.tween(itemNo, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
                FlxFlicker.flicker(item, 1, 0.06, true, false, function(_)
                {             
                    switch(curSelected)
                    {
                        case 1:
                            Main.switchState(new states.cd.Kissing());
                        default:
                            Main.switchState(new states.cd.Swat());
                    }
                });
            }
        }

        if (shaking) {
            kissButton.offset.x = FlxG.random.float(-0.05 * kissButton.width, 0.05 * kissButton.width);
            kissButton.offset.y = FlxG.random.float(-0.05 * kissButton.height, 0.05 * kissButton.height);
        }
    }

    var selected = false;
    var shaking = false;
    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        swatLogo.y -= 10;
        kissLogo.y -= 10;

        if(curSelected == 1) {
            if(!SaveData.progression.get("finished"))
                info.text = "Unlock this by beating every song!";
            else
                info.text = 'Supports: Keyboard / Controller | Highscore: ' + SaveData.saveFile.data.kissScore;
        }
        else
            info.text = 'Supports: Mouse Only | Highscore: ' + SaveData.saveFile.data.swatScore;

        info.screenCenter(X);
    }
}