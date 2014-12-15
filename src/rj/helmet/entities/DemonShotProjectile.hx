package rj.helmet.entities;

import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * ...
 * @author roguedjack
 */
class DemonShotProjectile extends MonsterProjectile {
	
	public static inline var POWER = 3;
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
		setImage(Gfx.entities[39]);
		setCollisionBox(12, 12, 8, 8);
	}

}