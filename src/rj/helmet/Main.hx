package rj.helmet;
import flash.net.FileReference;
import h2d.Text;
import haxe.Resource;
import hxd.App;
import hxd.BitmapData;
import hxd.Key;
import hxd.Res;
import hxd.res.FontBuilder;
import hxd.res.TiledMap;
import hxd.Timer;
import rj.helmet.dat.GameData;
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
	public static var Instance:Main;
		
	public var world(default, null):World;	
	public var view(default, default):View;
	public var screen(default, set):Screen;
	public var introScreen(default,null):TitleScreen;
	public var playScreen(default, null):PlayScreen;
	public var currentMap(get, never):TiledMap;
	public var playerSaveData(default, null):PlayerSaveData;

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
		return mapCycle[playerSaveData.level];
	}
	
	override function init() {
		Instance = this;
		
		GameData.load();
				
		s2d.setFixedSize(WIDTH, HEIGHT);
		engine.backgroundColor = 0xFF101010;
		
		Gfx.init();
		PlayerActor.initCharacterClasses();
		
		mapCycle = [ Res.levels.selectCharacter, Res.levels.level1 ];
		
		world = new World(this);
		view = null;
		
		introScreen = new TitleScreen(this);
		playScreen = new PlayScreen(this);
		screen = introScreen;
	}	
	
	override function update(dt:Float) {
		#if debug
		// screenshot
		if (Key.isPressed(Key.F1)) {
			var bmp = new BitmapData(Main.WIDTH, Main.HEIGHT);
			engine.setCapture(bmp, function():Void {
				var png = bmp.toPNG();
				var file = new FileReference();
				file.save(png.getData(), "screenshot.png");
				bmp.dispose();
			});
		}
		#end
		
		// update screen
		screen.update(dt * TARGET_FRAME_TIME); 
		
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
		playerSaveData = new PlayerSaveData(cl);
		screen = playScreen;		
		startLevel(0);
	}
	
	public function selectNewCharacterClass(cl:CharacterClass) {
		playerSaveData = new PlayerSaveData(cl);
		world.player.remove();
		world.spawnEntity(new PlayerActor(playerSaveData), world.player.pos.x, world.player.pos.y);		
	}
	
	public function startNextLevel() {
		startLevel(playerSaveData.level + 1);
	}
	
	public function startLevel(i:Int) {
		if (world.player != null) {
			playerSaveData.takeSnapshot(world.player);
		}
		playerSaveData.level = i % mapCycle.length;
		world.loadMap(mapCycle[playerSaveData.level]);
		playScreen.onNewLevel();		
	}
	
	static function main() {
		Res.initEmbed();
		Key.initialize();
		new Main();
	}
	
}