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
	public var nbKeys:Int;

	public function new(cl:CharacterClass) {		
		this.characterClass = cl;
		
		level = 0;
		nbKeys = 0;
		
		var props = PlayerActor.CHARACTER_CLASSES_PROPS[cast(cl, Int)];
		health = props.health;
		speed = props.speed;
		weaponCooldown = props.weaponCooldown;
	}
	
	public function takeSnapshot(player:PlayerActor) {
		health = player.health;
		speed = player.speed;
	}
}