package rj.helmet.ai;

import rj.helmet.Actor.ActorState;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.World;

/**
 * ...
 * @author roguedjack
 */
class AiStatePathToPlayer extends MonsterAIState {
	
	public var idleState(default, default):MonsterAIState;
	public var movingState(default, default):MonsterAIState;

	public function new() {
		super();	
	}
	
	override public function onUpdate(m:Monster, world:World, elapsed:Float) {
		if (world.player == null || world.player.state != ActorState.LIVING) {
			m.aiState = idleState;
			return;
		}
		if (m.tryToMoveToThePlayer()) {
			m.aiState = movingState;
		} else {
			m.aiState = idleState;
		}
	}
}