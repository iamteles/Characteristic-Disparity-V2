package states;

import flixel.sound.FlxSound;
import data.GameData.MusicBeatState;
import data.Discord.DiscordClient;
import data.DoidoVideoSprite;
import flixel.util.FlxTimer;
import subStates.CutscenePauseSubState;

class VideoState extends MusicBeatState
{
    public static var name:String = "divergence";
    private var video:DoidoVideoSprite;
	override public function create():Void
	{
        CoolUtil.playMusic();
        Main.setMouse(false);
        DiscordClient.changePresence("Watching cutscene...", null);

        video = new DoidoVideoSprite();
		video.antialiasing = SaveData.data.get("Antialiasing");

		video.bitmap.onFormatSetup.add(function():Void {
			if (video.bitmap != null && video.bitmap.bitmapData != null) {
				video.setGraphicSize(FlxG.width, FlxG.height);
				video.updateHitbox();
				video.screenCenter();
			}
		});

        video.bitmap.onEndReached.add(function():Void {
            close();
        });

        video.load(Paths.video(name));
        add(video);
        
        new FlxTimer().start(0.001, function(tmr) {
            video.play();
        });

		super.create();
	}

    public function close():Void
    {
        video.destroy();

        switch(name) {
            case "test":
                Main.skipClearMemory = true;
                states.VideoState.name = "intro";
                Main.switchState(new states.VideoState());
            case "intro":
                Main.skipStuff();
                Main.skipClearMemory = true;
                states.cd.TitleScreen.fromIntro = true;
		        Main.switchState(new states.cd.TitleScreen());
            case "divergence":
                // pop up here?
                //SaveData.progression.set("week1", true);
                if(!SaveData.progression.get("week1"))
                    states.cd.MainMenu.unlocks.push("Week 2!\nFreeplay!");
                SaveData.progression.set("week1", true);
                SaveData.save();
                Main.switchState(new states.cd.MainMenu());
            case "panic":
                states.cd.Dialog.dialog = "panic-attack";
                Main.switchState(new states.cd.Dialog());
            default:
                Main.switchState(new states.cd.MainMenu());
        }

    }

    var hasPause:Array<String> = ["intro", "test"];
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(Controls.justPressed("ACCEPT")) {
            if(!hasPause.contains(name))
                pauseVideo();
            else if(SaveData.progression.get("firstboot"))
                close();
        }
    }

    
    public function pauseVideo()
    {
        FlxG.sound.play(Paths.sound('menu/back'), 0.7);
        video.pause();
        
        openSubState(new subStates.CutscenePauseSubState(function(exit:PauseExit) {
            switch(exit) {
                case SKIP:                    
                    close();
                case RESTART:
                    video.restart();
                default:
                    video.resume();
            }
        }));
    }
}