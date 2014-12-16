package rj.helmet.entities;

import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * Projectile shot by monsters.
 * Does not collide with same kind of projectiles. Does not inflict damage to monsters and generators.
 * @author roguedjack
 */
class MonsterProjectile extends Projectile {

	public function new(owner:Entity, dx:Float, dy:Float, data) {
		super(owner, dx, dy, data);		
		disableSameCollision = true;
	}

	/**
	 * Does not inflict damage to monsters and generators.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (other.type == EntityType.MONSTER || other.type == EntityType.MONSTER_GENERATOR) {
			remove();
			return;
		}		
		super.onCollisionWith(other, vx, vy, active);
	}
}