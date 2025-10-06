package states.cd;

import data.GameData.MusicBeatSubState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.tweens.FlxTween;
import data.Discord.DiscordIO;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class StoryMode extends MusicBeatState
{
    var bg:FlxSprite;
    var week1:FlxSprite;
    var week2:FlxSprite;
    var epilogue:FlxSprite;
    var text:FlxSprite;

    var curSelected:Int = 0;
    var maxCurSelect:Int = 1;
    var lastVert:Int = 0;

    public static var usingMouse:Bool = false;
    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;

    var weeks:FlxTypedGroup<FlxSprite>;
    public static var weekData:Array<Array<Dynamic>> = [];
    override function create()
    {
        super.create();
        CoolUtil.playMusic("LoveLetter");
        DiscordIO.changePresence("In the Story Mode...", null);
        usingMouse = false;

        weekData = [
            [["euphoria", "nefarious", "divergence"], "week1"],
            [["allegro", "panic-attack", "convergence", "desertion"], "week2"],
            [["euphoria-vip", "nefarious-vip", "divergence-vip"], "week-vip"],
            [["sin"], "epilogue"], // technically intimidate is after this lol
        ];

        bg = new FlxSprite().loadGraphic(Paths.image('menu/story/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        weeks = new FlxTypedGroup<FlxSprite>();
		add(weeks);

        week1 = new FlxSprite().loadGraphic(Paths.image('menu/story/week1'));
        week1.scale.set(0.75,0.75);
        week1.updateHitbox();
        week1.ID = 0;
        weeks.add(week1);

        var huh:String = "";
        if(!SaveData.progression.get("week1"))
            huh = "lock";
        week2 = new FlxSprite().loadGraphic(Paths.image('menu/story/week2' + huh));
        week2.scale.set(0.75,0.75);
        week2.updateHitbox();
        week2.ID = 1;
        weeks.add(week2);

        if(SaveData.progression.get("week2")) {
            maxCurSelect = 2;
            epilogue = new FlxSprite().loadGraphic(Paths.image('menu/story/epilogue'));
            epilogue.scale.set(0.35,0.35);
            epilogue.updateHitbox();
            epilogue.alpha = 0;
            epilogue.ID = 2;
            weeks.add(epilogue);
        }

        text = new FlxSprite(127, 15 - 30).loadGraphic(Paths.image('menu/story/text'));
        text.updateHitbox();
        text.alpha = 0;
        FlxTween.tween(text, {alpha: 1}, 0.4);
        add(text);

        updatePos();
        lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
        lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
    }

    var week1Y:Float = 0;
    var week2X:Float = 0;
    var week2Y:Float = 0;
    
    function updatePos() {
        week1.screenCenter();
        week1.x -= 300;
        week1.y += 125;
        week1Y = week1.y;
        week1.y += 30;

        week2.screenCenter();
        week2.x += 300;
        week2.y += 125;
        week2X = week2.x;
        week2Y = week2.y;
        week2.y += 40;

        if(SaveData.progression.get("week2")) {
            epilogue.screenCenter();
            epilogue.y += 320;
        }
    }

    var shaking:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        text.y = FlxMath.lerp(text.y, 15, elapsed*6);
        week1.y = FlxMath.lerp(week1.y, week1Y, elapsed*6);
        week2.y = FlxMath.lerp(week2.y, week2Y, elapsed*6);

        if(Controls.justPressed("UI_LEFT"))
            changeSelection(-1);
        if(Controls.justPressed("UI_RIGHT"))
            changeSelection(1);

        if (shaking) { //lmfao old testament code
            week2.x = week2X + FlxG.random.float(-0.05 * week2.width, 0.05 * week2.width);
            week2.y = week2Y + FlxG.random.float(-0.05 * week2.height, 0.05 * week2.height);
        }

        //yuck
        if((Controls.justPressed("UI_UP") || Controls.justPressed("UI_DOWN")) && maxCurSelect == 2) {
            if(curSelected == 2) {
                if(lastVert == 1)
                    changeSelection(-1);
                else
                    changeSelection(1);
            }
            else {
                lastVert = curSelected;
                if(curSelected == 1)
                    changeSelection(1);
                else
                    changeSelection(-1);
            }
        }

        if(Controls.justPressed("BACK")) {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        if(!selected) {
            for(item in weeks) {
                if((usingMouse && CoolUtil.mouseOverlap(item, FlxG.camera)) || (!usingMouse && curSelected == item.ID)) {
                    item.alpha = FlxMath.lerp(item.alpha, 1, elapsed*8);
                    if(item.ID == 2) {
                        item.scale.x = FlxMath.lerp(item.scale.x, 0.4, elapsed*8);
                        item.scale.y = FlxMath.lerp(item.scale.y, 0.4, elapsed*8);
                    }
                    else {
                        item.scale.x = FlxMath.lerp(item.scale.x, 0.8, elapsed*8);
                        item.scale.y = FlxMath.lerp(item.scale.y, 0.8, elapsed*8);
                    }

                    if(item.ID != curSelected) {
                        curSelected = item.ID;
                        FlxG.sound.play(Paths.sound("menu/scroll"));
                    }
                    if(((FlxG.mouse.justPressed && focused) || Controls.justPressed("ACCEPT"))) {
                        FlxG.sound.play(Paths.sound("menu/select"));
                        if(item.ID == 2) {
                            Dialog.dialog = "sin";
                            Main.switchState(new Dialog());
                        }
                        else {
                            if(item.ID == 1 && !SaveData.progression.get("week1")) {
                                shaking = true;
                                FlxG.sound.play(Paths.sound("menu/locked"));
                                new FlxTimer().start(0.1, function(tmr:FlxTimer)
                                {
                                    shaking = false;
                                    week2.x = week2X;
                                    week2.y = week2Y;
                                });
                            }
                            else {
                                Slider.usingMouse = usingMouse;
                                Slider.weekID = item.ID;
                                Slider.weekData = weekData[item.ID];
                                Slider.weekVData = weekData[2];
                                openSubState(new Slider());
                            }
                        }
                        trace(curSelected);
                    }
                }
                else {
                    item.alpha = FlxMath.lerp(item.alpha, 0.78, elapsed*8);
                    if(item.ID == 2) {
                        item.scale.x = FlxMath.lerp(item.scale.x, 0.35, elapsed*8);
                        item.scale.y = FlxMath.lerp(item.scale.y, 0.35, elapsed*8);
                    }
                    else {
                        item.scale.x = FlxMath.lerp(item.scale.x, 0.75, elapsed*8);
                        item.scale.y = FlxMath.lerp(item.scale.y, 0.75, elapsed*8);
                    }
                }
            }
        }

        if(lastMouseX != FlxG.mouse.getScreenPosition(FlxG.camera).x || lastMouseY != FlxG.mouse.getScreenPosition(FlxG.camera).y) {
            if(!usingMouse) {
                usingMouse = true;
                Main.setMouse(true);
            }
            lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
            lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
        }
    }

    var selected = false;
    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, maxCurSelect);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        usingMouse = false;
        Main.setMouse(false);
    }
}

