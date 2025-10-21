package states.cd;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import data.GameData.MusicBeatState;
import flixel.sound.FlxSound;
import data.Conductor;
import flixel.ui.FlxBar;
import data.Discord.DiscordIO;
import flixel.FlxObject;
import flixel.FlxCamera;

class MusicPlayer extends MusicBeatState
{
    public static var songs:Array<Array<Array<Dynamic>>> = [[
        ["Characteristic Disparity", "CharaWhy", "music/intro"],
        ["Euphoria", "Coco Puffs", "songs/euphoria/Inst", "songs/euphoria/Voices"],
        ["Nefarious", "teles", "songs/nefarious/Inst", "songs/nefarious/Voices"],
        ["Divergence", "CharaWhy", "songs/divergence/Inst", "songs/divergence/Voices"],
        ["Allegro", "teles ft. Coco Puffs", "songs/allegro/Inst", "songs/allegro/Voices"],
        ["Panic Attack", "Coco Puffs", "songs/panic-attack/Inst", "songs/panic-attack/Voices"],
        ["Convergence", "CharaWhy", "songs/convergence/Inst", "songs/convergence/Voices"],
        ["Desertion", "Coco Puffs", "songs/desertion/Inst", "songs/desertion/Voices"],
        ["sin.", "teles ft. Coco Puffs", "songs/sin/old/Inst", "songs/sin/old/Voices"],
        ["Intimidate", "Coco Puffs", "songs/intimidate/Inst", "songs/intimidate/Voices"],
        ["Conservation", "CharaWhy", "songs/conservation/Inst", "songs/conservation/Voices"],
        ["Irritation", "Coco Puffs ft. CharaWhy", "songs/irritation/Inst", "songs/irritation/Voices"],
        ["Euphoria VIP", "CharaWhy ft. Leebert", "songs/euphoria-vip/Inst", "songs/euphoria-vip/Voices"],
        ["Nefarious VIP", "CharaWhy", "songs/nefarious-vip/Inst", "songs/nefarious-vip/Voices"],
        ["Divergence VIP", "CharaWhy", "songs/divergence-vip/Inst", "songs/divergence-vip/Voices"],
        ["Kaboom!", "teles ft. HighPoweredKeyz", "songs/kaboom/Inst", "songs/kaboom/Voices"],
        ["Ripple", "CharaWhy", "songs/ripple/Inst", "songs/ripple/Voices"],
        ["Customer Service", "teles ft. Jospi", "songs/customer-service/Inst", "songs/customer-service/Voices"],
        ["HeartPounder", "Coco Puffs", "songs/heartpounder/Inst", "songs/heartpounder/Voices"],
        ["Exotic", "Coco Puffs", "songs/exotic/Inst"],
        ["Cupid", "teles", "songs/cupid/Inst", "songs/cupid/Voices"],
        ["Over the Horizon", "Coco Puffs", "music/overTheHorizon"],
        ["Over the Thunder", "CharaWhy", "music/overTheHorizonBree"],
        ["Over the Counter", "teles", "music/shopkeeper"],
        ["Over the Clouds", "YaBoiJustin", "music/overTheHorizonHelica-old"],
        ["Movement", "CharaWhy", "music/movement"],
        ["Whatcha Buyin?", "CharaWhy", "music/WhatchaBuyin"],
        ["Love Letter (Bios Theme)", "Coco Puffs", "music/LoveLetter"],
        ["Allegretto (Credits Theme)", "teles", "music/credits"],
        ["Euphoria (Dialogue)", "Coco Puffs", "music/dialogue/old/11"],
        ["Nefarious (Dialogue)", "Coco Puffs", "music/dialogue/old/12"],
        ["Divergence (Dialogue)", "Coco Puffs", "music/dialogue/old/13"],
        ["Allegro (Dialogue)", "Coco Puffs", "music/dialogue/old/21"],
        ["Panic Attack (Dialogue)", "Coco Puffs", "music/dialogue/old/22"],
        ["Convergence (Dialogue)", "teles", "music/dialogue/old/23"],
        ["Desertion (Dialogue)", "teles", "music/dialogue/24"],
        ["Godsend (Finale)", "Coco Puffs", "music/godsend"],
        ["Ripple (Dialogue)", "teles", "music/dialogue/freeplay"],
        ["Reiterate (Game Over Theme)", "teles", "music/death/reiterate"],
        ["THUNDEROUS", "teles", "music/death/bree"],
        ["Speaker", "Coco Puffs", "music/speaker"],
        ["Reiterate (Retro)", "teles", "music/death/reiterate-old"]
    ],[
        ["Nefarious! Mini (Extra)", "Coco Puffs", "music/extra/nefarious-mini"],
        ["Ripple VIP (Extra)", "CharaWhy", "music/extra/ripple-vip"],
        ["sin. (Remastered)", "teles ft. Coco Puffs", "songs/sin/Inst", "songs/sin/Voices"],
        ["Over the Clouds (New)", "YaBoiJustin", "music/overTheHorizonHelica"],
        ["Euphoria (New Dialogue)", "Coco Puffs", "music/dialogue/11"],
        ["Nefarious (New Dialogue)", "Coco Puffs", "music/dialogue/12"],
        ["Divergence (New Dialogue)", "Coco Puffs", "music/dialogue/13"],
        ["Allegro (New Dialogue)", "Coco Puffs", "music/dialogue/21"],
        ["Panic Attack (New Dialogue)", "Coco Puffs", "music/dialogue/22"],
        ["Convergence (New Dialogue)", "Coco Puffs", "music/dialogue/23"],
        ["Euphoria (Classic)", "Coco Puffs", "songs/euphoria-old/Inst", "songs/euphoria-old/Voices"],
        ["Nefarious (Classic)", "teles", "songs/nefarious-old/Inst", "songs/nefarious-old/Voices"],
        ["Divergence (Classic)", "CharaWhy", "songs/divergence-old/Inst", "songs/divergence-old/Voices"],
    ]];
    static var curSelected:Int = 0;

