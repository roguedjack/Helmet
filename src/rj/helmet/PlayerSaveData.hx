package rj.helmet;
import rj.helmet.entities.PlayerActor;
import rj.helmet.entities.PlayerActor.CharacterClass;

/**
 * Player data that must be saved between levels or can be saved between game sessions.
 * 
 * @author roguedjack
 */
class PlayerSaveData {

	public var characterClass(default,null):CharacterClass;	
	public var level:Int;
	public var health:Int;
	public var score:Int;
	public var nbKeys:Int;

	public function new(cl:CharacterClass) {		
		this.characterClass = cl;
		
		level = 0;
		score = 0;
		nbKeys = 0;
		
		var props = PlayerActor.CHARACTER_CLASSES_PROPS[cast(cl, Int)];
		health = props.health;
	}
	
	public function takeSnapshot(player:PlayerActor) {
		health = player.health;		
	}
}