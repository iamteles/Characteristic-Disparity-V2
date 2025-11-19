package states;

import data.Conductor;
import gameObjects.MoneyCounter;
import gameObjects.hud.Shop;
import data.Discord.DiscordIO;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import data.GameData.MusicBeatState;
import data.SongData;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import data.ChartLoader;
import data.GameData.MusicBeatState;
import data.SongData.SwagSong;
import gameObjects.*;
import gameObjects.hud.*;
import gameObjects.hud.note.*;
import flixel.addons.display.FlxBackdrop;

#if sys
import sys.io.File;
import sys.thread.Mutex;
import sys.thread.Thread;
#end

using StringTools;

class ShopState extends MusicBeatState
{
    public static var behind:FlxGroup;
    public static var nilaMode:Bool = false;
    public static var camGame:FlxCamera;
    public static var camHUD:FlxCamera;

    public static var camFollow:FlxObject = new FlxObject();

    var moneyCount:MoneyCounter;
    public static var hudTalk:ShopTalk;
    public static var hudBuy:ShopBuy;
    var bg:FlxSprite;
    public static var watts:FlxSprite;
    public static var nila:FlxSprite; //wat!
    var desk:FlxSprite;

    var wattsSpeakin:Bool = false;

    public static var wattsOffset:Float = 0;

    public static var zoom:Float = 0.6;
    override function create()
    {
        super.create();
        nilaMode = SaveData.progression.get("nila");

        if(nilaMode)
            CoolUtil.playMusic("WhatchaBuyinNila", 0.7);
        else {
            CoolUtil.playMusic("WhatchaBuyin", 0.8);
            Paths.preloadSound('music/WhatchaBuyinNila');
        }

        Conductor.setBPM(88);

        DiscordIO.changePresence("In Watts' Shop", null);

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alphaFloat = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD, false);

        // default camera
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

        camGame.zoom = zoom;

        behind = new FlxGroup();
		add(behind);

		bg = new FlxSprite(-121, -126.95).loadGraphic(Paths.image('hud/shop/back'));
		add(bg);

        watts = new FlxSprite(628.6, 0);
        watts.frames = Paths.getSparrowAtlas("hud/shop/watts");
        watts.animation.addByPrefix("idle", 'stand', 24, true);
        watts.animation.addByPrefix("neutral", 'neutral', 24, true);
        watts.animation.addByPrefix("sad", 'sad', 24, true);
        watts.animation.addByPrefix("happy", 'happy', 24, true);
        watts.animation.addByPrefix("angry", 'angry', 24, true);
        watts.animation.addByPrefix("confused", 'confused', 24, true);
        watts.animation.addByPrefix("neutralidle", 'stand0000', 24, true);
        watts.animation.addByPrefix("sadidle", 'sad0000', 24, true);
        watts.animation.addByPrefix("happyidle", 'happy0000', 24, true);
        watts.animation.addByPrefix("angryidle", 'angry0000', 24, true);
        watts.animation.addByPrefix("confusedidle", 'confused0000', 24, true);
        watts.animation.addByPrefix("pull", 'pull out0', 24, false);
        watts.animation.addByPrefix("pullalt", 'pull out-alt', 24, false);
        watts.animation.play("idle");
        watts.updateHitbox();
        add(watts);

        nila = new FlxSprite(968.6, 167.3);
        nila.frames = Paths.getSparrowAtlas("hud/shop/nila");
        nila.animation.addByPrefix("idle", 'Stand', 24, true);
        nila.animation.addByPrefix("neutral", 'Normal', 24, true);
        nila.animation.addByPrefix("sad", 'Sad', 24, true);
        nila.animation.addByPrefix("happy", 'Excited', 24, true);
        nila.animation.addByPrefix("angry", 'Angry', 24, true);
        nila.animation.addByPrefix("confused", 'Confused', 24, true);
        nila.animation.addByPrefix("neutralidle", 'Normal0000', 24, true);
        nila.animation.addByPrefix("sadidle", 'Sad0009', 24, true);
        nila.animation.addByPrefix("happyidle", 'Excited0000', 24, true);
        nila.animation.addByPrefix("angryidle", 'Angry0000', 24, true);
        nila.animation.addByPrefix("confusedidle", 'Confused0000', 24, true);
        nila.animation.addByPrefix("pull", 'Pull Out0', 24, false);
        nila.animation.play("idle");
        nila.updateHitbox();
        nila.visible = false;
        add(nila);

        wattsOffset = 0;
        
        if(nilaMode) {
            wattsOffset = 280;
            nila.visible = true;
        }
        else
            nila.x -= 280;

        watts.x -= wattsOffset;

        desk = new FlxSprite(-74.4, 673.35).loadGraphic(Paths.image('hud/shop/desk'));
        desk.scale.set(1.1, 1.1);
		add(desk);

        camFollow.setPosition(watts.getMidpoint().x + wattsOffset, watts.getMidpoint().y + 80);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());

        moneyCount = new MoneyCounter();
        moneyCount.cameras = [camHUD];
		add(moneyCount);

        hudTalk = new ShopTalk();
        hudTalk.cameras = [camHUD];
		add(hudTalk);

        hudBuy = new ShopBuy();
        hudBuy.cameras = [camHUD];
        hudBuy.tweenAlpha(0,0.01);
		add(hudBuy);
    }
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        camGame.followLerp = elapsed * 3;
        camGame.zoom = FlxMath.lerp(camGame.zoom, zoom, elapsed * 6);

        // yo im so lazy dawg
        // ill fix this in an update or something
        if(nilaMode || hudTalk.nilaIntro) {
            switch(nila.animation.name) {
                case "pull":
                    nila.offset.set(8,118);
                case "happy" | "happyidle":
                    nila.offset.set(-1,71);
                case "confused" | "confusedidle":
                    nila.offset.set(13,31);
                case "angry" | "angryidle":
                    nila.offset.set(4,4);
                case "sad" | "sadidle":
                    nila.offset.set(0,5);
                default:
                    nila.offset.set(0,0);
            //OFFSETS
            //happy -1 71
            //confused 13 31
            //angry -4 4
            //sad -8 5
            //neutral -6 7 //hmm
            }
        }

        //if(Controls.justPressed("BACK"))
		//	Main.switchState(new MenuState());
    }

    public static function enterShop()
    {
        hudTalk.tweenAlpha(0, 0.6);

        var countTimer = new FlxTimer().start(0.6, function(tmr:FlxTimer)
        {
            camFollow.setPosition(watts.getMidpoint().x + 480 + wattsOffset, watts.getMidpoint().y + 80);
            var countTimer = new FlxTimer().start(0.4, function(tmr:FlxTimer)
            {
                hudBuy.tweenAlpha(1,0.7);
            });
        });
    }

    public static function exitShop(question:Bool = false)
    {
        hudBuy.tweenAlpha(0, 0.6);

        Main.setMouse(false);

        var countTimer = new FlxTimer().start(0.6, function(tmr:FlxTimer)
        {
            camFollow.setPosition(watts.getMidpoint().x + wattsOffset, watts.getMidpoint().y + 80);
            var countTimer = new FlxTimer().start(0.4, function(tmr:FlxTimer)
            {
                if(question) hudTalk.activeIcon = "watts"; //ugh
                hudTalk.tweenAlpha(1, 1);
                if(question) {
                    if(!SaveData.progression.get("oneofthem"))
                        hudTalk.resetDial("entersong");
                    else
                        hudTalk.resetDial("replaysong");
                }
                else
                    hudTalk.resetDial("postS");
            });
        });
    }
}