    var playing:Bool = false;
    var looping:Bool = false;
    var vocalsMuted:Bool = false;

    var clouds:FlxSprite;
    var frame:FlxSprite;
    var frameL:FlxSprite;
    var arrow:FlxSprite;

    var skipF:FlxSprite;
    var skipB:FlxSprite;
    var pause:FlxSprite;
    var loop:FlxSprite;

    var vol1:FlxSprite;
    var vol2:FlxSprite;

    var timeBar:FlxBar;
    var icon:FlxSprite;
    var timeTxt:FlxText;

    var songName:FlxText;
    var songComposer:FlxText;
    var hints:FlxText;

    var holders:FlxTypedGroup<FlxSprite>;
    var names:FlxTypedGroup<FlxSprite>;

    public var inst:FlxSound;
	public var vocals:FlxSound;
	public var musicList:Array<FlxSound> = [];
    var songLength:Float = 0;

    public static var camFollow:FlxObject = new FlxObject();
    public static var camGame:FlxCamera;
    var vol:Int = 0;

    public override function create()
    {
        super.create();

        CoolUtil.playMusic();
        //Main.setMouse(true);

        DiscordIO.changePresence("In the Music Player...", null);

        camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        var color = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
		color.screenCenter();
		add(color);

        clouds = new FlxSprite().loadGraphic(Paths.image('menu/music/sky'));
        clouds.x = -5.2;
        clouds.y = -2.55;
		add(clouds);

        holders = new FlxTypedGroup<FlxSprite>();
		add(holders);

        names = new FlxTypedGroup<FlxSprite>();
		add(names);

        for(i in 0...songs[0].length)
        {
            var num:String = Std.string(i+1) + ". ";
            if(i <= 8)
                num = "0" + num;

            var holder = new FlxSprite().loadGraphic(Paths.image('menu/music/song'));
            holder.x = 769.4;
            holder.y = 143.25 + ((i-curSelected)*holder.height);
            holder.ID = i;
            holders.add(holder);

            var text = new FlxText(0,0,0,"");
            text.setFormat(Main.gFont, 30, 0xFF000000, CENTER);
            text.text = num + songs[0][i][0];
            trace(num + songs[vol][i][0]);
            text.x = 774.85;
            text.y = holder.y + 10;
            text.ID = i;
            names.add(text);
        }

        for(i in 0...songs[1].length)
        {
            var num:String = Std.string(i+1) + ". ";
            if(i <= 8)
                num = "0" + num;

            var holder = new FlxSprite().loadGraphic(Paths.image('menu/music/song'));
            holder.x = -holder.width - 65;
            holder.y = 143.25 + ((i-curSelected)*holder.height);
            holder.ID = i;
            holders.add(holder);

            var text = new FlxText(0,0,0,"");
            text.setFormat(Main.gFont, 30, 0xFF000000, CENTER);
            text.text = num + songs[1][i][0];
            trace(num + songs[vol][i][0]);
            text.x = holder.x + 13;
            text.y = holder.y + 10;
            text.ID = i;
            names.add(text);
        }

        frame = new FlxSprite().loadGraphic(Paths.image('menu/music/list-overlay'));
        frame.x = 705.25;
        frame.y = -3.8;
		add(frame);

        frameL = new FlxSprite().loadGraphic(Paths.image('menu/music/list-overlay'));
        frameL.flipX = true;
        frameL.x = -frameL.width;
        frameL.y = -3.8;
		add(frameL);

        arrow = new FlxSprite().loadGraphic(Paths.image('menu/music/arrow'));
        arrow.x = 1251;
        arrow.y = 149.7;
		add(arrow);

        var where:Float = 390;
        var what:Float = 150;

        pause = new FlxSprite();
        pause.frames = Paths.getSparrowAtlas('menu/music/buttons');
        pause.animation.addByPrefix('pause',  'play button', 24, true);
        pause.animation.addByPrefix('play',  'pause button', 24, true);
        pause.animation.play('pause');
        pause.x = 57.7 + what + 5;//290.05;
        pause.y = where;
        pause.alpha = 0.8;
        add(pause);

        skipB = new FlxSprite();
        skipB.frames = Paths.getSparrowAtlas('menu/music/buttons');
        skipB.animation.addByPrefix('idle',  'last track', 24, true);
        skipB.animation.play('idle');
        skipB.x = 57.7;
        skipB.y = where;
        skipB.alpha = 0.8;
        add(skipB);

        skipF = new FlxSprite();
        skipF.frames = Paths.getSparrowAtlas('menu/music/buttons');
        skipF.animation.addByPrefix('idle',  'next track', 24, true);
        skipF.animation.play('idle');
        skipF.x = 57.7 + (what*2) + 5;//512.65;
        skipF.y = where;
        skipF.alpha = 0.8;
        add(skipF);

        loop = new FlxSprite();
        loop.frames = Paths.getSparrowAtlas('menu/music/buttons');
        loop.animation.addByPrefix('idle',  'Loop0000', 24, true);
        loop.animation.play('idle');
        loop.x = 512.65;//293.1;
        loop.y = where;
        loop.alpha = 0.6;
        add(loop);

        vol1 = new FlxSprite().loadGraphic(Paths.image('menu/music/vol1'));
        vol1.scale.set(0.5,0.5);
        vol1.updateHitbox();
        vol1.y += 23;
        vol1.x = clouds.width / 2 - vol1.width / 2 - 10; 
		add(vol1);

        vol2 = new FlxSprite().loadGraphic(Paths.image('menu/music/vol2'));
        vol2.scale.set(0.5,0.5);
        vol2.updateHitbox();
        vol2.alpha = 0;
        vol2.y += 23;
        vol2.x = clouds.width / 2 - vol2.width / 2 - 10; 
		add(vol2);

        timeBar = new FlxBar(
			115.3, 539.5,
			LEFT_TO_RIGHT,
			482,
			13.5
		);
		timeBar.createFilledBar(0xFFFFFFFF, 0xFF3B4877);
		timeBar.updateBar();
        add(timeBar);

        icon = new FlxSprite().loadGraphic(Paths.image('menu/music/cursor'));
        icon.y = 520.4;
		add(icon);

        timeTxt = new FlxText(0,0,0,"0:00 / 0:00");
        timeTxt.setFormat(Main.gFont, 30, 0xFF3B4877, CENTER);
        timeTxt.x = timeBar.x + (timeBar.width/2) - (timeTxt.width/2);
        timeTxt.y = icon.y + icon.height + 2;
        add(timeTxt);

        songName = new FlxText(0,0,0,"Euphoria");
        songName.setFormat(Main.gFont, 50, 0xFF3B4877, CENTER);
        songName.x = timeBar.x + (timeBar.width/2) - (songName.width/2);
        songName.y = timeTxt.y + timeTxt.height + 3;
        add(songName);

        songComposer = new FlxText(0,0,0,"Coco Puffs");
        songComposer.setFormat(Main.gFont, 30, 0xFF3B4877, CENTER);
        songComposer.x = timeBar.x + (timeBar.width/2) - (songComposer.width/2);
        songComposer.y = songName.y + songName.height + 2;
        add(songComposer);

        hints = new FlxText(0,0,0,"LEFT / RIGHT: Skip Song\nACCEPT: Play / Pause\nX: Mute Vocals\nY: Toggle Loop\nL/Q: Change Album\nR/E: View in Web");
        hints.setFormat(Main.gFont, 20, 0xFF000000, LEFT);
        hints.x = frame.x + 70;
        hints.y = 9;
        add(hints);

        camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());

