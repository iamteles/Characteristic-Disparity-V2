package states;

import flixel.sound.FlxSound;
import data.GameData.MusicBeatState;
import data.Discord.DiscordIO;
import data.DoidoVideoSprite;
import flixel.util.FlxTimer;
import subStates.CutscenePauseSubState;
import hxvlc.util.Handle;

class VideoState extends MusicBeatState
{
    public static var name:String = "divergence";
    private var video:DoidoVideoSprite;
    var loaded:Bool = false;
	override public function create():Void
	{
        CoolUtil.playMusic();
        Main.setMouse(false);
        DiscordIO.changePresence("Watching Cutscene", null);

        Handle.initAsync(function(success:Bool):Void
		{
            if(!success)
                trace("uh oh");
            
            video = new DoidoVideoSprite();
            video.antialiasing = SaveData.data.get("Antialiasing");

            video.bitmap.onEncounteredError.add(function(message:String):Void
			{
				trace('VLC Error: $message');
			});

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
                loaded = true;
                video.play();
            });
        });

		super.create();
	}

    public function close():Void
    {
        video.destroy();
        skipped = true;

        switch(name) {
            /*case "test":
                Main.skipClearMemory = true;
                states.VideoState.name = "intro";
                Main.switchState(new states.VideoState());*/
            case "intro" | "test":
                Main.skipStuff();
                Main.skipClearMemory = true;
                //states.cd.TitleScreen.introEnded = true;
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

    var skipped:Bool = false;
    var hasPause:Array<String> = ["intro", "test"];
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(Controls.justPressed("ACCEPT") && !skipped && loaded) {
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
                    video.pause();
					video.bitmap.position = 0.0;
					video.resume();
                default:
                    video.resume();
            }
        }));
    }
}