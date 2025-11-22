package subStates;

import data.GameData.MusicBeatSubState;
import states.cd.Dialog;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class DialogHistorySubState extends MusicBeatSubState
{
    var data:PastDialogue;

    var boxGrp:FlxTypedGroup<FlxSprite>;
    var txtGrp:FlxTypedGroup<FlxText>;
    var namGrp:FlxTypedGroup<FlxText>;

	var curSelected:Int = 0;
    var spacing:Float = -350;

    public function new(data:PastDialogue) {
        super();
		this.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        this.data = data;
        curSelected = data.lines.length - 1;
        
        var banana = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(banana);

		banana.alpha = 0;
		FlxTween.tween(banana, {alpha: 0.65}, 0.1);

        boxGrp = new FlxTypedGroup<FlxSprite>();
        txtGrp = new FlxTypedGroup<FlxText>();
        namGrp = new FlxTypedGroup<FlxText>();

		add(boxGrp);
		add(txtGrp);
        add(namGrp);

        for(i in 0...data.lines.length) {
            var box = new FlxSprite().loadGraphic(Paths.image('dialog/dialogue-${data.boxName}'));
            box.scale.set(0.65,0.65);
            box.updateHitbox();
            box.ID = i;
            box.x = ((FlxG.width/2) - (box.width/2));
            box.y = ((FlxG.width/2) - (box.height/2)) + ((curSelected - box.ID) * spacing);
            boxGrp.add(box);

            var tex = new FlxText(0, 0, Std.int(FlxG.width - 110), data.lines[i].text, true);
            tex.alpha = 1;
            tex.setFormat(Main.gFont, 36, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
            tex.borderSize = 2;
            tex.ID = i;
            tex.x = box.x + 25;
            tex.y = box.y + 123;
            txtGrp.add(tex);

            var name = new FlxText(0,0,0,data.lines[i].name, 200);
            name.setFormat(Main.gFont, 50, 0xFFFFFFFF, CENTER);
            name.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
            name.ID = i;
            name.x = ((FlxG.width/2) - (name.width/2));
            name.x -= Dialog.namePos;
            name.y = box.y + 22;
            namGrp.add(name);
        }

        var stateTxt = new FlxText(0,0,0,'DIALOGUE HISTORY');
        stateTxt.setFormat(Main.dsFont, 36, 0xFFFFFFFF, LEFT);
		stateTxt.setBorderStyle(OUTLINE, 0xFF000000, 2.5);
		stateTxt.x = FlxG.width - stateTxt.width - 5;
        stateTxt.y = 3;
		stateTxt.alpha = 1;
        stateTxt.antialiasing = false;
        add(stateTxt);

        changeSelection();
    }

    var inputDelay:Float = 0.05;
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        for(box in boxGrp.members) {
            box.y = FlxMath.lerp(box.y, ((FlxG.height/2) - (box.height/2)) + ((curSelected - box.ID) * spacing), elapsed*8);
            box.alpha = FlxMath.lerp(box.alpha, (box.ID == curSelected ? 1 : 0.5), elapsed*12);
        }

        for(text in txtGrp.members) {
            for(box in boxGrp.members)
                if(text.ID == box.ID)
                    text.y = box.y + 123;

            text.alpha = FlxMath.lerp(text.alpha, (text.ID == curSelected ? 1 : 0.5), elapsed*12);
        }

        for(name in namGrp.members) {
            for(box in boxGrp.members)
                if(name.ID == box.ID)
                    name.y = box.y + 22;

            name.alpha = FlxMath.lerp(name.alpha, (name.ID == curSelected ? 1 : 0.5), elapsed*12);
        }
        
        if(Controls.justPressed("UI_UP"))
            changeSelection(-1);
        if(Controls.justPressed("UI_DOWN"))
            changeSelection(1);

        // works the same as resume
        if(Controls.justPressed("BACK"))
            close();
    }

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, data.lines.length - 1);

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scroll"));
	}
}