        changeSelection();
        lastMouseX = FlxG.mouse.getScreenPosition(FlxG.camera).x;
        lastMouseY = FlxG.mouse.getScreenPosition(FlxG.camera).y;
    }

    public function updateTimeTxt()
    {
        timeTxt.text
        = CoolUtil.posToTimer(Conductor.songPos)
        + ' / '
        + CoolUtil.posToTimer(songLength);
        timeTxt.x = timeBar.x + (timeBar.width/2) - (timeTxt.width/2);
    }
    
    var formatTime:Float = 0;
    var usingMouse:Bool = false;
    var lastMouseX:Float = 0;
    var lastMouseY:Float = 0;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        camGame.followLerp = elapsed * 6;
        
        if(Controls.justPressed("L_SPECIAL")) {
            if(vol == 0)
                vol = 1;
            else
                vol = 0;

            vol1.alpha = 1-vol;
            vol2.alpha = vol;

            camFollow.setPosition((!(vol == 1) ? (FlxG.width/2) : (FlxG.width/2) - 581), FlxG.height/2);
            curSelected = 0;
            changeSelection(0);
        }

        if(Controls.justPressed("R_SPECIAL")) //TO-DO (IMPORTANT): SEPARATE LINKS FOR VOL 1 and 2
            FlxG.openURL("https://shatterdisk.bandcamp.com/album/characteristic-disparity-original-soundtrack");

        if(Controls.justPressed("UI_LEFT") || Controls.justPressed("UI_UP")) {
            changeSelection(-1);
            usingMouse = false;
            Main.setMouse(false);
        }

        if(Controls.justPressed("UI_RIGHT") || Controls.justPressed("UI_DOWN")) {
            changeSelection(1);
            usingMouse = false;
            Main.setMouse(false);
        }

        if(Controls.justPressed("BACK"))
        {
            FlxG.sound.play(Paths.sound('menu/back'));
            Main.switchState(new states.cd.MainMenu());
        }

        for(holder in holders.members)
        {
            holder.y = FlxMath.lerp(holder.y, 143.25 + ((holder.ID-curSelected)*holder.height), elapsed*6);

            for(text in names.members)
            {
                if(text.ID == holder.ID)
                    text.y = holder.y + 10;
            }
        }

        formatTime = ((Conductor.songPos / songLength));
        icon.x = (timeBar.x + (timeBar.width * (formatTime))) - (icon.width/2);
        timeBar.percent = formatTime*100;
        updateTimeTxt();

        if(Conductor.songPos >= songLength)
        {
            if(looping)
                reloadAudio();
            else
                changeSelection(1);
        }

        for(song in musicList)
        {
            if(playing && Conductor.songPos >= 0)
            {
                if(!song.playing)
                    song.play(Conductor.songPos);
                if(Math.abs(song.time - Conductor.songPos) >= 40)
                    song.time = Conductor.songPos;
            }
            if(!playing && song.playing)
                song.stop();
        }

        if(playing)
        {
            Conductor.songPos += elapsed * 1000;
        }

        if(Controls.justPressed("ACCEPT")) {
            playSong();
        }

        if(Controls.justPressed("BOTPLAY")) {
            vocalsMuted = !vocalsMuted;
            if(vocals != null && vocalsMuted)
                vocals.volume = 0;
            else if(vocals != null)
                vocals.volume = 1;
        }

        if(CoolUtil.mouseOverlapWorld(pause, camGame)) {
            pause.alpha = 1;
            if(FlxG.mouse.justPressed) {
                playSong();
            }
        }
        else
            pause.alpha = 0.8;

        if(CoolUtil.mouseOverlapWorld(skipF, camGame)) {
            skipF.alpha = 1;
            if(FlxG.mouse.justPressed) {
                changeSelection(1);
            }
        }
        else
            skipF.alpha = 0.8;

        if(CoolUtil.mouseOverlapWorld(skipB, camGame)) {
            skipB.alpha = 1;
            if(FlxG.mouse.justPressed) {
                changeSelection(-1);
            }
        }
        else
            skipB.alpha = 0.8;

        if(Controls.justPressed("LOOP")) {
            looping = !looping;
            if(looping)
                loop.alpha = 1;
            else
                loop.alpha = 0.6;
        }

        if(CoolUtil.mouseOverlapWorld(loop, camGame)) {
            if(FlxG.mouse.justPressed) {
                looping = !looping;
                if(looping)
                    loop.alpha = 1;
                else
                    loop.alpha = 0.6;
            }
        }

        if(lastMouseX != FlxG.mouse.getScreenPosition(camGame).x || lastMouseY != FlxG.mouse.getScreenPosition(camGame).y) {
            if(!usingMouse) {
                usingMouse = true;
                Main.setMouse(true);
            }
            lastMouseX = FlxG.mouse.getScreenPosition(camGame).x;
            lastMouseY = FlxG.mouse.getScreenPosition(camGame).y;
        }
    }

    function playSong() {
        playing = !playing;
        if(playing)
            pause.animation.play('play');
        else
            pause.animation.play('pause');
    }

	function reloadAudio()
	{
        Conductor.songPos = 0;
        for(song in musicList)
        {
            song.stop();
        }

		musicList = [];
		function addMusic(music:FlxSound):Void
		{
			FlxG.sound.list.add(music);

			if(music.length > 0)
			{
				musicList.push(music);

				if(music.length < songLength)
					songLength = music.length;
			}

			music.play();
			music.stop();
		}

		inst = new FlxSound();
		inst.loadEmbedded(Paths.getPath(songs[vol][curSelected][2] + ".ogg"), false, false);
		songLength = inst.length;
		addMusic(inst);

		if(songs[vol][curSelected][3] != null)
		{
			vocals = new FlxSound();
			vocals.loadEmbedded(Paths.getPath(songs[vol][curSelected][3] + ".ogg"), false, false);
            if(vocalsMuted)
                vocals.volume = 0;
            else
                vocals.volume = 1;
			addMusic(vocals);
		}
	}

    public function changeSelection(change:Int = 0)
    {
        //if(selected) return; //do not
        curSelected += change;
        curSelected = FlxMath.wrap(curSelected, 0, songs[vol].length - 1);
        //if(change != 0)
        //    FlxG.sound.play(Paths.sound("menu/scroll"));

        songName.text = songs[vol][curSelected][0];
        songComposer.text = songs[vol][curSelected][1];

        songName.x = timeBar.x + (timeBar.width/2) - (songName.width/2);
        songName.y = timeTxt.y + timeTxt.height + 3;

        songComposer.x = timeBar.x + (timeBar.width/2) - (songComposer.width/2);
        songComposer.y = songName.y + songName.height + 2;

        reloadAudio();
    }
}