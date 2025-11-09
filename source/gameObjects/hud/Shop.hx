package gameObjects.hud;

import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.PlayState;
import flixel.tweens.FlxTween;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound ;
import flixel.input.keyboard.FlxKey;
import states.ShopState;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import data.SongData;

typedef WattsDialog =
{
    var ident:String;
    var saveIdent:Null<String>;
    var lines:Array<Dynamic>;
}

class ShopTalk extends FlxGroup
{
    var dialogBig:FlxSprite;
    var iconW:FlxSprite;
    var iconN:FlxSprite;
    var iconB:FlxSprite;
    var tex:FlxTypeText;
    var hasScrolled:Bool = false;
    var activeg:Bool = true;

    var curLine:Int = 0;

    var dialogData:WattsDialog;

    var watts1:FlxSound;
    var watts2:FlxSound;
    var watts3:FlxSound;
    var watts4:FlxSound;

    var nila1:FlxSound;
    var nila2:FlxSound;
    var nila3:FlxSound;
    var nila4:FlxSound;

    var bella:FlxSound;

    var starting:String = 'post';

    var curChoice:Int = 0;
    var choiceGrp:FlxTypedGroup<FlxText>;

    public function new()
    {
        super();

        dialogBig = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/box'));
        dialogBig.scale.set(0.7, 0.7);
        dialogBig.updateHitbox();
        dialogBig.screenCenter(X);
        dialogBig.y = FlxG.height - dialogBig.height - 30;
		add(dialogBig);

        iconW = new FlxSprite(0, 0);
        iconW.frames = Paths.getSparrowAtlas("hud/shop/wattsicons");
        iconW.animation.addByPrefix("neutral", 'watts text neutral', 24, true);
        iconW.animation.addByPrefix("sad", 'watts text sad', 24, true);
        iconW.animation.addByPrefix("happy", 'watts text happy', 24, true);
        iconW.animation.addByPrefix("angry", 'watts text angry', 24, true);
        iconW.animation.addByPrefix("confused", 'watts text confused', 24, true);
        iconW.animation.play("neutral");
        iconW.scale.set(0.7, 0.7);
        iconW.updateHitbox();
        iconW.x = dialogBig.x + 85;
        iconW.y = dialogBig.y + 70;
        add(iconW);

        iconN = new FlxSprite(0, 0);
        iconN.frames = Paths.getSparrowAtlas("hud/shop/nilaicons");
        iconN.animation.addByPrefix("neutral", 'nila text neutral', 24, true);
        iconN.animation.addByPrefix("sad", 'nila text sad', 24, true);
        iconN.animation.addByPrefix("happy", 'nila text happy', 24, true);
        iconN.animation.addByPrefix("angry", 'nila text angry', 24, true);
        iconN.animation.addByPrefix("confused", 'nila text confused', 24, true);
        iconN.animation.play("neutral");
        iconN.scale.set(0.7, 0.7);
        iconN.updateHitbox();
        iconN.x = dialogBig.x + 120;
        iconN.y = dialogBig.y + 75;
        add(iconN);

        iconB = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/bella'));
        iconB.scale.set(0.7, 0.7);
        iconB.updateHitbox();
        iconB.x = dialogBig.x + 100;
        iconB.y = dialogBig.y + 75;
        add(iconB);

        watts1 = new FlxSound();
        watts1.loadEmbedded(Paths.sound("dialog/watts/watts1"), false, false);
        watts1.volume = 0.7;
        FlxG.sound.list.add(watts1);

        watts2 = new FlxSound();
        watts2.loadEmbedded(Paths.sound("dialog/watts/watts2"), false, false);
        watts2.volume = 0.7;
        FlxG.sound.list.add(watts2);

        watts3 = new FlxSound();
        watts3.loadEmbedded(Paths.sound("dialog/watts/watts3"), false, false);
        watts3.volume = 0.7;
        FlxG.sound.list.add(watts3);

        watts4 = new FlxSound();
        watts4.loadEmbedded(Paths.sound("dialog/watts/watts4"), false, false);
        watts4.volume = 0.7;
        FlxG.sound.list.add(watts4);

        nila1 = new FlxSound();
        nila1.loadEmbedded(Paths.sound("dialog/watts/nila1"), false, false);
        nila1.volume = 0.7;
        FlxG.sound.list.add(nila1);

        nila2 = new FlxSound();
        nila2.loadEmbedded(Paths.sound("dialog/watts/nila2"), false, false);
        nila2.volume = 0.7;
        FlxG.sound.list.add(nila2);

        nila3 = new FlxSound();
        nila3.loadEmbedded(Paths.sound("dialog/watts/nila3"), false, false);
        nila3.volume = 0.7;
        FlxG.sound.list.add(nila3);

        nila4 = new FlxSound();
        nila4.loadEmbedded(Paths.sound("dialog/watts/nila4"), false, false);
        nila4.volume = 0.7;
        FlxG.sound.list.add(nila4);

        bella = new FlxSound();
        bella.loadEmbedded(Paths.sound("dialog/bella"), false, false);
        bella.volume = 0.7;
        FlxG.sound.list.add(bella);

        tex = new FlxTypeText(iconW.x + iconW.width + 25, iconW.y, Std.int(dialogBig.width - (iconW.x + iconW.width + 25) - 50), '', true);
		tex.alpha = 1;
		tex.setFormat(Paths.font("sylfaen.ttf"), 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 1.4;
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
        tex.sounds = [watts1, watts2, watts3, watts4];
		tex.finishSounds = false;
        tex.start();
		add(tex);

        choiceGrp = new FlxTypedGroup<FlxText>();
		add(choiceGrp);

        var hahaHeight:Float = 0;
        for (i in 0...5) {
            var choice = new FlxText(iconW.x + iconW.width + 25, iconW.y + (i*(hahaHeight)), Std.int(dialogBig.width - (iconW.x + iconW.width + 25) - 50), 'a', true);
            choice.alpha = 0;
            choice.setFormat(Paths.font("sylfaen.ttf"), 30, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
            choice.borderSize = 1.4;
            choice.ID = i;
            hahaHeight = choice.height;
            choiceGrp.add(choice);
        }

        if(!SaveData.progression.get("shopentrance")) {
            trace(SaveData.progression.get("shopentrance"));
            starting = "intro";
            SaveData.progression.set("shopentrance", true);
            trace(SaveData.progression.get("shopentrance"));
            SaveData.save();
        }


        dialogData = haxe.Json.parse(Paths.getContent('data/watts/$starting.json').trim());
        scrollText(dialogData.lines[curLine], dialogData.ident);
    }

    function getSaved(ident:String):Bool {
        if(ident == "bellaW")
            return (getSaved("bellaA") && getSaved("bellaB") && getSaved("bellaC"));
        else if(ident == "bellaN")
            return (getSaved("bellaA") && getSaved("bellaB") && getSaved("bellaC") && getSaved("bellaD"));
        else if(ident == "bexW")
            return (getSaved("bexA") && getSaved("bexB") && getSaved("bexC"));
        else if(ident == "bexN")
            return (getSaved("bexA") && getSaved("bexB") && getSaved("bexC") && getSaved("bexD"));
        else if(ident == "breeN")
            return (getSaved("breeA") && getSaved("breeB"));
        else if(ident == "wattsW")
            return (getSaved("wattsA") && getSaved("wattsB") && getSaved("wattsC") && getSaved("wattsD"));
        else if(ident == "wattsN")
            return (getSaved("wattsW") && getSaved("nilaN"));
        else if(ident == "nilaN")
            return (getSaved("nilaA") && getSaved("nilaB") && getSaved("nilaC") && getSaved("nilaD"));
        else if(ident == "wattsB")
            return !SaveData.progression.get("nila");

        return !SaveData.wattsLines.get(ident);
    }

    var curSelecting:Bool = false;
    var choiceCount:Int = 0;
    var sounder:String = "watts";
    var lastSounder:String = "watts";
    function scrollText(info:Array<Dynamic>, ident:String = 'doesntmatter') {
        if(info[4] != null) {
            if((info[4] == "w" && ShopState.nilaMode) || (info[4] == "n" && !ShopState.nilaMode)) {
                curLine++;
                scrollText(dialogData.lines[curLine], dialogData.ident);
                return;
            }
        }

        if(!ShopState.nilaMode) {
            if(ident == 'wattsphoto' && curLine == 1) {
                FlxTween.tween(ShopState.watts, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut});
                ShopState.zoom = 1;
                ShopState.camFollow.setPosition(ShopState.watts.getMidpoint().x, ShopState.watts.getMidpoint().y - 100);
            }
            if(ident == 'wattsphoto' && curLine == 6) { //IMPORTANT! TEST LATER
                FlxTween.tween(ShopState.watts, {alpha: 1}, 0.5, {ease: FlxEase.sineInOut});
                ShopState.zoom = 0.6;
                ShopState.camFollow.setPosition(ShopState.watts.getMidpoint().x, ShopState.watts.getMidpoint().y + 80);
            }
        }

        if(curLine == 0 && dialogData.saveIdent != null) {
            SaveData.wattsLines.set(dialogData.saveIdent, true);
            SaveData.save();
        }

        var char:FlxSprite = ShopState.watts;
        var icon:FlxSprite = iconW;
        var iconHide:FlxSprite = iconN;
        var iconHide2:FlxSprite = iconB;
        var dontAnim:Bool = false;
        sounder = "watts";

        if(info[3] != null) {
            if(info[3] == "q") {
                curChoice = 0;
                tex.resetText(' ');
                curLine++;
                tex.start(false, function()
                {
                    new FlxTimer().start(0.1, function(tmr:FlxTimer)
                    {
                        hasScrolled = true;
                    });
                });

                var saves:Array<String> = [];
                if(info[5] != null)
                    saves = info[5];

                var choices:Array<String> = info[0].split("\n");
                choiceCount = choices.length;
                for (i in 0...choices.length) {
                    for(ch in choiceGrp.members) {
                        if(i == ch.ID) {
                            if(saves[i] != null) {
                                if(getSaved(saves[i]))
                                    ch.color = FlxColor.YELLOW;
                                else
                                    ch.color = FlxColor.WHITE;
                            }
                            else
                                ch.color = FlxColor.WHITE;
                            ch.text = choices[i];
                        }
                    }
                }

                ShopState.watts.animation.play("neutralidle");
                iconW.animation.play("neutral");

                if(ShopState.nilaMode) {
                    ShopState.nila.animation.play("neutralidle");
                    iconN.animation.play("neutral");
                }

                curSelecting = true;
                return;
            }
            else if(info[3] == "n") {
                char = ShopState.nila;
                icon = iconN;
                iconHide = iconW;
                sounder = "nila";
            }
            else if(info[3] == "b") {
                dontAnim = true;
                sounder = "bella";
                iconHide = iconW;
                iconHide2 = iconN;
                icon = iconB;
            }
        }
        curSelecting = false;
        if(!dontAnim)
            char.animation.play(info[1]);
        icon.animation.play(info[1]);
        icon.alpha = 1;
        iconHide.alpha = 0;
        iconHide2.alpha = 0;
        tex.resetText('* ' + info[0]);

        if(sounder != lastSounder) {
            if(sounder == "nila")
                tex.sounds = [nila1, nila2, nila3, nila4];
            else if(sounder == "bella")
                tex.sounds = [bella];
            else
                tex.sounds = [watts1, watts2, watts3, watts4];
        }
        lastSounder = sounder;
        curLine++;

        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                if(!dontAnim)
                    char.animation.play(info[1] + "idle");
                hasScrolled = true;
            });
        });
    }


    public function tweenAlpha(alpha:Float, time:Float) {
        if(alpha == 1)
            activeg = true;
        if(alpha == 0)
            activeg = false;
        FlxTween.tween(dialogBig, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(iconW, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(iconN, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(tex, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
    }

    public function createProgress():WattsDialog {
        return {
            ident: "buy",
            saveIdent: null,
            lines: [
                [
                    'progress is ${SaveData.percentage()}%, as previously shown in the options menu. new text tba.',
                    "confused",
                    0.05
                ],
                [
                    "* Buy\n* Talk\n* Progress\n* Leave",
                    "neutral",
                    0.05,
                    "q"
                ]
            ]
        }
    }

    public function createB(force:Bool = false):WattsDialog {
        if(force)
            SaveData.wattsNum = -1;

        if(ShopState.nilaMode) {
            return {
                ident: "wattsB",
                saveIdent: null,
                lines: [
                        "That's me, silly...",
                        "confused",
                        0.05,"n","n"
                ],
            };
        }
        
        SaveData.wattsNum++;
        SaveData.save();
        return switch(SaveData.wattsNum) {
            case 0: {
                ident: "wattsphoto",
                saveIdent: null,
                lines: [
                    [
                        "Oh yes, that photo!",
                        "neutral",
                        0.05,"w","w"
                    ],
                    [
                        "Another job I took up was babysitting.",
                        "neutral",
                        0.05,"w","w"
                    ],
                    [
                        "That girl right there is Nila.",
                        "neutral",
                        0.05,"w","w"
                    ],
                    [
                        "Her parents are always pretty busy so I take care of her really often.",
                        "neutral",
                        0.05,"w","w"
                    ],
                    [
                        "I love that child to death! She’s like a daughter to me.",
                        "happy",
                        0.05,"w","w"
                    ],
                    [
                        "As someone who aspires to be a mom, she’s been a really good test run.",
                        "happy",
                        0.05,"w","w"
                    ],
                    [
                        "* What do you do?\n* What's that framed photo behind you?\n* Are you single?\n* Do you like to travel?\n* Go Back.",
                        "neutral",
                        0.05,
                        "q","b",
                        ["wattsA", "wattsB", "wattsC", "wattsD"]
                    ]
                ]
            }
            case 1: {
                ident: "wattsb",
                saveIdent: null,
                lines: [
                    [
                        "Uhh... You already asked about that...",
                        "confused",
                        0.05,"w"
                    ],
                    [
                        "That's Nila.. remember? Sweetest kid in the world, love her like shes my own!",
                        "confused",
                        0.05,"w"
                    ],
                    [
                        "Wonder how shes doing right now...",
                        "neutral",
                        0.05,"w"
                    ],
                    [
                        "* What do you do?\n* What's that framed photo behind you?\n* Are you single?\n* Do you like to travel?\n* Go Back.",
                        "neutral",
                        0.05,
                        "q","b",
                        ["wattsA", "wattsB", "wattsC", "wattsD"]
                    ]
                ]
            }
            case 2: {
                ident: "wattsb",
                saveIdent: null,
                lines: [
                    [
                        "...sometimes, I wish babysitting her was my main job.",
                        "sad",
                        0.05,"w"
                    ],
                    [
                        "Don't get me wrong, I love this shop. I'ts good for me and my fam but...",
                        "neutral",
                        0.05,"w"
                    ],
                    [
                        "Once you get a taste of being a mom sometimes you just... hm...",
                        "neutral",
                        0.05,"w"
                    ],
                    [
                        "...a-am I saying too much..? I apologize...",
                        "sad",
                        0.05,"w"
                    ],
                    [
                        "*sniffle*",
                        "sad",
                        0.05,"w"
                    ],
                    [
                        "* What do you do?\n* What's that framed photo behind you?\n* Are you single?\n* Do you like to travel?\n* Go Back.",
                        "neutral",
                        0.05,
                        "q","b",
                        ["wattsA", "wattsB", "wattsC", "wattsD"]
                    ]
                ]
            }
            case 3: {
                ident: "wattsb",
                saveIdent: null,
                lines: [
                    [
                        "GGAH I HATE SEPERATION ANXIETY!",
                        "confused",
                        0.05,"w"
                    ],
                    [
                        "Why can't she just...",
                        "confused",
                        0.05,"w"
                    ],
                    [
                        "I",
                        "neutral",
                        0.05,"w"
                    ],
                    [
                        "* What do you do?\n* What's that framed photo behind you?\n* Are you single?\n* Do you like to travel?\n* Go Back.",
                        "neutral",
                        0.05,
                        "q","b",
                        ["wattsA", "wattsB", "wattsC", "wattsD"]
                    ]
                ]
            }
            default: createB(true);
        }
    }

    public function resetDial(newd:String) {
        if(newd == "progress")
            dialogData = createProgress();
        else if(newd == "wattsB")
            dialogData = createB();
        else
            dialogData = haxe.Json.parse(Paths.getContent('data/watts/$newd.json').trim());
        curLine = 0;
        hasScrolled = false;
        scrollText(dialogData.lines[curLine], dialogData.ident);
    }

    public function changeSelection(change:Int = 0)
    {
        curChoice += change;
        curChoice = FlxMath.wrap(curChoice, 0, choiceCount - 1);
        if(change != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(curSelecting && activeg) {
                for(ch in choiceGrp.members) {
                    ch.alpha = FlxMath.lerp(ch.alpha, (curChoice == ch.ID ? 1 : (ch.ID >= choiceCount ? 0 : 0.45)), elapsed*24);
                }

                if(Controls.justPressed("UI_UP"))
                    changeSelection(-1);
                if(Controls.justPressed("UI_DOWN"))
                    changeSelection(1);
        }
        else {
            for(ch in choiceGrp.members) {
                ch.alpha = 0;
            }
        }

        if(activeg) {
            if(hasScrolled) {
                if(curLine >= dialogData.lines.length || curSelecting) {
                    switch(dialogData.ident) {
                        case "sel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("bellasel");
                                    case 1: resetDial("bexsel");
                                    case 2: 
                                        if(ShopState.nilaMode)
                                            resetDial("breesel");
                                        else
                                            resetDial("bree");
                                    case 3: 
                                        if(ShopState.nilaMode)
                                            resetDial("duosel");
                                        else
                                            resetDial("wattssel");
                                    case 4: 
                                        resetDial("postS");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("postS");
                            }
                        case "entersong" | "replaysong":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("conservation");
                                    case 1: resetDial("irritation");
                                }
                            }
                        case "conservation":
                            if(Controls.justPressed("ACCEPT")) {
                                ShopState.watts.animation.play("pull");
                                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                                {
                                    CoolUtil.playMusic();
                                    PlayState.SONG = SongData.loadFromJson("conservation");
                                    Main.skipTrans = true;
                                    Main.skipClearMemory = true;
                                    PlayState.isStoryMode = false;
                                    Main.switchState(new PlayState());
                                });
                            }
                        case "irritation":
                            if(Controls.justPressed("ACCEPT")) {
                                ShopState.watts.animation.play("pullalt");
                                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                                {
                                    CoolUtil.playMusic();
                                    PlayState.SONG = SongData.loadFromJson("irritation");
                                    Main.skipTrans = true;
                                    Main.skipClearMemory = true;
                                    PlayState.isStoryMode = false;
                                    Main.switchState(new PlayState());
                                });
                            }
                        case "bellasel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("bellaA");
                                    case 1: resetDial("bellaB");
                                    case 2: resetDial("bellaC");
                                    case 3:
                                        if(ShopState.nilaMode)
                                            resetDial("bellaD");
                                        else
                                            resetDial("sel");
                                    case 4:
                                        resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("sel");
                            }
                        case "bexsel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("bexA");
                                    case 1: resetDial("bexB");
                                    case 2: resetDial("bexC");
                                    case 3:
                                        if(ShopState.nilaMode)
                                            resetDial("bexD");
                                        else
                                            resetDial("sel");
                                    case 4:
                                        resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("sel");
                            }

                        case "breesel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("breeA");
                                    case 1: resetDial("breeB");
                                    case 2:
                                        resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("sel");
                            }

                        case "duosel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("wattssel");
                                    case 1: resetDial("nilasel");
                                    case 2:
                                        resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("sel");
                            }

                        case "wattssel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("wattsA");
                                    case 1: resetDial("wattsB");
                                    case 2: resetDial("wattsC");
                                    case 3: resetDial("wattsD");
                                    case 4: 
                                        if(ShopState.nilaMode)
                                            resetDial("duosel");
                                        else
                                            resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                if(ShopState.nilaMode)
                                    resetDial("duosel");
                                else
                                    resetDial("sel");
                            }
                        case "nilasel":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("nilaA");
                                    case 1: resetDial("nilaB");
                                    case 2: resetDial("nilaC");
                                    case 3: resetDial("nilaD");
                                    case 4: resetDial("duosel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("duosel");
                            }
                        case "wattsphoto": // note to self unfuckup later
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0: resetDial("wattsA");
                                    case 1: resetDial("wattsB");
                                    case 2: resetDial("wattsC");
                                    case 3: resetDial("wattsD");
                                    case 4: resetDial("sel");
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                resetDial("sel");
                            }
                        case "buy":
                            if(Controls.justPressed("ACCEPT")) {
                                switch(curChoice) {
                                    case 0:
                                        curSelecting = false;
                                        ShopState.enterShop();
                                    case 1: resetDial("sel");
                                    case 2: resetDial("progress");
                                    case 3: Main.switchState(new states.cd.MainMenu());
                                }
                            }

                            if(Controls.justPressed("BACK")) {
                                Main.switchState(new states.cd.MainMenu());
                            }

                    }

                }
                else {
                    if(Controls.justPressed("ACCEPT")) {
                        FlxG.sound.play(Paths.sound('dialog/skip'));
    
                        hasScrolled = false;
        
                        scrollText(dialogData.lines[curLine], dialogData.ident);
                    }
                }

            }
            else {
                if(Controls.justPressed("ACCEPT")) {
                    tex.skip();
                }
            }
        }
    }
}

