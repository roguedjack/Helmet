package rj.helmet.entities;

import h2d.Anim;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.ai.AiStateIdle;
import rj.helmet.ai.AiStateMovingState;
import rj.helmet.ai.AiStatePathToPlayer;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.WeaponMelee;


/**
 * ...
 * @author roguedjack
 */
class GhostMonster extends Monster {
	
	static var CreateAiStates:Bool = true;
	static var StateIdle:MonsterAIState;

	public function new() {
		super(GameData.GhostMonster);
		
		// FIXME --- uggly, find another way to init class ai
		if (CreateAiStates) {
			CreateAiStates = false;
			var ai = GameData.parseMonsterClassAi(GameData.GhostMonster.ai);
			StateIdle = ai.idle;
		}
		
		aiIdleState = StateIdle;
	}

	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);	
		// fade out to show health level
		var healthLevel = health / startingHealth;
		bitmap.alpha = 0.25 + 0.75 * healthLevel;
	}
		
}