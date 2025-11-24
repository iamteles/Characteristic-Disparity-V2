package states.cd;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import data.GameData.MusicBeatState;
import data.Discord.DiscordIO;

#if MUNCH
import states.cd.Munch;
#end

class Gallery extends MusicBeatState
{
	public var curSelected:Int = 0;
	public var menuItems:FlxTypedGroup<GalleryImg>;

	var zoomAmmount:Int = 100;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var itemScale:Float = 1;

	var descText:FlxText;
	var descTextTwo:FlxText;
    var bg:FlxSprite;
	var banana:FlxSprite;
	var textsGrp:FlxTypedGroup<FlxText>;

	public static var curCat:String = "main";
	var ctrlHidden:Bool = false;

    var items:Map<String, Array<Array<String>>> = [
		"main" => [
			["menu/gallery/main/" + "fanart", "fanart", ""],
			//["menu/gallery/main/" + "videos", "videos", ""],
			//["menu/gallery/main/" + "fanart", "fanart", ""],
		],
		"fanart" => [
			["menu/gallery/fanart/" + "daiseydraws", "", "@daiseydraws on Instagram"],
			["menu/gallery/fanart/" + "sammy_jiru", "", "@sammy_jiru on Instagram"],
			["menu/gallery/fanart/" + "Pankiepoo", "", "@Pankiepoo on Twitter"],
			["menu/gallery/fanart/" + "Spamtune", "", "@thesound_crows (Spamtune) on Twitter"],
			["menu/gallery/fanart/" + "OOBO3310", "", "@OOBO3310 on Twitter"],
			["menu/gallery/fanart/" + "duster", "", "@SirDusterBuster on Twitter"],
			["menu/gallery/fanart/" + "softbluelily", "", "@Softbluelily on Twitter"],
			["menu/gallery/fanart/" + "dp2007", "", "@DDP2007 on Discord"],
			["menu/gallery/fanart/" + "ohsnap_jack", "", "@ohsnap_jack on Twitter"],
			["menu/gallery/fanart/" + "skydimensions", "", "SkyDimensions on Newgrounds"],
			["menu/gallery/fanart/" + "curesupremefan", "", "@Curesupremefan on Twitter"],
			["menu/gallery/fanart/" + "teeeeeeeee_jay", "", "@teeeeeeeee_jay on Twitter"],
			["menu/gallery/fanart/" + "lukasp", "", "@_lukasp on Discord"],
		],
		"concepts" => [
			// v1
			["menu/gallery/official/v1/" + "first_jam_idea", "First Jam Idea", "v1"],
			["menu/gallery/official/v1/" + "first_designs", "First Designs", "v1"],
			["menu/gallery/official/v1/" + "used_designs", "Finalized Designs", "v1"],
			["menu/gallery/official/v1/" + "gb-promo", "Promo Art", "v1"],
			["menu/gallery/official/v1/" + "divergence", "Achievement", "v1"],
			["menu/gallery/official/v1/" + "lovey_dovey", "Lovey Dovey", "v1"],
			["menu/gallery/official/v1/" + "note", "Note", "v1"],
			["menu/gallery/official/v1/" + "v1_cover_spotify", "OST Cover (Spotify)", "v1"],
			["menu/gallery/official/v1/" + "v1_cover_tpt", "OST Cover (TPT / Bandcamp)", "v1"],
			["menu/gallery/official/v1/" + "cd_back_art", "OST Back (TPT / Bandcamp)", "v1"],
			["menu/gallery/official/v1/" + "ost_insert", "Jewel Case Insert", "v1"],

			//v2 early
			["menu/gallery/official/v2_late22-early23/" + "good_for_them", "Good For Them (Heartpounder)", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "first_redesigns", "BxB First Redesign", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bxb_refs", "BxB References", "v2 (Early)"],
			["menu/gallery/official/v2_23/" + "second_redesigns", "Second Redesign", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bree_first_design", "Bree First Design", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bree_key_art", "Bree Key Art", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bree_second_design", "Bree Second Design", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bree_second_god", "Bree Second Design", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "bree_wallpaper", "Bree Wallpaper", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "love_runs", "Love Runs", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "violence", "Violence", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "heh", "heh", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "cute_bella", "Cute Bella", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "derp", ":P", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "neko_nyaa", "nya", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "proud_daughter", "Proud Daughter", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "xmas", "A Shatterdisk Christmas", "v2 (Early)"],
			["menu/gallery/official/v2_late22-early23/" + "fnf_style_bella", "FNF Style Bella", "v2 (Early)"],

			//v2 designs
			["menu/gallery/official/v2_late22-early23/" + "bxb_final", "Final Redesigns", "v2"],
			["menu/gallery/official/v2_23/" + "bree_third_design", "Bree Third Design", "v2"],
			["menu/gallery/official/v2_late22-early23/" + "watts_first_design", "Watts First Design", "v2"],
			["menu/gallery/official/v2_23/" + "nyana_old_nila", "Nyana 1 (Old Nila)", "v2"],
			["menu/gallery/official/v2_23/" + "nyana_second_old_nila", "Nyana 2 (Old Nila)", "v2"],
			["menu/gallery/official/v2_23/" + "helica_concept", "Helica Concept", "v2"],
			["menu/gallery/official/v2_23/" + "helica_ft_abi", "Helica Redesign (Ft. Abi)", "v2"],
			["menu/gallery/official/v2_23/" + "early_vip_bella", "Early Bella VIP", "v2"],
			["menu/gallery/official/v2_23/" + "early_vip_bex", "Early Bex VIP", "v2"],
			["menu/gallery/official/v2_23/" + "second_vip_designs", "Second VIP Designs", "v2"],
			["menu/gallery/official/v2_23/" + "bree_vip", "Bree VIP", "v2"],
			["menu/gallery/official/v2_23/" + "spicy_sketch", "Spicy Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "spicy_ref", "Spicy (Ref)", "v2"],
			["menu/gallery/official/v2_23/" + "drown_ref", "Drown", "v2"],
			["menu/gallery/official/v2_23/" + "wave_empitri_ref", "Wave and Empitri", "v2"],
			["menu/gallery/official/v2_23/" + "lesser_gods", "Lesser Gods", "v2"],
			["menu/gallery/official/v2_23/" + "love_wins", "Love Wins Power", "v2"],

			//v2 (mod concepts)
			["menu/gallery/official/v2_23/" + "skeletons", "Game Over Idea", "v2"],
			["menu/gallery/official/v2_23/" + "early_songs", "Early Songs", "v2"],
			["menu/gallery/official/v2_23/" + "early_songs_2", "Early Songs", "v2"],
			["menu/gallery/official/v2_23/" + "watts_shop_concept1", "Watts Shop Concept", "v2"],
			["menu/gallery/official/v2_23/" + "watts_shop_concept2", "Watts Shop Concept", "v2"],
			["menu/gallery/official/v2_23/" + "hud_ideas", "Hud Ideas", "v2"],
			["menu/gallery/official/v2_23/" + "early_logos", "Early Logos", "v2"],
			["menu/gallery/official/v2_23/" + "bree_sketch", "Bree Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "convergence_concepts", "Convergence Concepts", "v2"],
			["menu/gallery/official/v2_23/" + "desertion_concept", "Desertion Concept", "v2"],
			["menu/gallery/official/v2_23/" + "desertion_sketches", "Desertion Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "early_hud", "Early Gameplay", "v2"],
			["menu/gallery/official/v2_23/" + "early_hud2", "Early Gameplay", "v2"],
			["menu/gallery/official/v2_23/" + "gamejolt", "Scrapped Gamejolt Login Screen", "v2"],
			["menu/gallery/official/v2_23/" + "week1_sketch", "Week 1 Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "helica_concept_sprite", "Helica Early Sprite", "v2"],
			["menu/gallery/official/v2_23/" + "helica_sin_background", "Sin Early Background", "v2"],
			["menu/gallery/official/v2_23/" + "sin_bg_sketch", "Sin BG Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "intimidate_scrapped_1", "Scrapped Intimidate Section", "v2"],
			["menu/gallery/official/v2_23/" + "intimidate_scrapped_2", "Scrapped Intimidate Section", "v2"],
			["menu/gallery/official/v2_23/" + "intimidate_sketch", "Intimidate Sketch", "v2"],
			["menu/gallery/official/v2_23/" + "teles_concept", "Shop UI Concept", "v2"],
			["menu/gallery/official/v2_23/" + "good_for_them2", "Good for Them (Heartpounder)", "v2"],
			["menu/gallery/official/v2_23/" + "kaboom_breetar", "Bree's Guitar", "v2"],
			["menu/gallery/official/v2_23/" + "spicy_render_old", "Scrapped Spicy Render", "v2"],
			["menu/gallery/official/v2_23/" + "menu_concepts", "Menu Concepts", "v2"],
			["menu/gallery/official/v2_23/" + "freeplay_old", "Old Freeplay", "v2"],
			["menu/gallery/official/v2_23/" + "freeplay_categories", "Freeplay Categories", "v2"],

			//v2 release
			["menu/gallery/official/v2_23/" + "dev_update", "Development Update", "v2"],
			["menu/gallery/official/v2_23/" + "twitter_post", "Sketches", "v2"],
			["menu/gallery/official/v2_23/" + "logo", "Logo", "v2"],
			["menu/gallery/official/v2_23/" + "icon", "Game Icon", "v2"],
			["menu/gallery/official/v2_23/" + "release_date", "Release Date Announcement", "v2"],
			["menu/gallery/official/v2_23/" + "promo_v2", "Promo Art", "v2"],
			["menu/gallery/official/v2_23/" + "sam", "Bex's Friend Sam", "v2"],

			//v2 fun
			["menu/gallery/official/v2_late22-early23/" + "smoke_blank_everyday", "smoke WHAT?", "v2"],
			["menu/gallery/official/v2_late22-early23/" + "single_fish", "master chef", "v2"],
			["menu/gallery/official/v2_late22-early23/" + "style-swap", "Style Swap", "v2"],
			["menu/gallery/official/v2_23/" + "bella_aurora", "Bella (Aurora)", "v2"],
			["menu/gallery/official/v2_23/" + "cutes", "Cutes", "v2"],
			["menu/gallery/official/v2_23/" + "expressions", "Expressions", "v2"],
			["menu/gallery/official/v2_23/" + "love_punches", "Love Punches", "v2"],
			["menu/gallery/official/v2_23/" + "outfit_swap", "Outfit Swap", "v2"],
			["menu/gallery/official/v2_23/" + "quieres", "quieres?", "v2"],
			["menu/gallery/official/v2_23/" + "rage", "Rage", "v2"],
			["menu/gallery/official/v2_23/" + "younger_designs", "CD Kids", "v2"],

			//post v2
			["menu/gallery/official/post_v2/" + "cool_style", "Love Wins", "Post V2"],
			["menu/gallery/official/post_v2/" + "mods_in_cd_style", "Mods in CD Style", "Post V2"],
			["menu/gallery/official/post_v2/" + "bella_final", "Bella Final Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "bex_final", "Bex Final Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "bree_final", "Bree Final Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "watts_final", "Watts Final Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "nila_final", "Nila Outdated Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "helica_final", "Helica Final Design", "Post V2"],
			["menu/gallery/official/post_v2/" + "vip_drown", "Drown VIP", "Post V2"],
			["menu/gallery/official/post_v2/" + "jp_logo", "Tokuchou no Chigai", "Post V2"], //とくちょうの違い
			["menu/gallery/official/post_v2/" + "alt_bree", "Alt Bree (Human)", "Post V2"],
			["menu/gallery/official/post_v2/" + "alt_bex", "Alt Bex", "Post V2"],
			["menu/gallery/official/post_v2/" + "alt_shop", "Alt Watts and Nila", "Post V2"],

			//plus
			["menu/gallery/official/plus/" + "promo", "Promo Art (WIP)", "CD+"],
			["menu/gallery/official/plus/" + "cd_promo_art", "Promo Art", "CD+"],
			["menu/gallery/official/plus/" + "reveal", "Update Reveal", "CD+"],
			["menu/gallery/official/plus/" + "cdp_us", "Release Date Reveal", "CD+"],
			["menu/gallery/official/plus/" + "voltwo", "OST Cover (Volume 2)", "CD+"],
			["menu/gallery/official/plus/" + "iconOG", "Game Icon", "CD+"],
			["menu/gallery/official/plus/" + "smooch", "Minigame Sketches", "CD+"],
		]
    ];
	public override function create()
	{
		super.create();
		menuItems = new FlxTypedGroup<GalleryImg>();

		Main.setMouse(false);
		DiscordIO.changePresence("In the Gallery", null);
		CoolUtil.playMusic("gallery");

        bg = new FlxSprite().loadGraphic(Paths.image('menu/gallery/bg'));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		if(SaveData.shop.get("galleryp"))
			items.get("main").push(["menu/gallery/main/" + "concepts", "concepts", ""]);
		else
			items.get("main").push(["menu/gallery/main/" + "concepts-locked", "", ""]);

		for(i in 0...items.get(curCat).length)
		{
			var item:GalleryImg = new GalleryImg(items.get(curCat)[i][0], curCat == "main");
			item.screenCenter(X);
			item.screenCenter(Y);
			item.x = ((FlxG.width/2) - (item.width/2)) + ((0 - i)*-900);
			menuItems.add(item);
			if(curCat == "main")
				itemScale = 1.3;

			if(i != 0)
				item.alpha = 0;

			item.ID = i;
		}

		add(menuItems);

        leftArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		rightArrow = new FlxSprite().loadGraphic(Paths.image("menu/gallery/arrow"));
		rightArrow.flipX = true;
		leftArrow.scale.set(0.7, 0.7);
		rightArrow.scale.set(0.7, 0.7);
		leftArrow.updateHitbox();
		rightArrow.updateHitbox();
        leftArrow.screenCenter(Y);
        rightArrow.screenCenter(Y);
        rightArrow.x = FlxG.width - rightArrow.width;
		//leftArrow.alpha = 0.7;
		//rightArrow.alpha = 0.7;
		add(leftArrow);
		add(rightArrow);

		descText = new FlxText(50, 610, 1180, "", 32);
		descText.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		descTextTwo = new FlxText(50, 640, 1180, "", 32);
		descTextTwo.setFormat(Main.gFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descTextTwo.scrollFactor.set();
		descTextTwo.borderSize = 2.4;
		add(descTextTwo);

		var textArray:Array<String> = [
            'DPad - Scroll',
            'L/R or Q/E - Zoom In/Out',
            'X - Reset Size',
            'Y - Hide Controls',
            'BACK - Exit'
		];

		textsGrp = new FlxTypedGroup<FlxText>();

		var width:Int = 0;
        var height:Int = 0;

		for(i in 0...textArray.length)
		{
			if(textArray[i] == "") continue;
		
			var text = new FlxText(0,0,0,textArray[i]);
			text.setFormat(Main.gFont, 30, 0xFFFFFFFF, RIGHT);
			text.setPosition(25, FlxG.height - (text.height*(textArray.length - i)) - 15);
            text.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
			textsGrp.add(text);

            if(text.width > width)
                width = Std.int(text.width);

            height += Std.int(text.height);
		}

		banana = new FlxSprite().makeGraphic(width + 10, height + 10, 0xFF000000);
        banana.setPosition(20, FlxG.height - height - 20);
		add(banana);
		add(textsGrp);

		banana.alpha = 0.4;

		if(curCat == "main") {
			ctrlHidden = true;
			
			banana.alpha = 0;
			for(text in textsGrp) {
				text.alpha = 0;
			}
		}
		
		changeItem(0);
	}
	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		leftArrow.x = FlxMath.lerp(leftArrow.x, 0, elapsed*6);
		rightArrow.x = FlxMath.lerp(rightArrow.x, FlxG.width - rightArrow.width, elapsed*6);

        if(Controls.justPressed("UI_LEFT")) {
			changeItem(-1);
			leftArrow.x -= 8;
		}
		if(Controls.justPressed("UI_RIGHT")) {
			changeItem(1);
			rightArrow.x += 8;
		}

        if(Controls.justPressed("BACK"))
        {
			if(curCat == "main") {
				FlxG.sound.play(Paths.sound('menu/back'));
				Main.switchState(new states.cd.MainMenu());
			}
			else {
				FlxG.sound.play(Paths.sound('menu/back'));
				curCat = "main";
				Main.switchState();
			}
        }

		if(curCat != "main") {
			if (Controls.justPressed("BOTPLAY")) {
				itemScale = 1;
			}

			if(Controls.justPressed("LOOP")) {
				if(!ctrlHidden) {
					banana.alpha = 0;
					for(text in textsGrp) {
						text.alpha = 0;
					}
				}
				else {
					banana.alpha = 0.4;
					for(text in textsGrp) {
						text.alpha = 1;
					}
				}

				ctrlHidden = !ctrlHidden;
			}
			
			if (Controls.pressed("R_SPECIAL") && itemScale < 3) {
				itemScale += elapsed * itemScale;
				if(itemScale > 3) itemScale = 3;
			}
			if (Controls.pressed("L_SPECIAL") && itemScale > 0.1) {
				itemScale -= elapsed * itemScale;
				if(itemScale < 0.1) itemScale = 0.1;
			}
		}

		if(Controls.justPressed("ACCEPT") && curCat == "main") {
			if(items.get(curCat)[curSelected][1] == "") {
				FlxG.camera.shake(0.005, 0.1, null, true, XY);
				FlxG.sound.play(Paths.sound('menu/locked'));
			}
			else {
				FlxG.sound.play(Paths.sound('menu/select'));
				curCat = items.get(curCat)[curSelected][1];
				Main.switchState();
			}

		}

		menuItems.forEach(function(item:GalleryImg)
		{
			item.x = FlxMath.lerp(item.x, ((FlxG.width/2) - (item.width/2)) + ((curSelected - item.ID)*-900), elapsed*6);
			if(item.ID == curSelected)
			{
				item.alpha = FlxMath.lerp(item.alpha, 1, elapsed*12);
				item.itemScale = itemScale;
				//item.setGraphicSize(Std.int(item.width * itemScale));
			}
			else
				item.alpha = FlxMath.lerp(item.alpha, 0, elapsed*12);
		});
	}
	function changeItem(val:Int = 0)
	{
		curSelected += val;
        curSelected = FlxMath.wrap(curSelected, 0, items.get(curCat).length - 1);

        if(val != 0)
            FlxG.sound.play(Paths.sound("menu/scroll"));

		if(curCat != "main") {
			descText.text = items.get(curCat)[curSelected][1];
			descTextTwo.text = items.get(curCat)[curSelected][2];
		}
		itemScale = 1;
	}
}

class GalleryImg extends FlxSprite
{
	public var itemScale:Float = 1;
	var internalScale:Float = 1;

	public function new(image:String, manualScale:Bool = false) {
		super();
		loadGraphic(Paths.image(image));
		updateHitbox();

		if(!manualScale) {
			var internalWidth = 1000/width;
			var internalHeight = 600/height;

			if(internalWidth < internalHeight)
				internalScale = internalWidth;
			else
				internalScale = internalHeight;
		}
	}

	override function update(elapsed:Float)
	{
		scale.set(itemScale * internalScale, itemScale * internalScale);
	}
}