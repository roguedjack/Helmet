package rj.helmet;
import hxd.App;
import hxd.Key;
import hxd.Res;
import rj.helmet.screens.IntroScreen;
import rj.helmet.screens.PlayScreen;


/**
 * ...
 * @author roguedjack
 */

class Main extends App {	
	
	public static inline var WIDTH = 800;
	public static inline var HEIGHT = 600;
	public static inline var VERSION = "0.1";
	public static inline var TILE_SIZE = 32;
	public static inline var TILE_SHEET_COLUMNS = 8;
	public static inline var TILE_SHEET_ROWS = 8;
	public static inline var TILED_TILE_LAYER_NAME = "tiles";
	
	public static var Instance:Main;
		
	public var world(default,null):World;
	public var view(default, default):View;
	public var screen(default, set):Screen;
	public var introScreen(default,null):IntroScreen;
	public var playScreen(default,null):PlayScreen;
	
	function set_screen(s:Screen) {
		if (s == screen) {
			return s;
		}
		if (screen != null) {
			screen.onLeave();
		}
		screen = s;
		screen.onEnter();
		return screen;
	}
	
	override function init() {
		Instance = this;
		
		s2d.setFixedSize(WIDTH, HEIGHT);
		engine.backgroundColor = 0x101010;
		
		world = new World(this);
		view = null;
		
		introScreen = new IntroScreen(this);
		playScreen = new PlayScreen(this);
		screen = introScreen;
		
		// TEST
		world.loadLevel(Res.levels.level0);		
	}
	
	override function update(dt:Float) {
		screen.update(1.0 / engine.fps);
	}
	
	static function main() {
		Res.initEmbed();
		Key.initialize();
		new Main();
	}
	
}