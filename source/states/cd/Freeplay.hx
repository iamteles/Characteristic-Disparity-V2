package states.cd;

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
import flixel.addons.display.FlxBackdrop;
import states.*;
import flixel.util.FlxTimer;
import data.Timings;

class Freeplay extends MusicBeatState
{
    var songs:Array<Array<Dynamic>> = [
        // default
        ["euphoria", "bella", 0xFFF85E4D, "Week 1", true, "Unlocked by default"],
        ["nefarious", "bex", 0xFF5B7A9E, "Week 1", true, "Unlocked by default"],
        ["divergence", "duo", 0xFF970F00, "Week 1", true, "Unlocked by default"],
    ];
    var oldSongs:Array<Array<Dynamic>> = [
        // default
        ["euphoria-old", "cute", 0xFFFFFFFF, "CDv1", true, "Unlocked by default"],
        ["nefarious-old", "evil", 0xFFFFFFFF, "CDv1", true, "Unlocked by default"],
        ["divergence-old", "cutenevil", 0xFFFFFFFF, "CDv1", true, "Unlocked by default"],
        //["desertion-sc", "bree-angry", 0xFFFF0000, "CDv2", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]
    ];
    static var curSelected:Int = 0;
    static var curDiff:Int = 0;

    var texts:FlxTypedGroup<FlxSprite>;
    var characters:FlxTypedGroup<FlxSprite>;

    var bg:FlxSprite;
    var waves:FlxSprite; //like the????????????
    var box:FlxSprite;
    var arrows:FlxSprite;
    var shaking:Bool = false;
    public static var selected:Bool = false;

    var fr:FlxSprite;
    var shack:FlxSprite;

    var bgTween:FlxTween;

    public var realValues:ScoreData;
	public var lerpValues:ScoreData;
    var scores:FlxText;
    var diff:FlxText;
    var old:Bool = false;

    public function new(old:Bool = false)
	{
		super();
		this.old = old;
	}

