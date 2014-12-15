package rj.helmet.ai;

import rj.helmet.Actor.ActorState;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.World;

/**
 * ...
 * @author roguedjack
 */
class AiStateShootOrPathToPlayer extends MonsterAIState {
	
	public var idleState(default, default):MonsterAIState;
	public var movingState(default, default):MonsterAIState;

	public function new() {
		super();	
	}
		
	public function link(idleState:MonsterAIState, movingState:MonsterAIState) {
		this.idleState = idleState;
		this.movingState = movingState;
	}	
	
	override public function onUpdate(m:Monster, elapsed:Float) {
		if (m.world.player == null || m.world.player.state != ActorState.LIVING) {
			m.aiState = idleState;
			return;
		}
		if (m.tryShootingAtPlayer()) {
			return;
		}
		if (m.tryToMoveToThePlayer()) {
			m.aiState = movingState;
		} else {
			m.aiState = idleState;
		}
	}
}