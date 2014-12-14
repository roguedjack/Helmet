package rj.helmet.ai;
import haxe.EnumFlags;
import rj.helmet.Entity;
import rj.helmet.Entity.ColFlags;
import rj.helmet.World;
import rj.helmet.Monster;

/**
 * ...
 * @author roguedjack
 */
class AiStateMovingState extends MonsterAIState {
	
	public var movingTime(default, default):Float;
	public var idleState(default, default):MonsterAIState;
	public var pathState(default, default):MonsterAIState;

	public function new(movingTime:Float) {
		super();
		this.movingTime = movingTime;
	}
	
	override public function onUpdate(m:Monster, world:World, elapsed:Float) {
		if (m.aiStateTime >= movingTime) {
			m.aiState = pathState;
			return;
		}
		m.continueLastMovement();
	}
	
	override public function onWorldCollision(m:Monster, colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		m.aiState = idleState;
	}
	
	override public function onCollisionWith(m:Monster, other:Entity, vx:Float, vy:Float, active:Bool) {
		if (other.type == EntityType.DOOR || other.type == EntityType.ITEM) {
			m.aiState = idleState;
		}
	}
}