//unified
class Slider extends MusicBeatSubState
{
    var thing:FlxSprite;
    var button:FlxSprite;
    var vipButton:FlxSprite;

    public static var usingMouse:Bool = false;
    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;

    public static var weekID:Int = 0;
    public static var weekData:Array<Dynamic> = [];
    public static var weekVData:Array<Dynamic> = [];

    var weekName:FlxText;
    var songs:FlxText;
	public function new()
    {
        super();

        thing = new FlxSprite().loadGraphic(Paths.image('menu/story/slider'));
        thing.alpha = 0;
		add(thing);

        button = new FlxSprite().loadGraphic(Paths.image('menu/story/start'));
        button.alpha = 0;
        add(button);

        if(weekID == 0) {
            vipButton = new FlxSprite();
            vipButton.frames = Paths.getSparrowAtlas('menu/story/vip');
            vipButton.animation.addByPrefix('lock',  "vip locked", 24, true);
            vipButton.animation.addByPrefix('on',  "vip selected", 14, true);
            if(SaveData.shop.get("crown"))
                vipButton.animation.play('on');
            else
                vipButton.animation.play('lock');
            vipButton.updateHitbox();
            add(vipButton);
        }

        weekName = new FlxText(0, 0, 0, "Week " + (weekID+1));
		weekName.setFormat(Main.gFont, 120, 0xFFFFFFFF, CENTER);
        weekName.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
        weekName.alpha = 0;
		add(weekName);

        var songString:String = "";
        var songArray:Array<String> = (cast weekData[0]);
        for(song in songArray) {
            songString += song.toUpperCase();
            songString += "\n";
        }

        songs = new FlxText(0, 0, 0, songString);
		songs.setFormat(Main.gFont, 60, 0xFFFFFFFF, CENTER);
        songs.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
        songs.alpha = 0;
		add(songs);

        for (i in [thing, button, weekName, songs])
            FlxTween.tween(i, {alpha: 1}, 0.3);

        updatePos();
            lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
        lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
    }

