package rj.helmet;
import h2d.Text;
import hxd.App;
import hxd.Key;
import hxd.Res;
import hxd.res.FontBuilder;
import hxd.res.TiledMap;
import rj.helmet.entities.PlayerActor;
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
	public static inline var TILED_ENTITIES_LAYER_NAME = "entities";
	public static inline var TILEDOBJ_EXIT = "exit";
	public static inline var TILEDOBJ_START = "start";
	public static inline var TILEDOBJ_GEN_GHOST = "gen_ghost";
	public static inline var TILEDOBJ_HDOOR = "hdoor";
	public static inline var TILEDOBJ_VDOOR = "vdoor";
	public static inline var TILEDOBJ_KEY = "key";
	public static inline var TILEDOBJ_TREASURE = "treasure";
	public static inline var TILEDOBJ_HEALTH = "health";
	
	public static var Instance:Main;
		
	public var world(default,null):World;
	public var view(default, default):View;
	public var screen(default, set):Screen;
	public var introScreen(default,null):TitleScreen;
	public var playScreen(default, null):PlayScreen;
	public var currentMap(get, never):TiledMap;
	public var playerData(default, null):PlayerData;

	static inline var TARGET_FRAME_TIME = 1.0 / 60.0;
	
	static inline var DEBUG_INFO = true;
	var debugText:Text;
	
	var mapCycle:Array<TiledMap>;
	
	function set_screen(s:Screen) {
		if (screen != null) {
			screen.onLeave();
		}
		screen = s;
		screen.onEnter();
		return screen;
	}
	
	function get_currentMap() {
		return mapCycle[playerData.level];
	}
	
	override function init() {
		Instance = this;
		
		s2d.setFixedSize(WIDTH, HEIGHT);
		engine.backgroundColor = 0x101010;
		
		Gfx.init();
		PlayerActor.initCharacterClasses();
		
		mapCycle = [ Res.levels.level0, Res.levels.level1 ];
		
		world = new World(this);
		view = null;
		
		introScreen = new TitleScreen(this);
		playScreen = new PlayScreen(this);
		screen = introScreen;
	}	
	
	override function update(dt:Float) {
		// using dt instead of raw fps, if I understood it correctly it does some smoothing and lag check.
		screen.update(dt * TARGET_FRAME_TIME); // raw fps --- screen.update(1.0 / engine.fps);
		
		if (DEBUG_INFO) {
			if (debugText == null) {
				debugText = new Text(FontBuilder.getFont("arial", 10));				
				debugText.textAlign = Align.Right;				
				debugText.setPos(s2d.width - 125, 0);
				s2d.addChildAt(debugText, 10);
			}
			var rounded_dt = Math.fround(100 * dt) / 100.0;
			debugText.text = 'ents:${world.countEntities} fps:${Std.int(engine.fps)} dt:$rounded_dt';
		}
	}
	
	public function startNewGame(cl:CharacterClass) {
		playerData = new PlayerData(cl);
		screen = playScreen;		
		startLevel(0);
	}
	
	public function startNextLevel() {
		startLevel(playerData.level + 1);
	}
	
	public function startLevel(i:Int) {
		if (world.player != null) {
			playerData.takeSnapshot(world.player);
			playerData.nbKeys = 0;  // remove all keys but not other bonuses
		}
		playerData.level = i % mapCycle.length;
		world.loadMap(mapCycle[playerData.level]);
		playScreen.onNewLevel();		
	}
	
	static function main() {
		Res.initEmbed();
		Key.initialize();
		new Main();
	}
	
}