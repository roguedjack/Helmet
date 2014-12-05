package rj.helmet.entities;

import h2d.Anim;
import haxe.EnumFlags;
import hxd.Key;
import rj.helmet.Actor;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class PlayerActor extends Actor {

	private static inline var ANIM_IDLE = 0;
	private static inline var ANIM_WALK = 1;

	public function new() {
		super(EntityType.PLAYER, { speed:64.0 } );
		setCollisionBox(8, 8, 16, 16);
		
		addAnim(ANIM_IDLE, new Anim([Gfx.entities[8]]));		
		addAnim(ANIM_WALK, new Anim([Gfx.entities[9], Gfx.entities[10]], 5));
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		playAnim(ANIM_IDLE);
	}

	override function updateBehavior(elapsed:Float) {
		super.updateBehavior(elapsed);
		
		// movement
		var mx = 0, my = 0;
		if (Key.isDown(Key.UP)) my -= 1;
		if (Key.isDown(Key.DOWN)) my += 1;
		if (Key.isDown(Key.LEFT)) mx -= 1;
		if (Key.isDown(Key.RIGHT)) mx += 1;		
		motion = { dx:mx, dy:my };
		
		// TODO --- shoot
				
		// anim
		if (mx != 0 || my != 0) {
			playAnim(ANIM_WALK);
		} else {
			playAnim(ANIM_IDLE);
		}		
		
		// face motion
		faceLastMotion();
	}
	
	override function onCollisionWith(elapsed:Float, other:Entity) {
		super.onCollisionWith(elapsed, other);
		if (other.type == EntityType.EXIT) {
			// spin madly!
			rotation += 4 * Math.PI * elapsed;
		}
	}
}