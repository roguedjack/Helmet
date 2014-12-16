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
		
	static inline var DATA_FILE = "data.json";
		
	public static function load() {
		var content = Resource.getString(DATA_FILE);
		if (content == null) {
			throw "could not read data file";
		}
		var json = Json.parse(content);
		
		// Projectiles
		ArrowProjectile = json.Projectiles[0];
		AxeProjectile = json.Projectiles[1];
		FireballProjectile = json.Projectiles[2];
		SwordProjectile = json.Projectiles[3];
		DemonShotProjectile = json.Projectiles[4];
		/*
		trace(ArrowProjectile);
		trace(AxeProjectile);
		trace(FireballProjectile);
		trace(SwordProjectile);
		trace(DemonShotProjectile);
		*/
		
		// Characters
		WarriorCharacter = json.Characters[0];
		ValkyrieCharacter = json.Characters[1];
		ElfCharacter = json.Characters[2];
		WizardCharacter = json.Characters[3];
		/*
		trace(WarriorCharacter);
		trace(ValkyrieCharacter);
		trace(ElfCharacter);
		trace(WizardCharacter);
		*/
	}
}




