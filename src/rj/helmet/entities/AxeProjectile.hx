package rj.helmet.entities;

import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * ...
 * @author roguedjack
 */
class AxeProjectile extends Projectile {
	
	static inline var SPEED = 128.0;
	static inline var SPIN_DEG = 720.0;
	
	public function new(owner:Entity, mx:Float, my:Float) {
		super(owner, mx, my, (SPIN_DEG*Math.PI)/180.0, { speed:SPEED } );
		setImage(Gfx.entities[16]);
		setCollisionBox(11, 9, 10, 10);
	}
	
	override function onCollisionWith(elapsed:Float, other:Entity) {
		super.onCollisionWith(elapsed, other);
		
		// FIXME --- all this is propably common to all player projectiles (but might want to do some funky ones)
		// TODO --- damage target monster/generator, do not kill instantly
		if (other.type == EntityType.MONSTER || other.type == EntityType.MONSTER_GENERATOR)
			other.remove();
	}
}