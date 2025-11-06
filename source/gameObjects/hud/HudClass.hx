package gameObjects.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import data.Conductor;
import data.Timings;
import states.PlayState;

class HudClass extends FlxGroup
{
	public var infoTxt:FlxText;
	public var timeTxt:FlxText;

	// health bar
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var timeBar:FlxSprite;
	var smoothBar:Bool = true;

	// icon stuff
	public var iconBf:HealthIcon;
	public var iconDad:HealthIcon;
	public var iconCenter:HealthIcon;

	public var invertedIcons:Bool = false;
	public var health:Float = 1;

	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	var simpleInfo:Bool = false;
	var retroStyle:Bool = true;
	var alignment:FlxTextAlign = CENTER;

	public function new()
	{
		super();

		simpleInfo = (PlayState.SONG.song.toLowerCase() == 'heartpounder');
		retroStyle = (PlayState.SONG.song.endsWith("-old") || PlayState.SONG.song.toLowerCase() == 'exotic' || SaveData.skin() == "base");
		if(simpleInfo)
			alignment = LEFT;

		healthBarBG = new FlxSprite().loadGraphic(Paths.image("hud/base/healthBar" + (retroStyle ? "Border" : "")));
		healthBarBG.visible = !simpleInfo;

		if(PlayState.SONG.song.toLowerCase() == 'nefarious' || PlayState.SONG.song.toLowerCase() == 'divergence' || PlayState.invertedCharacters || PlayState.SONG.song.toLowerCase() == 'cupid' || PlayState.SONG.song.toLowerCase() == 'euphoria-vip')
			invertedIcons = true;

		if(retroStyle) {
			healthBar = new FlxBar(
				0, 0,
				RIGHT_TO_LEFT,
				Math.floor(healthBarBG.width) - 8,
				Math.floor(healthBarBG.height) - 8
			);
		}
		else {
			healthBar = new FlxBar(
				0, 0,
				RIGHT_TO_LEFT,
				Math.floor(healthBarBG.width) - 140,
				Math.floor(healthBarBG.height) - 20
			);
		}
		healthBar.createFilledBar(0xFFFF0000, 0xFF00FF00);
		healthBar.updateBar();
		healthBar.visible = !simpleInfo;

		add(healthBar);
		add(healthBarBG);

		smoothBar = true;

		iconDad = new HealthIcon();
		iconDad.setIcon(PlayState.SONG.player2, false, PlayState.daSong);
		iconDad.visible = !simpleInfo;
		iconDad.ID = 0;
		add(iconDad);

		iconBf = new HealthIcon();
		iconBf.setIcon(PlayState.SONG.player1, true, PlayState.daSong);
		iconBf.ID = 1;
		iconBf.visible = !simpleInfo;
		add(iconBf);

		iconCenter = new HealthIcon();
		iconCenter.setIcon("center", false, PlayState.daSong);
		iconCenter.visible = !(simpleInfo || retroStyle);
		//iconCenter.ID = 0;
		add(iconCenter);

		changeIcon(0, iconDad.curIcon);

		var size:Int = 20;
		var font = Main.gFont;
		if(simpleInfo)
			size = 32;
		else if(retroStyle) {
			font = Paths.font("phantommuff.ttf");
		}
		infoTxt = new FlxText(0, 0, 0, "hi there! i am using whatsapp");
		infoTxt.setFormat(font, size, 0xFFFFFFFF, alignment);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);
		
		timeTxt = new FlxText(0, 0, 0, "nuts / balls even");
		timeTxt.setFormat(Main.gFont, 32, 0xFFFFFFFF, CENTER);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		timeTxt.visible = !retroStyle;
		add(timeTxt);

		badScoreTxt = new FlxText(0,0,0,"SAVING SCORES DISABLED");
		badScoreTxt.setFormat(Main.gFont, size, 0xFFFF0000, alignment);
		badScoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		badScoreTxt.screenCenter(X);
		badScoreTxt.visible = false;
		add(badScoreTxt);

