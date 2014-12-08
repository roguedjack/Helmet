package rj.helmet.entities;

import h2d.Anim;
import rj.helmet.Monster;


/**
 * ...
 * @author roguedjack
 */
class SkeletonMonster extends Monster {
	
	private static inline var ANIM_IDLE = 0;
	private static inline var ANIM_WALK = 1;

	public function new() {
		super( { speed : 24 } );		

		// FIXME -- a lot of monster types will have the same things, not particular to skeleton
		setCollisionBox(8, 8 , 16, 16);
		addAnim(ANIM_IDLE, new Anim([Gfx.entities[25]]));
		addAnim(ANIM_WALK, new Anim([Gfx.entities[26], Gfx.entities[27]], 2));
	}

	override function onStartSpawning() {
		super.onStartSpawning();
		playAnim(ANIM_IDLE);
	}
	
	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
				
		// FIXME -- a lot of monster types do the same thing, not particular to skeleton
		var m = doMoveStraightAtPlayer(elapsed);		
		if (m.vx != 0 || m.vy != 0) {
			faceDirection(m.vx, m.vy);
			playAnim(ANIM_WALK);			
		} else {
			faceEntity(world.player);
			playAnim(ANIM_IDLE);
		}	
	}
}