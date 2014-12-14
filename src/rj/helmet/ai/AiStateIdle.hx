package rj.helmet.ai;
import rj.helmet.World;
import rj.helmet.Monster;

/**
 * ...
 * @author roguedjack
 */
class AiStateIdle extends MonsterAIState {

	public var idleTime(default, default):Float;
	public var pathState(default, default):MonsterAIState;
	
	public function new(idleTime:Float) {
		super();
		this.idleTime = idleTime;
	}

	override public function onUpdate(m:Monster, world:World, elapsed:Float) {
		if (m.aiStateTime < idleTime) {
			return;
		}
		m.aiState = pathState;
	}
}