    function updatePos() {
        if(weekID == 0) {
            thing.flipX = true;
            thing.x = FlxG.width - thing.width + 52;
            thing.x += 52;

            weekName.screenCenter(X);
            weekName.x += 320;
            weekName.y += 70;

            songs.screenCenter();
            songs.x += 320;
            songs.y -= 15;

            button.screenCenter();
            button.y += 221;
            button.x += 410;

            vipButton.screenCenter();
            vipButton.y += 211;
            vipButton.x += 140;
        }
        else {
            thing.x -= 52;
            thing.x -= 52;
            weekName.screenCenter(X);
            weekName.x -= 335;
            weekName.y += 70;

            songs.screenCenter();
            songs.x -= 335;
            songs.y -= 15;

            button.screenCenter();
            button.y += 221;
            button.x -= 335;
        }

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			selected = false;
		});
    }

    var curSelected:Int = 0;
    override function update(elapsed:Float)
    {
        super.update(elapsed);
    
        if(weekID == 0)
            thing.x = FlxMath.lerp(thing.x, FlxG.width - thing.width + 52, elapsed*6);
        else
            thing.x = FlxMath.lerp(thing.x, -52, elapsed*6);

        if(Controls.justPressed("BACK"))
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            StoryMode.usingMouse = usingMouse;
            close();
        }

        if(Controls.justPressed("UI_LEFT"))
            changeSelection(-1);
        if(Controls.justPressed("UI_RIGHT"))
            changeSelection(1);

        if((usingMouse && CoolUtil.mouseOverlap(button, FlxG.camera)) || (!usingMouse && curSelected == 0)) {
            button.scale.x = FlxMath.lerp(button.scale.x, 1.05, elapsed*8);
            button.scale.y = FlxMath.lerp(button.scale.y, 1.05, elapsed*8);
            button.alpha = FlxMath.lerp(button.alpha, 1, elapsed*8);
            
            if(curSelected == 1)
                curSelected = 0;
            if(((FlxG.mouse.justPressed && focused) || Controls.justPressed("ACCEPT")) && !selected) {
                FlxG.sound.play(Paths.sound("menu/select"));
                selected = true;
                FlxFlicker.flicker(button, 1.3, 0.06, true, false, function(_) {
                    enterWeek(false);
                });
            }
        }
        else {
            button.alpha = FlxMath.lerp(button.alpha, 0.78, elapsed*8);
            button.scale.x = FlxMath.lerp(button.scale.x, 1, elapsed*8);
            button.scale.y = FlxMath.lerp(button.scale.y, 1, elapsed*8);
        }

        if(weekID == 0) {
            if((usingMouse && CoolUtil.mouseOverlap(vipButton, FlxG.camera)) || (!usingMouse && curSelected == 1)) {
                vipButton.scale.x = FlxMath.lerp(vipButton.scale.x, 1.05, elapsed*8);
                vipButton.scale.y = FlxMath.lerp(vipButton.scale.y, 1.05, elapsed*8);
                vipButton.alpha = FlxMath.lerp(vipButton.alpha, 1, elapsed*8);

                if(curSelected == 0)
                    curSelected = 1;
                if(((FlxG.mouse.justPressed && focused) || Controls.justPressed("ACCEPT")) && !selected) {
                    FlxG.sound.play(Paths.sound("menu/select"));
                    selected = true;
                    FlxFlicker.flicker(vipButton, 2, 0.06, true, false, function(_) {
                        enterWeek(true);
                    });
                }
            }
            else {
                vipButton.alpha = FlxMath.lerp(vipButton.alpha, 0.78, elapsed*8);
                vipButton.scale.x = FlxMath.lerp(vipButton.scale.x, 1, elapsed*8);
                vipButton.scale.y = FlxMath.lerp(vipButton.scale.y, 1, elapsed*8);
            }
        }

        if(lastMouseX != FlxG.mouse.getScreenPosition(FlxG.camera).x || lastMouseY != FlxG.mouse.getScreenPosition(FlxG.camera).y) {
            if(!usingMouse) {
                usingMouse = true;
                Main.setMouse(true);
            }
            lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
            lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
        }
    }

    function enterWeek(vip:Bool) {
        if(!vip) {
            if(weekID == 0) {
                Dialog.dialog = "euphoria";
                Main.switchState(new Dialog());
            }
            else if(weekID == 1) {
                Dialog.dialog = "allegro";
                Main.switchState(new Dialog());
            }
        }
        else {
            PlayState.playList = [];

            trace(PlayState.playList);
    
            var week = weekVData[0];
            var name = weekVData[1];
    
            trace(week);
    
            PlayState.curWeek = name;
            PlayState.songDiff = "normal";
            PlayState.isStoryMode = true;
            PlayState.weekScore = 0;
            
            PlayState.SONG = SongData.loadFromJson(week[0], "normal");
            PlayState.playList = week;
            PlayState.playList.remove(week[0]);
    
            trace(PlayState.playList);
            
            //CoolUtil.playMusic();
            Main.switchState(new LoadSongState());
        }
    }

    var selected:Bool = true;
    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not

        usingMouse = false;
        Main.setMouse(false);
        if(!(weekID == 0 && SaveData.shop.get("crown"))) return;

        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));
    }
}