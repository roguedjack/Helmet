package rj.helmet.dat;
import haxe.Json;
import haxe.Resource;
import h2d.Tile;

class GameData {
	
	public static var ArrowProjectile:Dynamic;
	public static var AxeProjectile:Dynamic;
	public static var FireballProjectile:Dynamic;
	public static var SwordProjectile:Dynamic;
	public static var DemonShotProjectile:Dynamic;
	
	public static var WarriorCharacter:Dynamic;
	public static var ValkyrieCharacter:Dynamic;	
	public static var ElfCharacter:Dynamic;
	public static var WizardCharacter:Dynamic;
	
	public static var HealthItem:Dynamic;
	public static var KeyItem:Dynamic;
	public static var TreasureItem:Dynamic;
	public static var SpeedBonus:Dynamic;
	
	public static var GhostMonster:Dynamic;
	public static var DemonMonster:Dynamic;
	
	public static var GhostGenerator:Dynamic;
	public static var DemonGenerator:Dynamic;
	
	public static var MovingWall:Dynamic;
	public static var DestructibleWall:Dynamic;
		
	static inline var DATA_FILE = "data.json";
	
	private static function findById(dataArray:Iterable<Dynamic>, id:String, mustFind:Bool = true) {		
		for (d in dataArray) {
			if (d.id == id) {
				return d;
			}
		}
		if (mustFind) {
			throw "could not find data with id " + id;
		}
		return null;
	}
		
	public static function load() {
		var content = Resource.getString(DATA_FILE);
		if (content == null) {
			throw "could not read data file";
		}
		var json = Json.parse(content);
		
		// Projectiles
		ArrowProjectile = findById(json.Projectiles, "ArrowProjectile"); 
		AxeProjectile = findById(json.Projectiles, "AxeProjectile"); 
		FireballProjectile = findById(json.Projectiles, "FireballProjectile"); 
		SwordProjectile = findById(json.Projectiles, "SwordProjectile"); 
		DemonShotProjectile = findById(json.Projectiles, "DemonShotProjectile"); 
		
		// Characters
		WarriorCharacter = findById(json.Characters, "WarriorCharacter");
		ValkyrieCharacter = findById(json.Characters, "ValkyrieCharacter");
		ElfCharacter = findById(json.Characters, "ElfCharacter");
		WizardCharacter = findById(json.Characters, "WizardCharacter");

		
		// Items
		HealthItem = findById(json.Items, "HealthItem");
		KeyItem = findById(json.Items, "KeyItem");
		TreasureItem = findById(json.Items, "TreasureItem");
		SpeedBonus = findById(json.Items, "SpeedBonus");
		
		// Monsters
		GhostMonster = findById(json.Monsters, "GhostMonster");
		DemonMonster = findById(json.Monsters, "DemonMonster");
		
		// Generators
		GhostGenerator = findById(json.Generators, "GhostGenerator");
		DemonGenerator = findById(json.Generators, "DemonGenerator");
		
		// Traps
		MovingWall = findById(json.Traps, "MovingWall");
		DestructibleWall = findById(json.Traps, "DestructibleWall");		
	}
	
	public static function parseEntityFrames(framesData:Array<Int>) : Array<Tile> {
		if (framesData == null) {
			trace("parseFrames : null frames data");
		}
		var frames = new Array<Tile>();
		for (gfx in framesData) {
			frames.push(Gfx.entities[gfx]);
		}
		return frames;
	}
	
	public static function parseMonsterClassAi(aiData) : {  idle:MonsterAIState, path:MonsterAIState, move:MonsterAIState } {
		var idle:Dynamic = Type.createInstance(Type.resolveClass("rj.helmet.ai.AiState" + aiData.idle.script), [aiData.idle.time]);		
		var path:Dynamic = Type.createInstance(Type.resolveClass("rj.helmet.ai.AiState" + aiData.path.script), []);		
		var move:Dynamic = Type.createInstance(Type.resolveClass("rj.helmet.ai.AiState" + aiData.move.script), [aiData.move.time]);
		// FIXME --- uggly magic.
		idle.link(path);
		path.link(idle, move);
		move.link(idle, path);
		return { idle:idle, path:path, move:move };		
	}
}