    override function create()
    {
        super.create();

        DiscordIO.changePresence("In the Freeplay Menu...", null);
        CoolUtil.playMusic("movement");

        Main.setMouse(false);

        selected = false;

        if(!old) {
            songs.push(["allegro", "duo", 0xFF0C2E55, "Week 2", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]);
            songs.push(["panic-attack", "bree", 0xFFF85EA4, "Week 2", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]);
            songs.push(["convergence", "bree", 0xFFB6318E, "Week 2", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]);
            songs.push(["desertion", "bree-angry", 0xFFFF0000, "Week 2", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]);

            if(SaveData.progression.get("week2")) {
                songs.push(["sin", "helica", 0xFFE17B00, "Epilogue", SaveData.progression.get("intimidated"), "Unlocked by completing Epilogue"]);
                songs.push(["intimidate", "bex-scared", 0xFF0A203B, "Epilogue", SaveData.progression.get("intimidated"), "Unlocked by completing Epilogue"]);
                
                songs.push(["conservation", "watts", 0xFFFEC404, "Shopkeeper", SaveData.shop.get("mic"), "Purchasable in Watts' Shop"]);
                songs.push(["irritation", "watts", 0xFFFEC404, "Shopkeeper", SaveData.shop.get("mic"), "Purchasable in Watts' Shop"]);
                songs.push(["commotion", "nila", 0xFF66CC99, "Shopkeeper", SaveData.shop.get("mic"), "Purchasable in Watts' Shop"]);

                songs.push(["euphoria-vip", "bellavip", 0xFFFFCB1F, "Week VIP", SaveData.progression.get("vip"), "Unlocked by buying and beating Week VIP"]);
                songs.push(["nefarious-vip", "bexvip", 0xFFFFCB1F, "Week VIP", SaveData.progression.get("vip"), "Unlocked by buying and beating Week VIP"]);
                songs.push(["divergence-vip", "duovip", 0xFFFFCB1F, "Week VIP", SaveData.progression.get("vip"), "Unlocked by buying and beating Week VIP"]);

                songs.push(["kaboom", "spicy-v2", 0xFFFF006A, "FRxCD", SaveData.shop.get("ticket"), "Purchasable in Watts' Shop"]);
                songs.push(["ripple", "drown", 0xFF049AFE, "The Shack", SaveData.shop.get("shack"), "Purchasable in Watts' Shop"]);
                songs.push(["customer-service", "empitri", 0xFFfdacbc, "The Shack", SaveData.shop.get("shack"), "Purchasable in Watts' Shop"]);

                songs.push(["heartpounder", "duo", 0xFFF85EA4, "Extra", SaveData.progression.get("week2"), "Unlocked by beating Week 2"]);
                songs.push(["exotic", "cutenevil", 0xFFFFFFFF, "Extra", (SaveData.shop.get("time") || SaveData.progression.get("vip")), "Purchasable in Watts' Shop\nOR\nUnlocked by beating Week VIP"]);
                songs.push(["cupid", "duo", 0xFFF85EA4, "Extra", SaveData.progression.get("finished"), "Unlocked by beating everything else"]);
            }
        }
        else
            songs = oldSongs;

        bg = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/desat'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        waves = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/waves'));
		waves.updateHitbox();
		waves.screenCenter();
		add(waves);

        characters = new FlxTypedGroup<FlxSprite>();
		add(characters);

        texts = new FlxTypedGroup<FlxSprite>();
		add(texts);

        for(i in 0...songs.length)
        {
            var song:String = songs[i][0];
            var charN:String = songs[i][1];

            if(!Paths.fileExists('images/menu/freeplay/names/${song}.png') /*|| !SaveData.songs.get(songs[i][0])*/ || !songs[i][4])
                song = "nan";
            if(!Paths.fileExists('images/menu/freeplay/characters/${charN}.png'))
                charN = "bella";

            var char = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/characters/${charN}'));
            char.ID = i;
            char.x = 30;
            char.y = 0;
            char.alpha = 0;
            if(/*!SaveData.songs.get(songs[i][0]) ||*/ !songs[i][4])
                char.color = 0xFF000000;
            characters.add(char);

            if(charN == "cute" || charN == "evil" || charN == "duo" || charN == "bellavip" || charN == "duovip")
                char.offset.set(50,0);
            else if(charN == "cutenevil" || charN == "duo-shop")
                char.offset.set(100,0);
            else if(charN == "bex" || charN == "bex-scared")
                char.offset.set(-50,0);
            else if(charN == "spicy-v2")
                char.offset.set(100,100);
            else if(charN == "empitri")
                char.offset.set(50,50);
            else if(charN == "nila")
                char.offset.set(0,-50);
                
            var text = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/names/${song}'));
            text.ID = i;
            text.y = 40;
            text.x = FlxG.width - text.width - 60;
            text.alpha = 0;
            texts.add(text);
        }

        box = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/box'));
        box.x = 825.6;
        box.y = 333.9;
		add(box);

        scores = new FlxText(0, 0, 0, "");
		scores.setFormat(Main.gFont, 45, 0xFFFFFFFF, CENTER);
        scores.x = box.x + (box.width/2 - scores.width/2);
        scores.y = box.y + 64;
		add(scores);

        diff = new FlxText(0, 0, box.width - 18, "< FODASE >");
		diff.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
        diff.x = box.x + (box.width/2 - diff.width/2);
        diff.y = scores.y + 175;
		add(diff);

        realValues = {score: 0, accuracy: 0, misses: 0};
		lerpValues = {score: 0, accuracy: 0, misses: 0};

        arrows = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/arrows'));
        arrows.angle = 90;
        arrows.updateHitbox();
        arrows.x = 28;
        arrows.y = FlxG.height - arrows.height + 8;
		add(arrows);

        fr = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/fr_collab'));
        fr.scale.set(0.66, 0.66);
        fr.updateHitbox();
        fr.x = 5;
        fr.y = 5;
		add(fr);

        shack = new FlxSprite().loadGraphic(Paths.image('menu/freeplay/fs_collab'));
        shack.scale.set(0.66, 0.66);
        shack.updateHitbox();
        shack.x = 5;
        shack.y = 5;
		add(shack);

        changeSelection();
    }

    var rank:String = "N/A";
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.justPressed("UI_LEFT"))
            changeSelection(-1);
        if(Controls.justPressed("UI_RIGHT"))
            changeSelection(1);
        if(Controls.justPressed("L_SPECIAL"))
			changeCategory(-1);
		if(Controls.justPressed("R_SPECIAL"))
			changeCategory(1);

        if(Controls.justPressed("BACK"))
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        for(item in characters.members)
        {
            item.x = FlxMath.lerp(item.x, 30 + ((curSelected - item.ID)*-300), elapsed*6);

            if(item.ID == curSelected) {
                item.alpha = FlxMath.lerp(item.alpha, 1, elapsed*12);
            }
            else
                if(!selected) item.alpha = FlxMath.lerp(item.alpha, 0, elapsed*12);
        }

        for(item in texts.members)
        {
            item.y = FlxMath.lerp(item.y, 8, elapsed*6);
            if(item.ID == curSelected)
                item.alpha = 1;
            else
                item.alpha = 0;
        }

        if(Controls.justPressed("ACCEPT") && focused)
            go2Song(songs[curSelected]);

        if(SaveData.shop.get("time") && Controls.justPressed("BOTPLAY"))
            Main.switchState(new states.cd.Freeplay(!old));
        
        scores.text = "";

        if(songs[curSelected][4]) {
            scores.text +=   "SCORE: " + Math.floor(lerpValues.score);
            scores.text += "\nRANK: " +(Math.floor(lerpValues.accuracy * 100) / 100) + "%" + ' [$rank]';
            scores.text += "\nBREAKS: " + Math.floor(lerpValues.misses);
        }

		lerpValues.score 	= FlxMath.lerp(lerpValues.score, 	realValues.score, 	 elapsed * 8);
		lerpValues.accuracy = FlxMath.lerp(lerpValues.accuracy, realValues.accuracy, elapsed * 8);
		lerpValues.misses 	= FlxMath.lerp(lerpValues.misses, 	realValues.misses, 	 elapsed * 8);

        rank = Timings.getRank(
			lerpValues.accuracy,
			Math.floor(lerpValues.misses),
			false,
			lerpValues.accuracy == realValues.accuracy
		);

		if(Math.abs(lerpValues.score - realValues.score) <= 10)
			lerpValues.score = realValues.score;
		if(Math.abs(lerpValues.accuracy - realValues.accuracy) <= 0.4)
			lerpValues.accuracy = realValues.accuracy;
		if(Math.abs(lerpValues.misses - realValues.misses) <= 0.4)
			lerpValues.misses = realValues.misses;

        scores.x = box.x + (box.width/2 - scores.width/2);
        scores.y = box.y + 64;

        if(songs[curSelected][0] == "kaboom")
            fr.alpha = 1;
        else
            fr.alpha = 0;

        if(songs[curSelected][0] == "ripple" || songs[curSelected][0] == "customer-service")
            shack.alpha = 1;
        else
            shack.alpha = 0;

        fr.y = FlxMath.lerp(fr.y, 5, elapsed*6);
        shack.y = FlxMath.lerp(shack.y, 5, elapsed*6);
    }

    public function go2Song(song:Array<Dynamic>) {
        try {
            if(song[4]) {
                selected = true;
                var diff = CoolUtil.getDiffs()[curDiff];
        
                //trace('$diff');
                //trace('songs/${songList[curSelected][0]}/${songList[curSelected][0]}-${diff}');
                
                PlayState.playList = [];
                PlayState.SONG = SongData.loadFromJson(song[0], diff);
                PlayState.isStoryMode = false;
                //CoolUtil.playMusic();
                
                PlayState.songDiff = diff;

                switch(song[0]) {
                    case "kaboom":
                        openSubState(new CharacterSelect());
                    case "cupid" | "ripple" | "customer-service" | "euphoria" | "nefarious" | "divergence" | "euphoria-old" | "nefarious-old" | "divergence-old" | "allegro" | "panic-attack" | "convergence" | "desertion" | "sin":
                        trace(SaveData.songs.get(song[0]));
                        if(SaveData.data.get("Dialogue in Freeplay") == "ON" || (SaveData.data.get("Dialogue in Freeplay") == "UNSEEN" && !SaveData.songs.get(song[0]))) {
                            states.cd.Dialog.dialog = song[0];
                            Main.switchState(new states.cd.Dialog(false));
                        }
                        else
                            Main.switchState(new LoadSongState());
                    default:
                        Main.switchState(new LoadSongState());
                }
            }
            else {
                FlxG.sound.play(Paths.sound('menu/locked'));
                FlxG.camera.shake(0.005, 0.1, null, true, XY);
            }
        }
        catch(e) {
            FlxG.sound.play(Paths.sound('menu/back'));
        }
    }

    public function changeCategory(change:Int = 0)
    {
        if(selected || songs[curSelected][3] == null) return;
        var ammt:Int = 0;
        var realI:Int = 0;

        for(i in 0...songs.length) {
            if(songs[curSelected+(realI*change)] == null)
                realI = -curSelected;
            if(songs[curSelected][3] != songs[curSelected+(realI*change)][3]) {
                break;
            }

            ammt++;
            realI++;
        }

        curSelected += change*ammt;
        changeSelection(0);
    }

    public function changeSelection(change:Int = 0)
    {
        if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, characters.length - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        for(item in texts.members)
        {
            item.y -= 20;
        }

        if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.4, bg.color, songs[curSelected][2]);

        if(songs[curSelected][4]) {
            var category:String = "EXTRA";
            if(songs[curSelected][3] != null)
                category = songs[curSelected][3].toUpperCase();
            diff.text = category;
            diff.x = box.x + (box.width/2 - diff.width/2);
            diff.y = scores.y + 175;
        }
        else {
            diff.text = songs[curSelected][5];
            diff.x = box.x + (box.width/2 - diff.width/2);
            diff.y = box.y + (box.height/2 - diff.height/2);
        }

        if(songs[curSelected][0] == "kaboom")
            fr.y -= 10;
        if((songs[curSelected][0] == "ripple" && change == 1) || (songs[curSelected][0] == "customer-service" && change == -1))
            shack.y -= 10;

        updateScoreCount();
    }

    public function updateScoreCount() {
        realValues = Highscore.getScore('${songs[curSelected][0]}-${CoolUtil.getDiffs()[curDiff]}');
		//diffTxt.text = '< ${diff.toUpperCase()} >';
    }
}

