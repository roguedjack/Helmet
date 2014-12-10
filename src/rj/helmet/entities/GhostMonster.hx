package rj.helmet.entities;

import h2d.Anim;
import rj.helmet.Entity;
import rj.helmet.Monster;


/**
 * ...
 * @author roguedjack
 */
class GhostMonster extends Monster {
	
	private static inline var ANIM_IDLE = 0;
	private static inline var ANIM_WALK = 1;
	
	var startingHealth:Int;

	public function new() {
		super({ 
			speed : 24, 
			health: 10
		});

		// FIXME -- a lot of monster types will have the same things, not particular to this type
		setCollisionBox(8, 8 , 16, 16);
		addAnim(ANIM_IDLE, new Anim([Gfx.entities[27]]));
		addAnim(ANIM_WALK, new Anim([Gfx.entities[28], Gfx.entities[29]], 2));
	}

	override function onStartSpawning() {
		super.onStartSpawning();
		startingHealth = health;
		playAnim(ANIM_IDLE);
	}
	
	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
				
		// FIXME -- a lot of monster types do the same thing, not particular to this type
		var m = doMoveStraightAtPlayer(elapsed);		
		if (m.vx != 0 || m.vy != 0) {
			faceDirection(m.vx, m.vy);
			playAnim(ANIM_WALK);			
		} else {
			faceEntity(world.player);
			playAnim(ANIM_IDLE);
		}	
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
		
		// fade out to show health level
		var healthLevel = health / startingHealth;
		bitmap.alpha = 0.25 + 0.75 * healthLevel;
	}
}