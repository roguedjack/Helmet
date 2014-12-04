package rj.helmet;
import h2d.Text;
import hxd.App;
import hxd.Key;
import hxd.Res;
import hxd.res.FontBuilder;
import rj.helmet.screens.TitleScreen;
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
	public static inline var TILED_FLOOR_LAYER_NAME = "floor";
	public static inline var TILED_WALLS_LAYER_NAME = "walls";
	
	public static var Instance:Main;
		
	public var world(default,null):World;
	public var view(default, default):View;
	public var screen(default, set):Screen;
	public var introScreen(default,null):TitleScreen;
	public var playScreen(default, null):PlayScreen;
	
	static inline var DEBUG_FPS = true;
	var fpsText:Text;
	
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
		
		introScreen = new TitleScreen(this);
		playScreen = new PlayScreen(this);
		screen = introScreen;
		
		// TEST
		world.loadLevel(Res.levels.level0);		
	}
	
	override function update(dt:Float) {
		screen.update(1.0 / engine.fps);
		if (DEBUG_FPS) {
			if (fpsText == null) {
				fpsText = new Text(FontBuilder.getFont("arial", 10), s2d);				
				fpsText.setPos(s2d.width - 50, 0);
			}
			fpsText.text = 'fps:${Std.int(engine.fps)}';
		}
	}
	
	static function main() {
		Res.initEmbed();
		Key.initialize();
		new Main();
	}
	
}