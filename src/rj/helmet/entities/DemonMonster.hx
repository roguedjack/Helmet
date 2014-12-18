package rj.helmet.entities;

import h2d.Anim;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.ai.AiStateIdle;
import rj.helmet.ai.AiStateMovingState;
import rj.helmet.ai.AiStatePathToPlayer;
import rj.helmet.ai.AiStateShootOrPathToPlayer;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.ParticleGenerator;
import rj.helmet.WeaponMelee;
import rj.helmet.WeaponShooter;
import rj.helmet.World;


/**
 * ...
 * @author roguedjack
 */
class DemonMonster extends Monster {
	
	static var CreateAiStates:Bool = true;
	static var StateIdle:MonsterAIState;
	
	var bloodProjector:ParticleGenerator;	

	public function new() {
		super(GameData.DemonMonster);
		
		// FIXME --- uggly, find another way to init class ai
		if (CreateAiStates) {
			CreateAiStates = false;
			var ai = GameData.parseMonsterClassAi(GameData.DemonMonster.ai);
			StateIdle = ai.idle;
		}
		
		aiIdleState = StateIdle;
		
		bloodProjector = new ParticleGenerator(DebrisParticle, [0xFF0000]);
		bloodProjector.minLifetime = 0.25;
		bloodProjector.maxLifetime = 0.5;
		bloodProjector.batchSize = 4;		
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);	
		// blood splatter
		bloodProjector.emitBatch(bounds);
	}
	
}