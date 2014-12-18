package rj.helmet.ai;
import haxe.EnumFlags;
import rj.helmet.Entity;
import rj.helmet.Entity.ColFlags;
import rj.helmet.MonsterAIState;
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
	
	public function link(idleState:MonsterAIState, pathState:MonsterAIState) {
		this.idleState = idleState;
		this.pathState = pathState;
	}
	
	inline function distanceFromStart(m:Monster) {
		var dx = m.pos.x - m.aiStateStartPos.x;
		var dy = m.pos.y - m.aiStateStartPos.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	override public function onEnter(m:Monster) {
		m.aiStateDistance = 0;
		m.aiStateStartPos = m.pos;
	}
	
	override public function onUpdate(m:Monster, elapsed:Float) {
		// repath after time elapsed or 1 tile distance travelled
		m.aiStateDistance = distanceFromStart(m);
		if (m.aiStateTime >= movingTime || m.aiStateDistance >= Main.TILE_SIZE) {
			m.aiState = pathState;
			return;
		}
		
		m.continueLastMovement();
	}
	
	override public function onWorldCollision(m:Monster, colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		m.aiState = idleState;
	}
	
	override public function onCollisionWith(m:Monster, other:Entity, vx:Float, vy:Float, active:Bool) {
		if (active && other.hardCollision && other.type != EntityType.PROJECTILE && other.type != EntityType.TRAP) {
			m.aiState = idleState;
		}
	}
}