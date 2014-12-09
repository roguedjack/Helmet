package rj.helmet.entities;

import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The axe is slow but large and powerful.
 * 
 * @author roguedjack
 */
class AxeProjectile extends Projectile {
	
	public static inline var POWER = 10;
	public static inline var SPEED = 128.0;
	public static inline var SPIN_DEG = 720.0;
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, {
			spin:SPIN_DEG*Math.PI/180.0,
			power:POWER
		}, { 
			speed:SPEED,
			health:0
		});
		setImage(Gfx.entities[11]);
		setCollisionBox(8, 8, 16, 16);
	}
}