		botplayTxt = new FlxText(0,0,0,"[BOTPLAY]");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, CENTER);
		botplayTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		botplayTxt.visible = false;
		add(botplayTxt);

		if(retroStyle) {
			timeBar = new FlxSprite().makeGraphic(FlxG.width, 20, 0xFFFFFFFF);
			timeBar.y = FlxG.height - timeBar.height + 10;
			timeBar.scale.x = 0;
			add(timeBar);
		}

		updateHitbox();
		health = PlayState.health;
	}

	var separator:String = " | ";
	var breaks:String = "Breaks";

	public function updateText()
	{
		infoTxt.text = "";
		
		if(simpleInfo) {
			separator = "\n";
		}
		else if(retroStyle) {
			breaks = "Misses";
		}

		infoTxt.text += 			'Score: '		+ Timings.score;
		infoTxt.text += separator + 'Accuracy: '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		infoTxt.text += separator + breaks + ': '		+ Timings.misses;

		if(simpleInfo) {
			infoTxt.x =  160 + 25 + (healthBarBG.x - healthBarBG.width / 2);
			if(!SaveData.data.get("Downscroll"))
				infoTxt.y = FlxG.height - infoTxt.height - 16;
			else
				infoTxt.y = 16;
		}
		else if(retroStyle) {
			infoTxt.screenCenter(X);
			infoTxt.y = (!SaveData.data.get("Downscroll") ? 5 : FlxG.height - infoTxt.height - 5);
			if(SaveData.data.get("Downscroll")) infoTxt.y -= 4;
		}
		else {
			infoTxt.screenCenter(X);
			infoTxt.y = healthBarBG.y + healthBarBG.height + 4;
		}
	}
	
	public function updateTimeTxt(?elapsed:Float)
	{
		var displayedTime:Float = Conductor.songPos;
		if(Conductor.songPos < 0)
			displayedTime = 0;
		if(Conductor.songPos > PlayState.songLength)
			displayedTime = PlayState.songLength;

		if(retroStyle && elapsed != null) {
			timeBar.scale.x = FlxMath.lerp(timeBar.scale.x, (displayedTime / PlayState.songLength), elapsed * 6);
			timeBar.updateHitbox();
		}
		else {
			timeTxt.text
			= CoolUtil.posToTimer(displayedTime)
			+ ' / '
			+ CoolUtil.posToTimer(PlayState.songLength);
			timeTxt.screenCenter(X);
		}
	}

	public function updateHitbox(downscroll:Bool = false)
	{
		healthBarBG.screenCenter(X);

		if(retroStyle) {
			healthBarBG.y = (downscroll ? (0.11*FlxG.height) : (FlxG.height*0.89));
			healthBar.setPosition(healthBarBG.x + 4, healthBarBG.y + 4);
		}
		else {
			healthBarBG.y = (downscroll ? 50 : FlxG.height - healthBarBG.height - 50);
			healthBar.setPosition(healthBarBG.x + 73, healthBarBG.y + 18);
		}

		updateIconPos();
		updateText();
		
		badScoreTxt.y = infoTxt.y + infoTxt.height;
		botplayTxt.screenCenter(X);
		botplayTxt.y = (!downscroll ? 40 + 50 : FlxG.height - 40 - 50);
		updateTimeTxt();
		timeTxt.y = downscroll ? (FlxG.height - timeTxt.height - 8) : (8);
	}
	
	public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0)
	{
		// put the items you want to set invisible when the song starts here
		var allItems:Array<FlxSprite> = [
			infoTxt,
			timeTxt,
			healthBar,
			healthBarBG,
			iconBf,
			iconDad,
			iconCenter
		];

		for(item in allItems)
		{
			if(tweenTime <= 0)
				item.alpha = hudAlpha;
			else
				FlxTween.tween(item, {alpha: hudAlpha}, tweenTime, {ease: FlxEase.cubeOut});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
		if(Math.abs(health - PlayState.health) <= 0.00001 || !smoothBar)
			health = PlayState.health;
		
		healthBar.percent = (health * 50);

		botplayTxt.visible = PlayState.botplay;
		badScoreTxt.visible = !PlayState.validScore;

		if(botplayTxt.visible)
		{
			botplaySin += elapsed * Math.PI;
			botplayTxt.alpha = 0.5 + Math.sin(botplaySin) * 0.8;
		}

		if(retroStyle)
			healthBarBG.angle = healthBar.angle;

		updateIconPos();
		updateTimeTxt(elapsed);
	}

	public function updateIconPos()
	{
		var formatHealth = (2 - health);
		if(invertedIcons)
			formatHealth = health;

		var barX:Float = (healthBar.x + (healthBar.width * (formatHealth) / 2));
		var barY:Float = (healthBarBG.y + healthBarBG.height / 2);

		if(retroStyle) {
			barX = (healthBarBG.x + (healthBarBG.width * (formatHealth) / 2));
		}

		for(icon in [iconDad, iconBf, iconCenter])
		{
			icon.scale.set(
				FlxMath.lerp(icon.scale.x, 1, FlxG.elapsed * 6),
				FlxMath.lerp(icon.scale.y, 1, FlxG.elapsed * 6)
			);
			icon.updateHitbox();

			if(retroStyle) {
				icon.y = barY - icon.height / 2 - 12;
				icon.x = barX;

				if(icon == iconDad)
					icon.x -= icon.width - 24;
				else
					icon.x -= 24;
			}
			else {
				if(icon == iconCenter) {
					icon.y = (healthBarBG.y - iconBf.height/ 2) + (healthBarBG.height/2);
					icon.x = barX - (icon.width/2);
				}
				else if(icon == iconDad) {
					icon.x = (healthBarBG.x - (icon.width/2)) - 25;
					icon.y = (healthBarBG.y - icon.height/ 2) + (healthBarBG.height/2);
				}
				else {
					icon.y = (healthBarBG.y - icon.height/ 2) + (healthBarBG.height/2);
					icon.x = ((healthBarBG.x + healthBarBG.width) - (icon.width/2)) + 25;
				}
			}

			if(invertedIcons) {
				if(icon.isPlayer)
					icon.setAnim(2 - health);
				else
					icon.setAnim(health);
			}
			else {
				if(!icon.isPlayer)
					icon.setAnim(2 - health);
				else
					icon.setAnim(health);
			}
		}

		healthBar.flipX = invertedIcons;
	}

	public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		for(icon in [iconDad, iconBf])
		{
			if(icon.ID == iconID)
				icon.setIcon(newIcon, icon.isPlayer);
		}
		updateIconPos();

		if(invertedIcons) {
			healthBar.createFilledBar(
				HealthIcon.getColor(iconBf.curIcon),
				HealthIcon.getColor(iconDad.curIcon)
			);
		}
		else {
			healthBar.createFilledBar(
				HealthIcon.getColor(iconDad.curIcon),
				HealthIcon.getColor(iconBf.curIcon)
			);
		}

		healthBar.updateBar();
	}

	var angleshit:Int = 2;
	var anglevar:Int = 2;
	var turn:FlxTween;
	public function beatHit(curBeat:Int = 0)
	{
		var iconspeed:Int = 2;
		if(PlayState.beatSpeed <= iconspeed)
			iconspeed = PlayState.beatSpeed;
		if(curBeat % iconspeed == 0)
		{
			for(icon in [iconDad, iconBf, iconCenter])
			{
				icon.scale.set(1.3,1.3);
				icon.updateHitbox();
				updateIconPos();
			}
		}

		if(retroStyle) {
			if(curBeat % 2 == 0)
				angleshit = anglevar;
			else
				angleshit = -anglevar;

			if (turn != null)
				turn.cancel();

			healthBar.angle = angleshit*0.05;
			turn = FlxTween.tween(healthBar, {angle: angleshit}, Conductor.stepCrochet*0.0005, {ease: FlxEase.circOut});
		}
	}
}