class CharacterSelect extends MusicBeatSubState
{
    var spicy:FlxSprite;
    var bree:FlxSprite;
    var select:FlxSprite;

    var curSelected:Int = 0;
    var usingMouse:Bool = false;
	public function new()
    {
        super();

        var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

        //Main.setMouse(true);

		banana.alpha = 0;

        var tiles = new FlxBackdrop(Paths.image('menu/title/tiles/main'), XY, 0, 0);
        tiles.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
        tiles.screenCenter();
		tiles.alpha = 0;
		FlxTween.tween(tiles, {alpha: 0.4}, 0.6);
        add(tiles);

        select = new FlxSprite(0, 28.4 - 30).loadGraphic(Paths.image('menu/freeplay/select/select'));
        select.scale.set(0.9,0.9);
        select.updateHitbox();
        select.screenCenter(X);
        select.alpha = 0;
		add(select);

        spicy = new FlxSprite(0, 240.85).loadGraphic(Paths.image('menu/freeplay/select/spicy'));
        spicy.scale.set(0.9,0.9);
        spicy.updateHitbox();
        spicy.screenCenter(X);
        spicy.x -= 340;
        spicy.y += 50;
        spicy.y += 60;
        spicy.ID = 0;
		add(spicy);

        bree = new FlxSprite(0, 261.1).loadGraphic(Paths.image('menu/freeplay/select/bree'));
        bree.scale.set(0.9,0.9);
        bree.updateHitbox();
        bree.screenCenter(X);
        bree.x += 340;
        bree.y += 50;
        bree.y += 40;
        bree.ID = 1;
		add(bree);
        
		FlxTween.tween(banana, {alpha: 0.4}, 0.4);
        FlxTween.tween(select, {alpha: 1}, 0.4);

        lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
        lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;

        new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			selected = false;
		});
    }

    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        select.y = FlxMath.lerp(select.y, 28.4, elapsed*6);
        spicy.y = FlxMath.lerp(spicy.y, 240.85+50, elapsed*6);
        bree.y = FlxMath.lerp(bree.y, 261.1+50, elapsed*6);

        if(Controls.justPressed("UI_LEFT"))
            changeSelection(-1);
        if(Controls.justPressed("UI_RIGHT"))
            changeSelection(1);

        if(Controls.justPressed("BACK") || FlxG.mouse.justPressedRight)
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Freeplay.selected = false;
            Main.setMouse(false);
            close();
        }

        if(!selected) {
            for(button in [spicy, bree]) {
                var isIt:Bool = (usingMouse && CoolUtil.mouseOverlap(button, FlxG.camera)) || (!usingMouse && curSelected == button.ID);
                if(isIt) {
                    button.scale.x = FlxMath.lerp(button.scale.x, 1, elapsed*8);
                    button.scale.y = FlxMath.lerp(button.scale.y, 1, elapsed*8);

                    if(button.ID != curSelected) {
                        curSelected = button.ID; 
                        FlxG.sound.play(Paths.sound("menu/scroll"));
                    }
                    if(((FlxG.mouse.justPressed && focused) || Controls.justPressed("ACCEPT"))) {
                        selected = true;

                        if(FlxG.sound.music != null)
                            FlxTween.tween(FlxG.sound.music, {volume: 0.4}, 0.4);

                        var sound:String = "bree";
                        if(button.ID == 0)
                            sound = "rave";
                        FlxG.sound.play(Paths.sound(sound));

                        if(button.ID == 0)
                            FlxTween.tween(bree, {alpha: 0}, 0.5);
                        else
                            FlxTween.tween(spicy, {alpha: 0}, 0.5);

                        FlxFlicker.flicker(button, 2, 0.06, true, false, function(_)
                        {
                            PlayState.invertedCharacters = (button == spicy);
                            Main.switchState(new LoadSongState());
                        });
                    }
                }
                else {
                    button.scale.x = FlxMath.lerp(button.scale.x, 0.9, elapsed*8);
                    button.scale.y = FlxMath.lerp(button.scale.y, 0.9, elapsed*8);
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
        curSelected = FlxMath.wrap(curSelected, 0, 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        usingMouse = false;
        Main.setMouse(false);
    }
}