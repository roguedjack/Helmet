package rj.helmet;
import rj.helmet.entities.PlayerActor;
import rj.helmet.entities.PlayerActor.CharacterClass;

/**
 * ...
 * @author roguedjack
 */
class PlayerData {

	public var characterClass(default,null):CharacterClass;	
	public var level:Int;
	public var health:Int;
	public var speed:Float;
	public var weaponCooldown:Float;
	public var meleeDamage:Int;
	public var meleeCooldown:Float;
	public var nbKeys:Int;

	public function new(cl:CharacterClass) {		
		this.characterClass = cl;
		
		level = 0;
		nbKeys = 0;
		
		var props = PlayerActor.CHARACTER_CLASSES_PROPS[cast(cl, Int)];
		health = props.health;
		speed = props.speed;
		weaponCooldown = props.weaponCooldown;
		meleeDamage = props.meleeDamage;
		meleeCooldown = props.meleeCooldown;
	}
	
	public function takeSnapshot(player:PlayerActor) {
		health = player.health;
		speed = player.speed;
		// TODO --- weapons modifiers bonuses
	}
}