class ShopBuy extends FlxGroup
{
    public static var defaultTab:String = 'songs';
    var dialogBig:FlxSprite;
    var holder:FlxSprite;
    var icon:FlxSprite;
    public static var tex:FlxTypeText;
    
    var tabs:FlxTypedGroup<FlxSprite>;
    var curTab:ShopTab;
    var curId:Int = 0;
    public static var curItem:Int = 0;

    var songGroup:ShopTab;
    var extrasGroup:ShopTab;
    var skinsGroup:ShopTab;
    var label:FlxText;

    var tabPos:Array<Float>;

    public static var itemDesc = "What are you looking for?";

    public static var activeg:Bool = false;

    public static var char:Int = 0;

    public function new()
    {
        super();
        curItem = 0;

        dialogBig = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/small'));
        dialogBig.scale.set(0.6, 0.6);
        dialogBig.updateHitbox();
        dialogBig.x = 25;
        dialogBig.y = FlxG.height - dialogBig.height - 30;
		add(dialogBig);

        holder = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/shop/bix')); //man what the fuck is a bix
        holder.scale.set(0.6, 0.6);
        holder.updateHitbox();
        holder.x = FlxG.width - holder.width - 25;
        holder.y = FlxG.height - holder.height - 30;

        var tabsar:Array<String> = ["songs", "skins", "extras"];

        tabs = new FlxTypedGroup<FlxSprite>();
		add(tabs);

        tabPos = [holder.x - 130, holder.x - 200];

        for(i in tabsar)
        {
            var tab = new FlxSprite(0, 0); 
            tab.frames = Paths.getSparrowAtlas("hud/shop/tabs");
            tab.animation.addByPrefix("idle", '$i tab', 24, true);
            tab.animation.play("idle");
            tab.scale.set(0.6, 0.6);
            tab.updateHitbox();
            tab.ID = tabsar.indexOf(i);
            tab.x = tabPos[0];
            if(i == defaultTab)
                tab.x = tabPos[1];
            tab.y = holder.y + ((tabsar.indexOf(i)+1) * 70);
            tabs.add(tab);
        }
            
		add(holder);

        icon = new FlxSprite(0, 0);
        icon.frames = Paths.getSparrowAtlas("hud/shop/wattsicons");
        icon.animation.addByPrefix("neutral", 'watts text neutral', 24, true);
        icon.animation.addByPrefix("sad", 'watts text sad', 24, true);
        icon.animation.addByPrefix("happy", 'watts text happy', 24, true);
        icon.animation.addByPrefix("angry", 'watts text angry', 24, true);
        icon.animation.addByPrefix("confused", 'watts text confused', 24, true);
        icon.animation.play("neutral");
        icon.scale.set(0.6, 0.6);
        icon.updateHitbox();
        icon.x = dialogBig.x + 70;
        icon.y = dialogBig.y + 60;
        add(icon);

        tex = new FlxTypeText(icon.x + icon.width + 25, icon.y, Std.int(dialogBig.width - (icon.x + icon.width + 25) - 50), '* What are you looking for?', true);
		tex.alpha = 1;
		tex.setFormat(Paths.font("sylfaen.ttf"), 24, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		tex.borderSize = 1.4;
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
		tex.finishSounds = false;
        tex.start();
		add(tex);

        songGroup = new ShopTab("songs", holder.x, holder.y);
		add(songGroup);

        skinsGroup = new ShopTab("skins", holder.x, holder.y);
		add(skinsGroup);

        extrasGroup = new ShopTab("extras", holder.x, holder.y);
		add(extrasGroup);

        label = new FlxText(880, 25, 0, "Press Y to change Tab");
		label.setFormat(Main.gFont, 28, 0xFFFFFFFF, CENTER);
		label.setBorderStyle(OUTLINE, 0xFF000000, 1.4);
		add(label);

        curTab = songGroup;

        lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
        lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
    }

    public static function scrollText(text:String, ?delay:Float = 0.05) {
        if(text == itemDesc)
            return;
        
        if(char == 1 && ShopState.nilaMode)
            ShopState.nila.animation.play("neutral");
        else
            ShopState.watts.animation.play("neutral");
        itemDesc = text;
        tex.resetText('* ' + text);
        tex.start(false, function()
        {
            new FlxTimer().start(0.1, function(tmr:FlxTimer)
            {
                if(char == 1 && ShopState.nilaMode)
                    ShopState.nila.animation.play("idle");
                else
                    ShopState.watts.animation.play("idle");
            });
        });
    }

    public function tweenAlpha(alpha:Float, time:Float) {
        if(alpha == 1)
            activeg = true;
        if(alpha == 0)
            activeg = false;
        FlxTween.tween(dialogBig, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(icon, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(tex, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(holder, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        FlxTween.tween(label, {alpha: alpha}, time, {ease: FlxEase.sineInOut});

        for(i in tabs) {
            FlxTween.tween(i, {alpha: alpha}, time, {ease: FlxEase.sineInOut});
        }

        if(activeg && ShopState.nilaMode)
            char = FlxG.random.int(0,1);

        alphaTab(alpha, time);
    }

    public function alphaTab(alpha:Float, time:Float) {
        for(i in curTab) {
            var alphaF = alpha;
            FlxTween.tween(i, {alpha: (alphaF > 0.5 ? 0.5 : alphaF)}, time, {
                ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
                    {
                        i.overAlpha = (alphaF >= 0.5 ? false : true);
                    }
                });
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(activeg) {
            if(Controls.justPressed("BACK")) {
                ShopState.exitShop();
            }

            if(Controls.justPressed("LOOP"))
                changeTab(1);

            if(Controls.justPressed("UI_UP"))
                changeItem(-2);
            if(Controls.justPressed("UI_DOWN"))
                changeItem(2);
            if(Controls.justPressed("UI_LEFT"))
                changeItem(-1);
            if(Controls.justPressed("UI_RIGHT"))
                changeItem(1);

            for(item in curTab.members){
                if(item.ident == curItem && !usingMouse)
                    item.hovering = true;
                else
                    item.hovering = false;
            }
    
            for(i in tabs) {
                if(i.ID == curId) {
                    i.x = tabPos[1];
                }
                else if(CoolUtil.mouseOverlap(i, ShopState.camHUD, new FlxPoint(holder.x + 10, i.y + i.height))) {
                    i.x = tabPos[1];
                    if(FlxG.mouse.justPressed) {
                        changeTab(0, i.ID);
                    }
                }
                else {
                    i.x = tabPos[0];
                }
    
                //i.x = FlxMath.lerp(i.x, 	lerpPos, 	 elapsed * 30);
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
    }

    public var usingMouse:Bool = false;
    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;
    
    public function changeItem(change:Int = 0, skipSound:Bool = false)
    {
        curItem += change;
        curItem = FlxMath.wrap(curItem, 0, curTab.members.length-1);

        if(change != 0 && !skipSound)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        usingMouse = false;
        Main.setMouse(false);
    }

    public function changeTab(change:Int = 0, effective:Int = -1)
    {
        curId += change;
        curId = FlxMath.wrap(curId, 0, 2);
        if(effective != -1)
            curId = effective;
        if(change != 0 || effective != -1)
            FlxG.sound.play(Paths.sound("menu/scroll"));

        curItem = 0;

        alphaTab(0, 0.4);
        switch (curId) {
            case 0:
                curTab = songGroup;
            case 1:
                curTab = skinsGroup;
            case 2:
                curTab = extrasGroup;
        }
        alphaTab(0.7, 0.4);

        //usingMouse = false;
        //Main.setMouse(false);
    }
}

class ShopTab extends FlxTypedGroup<ShopItem>
{
    var itemList:Map<String, Array<Array<Dynamic>>> =
    [
        "songs" => [
            ["mic", "Used Microphone", 50],
            ["crown", "Golden Crown", 100],
            ["ticket", "Rave Ticket", 50],
            ["shack", "Hair Dye", 75],
            //["time", "Weird Hourglass", 50],
        ],
        "skins" => [
            ["base", "Classic FNF", 15],
            ["tails", "Tails.EXE", 15],
            ["mlc", "Mirror Life Crisis", 15]
        ],
        "extras" => [
            ["bio", "Legal Records", 25],
            ["music", "Legit Disc", 25],
            ["gallery", "Gallery", 25]
        ]
    ];

    var tab:String = 'songs';

    public function new(name:String, x:Float, y:Float)
    {
        super();

        if(ShopState.nilaMode) {
            itemList = [
                "songs" => [
                    ["mic", "Used Microphone", 50],
                    ["crown", "Golden Crown", 100],
                    ["ticket", "Rave Ticket", 50],
                    ["shack", "Hair Dye", 75],
                    ["time", "Weird Hourglass", 50],
                ],
                "skins" => [
                    ["base", "Classic FNF", 15],
                    ["tails", "Tails.EXE", 15],
                    ["mlc", "Mirror Life Crisis", 15],
                    ["egg" + SaveData.eggCount(), SaveData.eggData()[0], SaveData.eggData()[1]]
                ],
                "extras" => [
                    ["biop", "Bios+", (SaveData.shop.get("bio") ? 10 : 35)],
                    ["musicp", "Sounds+", (SaveData.shop.get("music") ? 10 : 35)],
                    ["galleryp", "Gallery+", (SaveData.shop.get("gallery") ? 10 : 35)],
                    ["camera", "Camera", 25],
                ]
            ];
        }
        
        tab = name;

        for(i in 0...itemList.get(tab).length) {
            var itemX:Float = x + 40;
            var itemY:Float = y + 30;
            if(i >= 4)
                itemY = y + 15 + 400;
            else if(i >= 2)
                itemY = y + 15 + 200;
            if(i == 1 || i == 3)
                itemX = x + 40 + 200;
            var item = new ShopItem(itemList.get(tab)[i], itemX, itemY);
            item.ident = i;
            add(item);
        }
    }
}

class ShopItem extends FlxGroup
{
    public var alpha:Float = 0;
    public var tempalpha:Float = 1;
    public var ident:Int;
    public var display:FlxSprite;
    public var icon:FlxSprite;
    public var plus:FlxSprite;
    public var name:FlxText;
    public var price:FlxText;

    public var info:Array<Dynamic>;

    public var overAlpha:Bool = true;
    var isPlus:Bool = false;
    public function new(info:Array<Dynamic>, x:Float, y:Float)
    {
        super();
        this.info = info;

        var displayThingo:String = info[0];
        if(displayThingo.endsWith("p")) {
            if(displayThingo != "musicp")
                displayThingo = info[0].substring(0, info[0].length-1);
            isPlus = true;
        }

        display = new FlxSprite(x, y);
        display.frames = Paths.getSparrowAtlas("hud/shop/ITEMS");
        display.animation.addByPrefix("idle", displayThingo, 24, true);
        display.animation.play("idle");
        display.scale.set(0.6, 0.6);
        display.updateHitbox();

        if(isPlus) {
            plus = new FlxSprite().loadGraphic(Paths.image("hud/shop/plus"));
            plus.scale.set(0.25, 0.25);
            plus.updateHitbox();
            plus.x = display.x+display.width-plus.width;
            plus.y = display.y+display.height-plus.height;
        }

        name = new FlxText(x, y+140, 0, info[1]);
		name.setFormat(Main.gFont, 22, 0xFFFFFFFF, LEFT);
		name.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.4);

        icon = new FlxSprite().loadGraphic(Paths.image("hud/base/money"));
        icon.scale.set(0.6, 0.6);
        icon.updateHitbox();
        icon.x = x;
        icon.y = name.y+name.height;

		price = new FlxText(0, 0, 0, Std.string(info[2]));
		price.setFormat(Main.gFont, 22, 0xFFFFFFFF, LEFT);
		price.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.4);
        price.x = icon.x+icon.width;
        price.y = name.y+name.height;

        add(display);
        if(isPlus)
            add(plus);
		add(name);
        add(icon);
        add(price);
    }

    var overlapinTest:Bool = false;
    public var hovering:Bool = false;
    var alphaSold:Float = 1;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        display.alpha = alpha * alphaSold;
        if(isPlus)
            plus.alpha = display.alpha;
        name.alpha = alpha;
        icon.alpha = alpha;
        price.alpha = alpha;

        if((CoolUtil.mouseOverlap(display, ShopState.camHUD) && ShopState.hudBuy.usingMouse)|| hovering)
            overlapinTest = true;
        else
            overlapinTest = false;

        if(overlapinTest) {
            tempalpha = 1;
            if(alpha != 0) {
                var text:String = "...err, what is this, again?";
                if(SaveData.displayShop.get(info[0])[ShopBuy.char + 1] != null)
                    text = SaveData.displayShop.get(info[0])[ShopBuy.char + 1];
                ShopBuy.scrollText(text);

                if((FlxG.mouse.justPressed && ShopState.hudBuy.usingMouse) || (Controls.justPressed("ACCEPT") && !ShopState.hudBuy.usingMouse)) {
                    var item:String = (cast info[0]);

                    if(!SaveData.shop.get(item) && SaveData.money >= info[2]) {
                        FlxG.sound.play(Paths.sound("csin"));
                        SaveData.buyItem(item);
                        SaveData.transaction(-Std.int(info[2]));

                        if(item.endsWith("p")) {
                            if(!SaveData.shop.get(item.substring(0, item.length-1)))
                                SaveData.buyItem(info[0].substring(0, item.length-1));
                        }

                        if(item.startsWith("egg")) {
                            SaveData.buyItem("fnfdon");
                            SaveData.buyItem("fitdon");
                            SaveData.buyItem("ylyl");
                        }

                        if(item == 'crown') {
                            states.cd.MainMenu.unlocks.push("Week 1: VIP!");
                            //Main.switchState(new states.cd.MainMenu());
                        }

                        if(item == 'shack') {
                            states.cd.MainMenu.unlocks.push("Song: Ripple! (FREEPLAY)\nSong: Customer Service! (FREEPLAY)");
                           // Main.switchState(new states.cd.MainMenu());
                        }

                        if(item == 'ticket') {
                            states.cd.MainMenu.unlocks.push("Song: Kaboom! (FREEPLAY)");
                            //Main.switchState(new states.cd.MainMenu());
                        }

                        if(item == 'camera') {
                            states.cd.MainMenu.unlocks.push("Photo Mode!");
                        }

                    }
                    else if (item != 'mic'){
                        FlxG.sound.play(Paths.sound("menu/locked"));
                    }

                    if(item == 'mic' && (SaveData.money >= info[2] || SaveData.shop.get(item))) {
                        ShopState.exitShop(true);
                    }
                }
            }
        }
        else {
            tempalpha = 0.5;
        }

        if(!overAlpha)
            alpha = tempalpha;

        if(SaveData.shop.get(info[0])) {
            alphaSold = 0.3;

            if(price.text != "0")
                price.text = "0";

            if(info[0] == "mic") {
                if(name.text != "REPLAY")
                    name.text = "REPLAY";
            }
            else {
                if(name.text != "SOLD")
                    name.text = "SOLD";
            }

        }
    }
}