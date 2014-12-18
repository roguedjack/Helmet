package rj.helmet.dat;
import haxe.Json;
import haxe.Resource;

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
		/*
		trace(ArrowProjectile);
		trace(AxeProjectile);
		trace(FireballProjectile);
		trace(SwordProjectile);
		trace(DemonShotProjectile);
		*/
		
		// Characters
		WarriorCharacter = findById(json.Characters, "WarriorCharacter");
		ValkyrieCharacter = findById(json.Characters, "ValkyrieCharacter");
		ElfCharacter = findById(json.Characters, "ElfCharacter");
		WizardCharacter = findById(json.Characters, "WizardCharacter");
		/*
		trace(WarriorCharacter);
		trace(ValkyrieCharacter);
		trace(ElfCharacter);
		trace(WizardCharacter);
		*/
		
		// Items
		HealthItem = findById(json.Items, "HealthItem");
		KeyItem = findById(json.Items, "KeyItem");
		TreasureItem = findById(json.Items, "TreasureItem");
		/*
		trace(HealthItem);
		trace(KeyItem);
		trace(TreasureItem);
		*/
	}
}