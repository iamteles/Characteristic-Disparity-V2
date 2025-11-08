package;

import data.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;
import data.FPSCounter;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import openfl.Lib;

using StringTools;

class Main extends Sprite
{
	public static var fpsVar:FPSCounter;
	public static var activeState:FlxState;
	public function new() {
	
		super();
		#if desktop
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		var ws:Array<String> = SaveData.displaySettings.get("Resolution")[0].split("x");
		var windowSize:Array<Int> = [Std.parseInt(ws[0]),Std.parseInt(ws[1])];
		addChild(new FlxGame(windowSize[0], windowSize[1], Init, 120, 120, true));

		#if desktop
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		#end
	}
	public static var gFont:String = Paths.font("matsaleh.ttf");
	public static var dsFont:String = Paths.font("ds.ttf");
	
	public static var skipClearMemory:Bool = false; // dont
	public static var skipTrans:Bool = true; // starts on but it turns false inside Init
	public static function switchState(?target:FlxState):Void
	{
		var trans = new GameTransition(false);
		trans.finishCallback = function()
		{
			if(target != null)		
				FlxG.switchState(target);
			else
				FlxG.resetState();
		};

		if(skipTrans)
		{
			return trans.finishCallback();
		}
		
		//FlxG.state.openSubState(trans);
		if(activeState != null)
			activeState.openSubState(trans);
	}

	// so you dont have to type it every time
	public static function skipStuff(?ohreally:Bool = true):Void
	{
		skipClearMemory = ohreally;
		skipTrans = ohreally;
	}

	public static function changeFramerate(rawFps:Float = 120)
	{
		var newFps:Int = Math.floor(rawFps);

		if(newFps > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFps;
			FlxG.drawFramerate   = newFps;
		}
		else
		{
			FlxG.drawFramerate   = newFps;
			FlxG.updateFramerate = newFps;
		}
	}

	public static var curTitle:Array<String> = ["main", "overTheHorizon"];
	public static var titles:Map<String, Array<String>> = [
		"HORIZON" => ["main", "overTheHorizon", "free"],
		"THUNDER" => ["bree", "overTheHorizonBree", "week2"],
		"COUNTER" => ["watts", "shopkeeper", "shopentrance"],
		"CLOUDS" => ["helica", "overTheHorizonHelica", "sin"],
		"BEAKER" => ["nila", "overTheHorizonNila", "free"],
		"CLOUDS-OLD" => ["helica", "overTheHorizonHelica-old", "sin"],
		"V1" => ["retro", "speaker", "free"],
	];
	
	public static function setMouse(visibility:Bool = false)
	{
		FlxG.mouse.visible = visibility;
	}

	public static function randomizeTitle()
	{
		if(SaveData.data.get("Menu Style") == "RANDOMIZE") {
			var temp:Array<Array<String>> = [titles.get("HORIZON")];

			for(style in ["THUNDER", "COUNTER", "CLOUDS"])
				if(titles.get(style)[2] == "free" || SaveData.progression.get(titles.get(style)[2]))
					temp.push(titles.get(style));

			curTitle = temp[FlxG.random.int(0, temp.length-1)];
		}
		else {
			var eyup:String = SaveData.data.get("Menu Style").toUpperCase();
			trace(eyup);
			if(titles.get(eyup)[2] == "free" || SaveData.progression.get(titles.get(eyup)[2]))
				curTitle = titles.get(eyup);
			else
				curTitle = titles.get("HORIZON");
		}
	}

	#if desktop
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "CD_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "Uncaught Error: " + e.error + "\nPlease report this error to the developers! Crash Handler written by: sqirra-rng";

		if (!sys.FileSystem.exists("./crash/"))
			sys.FileSystem.createDirectory("./crash/");

		sys.io.File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
	#end
}