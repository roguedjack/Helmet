package rj.helmet.entities;

import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The sword is average.
 * 
 * @author roguedjack
 */
class SwordProjectile extends Projectile {
	
	public static inline var POWER = 5;
	public static inline var SPEED = 160.0;
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, {
			spin:0,
			power:POWER
		}, { 
			speed:SPEED,
			health:0
		});
		setImage(Gfx.entities[15]);
		setCollisionBox(10, 10, 12, 12);
	}
}